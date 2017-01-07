From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v1] ipvlan: don't use IDR for generating dev_id
Date: Fri,  6 Jan 2017 16:33:11 -0800
Message-ID: <20170107003311.22940-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33963 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964977AbdAGAdR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 19:33:17 -0500
Received: by mail-pf0-f195.google.com with SMTP id y68so30597369pfb.1
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 16:33:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

The patch 009146d117b ("ipvlan: assign unique dev-id for each slave
device.") used ida_simple_get() to generate dev_ids assigned to the
slave devices. However (Eric has pointed out that) there is a shortcoming
with that approach as it always uses the first available ID. This
becomes a problem when a slave gets deleted and a new slave gets added.
The ID gets reassigned causing the new slave to get the same link-local
address. This side-effect is undesirable.

This patch replaces IDR logic with a simple per-port variable that keeps
incrementing and wraps around when the MAX (0xFFFE) is reached. The
only downside is that this is an inefficient (n^2) search if there are
64k (or close to 64k) slaves in the system, the dev-id search takes time.
However having these many devices in the system has it's own challenges.

Fixes: 009146d117b ("ipvlan: assign unique dev-id for each slave device.")
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ipvlan/ipvlan.h      |  2 +-
 drivers/net/ipvlan/ipvlan_main.c | 69 ++++++++++++++++++++++++++++++++++------
 2 files changed, 61 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 0a9068fdee0f..535f254324ba 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -94,10 +94,10 @@ struct ipvl_port {
 	struct hlist_head	hlhead[IPVLAN_HASH_SIZE];
 	struct list_head	ipvlans;
 	u16			mode;
+	u16			dev_id_base;
 	struct work_struct	wq;
 	struct sk_buff_head	backlog;
 	int			count;
-	struct ida		ida;
 };
 
 struct ipvl_skb_cb {
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index ce7ca6a5aa8a..691662e02abb 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -119,7 +119,7 @@ static int ipvlan_port_create(struct net_device *dev)
 
 	skb_queue_head_init(&port->backlog);
 	INIT_WORK(&port->wq, ipvlan_process_multicast);
-	ida_init(&port->ida);
+	port->dev_id_base = 1;
 
 	err = netdev_rx_handler_register(dev, ipvlan_handle_frame, port);
 	if (err)
@@ -151,7 +151,6 @@ static void ipvlan_port_destroy(struct net_device *dev)
 			dev_put(skb->dev);
 		kfree_skb(skb);
 	}
-	ida_destroy(&port->ida);
 	kfree(port);
 }
 
@@ -496,6 +495,60 @@ static int ipvlan_nl_fillinfo(struct sk_buff *skb,
 	return ret;
 }
 
+static u16 ipvlan_get_dev_id(struct ipvl_port *port)
+{
+	struct ipvl_dev *ipvlan;
+	u16 tid, dev_id = 0;
+	bool found, exhausted = false, second_round = false;
+
+	/* Idea here is to get the next available ID while avoiding
+	 * reuse of already used IDs. Per port variable (dev_id_base)
+	 * is used to get the next available ID.
+	 *
+	 * Possibilities are from 0x1 to 0xfffe so finding next available
+	 * ID is not be that difficult. However if the system is up for a
+	 * long time and these slave devices are getting added / deleted
+	 * routinely and it reaches the MAX, then only the assignment will
+	 * attempt to recycle previously used IDs starting from 0x1 (Provided
+	 * these are not currently in use).
+	 *
+	 * In case of a failure, dev-id search will return 0. All IDs in-use
+	 * case is very inefficient (n^2 search) but having close to 64k
+	 * slaves has it's own system limitations.
+	 */
+	while (!exhausted) {
+		tid = port->dev_id_base++;
+
+		if (tid == 0xFFFE) {
+			/* Reached MAX; restart from 1 */
+			port->dev_id_base = 1;
+			if (second_round)
+				exhausted = true;
+			else
+				second_round = true;
+			continue;
+		}
+		/* Should not be same as the masters' (if present) */
+		if (tid == port->dev->dev_id)
+			continue;
+		/* Make sure that it's already not assigned to any of the
+		 * existing slaves.
+		 */
+		found = false;
+		list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
+			if (ipvlan->dev->dev_id == tid) {
+				found = true;
+				break;
+			}
+		}
+		if (!found) {
+			dev_id = tid;
+			break;
+		}
+	}
+	return dev_id;
+}
+
 static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
@@ -540,10 +593,11 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	 * Assign IDs between 0x1 and 0xFFFE (used by the master) to each
 	 * slave link [see addrconf_ifid_eui48()].
 	 */
-	err = ida_simple_get(&port->ida, 1, 0xFFFE, GFP_KERNEL);
-	if (err < 0)
+	dev->dev_id = ipvlan_get_dev_id(port);
+	if (dev->dev_id == 0) {
+		err = -ENOSPC;
 		goto destroy_ipvlan_port;
-	dev->dev_id = err;
+	}
 
 	/* TODO Probably put random address here to be presented to the
 	 * world but keep using the physical-dev address for the outgoing
@@ -555,7 +609,7 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 
 	err = register_netdevice(dev);
 	if (err < 0)
-		goto remove_ida;
+		goto destroy_ipvlan_port;
 
 	err = netdev_upper_dev_link(phy_dev, dev);
 	if (err) {
@@ -574,8 +628,6 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	netdev_upper_dev_unlink(phy_dev, dev);
 unregister_netdev:
 	unregister_netdevice(dev);
-remove_ida:
-	ida_simple_remove(&port->ida, dev->dev_id);
 destroy_ipvlan_port:
 	if (create)
 		ipvlan_port_destroy(phy_dev);
@@ -593,7 +645,6 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
 		kfree_rcu(addr, rcu);
 	}
 
-	ida_simple_remove(&ipvlan->port->ida, dev->dev_id);
 	list_del_rcu(&ipvlan->pnode);
 	unregister_netdevice_queue(dev, head);
 	netdev_upper_dev_unlink(ipvlan->phy_dev, dev);
-- 
2.11.0.390.gc69c2f50cf-goog
