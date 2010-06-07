From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ip: Router Alert RCU conversion
Date: Mon, 07 Jun 2010 15:12:08 +0200
Message-ID: <1275916328.2545.64.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38895 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370Ab0FGNMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 09:12:13 -0400
Received: by fxm8 with SMTP id 8so2051368fxm.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 06:12:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Straightforward conversion to RCU.

One rwlock becomes a spinlock, and is static.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ip.h       |    2 +-
 net/ipv4/ip_input.c    |   11 +++--------
 net/ipv4/ip_sockglue.c |   23 ++++++++++++++---------
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 452f229..9982c97 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -62,10 +62,10 @@ struct ip_ra_chain {
 	struct ip_ra_chain	*next;
 	struct sock		*sk;
 	void			(*destructor)(struct sock *);
+	struct rcu_head		rcu;
 };
 
 extern struct ip_ra_chain *ip_ra_chain;
-extern rwlock_t ip_ra_lock;
 
 /* IP flags. */
 #define IP_CE		0x8000		/* Flag: "Congestion"		*/
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index d52c9da..08a3b12 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -146,7 +146,7 @@
 #include <linux/netlink.h>
 
 /*
- *	Process Router Attention IP option
+ *	Process Router Attention IP option (RFC 2113)
  */
 int ip_call_ra_chain(struct sk_buff *skb)
 {
@@ -155,8 +155,7 @@ int ip_call_ra_chain(struct sk_buff *skb)
 	struct sock *last = NULL;
 	struct net_device *dev = skb->dev;
 
-	read_lock(&ip_ra_lock);
-	for (ra = ip_ra_chain; ra; ra = ra->next) {
+	for (ra = rcu_dereference(ip_ra_chain); ra; ra = rcu_dereference(ra->next)) {
 		struct sock *sk = ra->sk;
 
 		/* If socket is bound to an interface, only report
@@ -167,10 +166,8 @@ int ip_call_ra_chain(struct sk_buff *skb)
 		     sk->sk_bound_dev_if == dev->ifindex) &&
 		    net_eq(sock_net(sk), dev_net(dev))) {
 			if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN)) {
-					read_unlock(&ip_ra_lock);
+				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN))
 					return 1;
-				}
 			}
 			if (last) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
@@ -183,10 +180,8 @@ int ip_call_ra_chain(struct sk_buff *skb)
 
 	if (last) {
 		raw_rcv(last, skb);
-		read_unlock(&ip_ra_lock);
 		return 1;
 	}
-	read_unlock(&ip_ra_lock);
 	return 0;
 }
 
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index ce23178..08b9519 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -239,7 +239,12 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
    sent to multicast group to reach destination designated router.
  */
 struct ip_ra_chain *ip_ra_chain;
-DEFINE_RWLOCK(ip_ra_lock);
+static DEFINE_SPINLOCK(ip_ra_lock);
+
+static void ip_ra_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct ip_ra_chain, rcu));
+}
 
 int ip_ra_control(struct sock *sk, unsigned char on,
 		  void (*destructor)(struct sock *))
@@ -251,35 +256,35 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 
 	new_ra = on ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
 
-	write_lock_bh(&ip_ra_lock);
+	spin_lock_bh(&ip_ra_lock);
 	for (rap = &ip_ra_chain; (ra = *rap) != NULL; rap = &ra->next) {
 		if (ra->sk == sk) {
 			if (on) {
-				write_unlock_bh(&ip_ra_lock);
+				spin_unlock_bh(&ip_ra_lock);
 				kfree(new_ra);
 				return -EADDRINUSE;
 			}
-			*rap = ra->next;
-			write_unlock_bh(&ip_ra_lock);
+			rcu_assign_pointer(*rap, ra->next);
+			spin_unlock_bh(&ip_ra_lock);
 
 			if (ra->destructor)
 				ra->destructor(sk);
 			sock_put(sk);
-			kfree(ra);
+			call_rcu(&ra->rcu, ip_ra_free_rcu);
 			return 0;
 		}
 	}
 	if (new_ra == NULL) {
-		write_unlock_bh(&ip_ra_lock);
+		spin_unlock_bh(&ip_ra_lock);
 		return -ENOBUFS;
 	}
 	new_ra->sk = sk;
 	new_ra->destructor = destructor;
 
 	new_ra->next = ra;
-	*rap = new_ra;
+	rcu_assign_pointer(*rap, new_ra);
 	sock_hold(sk);
-	write_unlock_bh(&ip_ra_lock);
+	spin_unlock_bh(&ip_ra_lock);
 
 	return 0;
 }


