From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/13] sock_diag: Generalize requests cookies managements
Date: Thu, 15 Dec 2011 16:43:44 +0400
Message-ID: <4EE9EB80.7020909@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4400 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758441Ab1LOMnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:43:50 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sk address is used as a cookie between dump/get_exact calls.
It will be required for unix socket sdumping, so move it from
inet_diag to sock_diag.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |    1 -
 include/linux/sock_diag.h |    3 +++
 net/core/sock_diag.c      |   19 +++++++++++++++++++
 net/ipv4/inet_diag.c      |   23 ++++-------------------
 net/ipv4/udp_diag.c       |    2 +-
 5 files changed, 27 insertions(+), 21 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index a27e621..afa5d5c 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -168,7 +168,6 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
 		struct inet_diag_req *req);
 
 int inet_diag_bc_sk(const struct nlattr *_bc, struct sock *sk);
-int inet_diag_check_cookie(struct sock *sk, struct inet_diag_req *req);
 
 extern int  inet_diag_register(const struct inet_diag_handler *handler);
 extern void inet_diag_unregister(const struct inet_diag_handler *handler);
diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 7999778..379d5dc 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -22,5 +22,8 @@ void sock_diag_unregister(struct sock_diag_handler *h);
 void sock_diag_register_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh));
 void sock_diag_unregister_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh));
 
+int sock_diag_check_cookie(void *sk, __u32 *cookie);
+void sock_diag_save_cookie(void *sk, __u32 *cookie);
+
 extern struct sock *sock_diag_nlsk;
 #endif
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index cee96f3..711bdef 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -12,6 +12,25 @@ static struct sock_diag_handler *sock_diag_handlers[AF_MAX];
 static int (*inet_rcv_compat)(struct sk_buff *skb, struct nlmsghdr *nlh);
 static DEFINE_MUTEX(sock_diag_table_mutex);
 
+int sock_diag_check_cookie(void *sk, __u32 *cookie)
+{
+	if ((cookie[0] != INET_DIAG_NOCOOKIE ||
+	     cookie[1] != INET_DIAG_NOCOOKIE) &&
+	    ((u32)(unsigned long)sk != cookie[0] ||
+	     (u32)((((unsigned long)sk) >> 31) >> 1) != cookie[1]))
+		return -ESTALE;
+	else
+		return 0;
+}
+EXPORT_SYMBOL_GPL(sock_diag_check_cookie);
+
+void sock_diag_save_cookie(void *sk, __u32 *cookie)
+{
+	cookie[0] = (u32)(unsigned long)sk;
+	cookie[1] = (u32)(((unsigned long)sk >> 31) >> 1);
+}
+EXPORT_SYMBOL_GPL(sock_diag_save_cookie);
+
 void sock_diag_register_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh))
 {
 	mutex_lock(&sock_diag_table_mutex);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index fa27313..fb2e47f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -102,8 +102,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	r->idiag_retrans = 0;
 
 	r->id.idiag_if = sk->sk_bound_dev_if;
-	r->id.idiag_cookie[0] = (u32)(unsigned long)sk;
-	r->id.idiag_cookie[1] = (u32)(((unsigned long)sk >> 31) >> 1);
+	sock_diag_save_cookie(sk, r->id.idiag_cookie);
 
 	r->id.idiag_sport = inet->inet_sport;
 	r->id.idiag_dport = inet->inet_dport;
@@ -221,8 +220,7 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 	r->idiag_family	      = tw->tw_family;
 	r->idiag_retrans      = 0;
 	r->id.idiag_if	      = tw->tw_bound_dev_if;
-	r->id.idiag_cookie[0] = (u32)(unsigned long)tw;
-	r->id.idiag_cookie[1] = (u32)(((unsigned long)tw >> 31) >> 1);
+	sock_diag_save_cookie(tw, r->id.idiag_cookie);
 	r->id.idiag_sport     = tw->tw_sport;
 	r->id.idiag_dport     = tw->tw_dport;
 	r->id.idiag_src[0]    = tw->tw_rcv_saddr;
@@ -261,18 +259,6 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 	return inet_csk_diag_fill(sk, skb, r, pid, seq, nlmsg_flags, unlh);
 }
 
-int inet_diag_check_cookie(struct sock *sk, struct inet_diag_req *req)
-{
-	if ((req->id.idiag_cookie[0] != INET_DIAG_NOCOOKIE ||
-	     req->id.idiag_cookie[1] != INET_DIAG_NOCOOKIE) &&
-	    ((u32)(unsigned long)sk != req->id.idiag_cookie[0] ||
-	     (u32)((((unsigned long)sk) >> 31) >> 1) != req->id.idiag_cookie[1]))
-		return -ESTALE;
-	else
-		return 0;
-}
-EXPORT_SYMBOL_GPL(inet_diag_check_cookie);
-
 int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_skb,
 		const struct nlmsghdr *nlh, struct inet_diag_req *req)
 {
@@ -304,7 +290,7 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_s
 	if (sk == NULL)
 		goto out_nosk;
 
-	err = inet_diag_check_cookie(sk, req);
+	err = sock_diag_check_cookie(sk, req->id.idiag_cookie);
 	if (err)
 		goto out;
 
@@ -617,8 +603,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	r->idiag_retrans = req->retrans;
 
 	r->id.idiag_if = sk->sk_bound_dev_if;
-	r->id.idiag_cookie[0] = (u32)(unsigned long)req;
-	r->id.idiag_cookie[1] = (u32)(((unsigned long)req >> 31) >> 1);
+	sock_diag_save_cookie(req, r->id.idiag_cookie);
 
 	tmo = req->expires - jiffies;
 	if (tmo < 0)
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index fe9db86..69f8a7c 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -57,7 +57,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 	if (sk == NULL)
 		goto out_nosk;
 
-	err = inet_diag_check_cookie(sk, req);
+	err = sock_diag_check_cookie(sk, req->id.idiag_cookie);
 	if (err)
 		goto out;
 
-- 
1.5.5.6
