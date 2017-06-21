From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V2 net 4/4] macvlan: Let passthru macvlan correctly restore lower mac address
Date: Wed, 21 Jun 2017 07:59:19 -0400
Message-ID: <20170621115919.28165-5-vyasevic@redhat.com>
References: <20170621115919.28165-1-vyasevic@redhat.com>
Cc: girish.moodalbail@oracle.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36732 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751806AbdFUL7f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 07:59:35 -0400
Received: by mail-qk0-f193.google.com with SMTP id r62so15046969qkf.3
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 04:59:35 -0700 (PDT)
In-Reply-To: <20170621115919.28165-1-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Passthru macvlans directly change the mac address of the lower
level device.  That's OK, but after the macvlan is deleted,
the lower device is left with changed address and one needs to
reboot to bring back the origina HW addresses.

This scenario is actually quite common with passthru macvtap devices.

This patch attempts to solve this, by storing the mac address
of the lower device in macvlan_port structure and keeping track of
it through the changes.

After this patch, any changes to the lower device mac address
done trough the macvlan device, will be reverted back.  Any
changs done directly to the lower device mac address will be kept.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c | 47 ++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 44 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 90d08d6..ad27704 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -40,6 +40,7 @@
 #define MACVLAN_BC_QUEUE_LEN	1000
 
 #define MACVLAN_F_PASSTHRU	1
+#define MACVLAN_F_ADDRCHANGE	2
 
 struct macvlan_port {
 	struct net_device	*dev;
@@ -51,6 +52,7 @@ struct macvlan_port {
 	int			count;
 	struct hlist_head	vlan_source_hash[MACVLAN_HASH_SIZE];
 	DECLARE_BITMAP(mc_filter, MACVLAN_MC_FILTER_SZ);
+	unsigned char           perm_addr[ETH_ALEN];
 };
 
 struct macvlan_source_entry {
@@ -78,6 +80,21 @@ static inline void macvlan_set_passthru(struct macvlan_port *port)
 	port->flags |= MACVLAN_F_PASSTHRU;
 }
 
+static inline bool macvlan_addr_change(const struct macvlan_port *port)
+{
+	return port->flags & MACVLAN_F_ADDRCHANGE;
+}
+
+static inline void macvlan_set_addr_change(struct macvlan_port *port)
+{
+	port->flags |= MACVLAN_F_ADDRCHANGE;
+}
+
+static inline void macvlan_clear_addr_change(struct macvlan_port *port)
+{
+	port->flags &= ~MACVLAN_F_ADDRCHANGE;
+}
+
 /* Hash Ethernet address */
 static u32 macvlan_eth_hash(const unsigned char *addr)
 {
@@ -193,11 +210,11 @@ static void macvlan_hash_change_addr(struct macvlan_dev *vlan,
 static bool macvlan_addr_busy(const struct macvlan_port *port,
 			      const unsigned char *addr)
 {
-	/* Test to see if the specified multicast address is
+	/* Test to see if the specified address is
 	 * currently in use by the underlying device or
 	 * another macvlan.
 	 */
-	if (!macvlan_passthru(port) &&
+	if (!macvlan_passthru(port) && !macvlan_addr_change(port) &&
 	    ether_addr_equal_64bits(port->dev->dev_addr, addr))
 		return true;
 
@@ -685,6 +702,7 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
+	struct macvlan_port *port = vlan->port;
 	int err;
 
 	if (!(dev->flags & IFF_UP)) {
@@ -695,7 +713,7 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
 		if (macvlan_addr_busy(vlan->port, addr))
 			return -EBUSY;
 
-		if (!macvlan_passthru(vlan->port)) {
+		if (!macvlan_passthru(port)) {
 			err = dev_uc_add(lowerdev, addr);
 			if (err)
 				return err;
@@ -705,6 +723,15 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
 
 		macvlan_hash_change_addr(vlan, addr);
 	}
+	if (macvlan_passthru(port) && !macvlan_addr_change(port)) {
+		/* Since addr_change isn't set, we are here due to lower
+		 * device change.  Save the lower-dev address so we can
+		 * restore it later.
+		 */
+		ether_addr_copy(vlan->port->perm_addr,
+				lowerdev->dev_addr);
+	}
+	macvlan_clear_addr_change(port);
 	return 0;
 }
 
@@ -721,6 +748,7 @@ static int macvlan_set_mac_address(struct net_device *dev, void *p)
 		return 0;
 
 	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
+		macvlan_set_addr_change(vlan->port);
 		dev_set_mac_address(vlan->lowerdev, addr);
 		return 0;
 	}
@@ -1138,6 +1166,7 @@ static int macvlan_port_create(struct net_device *dev)
 		return -ENOMEM;
 
 	port->dev = dev;
+	ether_addr_copy(port->perm_addr, dev->dev_addr);
 	INIT_LIST_HEAD(&port->vlans);
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
 		INIT_HLIST_HEAD(&port->vlan_hash[i]);
@@ -1177,6 +1206,18 @@ static void macvlan_port_destroy(struct net_device *dev)
 		kfree_skb(skb);
 	}
 
+	/* If the lower device address has been changed by passthru
+	 * macvlan, put it back.
+	 */
+	if (macvlan_passthru(port) &&
+	    !ether_addr_equal(port->dev->dev_addr, port->perm_addr)) {
+		struct sockaddr sa;
+
+		sa.sa_family = port->dev->type;
+		memcpy(&sa.sa_data, port->perm_addr, port->dev->addr_len);
+		dev_set_mac_address(port->dev, &sa);
+	}
+
 	kfree(port);
 }
 
-- 
2.9.4
