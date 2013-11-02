From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH RFC] ipv6: enable IPV6_FLOWLABEL_MGR for getsockopt
Date: Sat,  2 Nov 2013 17:58:44 +0100
Message-ID: <1383411524-16743-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:52794 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751951Ab3KBQ6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Nov 2013 12:58:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is already possible to set/put/renew a label
with IPV6_FLOWLABEL_MGR and setsockopt. This patch
add the possibility to get information about this
label (current value, time before expiration, etc).

It helps application to take decision for a renew
or a release of the label.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 include/net/ipv6.h       |  1 +
 net/ipv6/ip6_flowlabel.c | 23 +++++++++++++++++++++++
 net/ipv6/ipv6_sockglue.c | 23 +++++++++++++++++++++++
 3 files changed, 47 insertions(+)

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
index 819578e..34f58b7 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -475,6 +475,29 @@ static inline void fl_link(struct ipv6_pinfo *np, struct ipv6_fl_socklist *sfl,
 	spin_unlock_bh(&ip6_sk_fl_lock);
 }
 
+int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct ipv6_fl_socklist *sfl;
+
+	rcu_read_lock_bh();
+	for_each_sk_fl_rcu(np, sfl) {
+		if (sfl->fl->label == (np->flow_label & IPV6_FLOWLABEL_MASK)) {
+			freq->flr_label = sfl->fl->label;
+			freq->flr_dst = sfl->fl->dst;
+			freq->flr_share = sfl->fl->share;
+			freq->flr_expires = (sfl->fl->expires - jiffies) / HZ;
+			freq->flr_linger = sfl->fl->linger / HZ;
+
+			rcu_read_unlock_bh();
+			return 0;
+		}
+	}
+	rcu_read_unlock_bh();
+
+	return 0;
+}
+
 int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 {
 	int uninitialized_var(err);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 4919a8e..9ca96c2 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1212,6 +1212,29 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->sndflow;
 		break;
 
+	case IPV6_FLOWLABEL_MGR:
+	{
+		struct in6_flowlabel_req freq;
+
+		if (len < sizeof(freq))
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
+		break;
+	}
+
 	case IPV6_ADDR_PREFERENCES:
 		val = 0;
 
-- 
1.8.4.rc3
