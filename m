From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 3/4] sock_diag: do not disclose sock ptr to all users
Date: Thu, 25 Apr 2013 15:21:50 +0200
Message-ID: <1366896111-4436-4-git-send-email-nicolas.dichtel@6wind.com>
References: <20130425.050008.2129680886418162075.davem@davemloft.net>
 <1366896111-4436-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56288 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755926Ab3DYNV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 09:21:59 -0400
In-Reply-To: <1366896111-4436-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a sensible info, hence we restrict the user allowed to get it.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/sock_diag.h |  3 ++-
 net/core/sock_diag.c      | 12 +++++++++---
 net/ipv4/inet_diag.c      | 13 ++++++++-----
 net/netlink/diag.c        |  5 ++++-
 net/packet/diag.c         |  2 +-
 net/unix/diag.c           | 14 +++++++++-----
 6 files changed, 33 insertions(+), 16 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index e8d702e..023174f 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -19,7 +19,8 @@ void sock_diag_register_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsgh
 void sock_diag_unregister_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh));
 
 int sock_diag_check_cookie(void *sk, __u32 *cookie);
-void sock_diag_save_cookie(void *sk, __u32 *cookie);
+void sock_diag_save_cookie(struct user_namespace *user_ns, void *sk,
+			   __u32 *cookie);
 
 int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attr);
 
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index a29e90c..5adf531 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -25,10 +25,16 @@ int sock_diag_check_cookie(void *sk, __u32 *cookie)
 }
 EXPORT_SYMBOL_GPL(sock_diag_check_cookie);
 
-void sock_diag_save_cookie(void *sk, __u32 *cookie)
+void sock_diag_save_cookie(struct user_namespace *user_ns, void *sk,
+			   __u32 *cookie)
 {
-	cookie[0] = (u32)(unsigned long)sk;
-	cookie[1] = (u32)(((unsigned long)sk >> 31) >> 1);
+	if (ns_capable(user_ns, CAP_NET_ADMIN)) {
+		cookie[0] = (u32)(unsigned long)sk;
+		cookie[1] = (u32)(((unsigned long)sk >> 31) >> 1);
+	} else {
+		cookie[0] = 0;
+		cookie[1] = 0;
+	}
 }
 EXPORT_SYMBOL_GPL(sock_diag_save_cookie);
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 5f64875..e6607e0 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -18,6 +18,7 @@
 #include <linux/cache.h>
 #include <linux/init.h>
 #include <linux/time.h>
+#include <linux/user_namespace.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
@@ -102,7 +103,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	r->idiag_retrans = 0;
 
 	r->id.idiag_if = sk->sk_bound_dev_if;
-	sock_diag_save_cookie(sk, r->id.idiag_cookie);
+	sock_diag_save_cookie(user_ns, sk, r->id.idiag_cookie);
 
 	r->id.idiag_sport = inet->inet_sport;
 	r->id.idiag_dport = inet->inet_dport;
@@ -219,6 +220,7 @@ static int inet_csk_diag_fill(struct sock *sk,
 
 static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 			       struct sk_buff *skb, struct inet_diag_req_v2 *req,
+			       struct user_namespace *user_ns,
 			       u32 portid, u32 seq, u16 nlmsg_flags,
 			       const struct nlmsghdr *unlh)
 {
@@ -241,7 +243,7 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 	r->idiag_family	      = tw->tw_family;
 	r->idiag_retrans      = 0;
 	r->id.idiag_if	      = tw->tw_bound_dev_if;
-	sock_diag_save_cookie(tw, r->id.idiag_cookie);
+	sock_diag_save_cookie(user_ns, tw, r->id.idiag_cookie);
 	r->id.idiag_sport     = tw->tw_sport;
 	r->id.idiag_dport     = tw->tw_dport;
 	r->id.idiag_src[0]    = tw->tw_rcv_saddr;
@@ -274,8 +276,8 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 {
 	if (sk->sk_state == TCP_TIME_WAIT)
 		return inet_twsk_diag_fill((struct inet_timewait_sock *)sk,
-					   skb, r, portid, seq, nlmsg_flags,
-					   unlh);
+					   skb, r, user_ns, portid, seq,
+					   nlmsg_flags, unlh);
 	return inet_csk_diag_fill(sk, skb, r, user_ns, portid, seq, nlmsg_flags, unlh);
 }
 
@@ -666,6 +668,7 @@ static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
 	}
 
 	return inet_twsk_diag_fill(tw, skb, r,
+				   sk_user_ns(NETLINK_CB(cb->skb).sk),
 				   NETLINK_CB(cb->skb).portid,
 				   cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
@@ -724,7 +727,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	r->idiag_retrans = req->num_retrans;
 
 	r->id.idiag_if = sk->sk_bound_dev_if;
-	sock_diag_save_cookie(req, r->id.idiag_cookie);
+	sock_diag_save_cookie(user_ns, req, r->id.idiag_cookie);
 
 	tmo = req->expires - jiffies;
 	if (tmo < 0)
diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index 1af2962..57d7636 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -55,6 +55,7 @@ static int sk_diag_dump_groups(struct sock *sk, struct sk_buff *nlskb)
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 			struct netlink_diag_req *req,
+			struct user_namespace *user_ns,
 			u32 portid, u32 seq, u32 flags, int sk_ino)
 {
 	struct nlmsghdr *nlh;
@@ -76,7 +77,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 	rep->ndiag_portid	= nlk->portid;
 	rep->ndiag_dst_portid	= nlk->dst_portid;
 	rep->ndiag_dst_group	= nlk->dst_group;
-	sock_diag_save_cookie(sk, rep->ndiag_cookie);
+	sock_diag_save_cookie(user_ns, sk, rep->ndiag_cookie);
 
 	if ((req->ndiag_show & NDIAG_SHOW_GROUPS) &&
 	    sk_diag_dump_groups(sk, skb))
@@ -119,6 +120,7 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			}
 
 			if (sk_diag_fill(sk, skb, req,
+					 sk_user_ns(NETLINK_CB(cb->skb).sk),
 					 NETLINK_CB(cb->skb).portid,
 					 cb->nlh->nlmsg_seq,
 					 NLM_F_MULTI,
@@ -142,6 +144,7 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		}
 
 		if (sk_diag_fill(sk, skb, req,
+				 sk_user_ns(NETLINK_CB(cb->skb).sk),
 				 NETLINK_CB(cb->skb).portid,
 				 cb->nlh->nlmsg_seq,
 				 NLM_F_MULTI,
diff --git a/net/packet/diag.c b/net/packet/diag.c
index 822fe9b..7af2ae0 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -143,7 +143,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 	rp->pdiag_type = sk->sk_type;
 	rp->pdiag_num = ntohs(po->num);
 	rp->pdiag_ino = sk_ino;
-	sock_diag_save_cookie(sk, rp->pdiag_cookie);
+	sock_diag_save_cookie(user_ns, sk, rp->pdiag_cookie);
 
 	if ((req->pdiag_show & PACKET_SHOW_INFO) &&
 			pdiag_put_info(po, skb))
diff --git a/net/unix/diag.c b/net/unix/diag.c
index d591091..1637dfd 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -1,5 +1,6 @@
 #include <linux/types.h>
 #include <linux/spinlock.h>
+#include <linux/user_namespace.h>
 #include <linux/sock_diag.h>
 #include <linux/unix_diag.h>
 #include <linux/skbuff.h>
@@ -110,7 +111,8 @@ static int sk_diag_show_rqlen(struct sock *sk, struct sk_buff *nlskb)
 }
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_req *req,
-		u32 portid, u32 seq, u32 flags, int sk_ino)
+			struct user_namespace *user_ns,
+			u32 portid, u32 seq, u32 flags, int sk_ino)
 {
 	struct nlmsghdr *nlh;
 	struct unix_diag_msg *rep;
@@ -125,7 +127,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 	rep->udiag_type = sk->sk_type;
 	rep->udiag_state = sk->sk_state;
 	rep->udiag_ino = sk_ino;
-	sock_diag_save_cookie(sk, rep->udiag_cookie);
+	sock_diag_save_cookie(user_ns, sk, rep->udiag_cookie);
 
 	if ((req->udiag_show & UDIAG_SHOW_NAME) &&
 	    sk_diag_dump_name(sk, skb))
@@ -162,7 +164,7 @@ out_nlmsg_trim:
 }
 
 static int sk_diag_dump(struct sock *sk, struct sk_buff *skb, struct unix_diag_req *req,
-		u32 portid, u32 seq, u32 flags)
+			struct user_namespace *user_ns, u32 portid, u32 seq, u32 flags)
 {
 	int sk_ino;
 
@@ -173,7 +175,7 @@ static int sk_diag_dump(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 	if (!sk_ino)
 		return 0;
 
-	return sk_diag_fill(sk, skb, req, portid, seq, flags, sk_ino);
+	return sk_diag_fill(sk, skb, req, user_ns, portid, seq, flags, sk_ino);
 }
 
 static int unix_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
@@ -202,6 +204,7 @@ static int unix_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			if (!(req->udiag_states & (1 << sk->sk_state)))
 				goto next;
 			if (sk_diag_dump(sk, skb, req,
+					 sk_user_ns(NETLINK_CB(cb->skb).sk),
 					 NETLINK_CB(cb->skb).portid,
 					 cb->nlh->nlmsg_seq,
 					 NLM_F_MULTI) < 0)
@@ -267,7 +270,8 @@ again:
 	if (!rep)
 		goto out;
 
-	err = sk_diag_fill(sk, rep, req, NETLINK_CB(in_skb).portid,
+	err = sk_diag_fill(sk, rep, req, sk_user_ns(NETLINK_CB(in_skb).sk),
+			   NETLINK_CB(in_skb).portid,
 			   nlh->nlmsg_seq, 0, req->udiag_ino);
 	if (err < 0) {
 		nlmsg_free(rep);
-- 
1.8.2.1
