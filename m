From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V2 net 3/4] macvlan: convert port passthru to flags.
Date: Wed, 21 Jun 2017 07:59:18 -0400
Message-ID: <20170621115919.28165-4-vyasevic@redhat.com>
References: <20170621115919.28165-1-vyasevic@redhat.com>
Cc: girish.moodalbail@oracle.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36459 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbdFUL7e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 07:59:34 -0400
Received: by mail-qt0-f196.google.com with SMTP id s33so26925417qtg.3
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 04:59:33 -0700 (PDT)
In-Reply-To: <20170621115919.28165-1-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the port passthru boolean into flags with accesor functions.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c | 37 ++++++++++++++++++++++++-------------
 1 file changed, 24 insertions(+), 13 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 0c9c6da..90d08d6 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -39,13 +39,15 @@
 #define MACVLAN_HASH_SIZE	(1<<MACVLAN_HASH_BITS)
 #define MACVLAN_BC_QUEUE_LEN	1000
 
+#define MACVLAN_F_PASSTHRU	1
+
 struct macvlan_port {
 	struct net_device	*dev;
 	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
 	struct list_head	vlans;
 	struct sk_buff_head	bc_queue;
 	struct work_struct	bc_work;
-	bool 			passthru;
+	u32			flags;
 	int			count;
 	struct hlist_head	vlan_source_hash[MACVLAN_HASH_SIZE];
 	DECLARE_BITMAP(mc_filter, MACVLAN_MC_FILTER_SZ);
@@ -66,6 +68,16 @@ struct macvlan_skb_cb {
 
 static void macvlan_port_destroy(struct net_device *dev);
 
+static inline bool macvlan_passthru(const struct macvlan_port *port)
+{
+	return port->flags & MACVLAN_F_PASSTHRU;
+}
+
+static inline void macvlan_set_passthru(struct macvlan_port *port)
+{
+	port->flags |= MACVLAN_F_PASSTHRU;
+}
+
 /* Hash Ethernet address */
 static u32 macvlan_eth_hash(const unsigned char *addr)
 {
@@ -185,7 +197,7 @@ static bool macvlan_addr_busy(const struct macvlan_port *port,
 	 * currently in use by the underlying device or
 	 * another macvlan.
 	 */
-	if (!port->passthru &&
+	if (!macvlan_passthru(port) &&
 	    ether_addr_equal_64bits(port->dev->dev_addr, addr))
 		return true;
 
@@ -446,7 +458,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 	}
 
 	macvlan_forward_source(skb, port, eth->h_source);
-	if (port->passthru)
+	if (macvlan_passthru(port))
 		vlan = list_first_or_null_rcu(&port->vlans,
 					      struct macvlan_dev, list);
 	else
@@ -575,7 +587,7 @@ static int macvlan_open(struct net_device *dev)
 	struct net_device *lowerdev = vlan->lowerdev;
 	int err;
 
-	if (vlan->port->passthru) {
+	if (macvlan_passthru(vlan->port)) {
 		if (!(vlan->flags & MACVLAN_FLAG_NOPROMISC)) {
 			err = dev_set_promiscuity(lowerdev, 1);
 			if (err < 0)
@@ -650,7 +662,7 @@ static int macvlan_stop(struct net_device *dev)
 	dev_uc_unsync(lowerdev, dev);
 	dev_mc_unsync(lowerdev, dev);
 
-	if (vlan->port->passthru) {
+	if (macvlan_passthru(vlan->port)) {
 		if (!(vlan->flags & MACVLAN_FLAG_NOPROMISC))
 			dev_set_promiscuity(lowerdev, -1);
 		goto hash_del;
@@ -683,7 +695,7 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
 		if (macvlan_addr_busy(vlan->port, addr))
 			return -EBUSY;
 
-		if (!vlan->port->passthru) {
+		if (!macvlan_passthru(vlan->port)) {
 			err = dev_uc_add(lowerdev, addr);
 			if (err)
 				return err;
@@ -933,7 +945,7 @@ static int macvlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	/* Support unicast filter only on passthru devices.
 	 * Multicast filter should be allowed on all devices.
 	 */
-	if (!vlan->port->passthru && is_unicast_ether_addr(addr))
+	if (!macvlan_passthru(vlan->port) && is_unicast_ether_addr(addr))
 		return -EOPNOTSUPP;
 
 	if (flags & NLM_F_REPLACE)
@@ -957,7 +969,7 @@ static int macvlan_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 	/* Support unicast filter only on passthru devices.
 	 * Multicast filter should be allowed on all devices.
 	 */
-	if (!vlan->port->passthru && is_unicast_ether_addr(addr))
+	if (!macvlan_passthru(vlan->port) && is_unicast_ether_addr(addr))
 		return -EOPNOTSUPP;
 
 	if (is_unicast_ether_addr(addr))
@@ -1125,7 +1137,6 @@ static int macvlan_port_create(struct net_device *dev)
 	if (port == NULL)
 		return -ENOMEM;
 
-	port->passthru = false;
 	port->dev = dev;
 	INIT_LIST_HEAD(&port->vlans);
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
@@ -1331,7 +1342,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	port = macvlan_port_get_rtnl(lowerdev);
 
 	/* Only 1 macvlan device can be created in passthru mode */
-	if (port->passthru) {
+	if (macvlan_passthru(port)) {
 		/* The macvlan port must be not created this time,
 		 * still goto destroy_macvlan_port for readability.
 		 */
@@ -1357,7 +1368,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 			err = -EINVAL;
 			goto destroy_macvlan_port;
 		}
-		port->passthru = true;
+		macvlan_set_passthru(port);
 		eth_hw_addr_inherit(dev, lowerdev);
 	}
 
@@ -1439,7 +1450,7 @@ static int macvlan_changelink(struct net_device *dev,
 	if (data && data[IFLA_MACVLAN_FLAGS]) {
 		__u16 flags = nla_get_u16(data[IFLA_MACVLAN_FLAGS]);
 		bool promisc = (flags ^ vlan->flags) & MACVLAN_FLAG_NOPROMISC;
-		if (vlan->port->passthru && promisc) {
+		if (macvlan_passthru(vlan->port) && promisc) {
 			int err;
 
 			if (flags & MACVLAN_FLAG_NOPROMISC)
@@ -1602,7 +1613,7 @@ static int macvlan_device_event(struct notifier_block *unused,
 		}
 		break;
 	case NETDEV_CHANGEADDR:
-		if (!port->passthru)
+		if (!macvlan_passthru(port))
 			return NOTIFY_DONE;
 
 		vlan = list_first_entry_or_null(&port->vlans,
-- 
2.9.4
