From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v2] ipvlan: improvise dev_id generation logic in IPvlan
Date: Mon,  9 Jan 2017 15:05:54 -0800
Message-ID: <20170109230554.38328-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36112 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750821AbdAIXGA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 18:06:00 -0500
Received: by mail-pf0-f196.google.com with SMTP id b22so9257057pfd.3
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 15:06:00 -0800 (PST)
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

This patch adds a per-port variable that keeps track of the IDs
assigned and used as the stat-base for the IDR api. This base will be
wrapped around when it reaches the MAX (0xFFFE) value possibly on a
busy system where slaves are added and deleted routinely.

Fixes: 009146d117b ("ipvlan: assign unique dev-id for each slave device.")
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Eric Dumazet <edumazet@google.com>
CC: David Miller <davem@davemloft.org>
---
v1 -> v2
  Implemented Dave's comments and reinstated IDR API.

 drivers/net/ipvlan/ipvlan.h      |  1 +
 drivers/net/ipvlan/ipvlan_main.c | 13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 0a9068fdee0f..406ae4ff0ae8 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -94,6 +94,7 @@ struct ipvl_port {
 	struct hlist_head	hlhead[IPVLAN_HASH_SIZE];
 	struct list_head	ipvlans;
 	u16			mode;
+	u16			dev_id_start;
 	struct work_struct	wq;
 	struct sk_buff_head	backlog;
 	int			count;
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index ce7ca6a5aa8a..aca2885cf0b4 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -120,6 +120,7 @@ static int ipvlan_port_create(struct net_device *dev)
 	skb_queue_head_init(&port->backlog);
 	INIT_WORK(&port->wq, ipvlan_process_multicast);
 	ida_init(&port->ida);
+	port->dev_id_start = 1;
 
 	err = netdev_rx_handler_register(dev, ipvlan_handle_frame, port);
 	if (err)
@@ -535,15 +536,25 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	ipvlan_adjust_mtu(ipvlan, phy_dev);
 	INIT_LIST_HEAD(&ipvlan->addrs);
 
+	/* If the port-id base is at the MAX value, then wrap it around and
+	 * begin from 0x1 again. This may be due to a busy system where lots
+	 * of slaves are getting created and deleted.
+	 */
+	if (port->dev_id_start == 0xFFFE)
+		port->dev_id_start = 0x1;
+
 	/* Since L2 address is shared among all IPvlan slaves including
 	 * master, use unique 16 bit dev-ids to diffentiate among them.
 	 * Assign IDs between 0x1 and 0xFFFE (used by the master) to each
 	 * slave link [see addrconf_ifid_eui48()].
 	 */
-	err = ida_simple_get(&port->ida, 1, 0xFFFE, GFP_KERNEL);
+	err = ida_simple_get(&port->ida, port->dev_id_start, 0xFFFE,
+			     GFP_KERNEL);
 	if (err < 0)
 		goto destroy_ipvlan_port;
 	dev->dev_id = err;
+	/* Increment id-base to the next slot for the future assignment */
+	port->dev_id_start = err + 1;
 
 	/* TODO Probably put random address here to be presented to the
 	 * world but keep using the physical-dev address for the outgoing
-- 
2.11.0.390.gc69c2f50cf-goog
