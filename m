From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 01/15] ieee1394: eth1394: coding style
Date: Mon, 2 Apr 2007 02:12:32 +0200 (CEST)
Message-ID: <tkrat.47a675602b38dd19@s5r6.in-berlin.de>
References: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Content-Disposition: INLINE
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Adjust white space and line wraps.  Remove unnecessary parentheses and
braces, unused macros, and some of the more redundant comments.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |  426 +++++++++++++++++--------------------
 drivers/ieee1394/eth1394.h |   24 --
 2 files changed, 206 insertions(+), 244 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -1,5 +1,5 @@
 /*
- * eth1394.c -- Ethernet driver for Linux IEEE-1394 Subsystem
+ * eth1394.c -- IPv4 driver for Linux IEEE-1394 Subsystem
  *
  * Copyright (C) 2001-2003 Ben Collins <bcollins@debian.org>
  *               2000 Bonin Franck <boninf@free.fr>
@@ -22,10 +22,9 @@
  * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
  */
 
-/* This driver intends to support RFC 2734, which describes a method for
- * transporting IPv4 datagrams over IEEE-1394 serial busses. This driver
- * will ultimately support that method, but currently falls short in
- * several areas.
+/*
+ * This driver intends to support RFC 2734, which describes a method for
+ * transporting IPv4 datagrams over IEEE-1394 serial busses.
  *
  * TODO:
  * RFC 2734 related:
@@ -40,7 +39,6 @@
  * - Consider garbage collecting old partial datagrams after X amount of time
  */
 
-
 #include <linux/module.h>
 
 #include <linux/kernel.h>
@@ -84,10 +82,6 @@
 #define ETH1394_PRINT(level, dev_name, fmt, args...) \
 	printk(level "%s: %s: " fmt, driver_name, dev_name, ## args)
 
-#define DEBUG(fmt, args...) \
-	printk(KERN_ERR "%s:%s[%d]: " fmt "\n", driver_name, __FUNCTION__, __LINE__, ## args)
-#define TRACE() printk(KERN_ERR "%s:%s[%d] ---- TRACE\n", driver_name, __FUNCTION__, __LINE__)
-
 struct fragment_info {
 	struct list_head list;
 	int offset;
@@ -105,9 +99,9 @@ struct partial_datagram {
 };
 
 struct pdg_list {
-	struct list_head list;		/* partial datagram list per node	*/
-	unsigned int sz;		/* partial datagram list size per node	*/
-	spinlock_t lock;		/* partial datagram lock		*/
+	struct list_head list;	/* partial datagram list per node	*/
+	unsigned int sz;	/* partial datagram list size per node	*/
+	spinlock_t lock;	/* partial datagram lock		*/
 };
 
 struct eth1394_host_info {
@@ -121,16 +115,14 @@ struct eth1394_node_ref {
 };
 
 struct eth1394_node_info {
-	u16 maxpayload;			/* Max payload			*/
-	u8 sspd;			/* Max speed			*/
-	u64 fifo;			/* FIFO address			*/
-	struct pdg_list pdg;		/* partial RX datagram lists	*/
-	int dgl;			/* Outgoing datagram label	*/
+	u16 maxpayload;		/* max payload			*/
+	u8 sspd;		/* max speed			*/
+	u64 fifo;		/* FIFO address			*/
+	struct pdg_list pdg;	/* partial RX datagram lists	*/
+	int dgl;		/* outgoing datagram label	*/
 };
 
-/* Our ieee1394 highlevel driver */
-#define ETH1394_DRIVER_NAME "eth1394"
-static const char driver_name[] = ETH1394_DRIVER_NAME;
+static const char driver_name[] = "eth1394";
 
 static struct kmem_cache *packet_task_cache;
 
@@ -138,15 +130,12 @@ static struct hpsb_highlevel eth1394_hig
 
 /* Use common.lf to determine header len */
 static const int hdr_type_len[] = {
-	sizeof (struct eth1394_uf_hdr),
-	sizeof (struct eth1394_ff_hdr),
-	sizeof (struct eth1394_sf_hdr),
-	sizeof (struct eth1394_sf_hdr)
+	sizeof(struct eth1394_uf_hdr),
+	sizeof(struct eth1394_ff_hdr),
+	sizeof(struct eth1394_sf_hdr),
+	sizeof(struct eth1394_sf_hdr)
 };
 
-/* Change this to IEEE1394_SPEED_S100 to make testing easier */
-#define ETH1394_SPEED_DEF	IEEE1394_SPEED_MAX
-
 /* For now, this needs to be 1500, so that XP works with us */
 #define ETH1394_DATA_LEN	ETH_DATA_LEN
 
@@ -159,7 +148,8 @@ MODULE_AUTHOR("Ben Collins (bcollins@deb
 MODULE_DESCRIPTION("IEEE 1394 IPv4 Driver (IPv4-over-1394 as per RFC 2734)");
 MODULE_LICENSE("GPL");
 
-/* The max_partial_datagrams parameter is the maximum number of fragmented
+/*
+ * The max_partial_datagrams parameter is the maximum number of fragmented
  * datagrams per node that eth1394 will keep in memory.  Providing an upper
  * bound allows us to limit the amount of memory that partial datagrams
  * consume in the event that some partial datagrams are never completed.
@@ -179,10 +169,9 @@ static int ether1394_header_parse(struct
 static int ether1394_header_cache(struct neighbour *neigh, struct hh_cache *hh);
 static void ether1394_header_cache_update(struct hh_cache *hh,
 					  struct net_device *dev,
-					  unsigned char * haddr);
+					  unsigned char *haddr);
 static int ether1394_mac_addr(struct net_device *dev, void *p);
 
-static void purge_partial_datagram(struct list_head *old);
 static int ether1394_tx(struct sk_buff *skb, struct net_device *dev);
 static void ether1394_iso(struct hpsb_iso *iso);
 
@@ -190,9 +179,9 @@ static struct ethtool_ops ethtool_ops;
 
 static int ether1394_write(struct hpsb_host *host, int srcid, int destid,
 			   quadlet_t *data, u64 addr, size_t len, u16 flags);
-static void ether1394_add_host (struct hpsb_host *host);
-static void ether1394_remove_host (struct hpsb_host *host);
-static void ether1394_host_reset (struct hpsb_host *host);
+static void ether1394_add_host(struct hpsb_host *host);
+static void ether1394_remove_host(struct hpsb_host *host);
+static void ether1394_host_reset(struct hpsb_host *host);
 
 /* Function for incoming 1394 packets */
 static struct hpsb_address_ops addr_ops = {
@@ -207,13 +196,17 @@ static struct hpsb_highlevel eth1394_hig
 	.host_reset =	ether1394_host_reset,
 };
 
-
 static int ether1394_recv_init(struct net_device *dev)
 {
 	struct eth1394_priv *priv = netdev_priv(dev);
+	unsigned int iso_buf_size;
+
+	/* FIXME: rawiso limits us to PAGE_SIZE */
+	iso_buf_size = min((unsigned int)PAGE_SIZE,
+			   2 * (1U << (priv->host->csr.max_rec + 1)));
 
 	priv->iso = hpsb_iso_recv_init(priv->host,
-				       ETHER1394_ISO_BUF_SIZE,
+				       ETHER1394_GASP_BUFFERS * iso_buf_size,
 				       ETHER1394_GASP_BUFFERS,
 				       priv->broadcast_channel,
 				       HPSB_ISO_DMA_PACKET_PER_BUFFER,
@@ -239,64 +232,66 @@ static int ether1394_open(struct net_dev
 	struct eth1394_priv *priv = netdev_priv(dev);
 	int ret;
 
-	/* Something bad happened, don't even try */
 	if (priv->bc_state == ETHER1394_BC_ERROR) {
-		/* we'll try again */
 		ret = ether1394_recv_init(dev);
 		if (ret)
 			return ret;
 	}
-
-	netif_start_queue (dev);
+	netif_start_queue(dev);
 	return 0;
 }
 
 /* This is called after an "ifdown" */
-static int ether1394_stop (struct net_device *dev)
+static int ether1394_stop(struct net_device *dev)
 {
-	netif_stop_queue (dev);
+	netif_stop_queue(dev);
 	return 0;
 }
 
 /* Return statistics to the caller */
-static struct net_device_stats *ether1394_stats (struct net_device *dev)
+static struct net_device_stats *ether1394_stats(struct net_device *dev)
 {
 	return &(((struct eth1394_priv *)netdev_priv(dev))->stats);
 }
 
-/* What to do if we timeout. I think a host reset is probably in order, so
- * that's what we do. Should we increment the stat counters too?  */
-static void ether1394_tx_timeout (struct net_device *dev)
-{
-	ETH1394_PRINT (KERN_ERR, dev->name, "Timeout, resetting host %s\n",
-		       ((struct eth1394_priv *)netdev_priv(dev))->host->driver->name);
-
-	highlevel_host_reset (((struct eth1394_priv *)netdev_priv(dev))->host);
-
-	netif_wake_queue (dev);
+/* FIXME: What to do if we timeout? I think a host reset is probably in order,
+ * so that's what we do. Should we increment the stat counters too?  */
+static void ether1394_tx_timeout(struct net_device *dev)
+{
+	struct hpsb_host *host =
+			((struct eth1394_priv *)netdev_priv(dev))->host;
+
+	ETH1394_PRINT(KERN_ERR, dev->name, "Timeout, resetting host %s\n",
+		      host->driver->name);
+	highlevel_host_reset(host);
+	netif_wake_queue(dev);
 }
 
 static int ether1394_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct eth1394_priv *priv = netdev_priv(dev);
+	int max_rec =
+		((struct eth1394_priv *)netdev_priv(dev))->host->csr.max_rec;
 
-	if ((new_mtu < 68) ||
-	    (new_mtu > min(ETH1394_DATA_LEN,
-			   (int)((1 << (priv->host->csr.max_rec + 1)) -
-				 (sizeof(union eth1394_hdr) +
-				  ETHER1394_GASP_OVERHEAD)))))
+	if (new_mtu < 68 ||
+	    new_mtu > ETH1394_DATA_LEN ||
+	    new_mtu > (1 << (max_rec + 1)) - sizeof(union eth1394_hdr) -
+		      ETHER1394_GASP_OVERHEAD)
 		return -EINVAL;
+
 	dev->mtu = new_mtu;
 	return 0;
 }
 
 static void purge_partial_datagram(struct list_head *old)
 {
-	struct partial_datagram *pd = list_entry(old, struct partial_datagram, list);
+	struct partial_datagram *pd;
 	struct list_head *lh, *n;
+	struct fragment_info *fi;
+
+	pd = list_entry(old, struct partial_datagram, list);
 
 	list_for_each_safe(lh, n, &pd->frag_info) {
-		struct fragment_info *fi = list_entry(lh, struct fragment_info, list);
+		fi = list_entry(lh, struct fragment_info, list);
 		list_del(lh);
 		kfree(fi);
 	}
@@ -337,10 +332,10 @@ static struct eth1394_node_ref *eth1394_
 							 nodeid_t nodeid)
 {
 	struct eth1394_node_ref *node;
-	list_for_each_entry(node, inl, list) {
+
+	list_for_each_entry(node, inl, list)
 		if (node->ud->ne->nodeid == nodeid)
 			return node;
-	}
 
 	return NULL;
 }
@@ -403,24 +398,23 @@ static int eth1394_remove(struct device 
 	priv = netdev_priv(hi->dev);
 
 	old_node = eth1394_find_node(&priv->ip_node_list, ud);
+	if (!old_node)
+		return 0;
 
-	if (old_node) {
-		list_del(&old_node->list);
-		kfree(old_node);
+	list_del(&old_node->list);
+	kfree(old_node);
 
-		node_info = (struct eth1394_node_info*)ud->device.driver_data;
+	node_info = (struct eth1394_node_info*)ud->device.driver_data;
 
-		spin_lock_irqsave(&node_info->pdg.lock, flags);
-		/* The partial datagram list should be empty, but we'll just
-		 * make sure anyway... */
-		list_for_each_safe(lh, n, &node_info->pdg.list) {
-			purge_partial_datagram(lh);
-		}
-		spin_unlock_irqrestore(&node_info->pdg.lock, flags);
+	spin_lock_irqsave(&node_info->pdg.lock, flags);
+	/* The partial datagram list should be empty, but we'll just
+	 * make sure anyway... */
+	list_for_each_safe(lh, n, &node_info->pdg.list)
+		purge_partial_datagram(lh);
+	spin_unlock_irqrestore(&node_info->pdg.lock, flags);
 
-		kfree(node_info);
-		ud->device.driver_data = NULL;
-	}
+	kfree(node_info);
+	ud->device.driver_data = NULL;
 	return 0;
 }
 
@@ -438,35 +432,33 @@ static int eth1394_update(struct unit_di
 	priv = netdev_priv(hi->dev);
 
 	node = eth1394_find_node(&priv->ip_node_list, ud);
+	if (node)
+		return 0;
 
-	if (!node) {
-		node = kmalloc(sizeof(*node),
-			       in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
-		if (!node)
-			return -ENOMEM;
-
-		node_info = kmalloc(sizeof(*node_info),
-				    in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
-		if (!node_info) {
-			kfree(node);
-			return -ENOMEM;
-		}
+	node = kmalloc(sizeof(*node),
+		       in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
+	if (!node)
+		return -ENOMEM;
 
-		spin_lock_init(&node_info->pdg.lock);
-		INIT_LIST_HEAD(&node_info->pdg.list);
-		node_info->pdg.sz = 0;
+	node_info = kmalloc(sizeof(*node_info),
+			    in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
+	if (!node_info) {
+		kfree(node);
+		return -ENOMEM;
+	}
 
-		ud->device.driver_data = node_info;
-		node->ud = ud;
+	spin_lock_init(&node_info->pdg.lock);
+	INIT_LIST_HEAD(&node_info->pdg.list);
+	node_info->pdg.sz = 0;
 
-		priv = netdev_priv(hi->dev);
-		list_add_tail(&node->list, &priv->ip_node_list);
-	}
+	ud->device.driver_data = node_info;
+	node->ud = ud;
 
+	priv = netdev_priv(hi->dev);
+	list_add_tail(&node->list, &priv->ip_node_list);
 	return 0;
 }
 
-
 static struct ieee1394_device_id eth1394_id_table[] = {
 	{
 		.match_flags = (IEEE1394_MATCH_SPECIFIER_ID |
@@ -480,7 +472,7 @@ static struct ieee1394_device_id eth1394
 MODULE_DEVICE_TABLE(ieee1394, eth1394_id_table);
 
 static struct hpsb_protocol_driver eth1394_proto_driver = {
-	.name		= ETH1394_DRIVER_NAME,
+	.name		= driver_name,
 	.id_table	= eth1394_id_table,
 	.update		= eth1394_update,
 	.driver		= {
@@ -489,18 +481,16 @@ static struct hpsb_protocol_driver eth13
 	},
 };
 
-
-static void ether1394_reset_priv (struct net_device *dev, int set_mtu)
+static void ether1394_reset_priv(struct net_device *dev, int set_mtu)
 {
 	unsigned long flags;
 	int i;
 	struct eth1394_priv *priv = netdev_priv(dev);
 	struct hpsb_host *host = priv->host;
-	u64 guid = get_unaligned((u64*)&(host->csr.rom->bus_info_data[3]));
-	u16 maxpayload = 1 << (host->csr.max_rec + 1);
+	u64 guid = get_unaligned((u64 *)&(host->csr.rom->bus_info_data[3]));
 	int max_speed = IEEE1394_SPEED_MAX;
 
-	spin_lock_irqsave (&priv->lock, flags);
+	spin_lock_irqsave(&priv->lock, flags);
 
 	memset(priv->ud_list, 0, sizeof(struct node_entry*) * ALL_NODES);
 	priv->bc_maxpayload = 512;
@@ -511,23 +501,24 @@ static void ether1394_reset_priv (struct
 			max_speed = host->speed[i];
 	priv->bc_sspd = max_speed;
 
-	/* We'll use our maxpayload as the default mtu */
+	/* We'll use our maximum payload as the default MTU */
 	if (set_mtu) {
+		int max_payload = 1 << (host->csr.max_rec + 1);
+
 		dev->mtu = min(ETH1394_DATA_LEN,
-			       (int)(maxpayload -
-				     (sizeof(union eth1394_hdr) +
-				      ETHER1394_GASP_OVERHEAD)));
+			       (int)(max_payload - sizeof(union eth1394_hdr) -
+				     ETHER1394_GASP_OVERHEAD));
 
 		/* Set our hardware address while we're at it */
 		memcpy(dev->dev_addr, &guid, sizeof(u64));
 		memset(dev->broadcast, 0xff, sizeof(u64));
 	}
 
-	spin_unlock_irqrestore (&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
 /* This function is called right before register_netdev */
-static void ether1394_init_dev (struct net_device *dev)
+static void ether1394_init_dev(struct net_device *dev)
 {
 	/* Our functions */
 	dev->open		= ether1394_open;
@@ -553,7 +544,7 @@ static void ether1394_init_dev (struct n
 	dev->hard_header_len 	= ETH1394_HLEN;
 	dev->type		= ARPHRD_IEEE1394;
 
-	ether1394_reset_priv (dev, 1);
+	ether1394_reset_priv(dev, 1);
 }
 
 /*
@@ -561,7 +552,7 @@ static void ether1394_init_dev (struct n
  * when the module is installed. This is where we add all of our ethernet
  * devices. One for each host.
  */
-static void ether1394_add_host (struct hpsb_host *host)
+static void ether1394_add_host(struct hpsb_host *host)
 {
 	struct eth1394_host_info *hi = NULL;
 	struct net_device *dev = NULL;
@@ -593,7 +584,7 @@ static void ether1394_add_host (struct h
 				 "etherdevice for IEEE 1394 device %s-%d\n",
 				 host->driver->name, host->id);
 		goto out;
-        }
+	}
 
 	SET_MODULE_OWNER(dev);
 #if 0
@@ -616,7 +607,7 @@ static void ether1394_add_host (struct h
 				 "hostinfo for IEEE 1394 device %s-%d\n",
 				 host->driver->name, host->id);
 		goto out;
-        }
+	}
 
 	ether1394_init_dev(dev);
 
@@ -647,7 +638,7 @@ out:
 }
 
 /* Remove a card from our list */
-static void ether1394_remove_host (struct hpsb_host *host)
+static void ether1394_remove_host(struct hpsb_host *host)
 {
 	struct eth1394_host_info *hi;
 	struct eth1394_priv *priv;
@@ -664,8 +655,8 @@ static void ether1394_remove_host (struc
 	free_netdev(hi->dev);
 }
 
-/* A reset has just arisen */
-static void ether1394_host_reset (struct hpsb_host *host)
+/* A bus reset happened */
+static void ether1394_host_reset(struct hpsb_host *host)
 {
 	struct eth1394_host_info *hi;
 	struct eth1394_priv *priv;
@@ -682,20 +673,19 @@ static void ether1394_host_reset (struct
 		return;
 
 	dev = hi->dev;
-	priv = (struct eth1394_priv *)netdev_priv(dev);
+	priv = netdev_priv(dev);
 
-	/* Reset our private host data, but not our mtu */
-	netif_stop_queue (dev);
-	ether1394_reset_priv (dev, 0);
+	/* Reset our private host data, but not our MTU */
+	netif_stop_queue(dev);
+	ether1394_reset_priv(dev, 0);
 
 	list_for_each_entry(node, &priv->ip_node_list, list) {
-		node_info = (struct eth1394_node_info*)node->ud->device.driver_data;
+		node_info = node->ud->device.driver_data;
 
 		spin_lock_irqsave(&node_info->pdg.lock, flags);
 
-		list_for_each_safe(lh, n, &node_info->pdg.list) {
+		list_for_each_safe(lh, n, &node_info->pdg.list)
 			purge_partial_datagram(lh);
-		}
 
 		INIT_LIST_HEAD(&(node_info->pdg.list));
 		node_info->pdg.sz = 0;
@@ -703,7 +693,7 @@ static void ether1394_host_reset (struct
 		spin_unlock_irqrestore(&node_info->pdg.lock, flags);
 	}
 
-	netif_wake_queue (dev);
+	netif_wake_queue(dev);
 }
 
 /******************************************
@@ -711,7 +701,6 @@ static void ether1394_host_reset (struct
  ******************************************/
 /* These functions have been adapted from net/ethernet/eth.c */
 
-
 /* Create a fake MAC header for an arbitrary protocol layer.
  * saddr=NULL means use device source address
  * daddr=NULL means leave destination address (eg unresolved arp). */
@@ -719,25 +708,24 @@ static int ether1394_header(struct sk_bu
 			    unsigned short type, void *daddr, void *saddr,
 			    unsigned len)
 {
-	struct eth1394hdr *eth = (struct eth1394hdr *)skb_push(skb, ETH1394_HLEN);
+	struct eth1394hdr *eth =
+			(struct eth1394hdr *)skb_push(skb, ETH1394_HLEN);
 
 	eth->h_proto = htons(type);
 
-	if (dev->flags & (IFF_LOOPBACK|IFF_NOARP)) {
+	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
 		memset(eth->h_dest, 0, dev->addr_len);
-		return(dev->hard_header_len);
+		return dev->hard_header_len;
 	}
 
 	if (daddr) {
-		memcpy(eth->h_dest,daddr,dev->addr_len);
+		memcpy(eth->h_dest, daddr, dev->addr_len);
 		return dev->hard_header_len;
 	}
 
 	return -dev->hard_header_len;
-
 }
 
-
 /* Rebuild the faked MAC header. This is called after an ARP
  * (or in future other address resolution) has completed on this
  * sk_buff. We now let ARP fill in the other fields.
@@ -754,7 +742,7 @@ static int ether1394_rebuild_header(stru
 
 #ifdef CONFIG_INET
 	case __constant_htons(ETH_P_IP):
- 		return arp_find((unsigned char*)&eth->h_dest, skb);
+ 		return arp_find((unsigned char *)&eth->h_dest, skb);
 #endif
 	default:
 		ETH1394_PRINT(KERN_DEBUG, dev->name,
@@ -769,17 +757,17 @@ static int ether1394_rebuild_header(stru
 static int ether1394_header_parse(struct sk_buff *skb, unsigned char *haddr)
 {
 	struct net_device *dev = skb->dev;
+
 	memcpy(haddr, dev->dev_addr, ETH1394_ALEN);
 	return ETH1394_ALEN;
 }
 
-
 static int ether1394_header_cache(struct neighbour *neigh, struct hh_cache *hh)
 {
 	unsigned short type = hh->hh_type;
-	struct eth1394hdr *eth = (struct eth1394hdr*)(((u8*)hh->hh_data) +
-						      (16 - ETH1394_HLEN));
 	struct net_device *dev = neigh->dev;
+	struct eth1394hdr *eth =
+		(struct eth1394hdr *)((u8 *)hh->hh_data + 16 - ETH1394_HLEN);
 
 	if (type == htons(ETH_P_802_3))
 		return -1;
@@ -796,7 +784,7 @@ static void ether1394_header_cache_updat
 					  struct net_device *dev,
 					  unsigned char * haddr)
 {
-	memcpy(((u8*)hh->hh_data) + (16 - ETH1394_HLEN), haddr, dev->addr_len);
+	memcpy((u8 *)hh->hh_data + 16 - ETH1394_HLEN, haddr, dev->addr_len);
 }
 
 static int ether1394_mac_addr(struct net_device *dev, void *p)
@@ -807,9 +795,7 @@ static int ether1394_mac_addr(struct net
 	/* Not going to allow setting the MAC address, we really need to use
 	 * the real one supplied by the hardware */
 	 return -EINVAL;
- }
-
-
+}
 
 /******************************************
  * Datagram reception code
@@ -822,11 +808,11 @@ static u16 ether1394_type_trans(struct s
 	unsigned char *rawp;
 
 	skb->mac.raw = skb->data;
-	skb_pull (skb, ETH1394_HLEN);
+	skb_pull(skb, ETH1394_HLEN);
 	eth = eth1394_hdr(skb);
 
 	if (*eth->h_dest & 1) {
-		if (memcmp(eth->h_dest, dev->broadcast, dev->addr_len)==0)
+		if (memcmp(eth->h_dest, dev->broadcast, dev->addr_len) == 0)
 			skb->pkt_type = PACKET_BROADCAST;
 #if 0
 		else
@@ -835,17 +821,17 @@ static u16 ether1394_type_trans(struct s
 	} else {
 		if (memcmp(eth->h_dest, dev->dev_addr, dev->addr_len))
 			skb->pkt_type = PACKET_OTHERHOST;
-        }
+	}
 
-	if (ntohs (eth->h_proto) >= 1536)
+	if (ntohs(eth->h_proto) >= 1536)
 		return eth->h_proto;
 
 	rawp = skb->data;
 
-        if (*(unsigned short *)rawp == 0xFFFF)
-		return htons (ETH_P_802_3);
+	if (*(unsigned short *)rawp == 0xFFFF)
+		return htons(ETH_P_802_3);
 
-        return htons (ETH_P_802_2);
+	return htons(ETH_P_802_2);
 }
 
 /* Parse an encapsulated IP1394 header into an ethernet frame packet.
@@ -858,23 +844,22 @@ static u16 ether1394_parse_encap(struct 
 	u64 dest_hw;
 	unsigned short ret = 0;
 
-	/* Setup our hw addresses. We use these to build the
-	 * ethernet header.  */
+	/* Setup our hw addresses. We use these to build the ethernet header. */
 	if (destid == (LOCAL_BUS | ALL_NODES))
 		dest_hw = ~0ULL;  /* broadcast */
 	else
-		dest_hw = cpu_to_be64((((u64)priv->host->csr.guid_hi) << 32) |
+		dest_hw = cpu_to_be64((u64)priv->host->csr.guid_hi << 32 |
 				      priv->host->csr.guid_lo);
 
 	/* If this is an ARP packet, convert it. First, we want to make
 	 * use of some of the fields, since they tell us a little bit
 	 * about the sending machine.  */
 	if (ether_type == htons(ETH_P_ARP)) {
-		struct eth1394_arp *arp1394 = (struct eth1394_arp*)skb->data;
+		struct eth1394_arp *arp1394 = (struct eth1394_arp *)skb->data;
 		struct arphdr *arp = (struct arphdr *)skb->data;
 		unsigned char *arp_ptr = (unsigned char *)(arp + 1);
 		u64 fifo_addr = (u64)ntohs(arp1394->fifo_hi) << 32 |
-			ntohl(arp1394->fifo_lo);
+					   ntohl(arp1394->fifo_lo);
 		u8 max_rec = min(priv->host->csr.max_rec,
 				 (u8)(arp1394->max_rec));
 		int sspd = arp1394->sspd;
@@ -888,16 +873,17 @@ static u16 ether1394_parse_encap(struct 
 		if (sspd > 5 || sspd < 0)
 			sspd = 0;
 
-		maxpayload = min(eth1394_speedto_maxpayload[sspd], (u16)(1 << (max_rec + 1)));
+		maxpayload = min(eth1394_speedto_maxpayload[sspd],
+				 (u16)(1 << (max_rec + 1)));
 
 		guid = get_unaligned(&arp1394->s_uniq_id);
 		node = eth1394_find_node_guid(&priv->ip_node_list,
 					      be64_to_cpu(guid));
-		if (!node) {
+		if (!node)
 			return 0;
-		}
 
-		node_info = (struct eth1394_node_info*)node->ud->device.driver_data;
+		node_info =
+		    (struct eth1394_node_info *)node->ud->device.driver_data;
 
 		/* Update our speed/payload/fifo_offset table */
 		node_info->maxpayload =	maxpayload;
@@ -916,7 +902,7 @@ static u16 ether1394_parse_encap(struct 
 
 		arp->ar_hln = 8;
 		arp_ptr += arp->ar_hln;		/* skip over sender unique id */
-		*(u32*)arp_ptr = arp1394->sip;	/* move sender IP addr */
+		*(u32 *)arp_ptr = arp1394->sip;	/* move sender IP addr */
 		arp_ptr += arp->ar_pln;		/* skip over sender IP addr */
 
 		if (arp->ar_op == htons(ARPOP_REQUEST))
@@ -949,10 +935,10 @@ static struct list_head *find_partial_da
 {
 	struct partial_datagram *pd;
 
-	list_for_each_entry(pd, pdgl, list) {
+	list_for_each_entry(pd, pdgl, list)
 		if (pd->dgl == dgl)
 			return &pd->list;
-	}
+
 	return NULL;
 }
 
@@ -964,34 +950,34 @@ static int new_fragment(struct list_head
 
 	list_for_each(lh, frag_info) {
 		fi = list_entry(lh, struct fragment_info, list);
-		if ((fi->offset + fi->len) == offset) {
+		if (fi->offset + fi->len == offset) {
 			/* The new fragment can be tacked on to the end */
 			fi->len += len;
 			/* Did the new fragment plug a hole? */
 			fi2 = list_entry(lh->next, struct fragment_info, list);
-			if ((fi->offset + fi->len) == fi2->offset) {
+			if (fi->offset + fi->len == fi2->offset) {
 				/* glue fragments together */
 				fi->len += fi2->len;
 				list_del(lh->next);
 				kfree(fi2);
 			}
 			return 0;
-		} else if ((offset + len) == fi->offset) {
+		} else if (offset + len == fi->offset) {
 			/* The new fragment can be tacked on to the beginning */
 			fi->offset = offset;
 			fi->len += len;
 			/* Did the new fragment plug a hole? */
 			fi2 = list_entry(lh->prev, struct fragment_info, list);
-			if ((fi2->offset + fi2->len) == fi->offset) {
+			if (fi2->offset + fi2->len == fi->offset) {
 				/* glue fragments together */
 				fi2->len += fi->len;
 				list_del(lh);
 				kfree(fi);
 			}
 			return 0;
-		} else if (offset > (fi->offset + fi->len)) {
+		} else if (offset > fi->offset + fi->len) {
 			break;
-		} else if ((offset + len) < fi->offset) {
+		} else if (offset + len < fi->offset) {
 			lh = lh->prev;
 			break;
 		}
@@ -1005,7 +991,6 @@ static int new_fragment(struct list_head
 	new->len = len;
 
 	list_add(&new->list, lh);
-
 	return 0;
 }
 
@@ -1044,25 +1029,23 @@ static int new_partial_datagram(struct n
 	memcpy(new->pbuf + frag_off, frag_buf, frag_len);
 
 	list_add(&new->list, pdgl);
-
 	return 0;
 }
 
 static int update_partial_datagram(struct list_head *pdgl, struct list_head *lh,
 				   char *frag_buf, int frag_off, int frag_len)
 {
-	struct partial_datagram *pd = list_entry(lh, struct partial_datagram, list);
+	struct partial_datagram *pd =
+			list_entry(lh, struct partial_datagram, list);
 
-	if (new_fragment(&pd->frag_info, frag_off, frag_len) < 0) {
+	if (new_fragment(&pd->frag_info, frag_off, frag_len) < 0)
 		return -ENOMEM;
-	}
 
 	memcpy(pd->pbuf + frag_off, frag_buf, frag_len);
 
 	/* Move list entry to beginnig of list so that oldest partial
 	 * datagrams percolate to the end of the list */
 	list_move(lh, pdgl);
-
 	return 0;
 }
 
@@ -1107,7 +1090,7 @@ static int ether1394_data_handler(struct
 		priv->ud_list[NODEID_TO_NODE(srcid)] = ud;
 	}
 
-	node_info = (struct eth1394_node_info*)ud->device.driver_data;
+	node_info = (struct eth1394_node_info *)ud->device.driver_data;
 
 	/* First, did we receive a fragmented or unfragmented datagram? */
 	hdr->words.word1 = ntohs(hdr->words.word1);
@@ -1126,7 +1109,8 @@ static int ether1394_data_handler(struct
 			return -1;
 		}
 		skb_reserve(skb, (dev->hard_header_len + 15) & ~15);
-		memcpy(skb_put(skb, len - hdr_len), buf + hdr_len, len - hdr_len);
+		memcpy(skb_put(skb, len - hdr_len), buf + hdr_len,
+		       len - hdr_len);
 		ether_type = hdr->uf.ether_type;
 	} else {
 		/* A datagram fragment has been received, now the fun begins. */
@@ -1211,9 +1195,8 @@ static int ether1394_data_handler(struct
 
 		pd = list_entry(lh, struct partial_datagram, list);
 
-		if (hdr->common.lf == ETH1394_HDR_LF_FF) {
+		if (hdr->common.lf == ETH1394_HDR_LF_FF)
 			pd->ether_type = ether_type;
-		}
 
 		if (is_datagram_complete(lh, dg_size)) {
 			ether_type = pd->ether_type;
@@ -1240,8 +1223,8 @@ static int ether1394_data_handler(struct
 	skb->protocol = ether1394_parse_encap(skb, dev, srcid, destid,
 					      ether_type);
 
-
 	spin_lock_irqsave(&priv->lock, flags);
+
 	if (!skb->protocol) {
 		priv->stats.rx_errors++;
 		priv->stats.rx_dropped++;
@@ -1313,20 +1296,20 @@ static void ether1394_iso(struct hpsb_is
 	for (i = 0; i < nready; i++) {
 		struct hpsb_iso_packet_info *info =
 			&iso->infos[(iso->first_packet + i) % iso->buf_packets];
-		data = (quadlet_t*) (iso->data_buf.kvirt + info->offset);
+		data = (quadlet_t *)(iso->data_buf.kvirt + info->offset);
 
 		/* skip over GASP header */
 		buf = (char *)data + 8;
 		len = info->len - 8;
 
-		specifier_id = (((be32_to_cpu(data[0]) & 0xffff) << 8) |
-				((be32_to_cpu(data[1]) & 0xff000000) >> 24));
+		specifier_id = (be32_to_cpu(data[0]) & 0xffff) << 8 |
+			       (be32_to_cpu(data[1]) & 0xff000000) >> 24;
 		source_id = be32_to_cpu(data[0]) >> 16;
 
 		priv = netdev_priv(dev);
 
-		if (info->channel != (iso->host->csr.broadcast_channel & 0x3f) ||
-		   specifier_id != ETHER1394_GASP_SPECIFIER_ID) {
+		if (info->channel != (iso->host->csr.broadcast_channel & 0x3f)
+		    || specifier_id != ETHER1394_GASP_SPECIFIER_ID) {
 			/* This packet is not for us */
 			continue;
 		}
@@ -1358,21 +1341,16 @@ static void ether1394_arp_to_1394arp(str
 				     struct net_device *dev)
 {
 	struct eth1394_priv *priv = netdev_priv(dev);
-
 	struct arphdr *arp = (struct arphdr *)skb->data;
 	unsigned char *arp_ptr = (unsigned char *)(arp + 1);
 	struct eth1394_arp *arp1394 = (struct eth1394_arp *)skb->data;
 
-	/* Believe it or not, all that need to happen is sender IP get moved
-	 * and set hw_addr_len, max_rec, sspd, fifo_hi and fifo_lo.  */
 	arp1394->hw_addr_len	= 16;
 	arp1394->sip		= *(u32*)(arp_ptr + ETH1394_ALEN);
 	arp1394->max_rec	= priv->host->csr.max_rec;
 	arp1394->sspd		= priv->host->csr.lnk_spd;
-	arp1394->fifo_hi	= htons (priv->local_fifo >> 32);
-	arp1394->fifo_lo	= htonl (priv->local_fifo & ~0x0);
-
-	return;
+	arp1394->fifo_hi	= htons(priv->local_fifo >> 32);
+	arp1394->fifo_lo	= htonl(priv->local_fifo & ~0x0);
 }
 
 /* We need to encapsulate the standard header with our own. We use the
@@ -1382,7 +1360,8 @@ static unsigned int ether1394_encapsulat
 					       union eth1394_hdr *hdr,
 					       u16 dg_size, u16 dgl)
 {
-	unsigned int adj_max_payload = max_payload - hdr_type_len[ETH1394_HDR_LF_UF];
+	unsigned int adj_max_payload =
+				max_payload - hdr_type_len[ETH1394_HDR_LF_UF];
 
 	/* Does it all fit in one packet? */
 	if (dg_size <= adj_max_payload) {
@@ -1395,7 +1374,7 @@ static unsigned int ether1394_encapsulat
 		hdr->ff.dgl = dgl;
 		adj_max_payload = max_payload - hdr_type_len[ETH1394_HDR_LF_FF];
 	}
-	return((dg_size + (adj_max_payload - 1)) / adj_max_payload);
+	return (dg_size + adj_max_payload - 1) / adj_max_payload;
 }
 
 static unsigned int ether1394_encapsulate(struct sk_buff *skb,
@@ -1407,7 +1386,7 @@ static unsigned int ether1394_encapsulat
 	int hdrsz = hdr_type_len[ftype];
 	unsigned int adj_max_payload = max_payload - hdrsz;
 
-	switch(ftype) {
+	switch (ftype) {
 	case ETH1394_HDR_LF_UF:
 		bufhdr = (union eth1394_hdr *)skb_push(skb, hdrsz);
 		bufhdr->words.word1 = htons(hdr->words.word1);
@@ -1436,7 +1415,6 @@ static unsigned int ether1394_encapsulat
 		bufhdr->words.word3 = htons(hdr->words.word3);
 		bufhdr->words.word4 = 0;
 	}
-
 	return min(max_payload, skb->len);
 }
 
@@ -1455,13 +1433,13 @@ static struct hpsb_packet *ether1394_all
 
 static int ether1394_prep_write_packet(struct hpsb_packet *p,
 				       struct hpsb_host *host, nodeid_t node,
-				       u64 addr, void * data, int tx_len)
+				       u64 addr, void *data, int tx_len)
 {
 	p->node_id = node;
 	p->data = NULL;
 
 	p->tcode = TCODE_WRITEB;
-	p->header[1] = (host->node_id << 16) | (addr >> 32);
+	p->header[1] = host->node_id << 16 | addr >> 32;
 	p->header[2] = addr & 0xffffffff;
 
 	p->header_size = 16;
@@ -1472,12 +1450,12 @@ static int ether1394_prep_write_packet(s
 				"to node " NODE_BUS_FMT "\n", NODE_BUS_ARGS(host, node));
 		return -1;
 	}
-	p->header[0] = (p->node_id << 16) | (p->tlabel << 10)
-		| (1 << 8) | (TCODE_WRITEB << 4);
+	p->header[0] =
+		p->node_id << 16 | p->tlabel << 10 | 1 << 8 | TCODE_WRITEB << 4;
 
 	p->header[3] = tx_len << 16;
 	p->data_size = (tx_len + 3) & ~3;
-	p->data = (quadlet_t*)data;
+	p->data = data;
 
 	return 0;
 }
@@ -1489,14 +1467,13 @@ static void ether1394_prep_gasp_packet(s
 	p->header_size = 4;
 	p->tcode = TCODE_STREAM_DATA;
 
-	p->header[0] = (length << 16) | (3 << 14)
-		| ((priv->broadcast_channel) << 8)
-		| (TCODE_STREAM_DATA << 4);
+	p->header[0] = length << 16 | 3 << 14 | priv->broadcast_channel << 8 |
+		       TCODE_STREAM_DATA << 4;
 	p->data_size = length;
-	p->data = ((quadlet_t*)skb->data) - 2;
-	p->data[0] = cpu_to_be32((priv->host->node_id << 16) |
+	p->data = (quadlet_t *)skb->data - 2;
+	p->data[0] = cpu_to_be32(priv->host->node_id << 16 |
 				 ETHER1394_GASP_SPECIFIER_ID_HI);
-	p->data[1] = cpu_to_be32((ETHER1394_GASP_SPECIFIER_ID_LO << 24) |
+	p->data[1] = cpu_to_be32(ETHER1394_GASP_SPECIFIER_ID_LO << 24 |
 				 ETHER1394_GASP_VERSION);
 
 	/* Setting the node id to ALL_NODES (not LOCAL_BUS | ALL_NODES)
@@ -1525,7 +1502,7 @@ static int ether1394_send_packet(struct 
 		return -1;
 
 	if (ptask->tx_type == ETH1394_GASP) {
-		int length = tx_len + (2 * sizeof(quadlet_t));
+		int length = tx_len + 2 * sizeof(quadlet_t);
 
 		ether1394_prep_gasp_packet(packet, priv, ptask->skb, length);
 	} else if (ether1394_prep_write_packet(packet, priv->host,
@@ -1548,13 +1525,11 @@ static int ether1394_send_packet(struct 
 	return 0;
 }
 
-
 /* Task function to be run when a datagram transmission is completed */
 static void ether1394_dg_complete(struct packet_task *ptask, int fail)
 {
 	struct sk_buff *skb = ptask->skb;
-	struct net_device *dev = skb->dev;
-	struct eth1394_priv *priv = netdev_priv(dev);
+	struct eth1394_priv *priv = netdev_priv(skb->dev);
 	unsigned long flags;
 
 	/* Statistics */
@@ -1572,7 +1547,6 @@ static void ether1394_dg_complete(struct
 	kmem_cache_free(packet_task_cache, ptask);
 }
 
-
 /* Callback for when a packet has been sent and the status of that packet is
  * known */
 static void ether1394_complete_cb(void *__ptask)
@@ -1600,10 +1574,8 @@ static void ether1394_complete_cb(void *
 	}
 }
 
-
-
 /* Transmit a packet (called by kernel) */
-static int ether1394_tx (struct sk_buff *skb, struct net_device *dev)
+static int ether1394_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	gfp_t kmflags = in_interrupt() ? GFP_ATOMIC : GFP_KERNEL;
 	struct eth1394hdr *eth;
@@ -1637,13 +1609,14 @@ static int ether1394_tx (struct sk_buff 
 	}
 #endif
 
-	if ((skb = skb_share_check (skb, kmflags)) == NULL) {
+	skb = skb_share_check(skb, kmflags);
+	if (!skb) {
 		ret = -ENOMEM;
 		goto fail;
 	}
 
 	/* Get rid of the fake eth1394 header, but save a pointer */
-	eth = (struct eth1394hdr*)skb->data;
+	eth = (struct eth1394hdr *)skb->data;
 	skb_pull(skb, ETH1394_HLEN);
 
 	proto = eth->h_proto;
@@ -1658,7 +1631,7 @@ static int ether1394_tx (struct sk_buff 
 		tx_type = ETH1394_GASP;
 		dest_node = LOCAL_BUS | ALL_NODES;
 		max_payload = priv->bc_maxpayload - ETHER1394_GASP_OVERHEAD;
-		BUG_ON(max_payload < (512 - ETHER1394_GASP_OVERHEAD));
+		BUG_ON(max_payload < 512 - ETHER1394_GASP_OVERHEAD);
 		dgl = priv->bc_dgl;
 		if (max_payload < dg_size + hdr_type_len[ETH1394_HDR_LF_UF])
 			priv->bc_dgl++;
@@ -1671,7 +1644,8 @@ static int ether1394_tx (struct sk_buff 
 			ret = -EAGAIN;
 			goto fail;
 		}
-		node_info = (struct eth1394_node_info*)node->ud->device.driver_data;
+		node_info =
+		    (struct eth1394_node_info *)node->ud->device.driver_data;
 		if (node_info->fifo == CSR1212_INVALID_ADDR_SPACE) {
 			ret = -EAGAIN;
 			goto fail;
@@ -1679,7 +1653,7 @@ static int ether1394_tx (struct sk_buff 
 
 		dest_node = node->ud->ne->nodeid;
 		max_payload = node_info->maxpayload;
-		BUG_ON(max_payload < (512 - ETHER1394_GASP_OVERHEAD));
+		BUG_ON(max_payload < 512 - ETHER1394_GASP_OVERHEAD);
 
 		dgl = node_info->dgl;
 		if (max_payload < dg_size + hdr_type_len[ETH1394_HDR_LF_UF])
@@ -1689,7 +1663,7 @@ static int ether1394_tx (struct sk_buff 
 
 	/* If this is an ARP packet, convert it */
 	if (proto == htons(ETH_P_ARP))
-		ether1394_arp_to_1394arp (skb, dev);
+		ether1394_arp_to_1394arp(skb, dev);
 
 	ptask->hdr.words.word1 = 0;
 	ptask->hdr.words.word2 = 0;
@@ -1712,9 +1686,8 @@ static int ether1394_tx (struct sk_buff 
 
 	ptask->tx_type = tx_type;
 	ptask->max_payload = max_payload;
-        ptask->outstanding_pkts = ether1394_encapsulate_prep(max_payload, proto,
-							     &ptask->hdr, dg_size,
-							     dgl);
+	ptask->outstanding_pkts = ether1394_encapsulate_prep(max_payload,
+					proto, &ptask->hdr, dg_size, dgl);
 
 	/* Add the encapsulation header to the fragment */
 	tx_len = ether1394_encapsulate(skb, max_payload, &ptask->hdr);
@@ -1742,11 +1715,11 @@ fail:
 	return 0;  /* returning non-zero causes serious problems */
 }
 
-static void ether1394_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
+static void ether1394_get_drvinfo(struct net_device *dev,
+				  struct ethtool_drvinfo *info)
 {
-	strcpy (info->driver, driver_name);
-	/* FIXME XXX provide sane businfo */
-	strcpy (info->bus_info, "ieee1394");
+	strcpy(info->driver, driver_name);
+	strcpy(info->bus_info, "ieee1394"); /* FIXME provide more detail? */
 }
 
 static struct ethtool_ops ethtool_ops = {
@@ -1755,12 +1728,11 @@ static struct ethtool_ops ethtool_ops = 
 
 static int __init ether1394_init_module (void)
 {
-	packet_task_cache = kmem_cache_create("packet_task", sizeof(struct packet_task),
+	packet_task_cache = kmem_cache_create("packet_task",
+					      sizeof(struct packet_task),
 					      0, 0, NULL, NULL);
 
-	/* Register ourselves as a highlevel driver */
 	hpsb_register_highlevel(&eth1394_highlevel);
-
 	return hpsb_register_protocol(&eth1394_proto_driver);
 }
 
Index: linux/drivers/ieee1394/eth1394.h
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.h
+++ linux/drivers/ieee1394/eth1394.h
@@ -25,6 +25,8 @@
 #define __ETH1394_H
 
 #include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <asm/byteorder.h>
 
 #include "ieee1394.h"
 #include "ieee1394_types.h"
@@ -35,22 +37,15 @@
 
 /* GASP identifier numbers for IPv4 over IEEE 1394 */
 #define ETHER1394_GASP_SPECIFIER_ID	0x00005E
-#define ETHER1394_GASP_SPECIFIER_ID_HI	((ETHER1394_GASP_SPECIFIER_ID >> 8) & 0xffff)
-#define ETHER1394_GASP_SPECIFIER_ID_LO	(ETHER1394_GASP_SPECIFIER_ID & 0xff)
+#define ETHER1394_GASP_SPECIFIER_ID_HI	((0x00005E >> 8) & 0xffff)
+#define ETHER1394_GASP_SPECIFIER_ID_LO	(0x00005E & 0xff)
 #define ETHER1394_GASP_VERSION		1
 
-#define ETHER1394_GASP_OVERHEAD (2 * sizeof(quadlet_t))  /* GASP header overhead */
+#define ETHER1394_GASP_OVERHEAD	(2 * sizeof(quadlet_t))	/* for GASP header */
 
-#define ETHER1394_GASP_BUFFERS 16
+#define ETHER1394_GASP_BUFFERS	16
 
-/* rawiso buffer size - due to a limitation in rawiso, we must limit each
- * GASP buffer to be less than PAGE_SIZE. */
-#define ETHER1394_ISO_BUF_SIZE	ETHER1394_GASP_BUFFERS *                        \
-				   min((unsigned int)PAGE_SIZE,                 \
-				       2 * (1U << (priv->host->csr.max_rec + 1)))
-
-/* Node set == 64 */
-#define NODE_SET			(ALL_NODES + 1)
+#define NODE_SET		(ALL_NODES + 1)		/* Node set == 64 */
 
 enum eth1394_bc_states { ETHER1394_BC_ERROR,
 			 ETHER1394_BC_RUNNING,
@@ -86,19 +81,14 @@ struct eth1394hdr {
 	unsigned short	h_proto;		/* packet type ID field	*/
 }  __attribute__((packed));
 
-#ifdef __KERNEL__
-#include <linux/skbuff.h>
-
 static inline struct eth1394hdr *eth1394_hdr(const struct sk_buff *skb)
 {
 	return (struct eth1394hdr *)skb->mac.raw;
 }
-#endif
 
 typedef enum {ETH1394_GASP, ETH1394_WRREQ} eth1394_tx_type;
 
 /* IP1394 headers */
-#include <asm/byteorder.h>
 
 /* Unfragmented */
 #if defined __BIG_ENDIAN_BITFIELD

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
