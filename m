From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH RFC 2/2] ipv6: add a flag to get the flow label used remotly
Date: Thu, 12 Dec 2013 11:38:17 +0100
Message-ID: <1386844697-31169-2-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1386844697-31169-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:37886 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751120Ab3LLKiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 05:38:25 -0500
In-Reply-To: <1386844697-31169-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This information is already available via IPV6_FLOWINFO
of IPV6_2292PKTOPTIONS, and them a filtering to get the flow label
information. But it is probably logical and easier for users to add this
here, and to control both sent/received flow label values with the
IPV6_FLOWLABEL_MGR option.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 include/net/ipv6.h       | 2 +-
 net/ipv6/ip6_flowlabel.c | 8 +++++++-
 net/ipv6/ipv6_sockglue.c | 5 ++++-
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d0bfe3e..9e840f6 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -252,7 +252,7 @@ struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions *opt_space,
 					 struct ipv6_txoptions *fopt);
 void fl6_free_socklist(struct sock *sk);
 int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen);
-int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq);
+int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq, int flags);
 int ip6_flowlabel_init(void);
 void ip6_flowlabel_cleanup(void);
 
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 6bc17dc..375ca36 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -481,11 +481,17 @@ static inline void fl_link(struct ipv6_pinfo *np, struct ipv6_fl_socklist *sfl,
 	spin_unlock_bh(&ip6_sk_fl_lock);
 }
 
-int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq)
+int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq, int flags)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_fl_socklist *sfl;
 
+
+	if (flags & IPV6_FL_F_REPLY) {
+		freq->flr_label = np->rcv_flowinfo & IPV6_FLOWLABEL_MASK;
+		return 0;
+	}
+
 	rcu_read_lock_bh();
 
 	for_each_sk_fl_rcu(np, sfl) {
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 7d93915..bc4d8a2 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1219,6 +1219,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 	case IPV6_FLOWLABEL_MGR:
 	{
 		struct in6_flowlabel_req freq;
+		int flags;
 
 		if (len < sizeof(freq))
 			return -EINVAL;
@@ -1230,9 +1231,11 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			return -EINVAL;
 
 		len = sizeof(freq);
+		flags = freq.flr_flags;
+
 		memset(&freq, 0, sizeof(freq));
 
-		val = ipv6_flowlabel_opt_get(sk, &freq);
+		val = ipv6_flowlabel_opt_get(sk, &freq, flags);
 		if (val < 0)
 			return val;
 
-- 
1.8.5.1
