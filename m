From: Florian Zumbiehl <florz@florz.de>
Subject: [PATCH 2/4] PPPoE: race between interface going down and connect()
Date: Sun, 11 Mar 2007 05:40:51 +0100
Message-ID: <20070311044051.GB17712@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: mostrows@earthlink.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-d9bbdd48.pool.mediaWays.net ([217.187.221.72]:3381 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933147AbXCKEky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 23:40:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

below you find a patch that (hopefully) fixes a race between an interface
going down and a connect() to a peer on that interface. Before,
connect() would determine that an interface is up, then the interface
could go down and all entries referring to that interface in the
item_hash_table would be marked as ZOMBIEs and their references to
the device would be freed, and after that, connect() would put a new
entry into the hash table referring to the device that meanwhile is
down already - which also would cause unregister_netdevice() to wait
until the socket has been release()d.

This patch does not suffice if we are not allowed to accept connect()s
referring to a device that we already acked a NETDEV_GOING_DOWN for
(that is: all references are only guaranteed to be freed after
NETDEV_DOWN has been acknowledged, not necessarily after the
NETDEV_GOING_DOWN already). And if we are allowed to, we could avoid
looking through the hash table upon NETDEV_GOING_DOWN completely and
only do that once we get the NETDEV_DOWN ...

Florian

---------------------------------------------------------------------------
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 18d1a4d..1aeac2c 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -218,17 +218,6 @@ static inline struct pppox_sock *get_item_by_addr(struct sockaddr_pppox *sp)
 	return get_item(sp->sa_addr.pppoe.sid, sp->sa_addr.pppoe.remote, ifindex);
 }
 
-static inline int set_item(struct pppox_sock *po)
-{
-	int i;
-
-	write_lock_bh(&pppoe_hash_lock);
-	i = __set_item(po);
-	write_unlock_bh(&pppoe_hash_lock);
-
-	return i;
-}
-
 static inline struct pppox_sock *delete_item(unsigned long sid, char *addr, int ifindex)
 {
 	struct pppox_sock *ret;
@@ -595,14 +584,18 @@ static int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
 		po->pppoe_dev = dev;
 		po->pppoe_ifindex = dev->ifindex;
 
-		if (!(dev->flags & IFF_UP))
+		write_lock_bh(&pppoe_hash_lock);
+		if (!(dev->flags & IFF_UP)){
+			write_unlock_bh(&pppoe_hash_lock);
 			goto err_put;
+		}
 
 		memcpy(&po->pppoe_pa,
 		       &sp->sa_addr.pppoe,
 		       sizeof(struct pppoe_addr));
 
-		error = set_item(po);
+		error = __set_item(po);
+		write_unlock_bh(&pppoe_hash_lock);
 		if (error < 0)
 			goto err_put;
 
