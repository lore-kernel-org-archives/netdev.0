From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: add __rcu annotations to ip_ra_chain
Date: Mon, 25 Oct 2010 15:32:44 +0200
Message-ID: <1288013564.2826.123.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46653 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754997Ab0JYNct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 09:32:49 -0400
Received: by wyf28 with SMTP id 28so3402222wyf.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 06:32:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __rcu annotations to :
        (struct ip_ra_chain)->next
	struct ip_ra_chain *ip_ra_chain;

And use appropriate rcu primitives.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ip.h       |    4 ++--
 net/ipv4/ip_sockglue.c |   10 +++++++---
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index dbee3fe..86e2b18 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -59,7 +59,7 @@ struct ipcm_cookie {
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
 
 struct ip_ra_chain {
-	struct ip_ra_chain	*next;
+	struct ip_ra_chain __rcu *next;
 	struct sock		*sk;
 	union {
 		void			(*destructor)(struct sock *);
@@ -68,7 +68,7 @@ struct ip_ra_chain {
 	struct rcu_head		rcu;
 };
 
-extern struct ip_ra_chain *ip_ra_chain;
+extern struct ip_ra_chain __rcu *ip_ra_chain;
 
 /* IP flags. */
 #define IP_CE		0x8000		/* Flag: "Congestion"		*/
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 64b70ad..3948c86 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -238,7 +238,7 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
    but receiver should be enough clever f.e. to forward mtrace requests,
    sent to multicast group to reach destination designated router.
  */
-struct ip_ra_chain *ip_ra_chain;
+struct ip_ra_chain __rcu *ip_ra_chain;
 static DEFINE_SPINLOCK(ip_ra_lock);
 
 
@@ -253,7 +253,8 @@ static void ip_ra_destroy_rcu(struct rcu_head *head)
 int ip_ra_control(struct sock *sk, unsigned char on,
 		  void (*destructor)(struct sock *))
 {
-	struct ip_ra_chain *ra, *new_ra, **rap;
+	struct ip_ra_chain *ra, *new_ra;
+	struct ip_ra_chain __rcu **rap;
 
 	if (sk->sk_type != SOCK_RAW || inet_sk(sk)->inet_num == IPPROTO_RAW)
 		return -EINVAL;
@@ -261,7 +262,10 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 	new_ra = on ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
 
 	spin_lock_bh(&ip_ra_lock);
-	for (rap = &ip_ra_chain; (ra = *rap) != NULL; rap = &ra->next) {
+	for (rap = &ip_ra_chain;
+	     (ra = rcu_dereference_protected(*rap,
+			lockdep_is_held(&ip_ra_lock))) != NULL;
+	     rap = &ra->next) {
 		if (ra->sk == sk) {
 			if (on) {
 				spin_unlock_bh(&ip_ra_lock);


