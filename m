From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH V2 net-next 2/3] ipv6: add a flag to get the flow label used remotly
Date: Wed, 15 Jan 2014 12:30:02 +0100
Message-ID: <1389785403-6401-2-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1389785403-6401-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:49893 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666AbaAOLaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 06:30:08 -0500
In-Reply-To: <1389785403-6401-1-git-send-email-florent.fourcot@enst-bretagne.fr>
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
 include/uapi/linux/in6.h | 1 +
 net/ipv6/ip6_flowlabel.c | 7 ++++++-
 net/ipv6/ipv6_sockglue.c | 5 ++++-
 4 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 12079c6..54cb251 100644
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
 
diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index a4359b1..2428b80 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -86,6 +86,7 @@ struct in6_flowlabel_req {
 #define IPV6_FL_F_CREATE	1
 #define IPV6_FL_F_EXCL		2
 #define IPV6_FL_F_REFLECT 	4
+#define IPV6_FL_F_REMOTE	8
 
 #define IPV6_FL_S_NONE		0
 #define IPV6_FL_S_EXCL		1
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index ba23643..2c0f9dc 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -481,11 +481,16 @@ static inline void fl_link(struct ipv6_pinfo *np, struct ipv6_fl_socklist *sfl,
 	spin_unlock_bh(&ip6_sk_fl_lock);
 }
 
-int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq)
+int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq, int flags)
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
index af0ecb9..a47653a 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1220,6 +1220,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 	case IPV6_FLOWLABEL_MGR:
 	{
 		struct in6_flowlabel_req freq;
+		int flags;
 
 		if (len < sizeof(freq))
 			return -EINVAL;
@@ -1231,9 +1232,11 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
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
