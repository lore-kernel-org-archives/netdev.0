From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.69] IPV4/6 inetsw using RCU
Date: Thu, 8 May 2003 15:33:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030508153307.73d16f5e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch replaces the brlock with RCU for the IPV4 and IPV6 protocol
switch (inetsw) with Read Copy Update (RCU).  This gets rid of one of
the last two uses of brlock in the kernel.  

Tested on 8-way SMP and it is marginally faster when running on 1G Ethernet
using netperf. 

It changes inetsw from a public variable to static since there is a well
define register/unregister interface. IPV6 unregister needs to be a seperate
function because it has a seperate lock.  

This is a revised version of the earlier brlock removal patch, and addresses
all comments received so far. It is stable and works reliably, but
Dave, you may want to wait for any additional comments before applying.

diff -urNp -X dontdiff linux-2.5/include/net/protocol.h linux-2.5-nbr/include/net/protocol.h
--- linux-2.5/include/net/protocol.h	2003-04-17 09:05:10.000000000 -0700
+++ linux-2.5-nbr/include/net/protocol.h	2003-04-30 14:32:25.000000000 -0700
@@ -80,11 +80,9 @@ struct inet_protosw {
 
 extern struct inet_protocol *inet_protocol_base;
 extern struct inet_protocol *inet_protos[MAX_INET_PROTOS];
-extern struct list_head inetsw[SOCK_MAX];
 
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 extern struct inet6_protocol *inet6_protos[MAX_INET_PROTOS];
-extern struct list_head inetsw6[SOCK_MAX];
 #endif
 
 extern int	inet_add_protocol(struct inet_protocol *prot, unsigned char num);
diff -urNp -X dontdiff linux-2.5/net/ipv4/af_inet.c linux-2.5-nbr/net/ipv4/af_inet.c
--- linux-2.5/net/ipv4/af_inet.c	2003-05-05 09:41:03.000000000 -0700
+++ linux-2.5-nbr/net/ipv4/af_inet.c	2003-05-05 09:44:36.000000000 -0700
@@ -94,7 +94,6 @@
 #include <linux/inet.h>
 #include <linux/igmp.h>
 #include <linux/netdevice.h>
-#include <linux/brlock.h>
 #include <net/ip.h>
 #include <net/protocol.h>
 #include <net/arp.h>
@@ -129,7 +128,8 @@ static kmem_cache_t *raw4_sk_cachep;
 /* The inetsw table contains everything that inet_create needs to
  * build a new socket.
  */
-struct list_head inetsw[SOCK_MAX];
+static struct list_head inetsw[SOCK_MAX];
+static spinlock_t inetsw_lock = SPIN_LOCK_UNLOCKED;
 
 /* New destruction routine */
 
@@ -337,8 +337,8 @@ static int inet_create(struct socket *so
 
 	/* Look for the requested type/protocol pair. */
 	answer = NULL;
-	br_read_lock_bh(BR_NETPROTO_LOCK);
-	list_for_each(p, &inetsw[sock->type]) {
+	rcu_read_lock();
+	list_for_each_rcu(p, &inetsw[sock->type]) {
 		answer = list_entry(p, struct inet_protosw, list);
 
 		/* Check the non-wild match. */
@@ -356,7 +356,6 @@ static int inet_create(struct socket *so
 		}
 		answer = NULL;
 	}
-	br_read_unlock_bh(BR_NETPROTO_LOCK);
 
 	err = -ESOCKTNOSUPPORT;
 	if (!answer)
@@ -373,6 +372,7 @@ static int inet_create(struct socket *so
 	sk->no_check = answer->no_check;
 	if (INET_PROTOSW_REUSE & answer->flags)
 		sk->reuse = 1;
+	rcu_read_unlock();
 
 	inet = inet_sk(sk);
 
@@ -427,6 +427,7 @@ static int inet_create(struct socket *so
 out:
 	return err;
 out_sk_free:
+	rcu_read_unlock();
 	sk_free(sk);
 	goto out;
 }
@@ -978,7 +979,7 @@ void inet_register_protosw(struct inet_p
 	int protocol = p->protocol;
 	struct list_head *last_perm;
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
+	spin_lock_bh(&inetsw_lock);
 
 	if (p->type > SOCK_MAX)
 		goto out_illegal;
@@ -1007,9 +1008,12 @@ void inet_register_protosw(struct inet_p
 	 * non-permanent entry.  This means that when we remove this entry, the 
 	 * system automatically returns to the old behavior.
 	 */
-	list_add(&p->list, last_perm);
+	list_add_rcu(&p->list, last_perm);
 out:
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	spin_unlock_bh(&inetsw_lock);
+
+	synchronize_kernel();
+
 	return;
 
 out_permanent:
@@ -1031,9 +1035,11 @@ void inet_unregister_protosw(struct inet
 		       "Attempt to unregister permanent protocol %d.\n",
 		       p->protocol);
 	} else {
-		br_write_lock_bh(BR_NETPROTO_LOCK);
-		list_del(&p->list);
-		br_write_unlock_bh(BR_NETPROTO_LOCK);
+		spin_lock_bh(&inetsw_lock);
+		list_del_rcu(&p->list);
+		spin_unlock_bh(&inetsw_lock);
+
+		synchronize_kernel();
 	}
 }
 
diff -urNp -X dontdiff linux-2.5/net/ipv4/icmp.c linux-2.5-nbr/net/ipv4/icmp.c
--- linux-2.5/net/ipv4/icmp.c	2003-04-14 13:32:26.000000000 -0700
+++ linux-2.5-nbr/net/ipv4/icmp.c	2003-05-01 09:54:44.000000000 -0700
@@ -695,15 +695,12 @@ static void icmp_unreach(struct sk_buff 
 	}
 	read_unlock(&raw_v4_lock);
 
-	/*
-	 *	This can't change while we are doing it.
-	 *	Callers have obtained BR_NETPROTO_LOCK so
-	 *	we are OK.
-	 */
-
+	rcu_read_lock();
 	ipprot = inet_protos[hash];
+	smp_read_barrier_depends();
 	if (ipprot && ipprot->err_handler)
 		ipprot->err_handler(skb, info);
+	rcu_read_unlock();
 
 out:
 	return;
diff -urNp -X dontdiff linux-2.5/net/ipv4/ip_input.c linux-2.5-nbr/net/ipv4/ip_input.c
--- linux-2.5/net/ipv4/ip_input.c	2003-04-14 13:32:26.000000000 -0700
+++ linux-2.5-nbr/net/ipv4/ip_input.c	2003-05-01 09:54:44.000000000 -0700
@@ -215,6 +215,7 @@ static inline int ip_local_deliver_finis
         /* Point into the IP datagram, just past the header. */
         skb->h.raw = skb->data;
 
+	rcu_read_lock();
 	{
 		/* Note: See raw.c and net/raw.h, RAWV4_HTABLE_SIZE==MAX_INET_PROTOS */
 		int protocol = skb->nh.iph->protocol;
@@ -235,10 +236,11 @@ static inline int ip_local_deliver_finis
 		if ((ipprot = inet_protos[hash]) != NULL) {
 			int ret;
 
+			smp_read_barrier_depends();
 			if (!ipprot->no_policy &&
 			    !xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 				kfree_skb(skb);
-				return 0;
+				goto out;
 			}
 			ret = ipprot->handler(skb);
 			if (ret < 0) {
@@ -258,6 +260,8 @@ static inline int ip_local_deliver_finis
 			kfree_skb(skb);
 		}
 	}
+ out:
+	rcu_read_unlock();
 
 	return 0;
 }
diff -urNp -X dontdiff linux-2.5/net/ipv4/protocol.c linux-2.5-nbr/net/ipv4/protocol.c
--- linux-2.5/net/ipv4/protocol.c	2003-04-14 13:32:26.000000000 -0700
+++ linux-2.5-nbr/net/ipv4/protocol.c	2003-04-30 16:30:33.000000000 -0700
@@ -37,7 +37,6 @@
 #include <linux/inet.h>
 #include <linux/netdevice.h>
 #include <linux/timer.h>
-#include <linux/brlock.h>
 #include <net/ip.h>
 #include <net/protocol.h>
 #include <net/tcp.h>
@@ -49,6 +48,7 @@
 #include <linux/igmp.h>
 
 struct inet_protocol *inet_protos[MAX_INET_PROTOS];
+static spinlock_t inet_proto_lock = SPIN_LOCK_UNLOCKED;
 
 /*
  *	Add a protocol handler to the hash tables
@@ -60,16 +60,14 @@ int inet_add_protocol(struct inet_protoc
 
 	hash = protocol & (MAX_INET_PROTOS - 1);
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
-
+	spin_lock_bh(&inet_proto_lock);
 	if (inet_protos[hash]) {
 		ret = -1;
 	} else {
 		inet_protos[hash] = prot;
 		ret = 0;
 	}
-
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	spin_unlock_bh(&inet_proto_lock);
 
 	return ret;
 }
@@ -84,16 +82,15 @@ int inet_del_protocol(struct inet_protoc
 
 	hash = protocol & (MAX_INET_PROTOS - 1);
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
-
+	spin_lock_bh(&inet_proto_lock);
 	if (inet_protos[hash] == prot) {
 		inet_protos[hash] = NULL;
 		ret = 0;
 	} else {
 		ret = -1;
 	}
+	spin_unlock_bh(&inet_proto_lock);
 
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
 
 	return ret;
 }
diff -urNp -X dontdiff linux-2.5/net/ipv6/af_inet6.c linux-2.5-nbr/net/ipv6/af_inet6.c
--- linux-2.5/net/ipv6/af_inet6.c	2003-05-05 09:41:03.000000000 -0700
+++ linux-2.5-nbr/net/ipv6/af_inet6.c	2003-05-05 09:44:36.000000000 -0700
@@ -45,7 +45,6 @@
 #include <linux/inet.h>
 #include <linux/netdevice.h>
 #include <linux/icmpv6.h>
-#include <linux/brlock.h>
 #include <linux/smp_lock.h>
 
 #include <net/ip.h>
@@ -102,7 +101,8 @@ kmem_cache_t *raw6_sk_cachep;
 /* The inetsw table contains everything that inet_create needs to
  * build a new socket.
  */
-struct list_head inetsw6[SOCK_MAX];
+static struct list_head inetsw6[SOCK_MAX];
+static spinlock_t inetsw6_lock = SPIN_LOCK_UNLOCKED;
 
 static void inet6_sock_destruct(struct sock *sk)
 {
@@ -163,8 +163,8 @@ static int inet6_create(struct socket *s
 
 	/* Look for the requested type/protocol pair. */
 	answer = NULL;
-	br_read_lock_bh(BR_NETPROTO_LOCK);
-	list_for_each(p, &inetsw6[sock->type]) {
+	rcu_read_lock();
+	list_for_each_rcu(p, &inetsw6[sock->type]) {
 		answer = list_entry(p, struct inet_protosw, list);
 
 		/* Check the non-wild match. */
@@ -182,7 +182,6 @@ static int inet6_create(struct socket *s
 		}
 		answer = NULL;
 	}
-	br_read_unlock_bh(BR_NETPROTO_LOCK);
 
 	if (!answer)
 		goto free_and_badtype;
@@ -199,6 +198,7 @@ static int inet6_create(struct socket *s
 	sk->no_check = answer->no_check;
 	if (INET_PROTOSW_REUSE & answer->flags)
 		sk->reuse = 1;
+	rcu_read_unlock();
 
 	inet = inet_sk(sk);
 
@@ -267,12 +267,15 @@ static int inet6_create(struct socket *s
 	return 0;
 
 free_and_badtype:
+	rcu_read_unlock();
 	sk_free(sk);
 	return -ESOCKTNOSUPPORT;
 free_and_badperm:
+	rcu_read_unlock();
 	sk_free(sk);
 	return -EPERM;
 free_and_noproto:
+	rcu_read_unlock();
 	sk_free(sk);
 	return -EPROTONOSUPPORT;
 do_oom:
@@ -580,7 +583,7 @@ inet6_register_protosw(struct inet_proto
 	int protocol = p->protocol;
 	struct list_head *last_perm;
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
+	spin_lock_bh(&inetsw6_lock);
 
 	if (p->type > SOCK_MAX)
 		goto out_illegal;
@@ -609,9 +612,9 @@ inet6_register_protosw(struct inet_proto
 	 * non-permanent entry.  This means that when we remove this entry, the 
 	 * system automatically returns to the old behavior.
 	 */
-	list_add(&p->list, last_perm);
+	list_add_rcu(&p->list, last_perm);
 out:
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	spin_unlock_bh(&inetsw6_lock);
 	return;
 
 out_permanent:
@@ -629,7 +632,17 @@ out_illegal:
 void
 inet6_unregister_protosw(struct inet_protosw *p)
 {
-	inet_unregister_protosw(p);
+	if (INET_PROTOSW_PERMANENT & p->flags) {
+		printk(KERN_ERR
+		       "Attempt to unregister permanent protocol %d.\n",
+		       p->protocol);
+	} else {
+		spin_lock_bh(&inetsw6_lock);
+		list_del_rcu(&p->list);
+		spin_unlock_bh(&inetsw6_lock);
+
+		synchronize_kernel();
+	}
 }
 
 int
diff -urNp -X dontdiff linux-2.5/net/ipv6/icmp.c linux-2.5-nbr/net/ipv6/icmp.c
--- linux-2.5/net/ipv6/icmp.c	2003-04-29 09:57:41.000000000 -0700
+++ linux-2.5-nbr/net/ipv6/icmp.c	2003-05-01 09:54:44.000000000 -0700
@@ -456,9 +456,12 @@ static void icmpv6_notify(struct sk_buff
 
 	hash = nexthdr & (MAX_INET_PROTOS - 1);
 
+	rcu_read_lock();
 	ipprot = inet6_protos[hash];
+	smp_read_barrier_depends();
 	if (ipprot && ipprot->err_handler)
 		ipprot->err_handler(skb, NULL, type, code, inner_offset, info);
+	rcu_read_unlock();
 
 	read_lock(&raw_v6_lock);
 	if ((sk = raw_v6_htable[hash]) != NULL) {
diff -urNp -X dontdiff linux-2.5/net/ipv6/ip6_input.c linux-2.5-nbr/net/ipv6/ip6_input.c
--- linux-2.5/net/ipv6/ip6_input.c	2003-04-17 09:05:10.000000000 -0700
+++ linux-2.5-nbr/net/ipv6/ip6_input.c	2003-05-01 09:54:44.000000000 -0700
@@ -152,6 +152,7 @@ static inline int ip6_input_finish(struc
 		skb->h.raw += (skb->h.raw[1]+1)<<3;
 	}
 
+	rcu_read_lock();
 resubmit:
 	if (!pskb_pull(skb, skb->h.raw - skb->data))
 		goto discard;
@@ -165,6 +166,7 @@ resubmit:
 	if ((ipprot = inet6_protos[hash]) != NULL) {
 		int ret;
 		
+		smp_read_barrier_depends();
 		if (ipprot->flags & INET6_PROTO_FINAL) {
 			if (!cksum_sub && skb->ip_summed == CHECKSUM_HW) {
 				skb->csum = csum_sub(skb->csum,
@@ -173,10 +175,8 @@ resubmit:
 			}
 		}
 		if (!(ipprot->flags & INET6_PROTO_NOPOLICY) &&
-		    !xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-			kfree_skb(skb);
-			return 0;
-		}
+		    !xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) 
+			goto discard;
 		
 		ret = ipprot->handler(&skb, &nhoff);
 		if (ret > 0)
@@ -194,10 +194,11 @@ resubmit:
 			kfree_skb(skb);
 		}
 	}
-
+	rcu_read_unlock();
 	return 0;
 
 discard:
+	rcu_read_unlock();
 	kfree_skb(skb);
 	return 0;
 }
diff -urNp -X dontdiff linux-2.5/net/ipv6/protocol.c linux-2.5-nbr/net/ipv6/protocol.c
--- linux-2.5/net/ipv6/protocol.c	2003-04-14 13:32:27.000000000 -0700
+++ linux-2.5-nbr/net/ipv6/protocol.c	2003-04-30 14:39:23.000000000 -0700
@@ -32,7 +32,6 @@
 #include <linux/in6.h>
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
-#include <linux/brlock.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -41,12 +40,14 @@
 #include <net/protocol.h>
 
 struct inet6_protocol *inet6_protos[MAX_INET_PROTOS];
+static spinlock_t inet6_proto_lock = SPIN_LOCK_UNLOCKED;
+
 
 int inet6_add_protocol(struct inet6_protocol *prot, unsigned char protocol)
 {
 	int ret, hash = protocol & (MAX_INET_PROTOS - 1);
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
+	spin_lock_bh(&inet6_proto_lock);
 
 	if (inet6_protos[hash]) {
 		ret = -1;
@@ -55,7 +56,7 @@ int inet6_add_protocol(struct inet6_prot
 		ret = 0;
 	}
 
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	spin_unlock_bh(&inet6_proto_lock);
 
 	return ret;
 }
@@ -68,7 +69,7 @@ int inet6_del_protocol(struct inet6_prot
 {
 	int ret, hash = protocol & (MAX_INET_PROTOS - 1);
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
+	spin_lock_bh(&inet6_proto_lock);
 
 	if (inet6_protos[hash] != prot) {
 		ret = -1;
@@ -77,7 +78,7 @@ int inet6_del_protocol(struct inet6_prot
 		ret = 0;
 	}
 
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	spin_unlock_bh(&inet6_proto_lock);
 
 	return ret;
 }
