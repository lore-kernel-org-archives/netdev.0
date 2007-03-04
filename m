From: Florian Zumbiehl <florz@gmx.de>
Subject: Re: [PATCH][BUG][SECURITY] Re: Weird problem with PPPoE on tap interface
Date: Sun, 4 Mar 2007 02:55:16 +0100
Message-ID: <20070304015516.GE28150@florz.florz.dyndns.org>
References: <20070225195455.GC3318@florz.florz.dyndns.org> <20070226102908.GD3318@florz.florz.dyndns.org> <20070228123844.GA28150@florz.florz.dyndns.org> <20070302.131814.23015047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mostrows@speakeasy.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-d9bbf844.pool.mediaWays.net ([217.187.248.68]:4585 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964832AbXCDBzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 20:55:22 -0500
Content-Disposition: inline
In-Reply-To: <20070302.131814.23015047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> From: Florian Zumbiehl <florz@gmx.de>
> Date: Wed, 28 Feb 2007 13:38:44 +0100
> 
> > As noone seems to have an opinion on this: Here is a patch that does
> > work for me and that should solve the problem as far as that is easily
> > possible. It is based on the assumption that an interface's ifindex is
> > basically an alias for a local MAC address, so incoming packets now are
> > matched to sockets based on remote MAC, session id, and ifindex of the
> > interface the packet came in on/the socket was bound to by connect().
> 
> I agree with your analysis and have applied your patch.

Below you find a slightly changed version of the patch that avoids
a possible NULL pointer dereference in case pppoe_device_event()/
pppoe_flush_dev() dev_put()s dev and sets it to NULL before pppoe_connect()
tries to unbind from the previous address, in which case it would
dereference the NULL pointer in dev.

It now saves the ifindex in the socket's data structure upon connect(),
so that it's still available for finding the entry to remove from the
hash table in case pppoe_device_event() should have dropped the socket's
reference to dev.

> Another way to implement this would have been to store the
> pre-computed ifindex on the kernel side sockaddr.

Well, that probably depends on the intended semantics. There isn't any
documentation somewhere that specifies what the intended behaviour is,
is there?!

Florian

--- linux-2.6.20/drivers/net/pppoe.c.orig	2007-02-25 19:23:51.000000000 +0100
+++ linux-2.6.20/drivers/net/pppoe.c	2007-03-04 02:11:51.000000000 +0100
@@ -7,6 +7,12 @@
  *
  * Version:	0.7.0
  *
+ * 070228 :	Fix to allow multiple sessions with same remote MAC and same
+ *		session id by including the local device ifindex in the
+ *		tuple identifying a session. This also ensures packets can't
+ *		be injected into a session from interfaces other than the one
+ *		specified by userspace. Florian Zumbiehl <florz@florz.de>
+ *		(Oh, BTW, this one is YYMMDD, in case you were wondering ...)
  * 220102 :	Fix module use count on failure in pppoe_create, pppox_sk -acme
  * 030700 :	Fixed connect logic to allow for disconnect.
  * 270700 :	Fixed potential SMP problems; we must protect against
@@ -127,14 +133,14 @@
  *  Set/get/delete/rehash items  (internal versions)
  *
  **********************************************************************/
-static struct pppox_sock *__get_item(unsigned long sid, unsigned char *addr)
+static struct pppox_sock *__get_item(unsigned long sid, unsigned char *addr, int ifindex)
 {
 	int hash = hash_item(sid, addr);
 	struct pppox_sock *ret;
 
 	ret = item_hash_table[hash];
 
-	while (ret && !cmp_addr(&ret->pppoe_pa, sid, addr))
+	while (ret && !(cmp_addr(&ret->pppoe_pa, sid, addr) && ret->pppoe_ifindex == ifindex))
 		ret = ret->next;
 
 	return ret;
@@ -147,21 +153,19 @@
 
 	ret = item_hash_table[hash];
 	while (ret) {
-		if (cmp_2_addr(&ret->pppoe_pa, &po->pppoe_pa))
+		if (cmp_2_addr(&ret->pppoe_pa, &po->pppoe_pa) && ret->pppoe_ifindex == po->pppoe_ifindex)
 			return -EALREADY;
 
 		ret = ret->next;
 	}
 
-	if (!ret) {
-		po->next = item_hash_table[hash];
-		item_hash_table[hash] = po;
-	}
+	po->next = item_hash_table[hash];
+	item_hash_table[hash] = po;
 
 	return 0;
 }
 
-static struct pppox_sock *__delete_item(unsigned long sid, char *addr)
+static struct pppox_sock *__delete_item(unsigned long sid, char *addr, int ifindex)
 {
 	int hash = hash_item(sid, addr);
 	struct pppox_sock *ret, **src;
@@ -170,7 +174,7 @@
 	src = &item_hash_table[hash];
 
 	while (ret) {
-		if (cmp_addr(&ret->pppoe_pa, sid, addr)) {
+		if (cmp_addr(&ret->pppoe_pa, sid, addr) && ret->pppoe_ifindex == ifindex) {
 			*src = ret->next;
 			break;
 		}
@@ -188,12 +192,12 @@
  *
  **********************************************************************/
 static inline struct pppox_sock *get_item(unsigned long sid,
-					 unsigned char *addr)
+					 unsigned char *addr, int ifindex)
 {
 	struct pppox_sock *po;
 
 	read_lock_bh(&pppoe_hash_lock);
-	po = __get_item(sid, addr);
+	po = __get_item(sid, addr, ifindex);
 	if (po)
 		sock_hold(sk_pppox(po));
 	read_unlock_bh(&pppoe_hash_lock);
@@ -203,7 +207,15 @@
 
 static inline struct pppox_sock *get_item_by_addr(struct sockaddr_pppox *sp)
 {
-	return get_item(sp->sa_addr.pppoe.sid, sp->sa_addr.pppoe.remote);
+	struct net_device *dev = NULL;
+	int ifindex;
+
+	dev = dev_get_by_name(sp->sa_addr.pppoe.dev);
+	if(!dev)
+		return NULL;
+	ifindex = dev->ifindex;
+	dev_put(dev);
+	return get_item(sp->sa_addr.pppoe.sid, sp->sa_addr.pppoe.remote, ifindex);
 }
 
 static inline int set_item(struct pppox_sock *po)
@@ -220,12 +232,12 @@
 	return i;
 }
 
-static inline struct pppox_sock *delete_item(unsigned long sid, char *addr)
+static inline struct pppox_sock *delete_item(unsigned long sid, char *addr, int ifindex)
 {
 	struct pppox_sock *ret;
 
 	write_lock_bh(&pppoe_hash_lock);
-	ret = __delete_item(sid, addr);
+	ret = __delete_item(sid, addr, ifindex);
 	write_unlock_bh(&pppoe_hash_lock);
 
 	return ret;
@@ -391,7 +403,7 @@
 
 	ph = (struct pppoe_hdr *) skb->nh.raw;
 
-	po = get_item((unsigned long) ph->sid, eth_hdr(skb)->h_source);
+	po = get_item((unsigned long) ph->sid, eth_hdr(skb)->h_source, dev->ifindex);
 	if (po != NULL)
 		return sk_receive_skb(sk_pppox(po), skb, 0);
 drop:
@@ -425,7 +437,7 @@
 	if (ph->code != PADT_CODE)
 		goto abort;
 
-	po = get_item((unsigned long) ph->sid, eth_hdr(skb)->h_source);
+	po = get_item((unsigned long) ph->sid, eth_hdr(skb)->h_source, dev->ifindex);
 	if (po) {
 		struct sock *sk = sk_pppox(po);
 
@@ -517,7 +529,7 @@
 
 	po = pppox_sk(sk);
 	if (po->pppoe_pa.sid) {
-		delete_item(po->pppoe_pa.sid, po->pppoe_pa.remote);
+		delete_item(po->pppoe_pa.sid, po->pppoe_pa.remote, po->pppoe_ifindex);
 	}
 
 	if (po->pppoe_dev)
@@ -539,7 +551,7 @@
 		  int sockaddr_len, int flags)
 {
 	struct sock *sk = sock->sk;
-	struct net_device *dev = NULL;
+	struct net_device *dev;
 	struct sockaddr_pppox *sp = (struct sockaddr_pppox *) uservaddr;
 	struct pppox_sock *po = pppox_sk(sk);
 	int error;
@@ -565,7 +577,7 @@
 		pppox_unbind_sock(sk);
 
 		/* Delete the old binding */
-		delete_item(po->pppoe_pa.sid,po->pppoe_pa.remote);
+		delete_item(po->pppoe_pa.sid,po->pppoe_pa.remote,po->pppoe_ifindex);
 
 		if(po->pppoe_dev)
 			dev_put(po->pppoe_dev);
@@ -585,6 +597,7 @@
 			goto end;
 
 		po->pppoe_dev = dev;
+		po->pppoe_ifindex = dev->ifindex;
 
 		if (!(dev->flags & IFF_UP))
 			goto err_put;
@@ -705,7 +718,7 @@
 			break;
 
 		/* PPPoE address from the user specifies an outbound
-		   PPPoE address to which frames are forwarded to */
+		   PPPoE address which frames are forwarded to */
 		err = -EFAULT;
 		if (copy_from_user(&po->pppoe_relay,
 				   (void __user *)arg,
--- linux-2.6.20/include/linux/if_pppox.h.orig	2007-02-09 10:21:19.000000000 +0100
+++ linux-2.6.20/include/linux/if_pppox.h	2007-03-04 02:14:24.000000000 +0100
@@ -114,6 +114,7 @@
 #ifdef __KERNEL__
 struct pppoe_opt {
 	struct net_device      *dev;	  /* device associated with socket*/
+	int			ifindex;  /* ifindex of device associated with socket */
 	struct pppoe_addr	pa;	  /* what this socket is bound to*/
 	struct sockaddr_pppox	relay;	  /* what socket data will be
 					     relayed to (PPPoE relaying) */
@@ -132,6 +133,7 @@
 	unsigned short		num;
 };
 #define pppoe_dev	proto.pppoe.dev
+#define pppoe_ifindex	proto.pppoe.ifindex
 #define pppoe_pa	proto.pppoe.pa
 #define pppoe_relay	proto.pppoe.relay
 
