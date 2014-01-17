From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH V4 net-next 2/3] ipv6: add a flag to get the flow label used remotly
Date: Fri, 17 Jan 2014 17:15:04 +0100
Message-ID: <1389975305-12477-2-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1389975305-12477-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:35082 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752231AbaAQQPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 11:15:15 -0500
In-Reply-To: <1389975305-12477-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This information is already available via IPV6_FLOWINFO
of IPV6_2292PKTOPTIONS, and them a filtering to get the flow label
information. But it is probably logical and easier for users to add this
here, and to control both sent/received flow label values with the
IPV6_FLOWLABEL_MGR option.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 include/net/ipv6.h       | 3 ++-
 include/uapi/linux/in6.h | 1 +
 net/ipv6/ip6_flowlabel.c | 8 +++++++-
 net/ipv6/ipv6_sockglue.c | 5 ++++-
 4 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 6d80f51..78d3d51 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -253,7 +253,8 @@ struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions *opt_space,
 					 struct ipv6_txoptions *fopt);
 void fl6_free_socklist(struct sock *sk);
 int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen);
-int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq);
+int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq,
+			   int flags);
 int ip6_flowlabel_init(void);
 void ip6_flowlabel_cleanup(void);
 
diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index 02c0cd6..633b93c 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -86,6 +86,7 @@ struct in6_flowlabel_req {
 #define IPV6_FL_F_CREATE	1
 #define IPV6_FL_F_EXCL		2
 #define IPV6_FL_F_REFLECT	4
+#define IPV6_FL_F_REMOTE	8
 
 #define IPV6_FL_S_NONE		0
 #define IPV6_FL_S_EXCL		1
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 55823f1..01bf252 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -481,11 +481,17 @@ static inline void fl_link(struct ipv6_pinfo *np, struct ipv6_fl_socklist *sfl,
 	spin_unlock_bh(&ip6_sk_fl_lock);
 }
 
-int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq)
+int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq,
+			   int flags)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_fl_socklist *sfl;
 
+	if (flags & IPV6_FL_F_REMOTE) {
+		freq->flr_label = np->rcv_flowinfo & IPV6_FLOWLABEL_MASK;
+		return 0;
+	}
+
 	if (np->repflow) {
 		freq->flr_label = np->flow_label;
 		return 0;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 2855b00..7024a87 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1221,6 +1221,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 	case IPV6_FLOWLABEL_MGR:
 	{
 		struct in6_flowlabel_req freq;
+		int flags;
 
 		if (len < sizeof(freq))
 			return -EINVAL;
@@ -1232,9 +1233,11 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
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
1.8.5.2
