From: Florian Zumbiehl <florz@gmx.de>
Subject: Re: [PATCH][BUG][SECURITY] Re: Weird problem with PPPoE on tap interface
Date: Sun, 4 Mar 2007 13:09:39 +0100
Message-ID: <20070304120939.GG28150@florz.florz.dyndns.org>
References: <20070228123844.GA28150@florz.florz.dyndns.org> <20070302.131814.23015047.davem@davemloft.net> <20070304015516.GE28150@florz.florz.dyndns.org> <20070303.210843.41636777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mostrows@speakeasy.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-d9bbf844.pool.mediaWays.net ([217.187.248.68]:2784 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbXCDMJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 07:09:45 -0500
Content-Disposition: inline
In-Reply-To: <20070303.210843.41636777.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Florian Zumbiehl <florz@gmx.de>
> Date: Sun, 4 Mar 2007 02:55:16 +0100
> 
> > Below you find a slightly changed version of the patch
> 
> I already applied your first patch, so if you have any
> fixes to submit please provide them as relative patches
> to your original change.
> 
> Thank you.

Here you go ...

--- linux-2.6.20/drivers/net/pppoe.c.orig	2007-03-04 13:06:01.000000000 +0100
+++ linux-2.6.20/drivers/net/pppoe.c	2007-03-04 02:11:51.000000000 +0100
@@ -140,7 +140,7 @@
 
 	ret = item_hash_table[hash];
 
-	while (ret && !(cmp_addr(&ret->pppoe_pa, sid, addr) && ret->pppoe_dev->ifindex == ifindex))
+	while (ret && !(cmp_addr(&ret->pppoe_pa, sid, addr) && ret->pppoe_ifindex == ifindex))
 		ret = ret->next;
 
 	return ret;
@@ -153,7 +153,7 @@
 
 	ret = item_hash_table[hash];
 	while (ret) {
-		if (cmp_2_addr(&ret->pppoe_pa, &po->pppoe_pa) && ret->pppoe_dev->ifindex == po->pppoe_dev->ifindex)
+		if (cmp_2_addr(&ret->pppoe_pa, &po->pppoe_pa) && ret->pppoe_ifindex == po->pppoe_ifindex)
 			return -EALREADY;
 
 		ret = ret->next;
@@ -174,7 +174,7 @@
 	src = &item_hash_table[hash];
 
 	while (ret) {
-		if (cmp_addr(&ret->pppoe_pa, sid, addr) && ret->pppoe_dev->ifindex == ifindex) {
+		if (cmp_addr(&ret->pppoe_pa, sid, addr) && ret->pppoe_ifindex == ifindex) {
 			*src = ret->next;
 			break;
 		}
@@ -529,7 +529,7 @@
 
 	po = pppox_sk(sk);
 	if (po->pppoe_pa.sid) {
-		delete_item(po->pppoe_pa.sid, po->pppoe_pa.remote, po->pppoe_dev->ifindex);
+		delete_item(po->pppoe_pa.sid, po->pppoe_pa.remote, po->pppoe_ifindex);
 	}
 
 	if (po->pppoe_dev)
@@ -577,7 +577,7 @@
 		pppox_unbind_sock(sk);
 
 		/* Delete the old binding */
-		delete_item(po->pppoe_pa.sid,po->pppoe_pa.remote,po->pppoe_dev->ifindex);
+		delete_item(po->pppoe_pa.sid,po->pppoe_pa.remote,po->pppoe_ifindex);
 
 		if(po->pppoe_dev)
 			dev_put(po->pppoe_dev);
@@ -597,6 +597,7 @@
 			goto end;
 
 		po->pppoe_dev = dev;
+		po->pppoe_ifindex = dev->ifindex;
 
 		if (!(dev->flags & IFF_UP))
 			goto err_put;
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
 
