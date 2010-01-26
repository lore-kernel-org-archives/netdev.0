From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net-next-2.6] can: deny filterlist access on non-CAN interfaces
Date: Tue, 26 Jan 2010 14:51:59 +0100
Message-ID: <4B5EF37F.7070906@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:38926 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab0AZNwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 08:52:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 20dd3850bcf860561496827b711fa10fecf6e787 "can: Speed up CAN frame
receiption by using ml_priv" the formerly used hlist of receiver lists for
each CAN netdevice has been replaced. 

The hlist content ensured only CAN netdevices to be accessed by the
can_rx_(un)register() functions which accidently dropped away together with
the hlist receiver implementation.

This patch re-introduces the check for CAN netdevices in can_rx_(un)register().

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

---

diff --git a/net/can/af_can.c b/net/can/af_can.c
index bc18b08..702be5a 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -415,6 +415,9 @@ int can_rx_register(struct net_device *dev, canid_t can_id, canid_t mask,
 
 	/* insert new receiver  (dev,canid,mask) -> (func,data) */
 
+	if (dev && dev->type != ARPHRD_CAN)
+		return -ENODEV;
+
 	r = kmem_cache_alloc(rcv_cache, GFP_KERNEL);
 	if (!r)
 		return -ENOMEM;
@@ -478,6 +481,9 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
 	struct hlist_node *next;
 	struct dev_rcv_lists *d;
 
+	if (dev && dev->type != ARPHRD_CAN)
+		return;
+
 	spin_lock(&can_rcvlists_lock);
 
 	d = find_dev_rcv_lists(dev);

