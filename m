From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next v2 2/4] ipv6: enable IPV6_FLOWLABEL_MGR for getsockopt
Date: Tue,  5 Nov 2013 15:28:56 +0100
Message-ID: <1383661738-6083-2-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1383661738-6083-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:40709 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755112Ab3KEO3M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 09:29:12 -0500
In-Reply-To: <1383661738-6083-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is already possible to set/put/renew a label
with IPV6_FLOWLABEL_MGR and setsockopt. This patch
add the possibility to get information about this
label (current value, time before expiration, etc).

It helps application to take decision for a renew
or a release of the label.

v2:
 * Add spin_lock to prevent race condition
 * return -ENOENT if no result found
 * check if flr_action is GET

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 include/net/ipv6.h       |  1 +
 net/ipv6/ip6_flowlabel.c | 27 +++++++++++++++++++++++++++
 net/ipv6/ipv6_sockglue.c | 28 ++++++++++++++++++++++++++++
 3 files changed, 56 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index dd96638..2a5f668 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -250,6 +250,7 @@ struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions *opt_space,
 					 struct ipv6_txoptions *fopt);
 void fl6_free_socklist(struct sock *sk);
 int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen);
+int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq);
 int ip6_flowlabel_init(void);
 void ip6_flowlabel_cleanup(void);
 
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 819578e..76e62a1 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -475,6 +475,33 @@ static inline void fl_link(struct ipv6_pinfo *np, struct ipv6_fl_socklist *sfl,
 	spin_unlock_bh(&ip6_sk_fl_lock);
 }
 
+int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct ipv6_fl_socklist *sfl;
+
+	spin_lock_bh(&ip6_fl_lock);
+	rcu_read_lock_bh();
+
+	for_each_sk_fl_rcu(np, sfl) {
+		if (sfl->fl->label == (np->flow_label & IPV6_FLOWLABEL_MASK)) {
+			freq->flr_label = sfl->fl->label;
+			freq->flr_dst = sfl->fl->dst;
+			freq->flr_share = sfl->fl->share;
+			freq->flr_expires = (sfl->fl->expires - jiffies) / HZ;
+			freq->flr_linger = sfl->fl->linger / HZ;
+
+			rcu_read_unlock_bh();
+			spin_unlock_bh(&ip6_fl_lock);
+			return 0;
+		}
+	}
+	rcu_read_unlock_bh();
+	spin_unlock_bh(&ip6_fl_lock);
+
+	return -ENOENT;
+}
+
 int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 {
 	int uninitialized_var(err);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 4919a8e..1c6ce31 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1212,6 +1212,34 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->sndflow;
 		break;
 
+	case IPV6_FLOWLABEL_MGR:
+	{
+		struct in6_flowlabel_req freq;
+
+		if (len < sizeof(freq))
+			return -EINVAL;
+
+		if (copy_from_user(&freq, optval, sizeof(freq)))
+			return -EFAULT;
+
+		if (freq.flr_action != IPV6_FL_A_GET)
+			return -EINVAL;
+
+		len = sizeof(freq);
+		memset(&freq, 0, sizeof(freq));
+
+		val = ipv6_flowlabel_opt_get(sk, &freq);
+		if (val < 0)
+			return val;
+
+		if (put_user(len, optlen))
+			return -EFAULT;
+		if (copy_to_user(optval, &freq, len))
+			return -EFAULT;
+
+		return 0;
+	}
+
 	case IPV6_ADDR_PREFERENCES:
 		val = 0;
 
-- 
1.8.4.rc3
