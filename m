From: pablo@netfilter.org
Subject: [PATCH 06/19] netfilter: nf_conntrack: use atomic64 for accounting counters
Date: Sun, 25 Dec 2011 02:57:22 +0100
Message-ID: <1324778255-2830-7-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55988 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757980Ab1LYB56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 20:57:58 -0500
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

We can use atomic64_t infrastructure to avoid taking a spinlock in fast
path, and remove inaccuracies while reading values in
ctnetlink_dump_counters() and connbytes_mt() on 32bit arches.

Suggested by Pablo.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_acct.h |    4 +-
 net/netfilter/nf_conntrack_acct.c         |    4 +-
 net/netfilter/nf_conntrack_core.c         |   14 ++++--------
 net/netfilter/nf_conntrack_netlink.c      |   12 +++++++---
 net/netfilter/xt_connbytes.c              |   32 ++++++++++++++--------------
 5 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_acct.h b/include/net/netfilter/nf_conntrack_acct.h
index 4e9c63a..463ae8e 100644
--- a/include/net/netfilter/nf_conntrack_acct.h
+++ b/include/net/netfilter/nf_conntrack_acct.h
@@ -15,8 +15,8 @@
 #include <net/netfilter/nf_conntrack_extend.h>
 
 struct nf_conn_counter {
-	u_int64_t packets;
-	u_int64_t bytes;
+	atomic64_t packets;
+	atomic64_t bytes;
 };
 
 static inline
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index 369df3f..9332906 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -46,8 +46,8 @@ seq_print_acct(struct seq_file *s, const struct nf_conn *ct, int dir)
 		return 0;
 
 	return seq_printf(s, "packets=%llu bytes=%llu ",
-			  (unsigned long long)acct[dir].packets,
-			  (unsigned long long)acct[dir].bytes);
+			  (unsigned long long)atomic64_read(&acct[dir].packets),
+			  (unsigned long long)atomic64_read(&acct[dir].bytes));
 };
 EXPORT_SYMBOL_GPL(seq_print_acct);
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 7202b06..8b2842e 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1044,10 +1044,8 @@ acct:
 
 		acct = nf_conn_acct_find(ct);
 		if (acct) {
-			spin_lock_bh(&ct->lock);
-			acct[CTINFO2DIR(ctinfo)].packets++;
-			acct[CTINFO2DIR(ctinfo)].bytes += skb->len;
-			spin_unlock_bh(&ct->lock);
+			atomic64_inc(&acct[CTINFO2DIR(ctinfo)].packets);
+			atomic64_add(skb->len, &acct[CTINFO2DIR(ctinfo)].bytes);
 		}
 	}
 }
@@ -1063,11 +1061,9 @@ bool __nf_ct_kill_acct(struct nf_conn *ct,
 
 		acct = nf_conn_acct_find(ct);
 		if (acct) {
-			spin_lock_bh(&ct->lock);
-			acct[CTINFO2DIR(ctinfo)].packets++;
-			acct[CTINFO2DIR(ctinfo)].bytes +=
-				skb->len - skb_network_offset(skb);
-			spin_unlock_bh(&ct->lock);
+			atomic64_inc(&acct[CTINFO2DIR(ctinfo)].packets);
+			atomic64_add(skb->len - skb_network_offset(skb),
+				     &acct[CTINFO2DIR(ctinfo)].bytes);
 		}
 	}
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index ef21b22..a36e655 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -219,9 +219,9 @@ ctnetlink_dump_counters(struct sk_buff *skb, const struct nf_conn *ct,
 		goto nla_put_failure;
 
 	NLA_PUT_BE64(skb, CTA_COUNTERS_PACKETS,
-		     cpu_to_be64(acct[dir].packets));
+		     cpu_to_be64(atomic64_read(&acct[dir].packets)));
 	NLA_PUT_BE64(skb, CTA_COUNTERS_BYTES,
-		     cpu_to_be64(acct[dir].bytes));
+		     cpu_to_be64(atomic64_read(&acct[dir].bytes)));
 
 	nla_nest_end(skb, nest_count);
 
@@ -720,8 +720,12 @@ restart:
 				struct nf_conn_counter *acct;
 
 				acct = nf_conn_acct_find(ct);
-				if (acct)
-					memset(acct, 0, sizeof(struct nf_conn_counter[IP_CT_DIR_MAX]));
+				if (acct) {
+					atomic64_set(&acct[IP_CT_DIR_ORIGINAL].bytes, 0);
+					atomic64_set(&acct[IP_CT_DIR_ORIGINAL].packets, 0);
+					atomic64_set(&acct[IP_CT_DIR_REPLY].bytes, 0);
+					atomic64_set(&acct[IP_CT_DIR_REPLY].packets, 0);
+					}
 			}
 		}
 		if (cb->args[1]) {
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index 5b13850..2b8418c 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -40,46 +40,46 @@ connbytes_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	case XT_CONNBYTES_PKTS:
 		switch (sinfo->direction) {
 		case XT_CONNBYTES_DIR_ORIGINAL:
-			what = counters[IP_CT_DIR_ORIGINAL].packets;
+			what = atomic64_read(&counters[IP_CT_DIR_ORIGINAL].packets);
 			break;
 		case XT_CONNBYTES_DIR_REPLY:
-			what = counters[IP_CT_DIR_REPLY].packets;
+			what = atomic64_read(&counters[IP_CT_DIR_REPLY].packets);
 			break;
 		case XT_CONNBYTES_DIR_BOTH:
-			what = counters[IP_CT_DIR_ORIGINAL].packets;
-			what += counters[IP_CT_DIR_REPLY].packets;
+			what = atomic64_read(&counters[IP_CT_DIR_ORIGINAL].packets);
+			what += atomic64_read(&counters[IP_CT_DIR_REPLY].packets);
 			break;
 		}
 		break;
 	case XT_CONNBYTES_BYTES:
 		switch (sinfo->direction) {
 		case XT_CONNBYTES_DIR_ORIGINAL:
-			what = counters[IP_CT_DIR_ORIGINAL].bytes;
+			what = atomic64_read(&counters[IP_CT_DIR_ORIGINAL].bytes);
 			break;
 		case XT_CONNBYTES_DIR_REPLY:
-			what = counters[IP_CT_DIR_REPLY].bytes;
+			what = atomic64_read(&counters[IP_CT_DIR_REPLY].bytes);
 			break;
 		case XT_CONNBYTES_DIR_BOTH:
-			what = counters[IP_CT_DIR_ORIGINAL].bytes;
-			what += counters[IP_CT_DIR_REPLY].bytes;
+			what = atomic64_read(&counters[IP_CT_DIR_ORIGINAL].bytes);
+			what += atomic64_read(&counters[IP_CT_DIR_REPLY].bytes);
 			break;
 		}
 		break;
 	case XT_CONNBYTES_AVGPKT:
 		switch (sinfo->direction) {
 		case XT_CONNBYTES_DIR_ORIGINAL:
-			bytes = counters[IP_CT_DIR_ORIGINAL].bytes;
-			pkts  = counters[IP_CT_DIR_ORIGINAL].packets;
+			bytes = atomic64_read(&counters[IP_CT_DIR_ORIGINAL].bytes);
+			pkts  = atomic64_read(&counters[IP_CT_DIR_ORIGINAL].packets);
 			break;
 		case XT_CONNBYTES_DIR_REPLY:
-			bytes = counters[IP_CT_DIR_REPLY].bytes;
-			pkts  = counters[IP_CT_DIR_REPLY].packets;
+			bytes = atomic64_read(&counters[IP_CT_DIR_REPLY].bytes);
+			pkts  = atomic64_read(&counters[IP_CT_DIR_REPLY].packets);
 			break;
 		case XT_CONNBYTES_DIR_BOTH:
-			bytes = counters[IP_CT_DIR_ORIGINAL].bytes +
-				counters[IP_CT_DIR_REPLY].bytes;
-			pkts  = counters[IP_CT_DIR_ORIGINAL].packets +
-				counters[IP_CT_DIR_REPLY].packets;
+			bytes = atomic64_read(&counters[IP_CT_DIR_ORIGINAL].bytes) +
+				atomic64_read(&counters[IP_CT_DIR_REPLY].bytes);
+			pkts  = atomic64_read(&counters[IP_CT_DIR_ORIGINAL].packets) +
+				atomic64_read(&counters[IP_CT_DIR_REPLY].packets);
 			break;
 		}
 		if (pkts != 0)
-- 
1.7.2.5
