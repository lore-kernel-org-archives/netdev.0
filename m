From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-2
Date: Tue, 26 Aug 2008 22:18:18 +0800
Message-ID: <48B410AA.1050002@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58740 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754456AbYHZOUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:20:49 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 66de80b..53a2240 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -466,7 +466,7 @@ static int __devinit acenic_probe_one(struct pci_dev *pdev,
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	ap = dev->priv;
+	ap = netdev_priv(dev);
 	ap->pdev = pdev;
 	ap->name = pci_name(pdev);
 
diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index 1071144..9a0be9b 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -108,7 +108,7 @@ static struct net_device * __init ipddp_init(void)
  */
 static struct net_device_stats *ipddp_get_stats(struct net_device *dev)
 {
-        return dev->priv;
+	return netdev_priv(dev);
 }
 
 /*
@@ -170,8 +170,8 @@ static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
 
         skb->protocol = htons(ETH_P_ATALK);     /* Protocol has changed */
 
-	((struct net_device_stats *) dev->priv)->tx_packets++;
-        ((struct net_device_stats *) dev->priv)->tx_bytes+=skb->len;
+	((struct net_device_stats *) netdev_priv(dev))->tx_packets++;
+	((struct net_device_stats *) netdev_priv(dev))->tx_bytes += skb->len;
 
         if(aarp_send_ddp(rt->dev, skb, &rt->at, NULL) < 0)
                 dev_kfree_skb(skb);
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index fef5560..020e003 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -726,7 +726,8 @@ static int sendup_buffer (struct net_device *dev)
 	int dnode, snode, llaptype, len; 
 	int sklen;
 	struct sk_buff *skb;
-	struct net_device_stats *stats = &((struct ltpc_private *)dev->priv)->stats;
+	struct ltpc_private *ltpc_priv = netdev_priv(dev);
+	struct net_device_stats *stats = &ltpc_priv->stats;
 	struct lt_rcvlap *ltc = (struct lt_rcvlap *) ltdmacbuf;
 
 	if (ltc->command != LT_RCVLAP) {
@@ -823,7 +824,8 @@ static int ltpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct sockaddr_at *sa = (struct sockaddr_at *) &ifr->ifr_addr;
 	/* we'll keep the localtalk node address in dev->pa_addr */
-	struct atalk_addr *aa = &((struct ltpc_private *)dev->priv)->my_addr;
+	struct ltpc_private *ltpc_priv = netdev_priv(dev);
+	struct atalk_addr *aa = &ltpc_priv->my_addr;
 	struct lt_init c;
 	int ltflags;
 
@@ -904,7 +906,8 @@ static int ltpc_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * and skb->len is the length of the ddp data + ddp header
 	 */
 
-	struct net_device_stats *stats = &((struct ltpc_private *)dev->priv)->stats;
+	struct ltpc_private *ltpc_priv = netdev_priv(dev);
+	struct net_device_stats *stats = &ltpc_priv->stats;
 
 	int i;
 	struct lt_sendlap cbuf;
@@ -943,7 +946,8 @@ static int ltpc_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *ltpc_get_stats(struct net_device *dev)
 {
-	struct net_device_stats *stats = &((struct ltpc_private *) dev->priv)->stats;
+	struct ltpc_private *ltpc_priv = netdev_priv(dev);
+	struct net_device_stats *stats = &ltpc_priv->stats;
 	return stats;
 }
 
diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index e0a18e7..909ba77 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -87,7 +87,7 @@ MODULE_LICENSE("GPL");
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	int ofs;
@@ -168,7 +168,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 8c8d6c4..e3082a9 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -194,7 +194,7 @@ static int __init arcrimi_found(struct net_device *dev)
 
 	/* initialize the rest of the device structure. */
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->card_name = "RIM I";
 	lp->hw.command = arcrimi_command;
 	lp->hw.status = arcrimi_status;
@@ -260,7 +260,7 @@ err_free_irq:
  */
 static int arcrimi_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, ASTATUS());
@@ -281,7 +281,7 @@ static int arcrimi_reset(struct net_device *dev, int really_reset)
 
 static void arcrimi_setmask(struct net_device *dev, int mask)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	AINTMASK(mask);
@@ -289,7 +289,7 @@ static void arcrimi_setmask(struct net_device *dev, int mask)
 
 static int arcrimi_status(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	return ASTATUS();
@@ -297,7 +297,7 @@ static int arcrimi_status(struct net_device *dev)
 
 static void arcrimi_command(struct net_device *dev, int cmd)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	ACOMMAND(cmd);
@@ -306,7 +306,7 @@ static void arcrimi_command(struct net_device *dev, int cmd)
 static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
 	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
@@ -315,7 +315,7 @@ static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
 static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
 	TIME("memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
 }
@@ -361,7 +361,7 @@ static int __init arc_rimi_init(void)
 static void __exit arc_rimi_exit(void)
 {
 	struct net_device *dev = my_dev;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	unregister_netdev(dev);
 	iounmap(lp->mem_start);
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index bdc4c0b..d255e03 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -181,7 +181,7 @@ EXPORT_SYMBOL(arcnet_dump_skb);
 static void arcnet_dump_packet(struct net_device *dev, int bufnum,
 			       char *desc, int take_arcnet_lock)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int i, length;
 	unsigned long flags = 0;
 	static uint8_t buf[512];
@@ -247,7 +247,7 @@ void arcnet_unregister_proto(struct ArcProto *proto)
  */
 static void release_arcbuf(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int i;
 
 	lp->buf_queue[lp->first_free_buf++] = bufnum;
@@ -269,7 +269,7 @@ static void release_arcbuf(struct net_device *dev, int bufnum)
  */
 static int get_arcbuf(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int buf = -1, i;
 
 	if (!atomic_dec_and_test(&lp->buf_lock)) {
@@ -357,7 +357,7 @@ struct net_device *alloc_arcdev(char *name)
 	dev = alloc_netdev(sizeof(struct arcnet_local),
 			   name && *name ? name : "arc%d", arcdev_setup);
 	if(dev) {
-		struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+		struct arcnet_local *lp = netdev_priv(dev);
 		spin_lock_init(&lp->lock);
 	}
 
@@ -374,7 +374,7 @@ struct net_device *alloc_arcdev(char *name)
  */
 static int arcnet_open(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int count, newmtu, error;
 
 	BUGMSG(D_INIT,"opened.");
@@ -474,7 +474,7 @@ static int arcnet_open(struct net_device *dev)
 /* The inverse routine to arcnet_open - shuts down the card. */
 static int arcnet_close(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -556,7 +556,7 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 static int arcnet_rebuild_header(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int status = 0;		/* default is failure */
 	unsigned short type;
 	uint8_t daddr=0;
@@ -603,7 +603,7 @@ static int arcnet_rebuild_header(struct sk_buff *skb)
 /* Called by the kernel in order to transmit a packet. */
 static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr *pkt;
 	struct arc_rfc1201 *soft;
 	struct ArcProto *proto;
@@ -693,7 +693,7 @@ static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
  */
 static int go_tx(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	BUGMSG(D_DURING, "go_tx: status=%Xh, intmask=%Xh, next_tx=%d, cur_tx=%d\n",
 	       ASTATUS(), lp->intmask, lp->next_tx, lp->cur_tx);
@@ -723,7 +723,7 @@ static int go_tx(struct net_device *dev)
 static void arcnet_timeout(struct net_device *dev)
 {
 	unsigned long flags;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int status = ASTATUS();
 	char *msg;
 
@@ -771,8 +771,8 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	BUGMSG(D_DURING, "\n");
 
 	BUGMSG(D_DURING, "in arcnet_interrupt\n");
-	
-	lp = dev->priv;
+
+	lp = netdev_priv(dev);
 	BUG_ON(!lp);
 		
 	spin_lock(&lp->lock);
@@ -1010,7 +1010,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
  */
 static void arcnet_rx(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr pkt;
 	struct arc_rfc1201 *soft;
 	int length, ofs;
@@ -1074,7 +1074,7 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
  */
 static struct net_device_stats *arcnet_get_stats(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
@@ -1091,7 +1091,7 @@ static void null_rx(struct net_device *dev, int bufnum,
 static int null_build_header(struct sk_buff *skb, struct net_device *dev,
 			     unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	BUGMSG(D_PROTO,
 	       "tx: can't build header for encap %02Xh; load a protocol driver.\n",
@@ -1106,7 +1106,7 @@ static int null_build_header(struct sk_buff *skb, struct net_device *dev,
 static int null_prepare_tx(struct net_device *dev, struct archdr *pkt,
 			   int length, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct arc_hardware newpkt;
 
 	BUGMSG(D_PROTO, "tx: no encap for this host; load a protocol driver.\n");
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 02cb8f1..9105468 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -103,7 +103,7 @@ MODULE_LICENSE("GPL");
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	char *pktbuf, *pkthdrbuf;
@@ -198,7 +198,7 @@ static int build_header(struct sk_buff *skb,
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
@@ -250,7 +250,7 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 
 static int ack_tx(struct net_device *dev, int acked)
 {
-  struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+  struct arcnet_local *lp = netdev_priv(dev);
   struct sk_buff *ackskb;
   struct archdr *ackpkt;
   int length=sizeof(struct arc_cap);
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index 9289e61..ea53a94 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -52,7 +52,7 @@ static int __init com20020isa_probe(struct net_device *dev)
 {
 	int ioaddr;
 	unsigned long airqmask;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int err;
 
 	BUGLVL(D_NORMAL) printk(VERSION);
@@ -151,7 +151,7 @@ static int __init com20020_init(void)
 	if (node && node != 0xff)
 		dev->dev_addr[0] = node;
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->backplane = backplane;
 	lp->clockp = clockp & 7;
 	lp->clockm = clockm & 3;
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index b8c0fa6..8b51f63 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -72,7 +72,7 @@ static int __devinit com20020pci_probe(struct pci_dev *pdev, const struct pci_de
 	dev = alloc_arcdev(device);
 	if (!dev)
 		return -ENOMEM;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	pci_set_drvdata(pdev, dev);
 
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 8b51313..1c3986d 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -89,7 +89,7 @@ static void com20020_copy_to_card(struct net_device *dev, int bufnum,
 int com20020_check(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr, status;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	ARCRESET0;
 	mdelay(RESETtime);
@@ -159,7 +159,7 @@ int com20020_found(struct net_device *dev, int shared)
 
 	/* Initialize the rest of the device structure. */
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	lp->hw.owner = THIS_MODULE;
 	lp->hw.command = com20020_command;
@@ -233,7 +233,7 @@ int com20020_found(struct net_device *dev, int shared)
  */
 static int com20020_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	u_int ioaddr = dev->base_addr;
 	u_char inbyte;
 
@@ -300,7 +300,7 @@ static int com20020_status(struct net_device *dev)
 
 static void com20020_close(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* disable transmitter */
@@ -317,7 +317,7 @@ static void com20020_close(struct net_device *dev)
  */
 static void com20020_set_mc_list(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	if ((dev->flags & IFF_PROMISC) && (dev->flags & IFF_UP)) {	/* Enable promiscuous mode */
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 6599f10..89de29b 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -248,7 +248,7 @@ static int __init com90io_found(struct net_device *dev)
 		return -EBUSY;
 	}
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->card_name = "COM90xx I/O";
 	lp->hw.command = com90io_command;
 	lp->hw.status = com90io_status;
@@ -290,7 +290,7 @@ static int __init com90io_found(struct net_device *dev)
  */
 static int com90io_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, ASTATUS());
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 0d45553..f4113d2 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -468,7 +468,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 		release_mem_region(shmem, MIRROR_SIZE);
 		return -ENOMEM;
 	}
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	/* find the real shared memory start/end points, including mirrors */
 
 	/* guess the actual size of one "memory mirror" - the number of
@@ -585,7 +585,7 @@ static void com90xx_setmask(struct net_device *dev, int mask)
  */
 int com90xx_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
 	BUGMSG(D_INIT, "Resetting (status=%02Xh)\n", ASTATUS());
@@ -621,7 +621,7 @@ int com90xx_reset(struct net_device *dev, int really_reset)
 static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
 	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
@@ -630,7 +630,7 @@ static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 static void com90xx_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
 	TIME("memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
 }
@@ -656,7 +656,7 @@ static void __exit com90xx_exit(void)
 
 	for (count = 0; count < numcards; count++) {
 		dev = cards[count];
-		lp = dev->priv;
+		lp = netdev_priv(dev);
 
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index dab185b..0dfd4b0 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -88,7 +88,7 @@ MODULE_LICENSE("GPL");
  */
 static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
@@ -125,7 +125,7 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	int ofs;
@@ -169,7 +169,7 @@ static void rx(struct net_device *dev, int bufnum,
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
@@ -220,7 +220,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 6d6d95c..d1cc668 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -92,7 +92,7 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 {
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 
 	/* Pull off the arcnet header. */
@@ -134,7 +134,7 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	struct arc_rfc1201 *soft = &pkthdr->soft.rfc1201;
@@ -376,7 +376,7 @@ static void rx(struct net_device *dev, int bufnum,
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
@@ -443,7 +443,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 static void load_pkt(struct net_device *dev, struct arc_hardware *hard,
 		     struct arc_rfc1201 *soft, int softlen, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int ofs;
 
 	/* assume length <= XMTU: someone should have handled that by now. */
@@ -476,7 +476,7 @@ static void load_pkt(struct net_device *dev, struct arc_hardware *hard,
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	const int maxsegsize = XMTU - RFC1201_HDR_SIZE;
 	struct Outgoing *out;
 
@@ -511,7 +511,7 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 
 static int continue_tx(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct Outgoing *out = &lp->outgoing;
 	struct arc_hardware *hard = &out->pkt->hard;
 	struct arc_rfc1201 *soft = &out->pkt->soft.rfc1201, *newsoft;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 3efe5dd..ace77e5 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -95,9 +95,9 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 };
 
 #define IXGBE_QUEUE_STATS_LEN \
-		((((struct ixgbe_adapter *)netdev->priv)->num_tx_queues + \
-		 ((struct ixgbe_adapter *)netdev->priv)->num_rx_queues) * \
-		 (sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
+	((((struct ixgbe_adapter *)netdev_priv(netdev))->num_tx_queues + \
+	((struct ixgbe_adapter *)netdev_priv(netdev))->num_rx_queues) * \
+	(sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
 #define IXGBE_GLOBAL_STATS_LEN	ARRAY_SIZE(ixgbe_gstrings_stats)
 #define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 34bca16..6f8726b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3727,7 +3727,7 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 						pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev->priv;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	netif_device_detach(netdev);
 
@@ -3748,7 +3748,7 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev->priv;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	if (pci_enable_device(pdev)) {
 		DPRINTK(PROBE, ERR,
@@ -3776,7 +3776,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 static void ixgbe_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev->priv;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	if (netif_running(netdev)) {
 		if (ixgbe_up(adapter)) {





