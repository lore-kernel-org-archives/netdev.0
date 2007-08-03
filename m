From: Yoann Padioleau <padator@wanadoo.fr>
Subject: [PATCH 03/13] dev->priv to netdev_priv(dev), for drivers/net/arcnet
Date: Fri, 3 Aug 2007 19:33:36 +0200 (MEST)
Message-ID: <200708031733.TAA00753@ifs.emn.fr>
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Replacing accesses to dev->priv to netdev_priv(dev). The replacment
is safe when netdev_priv is used to access a private structure that is
right next to the net_device structure in memory. Cf
http://groups.google.com/group/comp.os.linux.development.system/browse_thread/thread/de19321bcd94dbb8/0d74a4adcd6177bd
This is the case when the net_device structure was allocated with
a call to alloc_netdev or one of its derivative.

Here is an excerpt of the semantic patch that performs the transformation

@ rule1 @
type T;
struct net_device *dev;
@@

 dev = 
(
        alloc_netdev
|         
        alloc_etherdev
|
        alloc_trdev
)
   (sizeof(T), ...)

@ rule1bis @
struct net_device *dev;
expression E;
@@
 dev->priv = E

@ rule2 depends on rule1 && !rule1bis  @
struct net_device *dev;
type rule1.T;
@@

- (T*) dev->priv
+ netdev_priv(dev)

Signed-off-by: Yoann Padioleau <padator@wanadoo.fr>
Cc: jeff@garzik.org
Cc: netdev@vger.kernel.org
Cc: akpm@linux-foundation.org
---

 drivers/net/arcnet/arc-rawmode.c  |    4 ++--
 drivers/net/arcnet/arc-rimi.c     |   16 ++++++++--------
 drivers/net/arcnet/arcnet.c       |   32 ++++++++++++++++----------------
 drivers/net/arcnet/capmode.c      |    6 +++---
 drivers/net/arcnet/com20020-isa.c |    4 ++--
 drivers/net/arcnet/com20020-pci.c |    2 +-
 drivers/net/arcnet/com20020.c     |   10 +++++-----
 drivers/net/arcnet/com90io.c      |    4 ++--
 drivers/net/arcnet/com90xx.c      |   10 +++++-----
 drivers/net/arcnet/rfc1051.c      |    8 ++++----
 drivers/net/arcnet/rfc1201.c      |   12 ++++++------
 11 files changed, 54 insertions(+), 54 deletions(-)

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
@@ -168,7 +168,7 @@ static int build_header(struct sk_buff *
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
@@ -194,7 +194,7 @@ static int __init arcrimi_found(struct n
 
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
@@ -281,7 +281,7 @@ static int arcrimi_reset(struct net_devi
 
 static void arcrimi_setmask(struct net_device *dev, int mask)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	AINTMASK(mask);
@@ -289,7 +289,7 @@ static void arcrimi_setmask(struct net_d
 
 static int arcrimi_status(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	return ASTATUS();
@@ -297,7 +297,7 @@ static int arcrimi_status(struct net_dev
 
 static void arcrimi_command(struct net_device *dev, int cmd)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	ACOMMAND(cmd);
@@ -306,7 +306,7 @@ static void arcrimi_command(struct net_d
 static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
 	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
@@ -315,7 +315,7 @@ static void arcrimi_copy_to_card(struct 
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
index 681e20b..230b545 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -181,7 +181,7 @@ #if (ARCNET_DEBUG_MAX & (D_RX | D_TX))
 static void arcnet_dump_packet(struct net_device *dev, int bufnum,
 			       char *desc, int take_arcnet_lock)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int i, length;
 	unsigned long flags = 0;
 	static uint8_t buf[512];
@@ -247,7 +247,7 @@ void arcnet_unregister_proto(struct ArcP
  */
 static void release_arcbuf(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int i;
 
 	lp->buf_queue[lp->first_free_buf++] = bufnum;
@@ -269,7 +269,7 @@ static void release_arcbuf(struct net_de
  */
 static int get_arcbuf(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int buf = -1, i;
 
 	if (!atomic_dec_and_test(&lp->buf_lock)) {
@@ -353,7 +353,7 @@ struct net_device *alloc_arcdev(char *na
 	dev = alloc_netdev(sizeof(struct arcnet_local),
 			   name && *name ? name : "arc%d", arcdev_setup);
 	if(dev) {
-		struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+		struct arcnet_local *lp = netdev_priv(dev);
 		spin_lock_init(&lp->lock);
 	}
 
@@ -370,7 +370,7 @@ struct net_device *alloc_arcdev(char *na
  */
 static int arcnet_open(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int count, newmtu, error;
 
 	BUGMSG(D_INIT,"opened.");
@@ -470,7 +470,7 @@ static int arcnet_open(struct net_device
 /* The inverse routine to arcnet_open - shuts down the card. */
 static int arcnet_close(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -491,7 +491,7 @@ static int arcnet_header(struct sk_buff 
 			 unsigned short type, void *daddr, void *saddr,
 			 unsigned len)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	uint8_t _daddr, proto_num;
 	struct ArcProto *proto;
 
@@ -552,7 +552,7 @@ static int arcnet_header(struct sk_buff 
 static int arcnet_rebuild_header(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int status = 0;		/* default is failure */
 	unsigned short type;
 	uint8_t daddr=0;
@@ -599,7 +599,7 @@ #endif
 /* Called by the kernel in order to transmit a packet. */
 static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr *pkt;
 	struct arc_rfc1201 *soft;
 	struct ArcProto *proto;
@@ -689,7 +689,7 @@ static int arcnet_send_packet(struct sk_
  */
 static int go_tx(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	BUGMSG(D_DURING, "go_tx: status=%Xh, intmask=%Xh, next_tx=%d, cur_tx=%d\n",
 	       ASTATUS(), lp->intmask, lp->next_tx, lp->cur_tx);
@@ -719,7 +719,7 @@ static int go_tx(struct net_device *dev)
 static void arcnet_timeout(struct net_device *dev)
 {
 	unsigned long flags;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int status = ASTATUS();
 	char *msg;
 
@@ -768,7 +768,7 @@ irqreturn_t arcnet_interrupt(int irq, vo
 
 	BUGMSG(D_DURING, "in arcnet_interrupt\n");
 	
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	BUG_ON(!lp);
 		
 	spin_lock(&lp->lock);
@@ -1005,7 +1005,7 @@ irqreturn_t arcnet_interrupt(int irq, vo
  */
 static void arcnet_rx(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr pkt;
 	struct arc_rfc1201 *soft;
 	int length, ofs;
@@ -1069,7 +1069,7 @@ static void arcnet_rx(struct net_device 
  */
 static struct net_device_stats *arcnet_get_stats(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
@@ -1086,7 +1086,7 @@ static void null_rx(struct net_device *d
 static int null_build_header(struct sk_buff *skb, struct net_device *dev,
 			     unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	BUGMSG(D_PROTO,
 	       "tx: can't build header for encap %02Xh; load a protocol driver.\n",
@@ -1101,7 +1101,7 @@ static int null_build_header(struct sk_b
 static int null_prepare_tx(struct net_device *dev, struct archdr *pkt,
 			   int length, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct arc_hardware newpkt;
 
 	BUGMSG(D_PROTO, "tx: no encap for this host; load a protocol driver.\n");
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index cc4610d..bd04be9 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -101,7 +101,7 @@ #endif				/* MODULE */
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	char *pktbuf, *pkthdrbuf;
@@ -196,7 +196,7 @@ static int build_header(struct sk_buff *
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
@@ -248,7 +248,7 @@ static int prepare_tx(struct net_device 
 
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
@@ -52,7 +52,7 @@ static int __init com20020isa_probe(stru
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
@@ -72,7 +72,7 @@ static int __devinit com20020pci_probe(s
 	dev = alloc_arcdev(device);
 	if (!dev)
 		return -ENOMEM;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	pci_set_drvdata(pdev, dev);
 
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 7cf0a25..dd02463 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -89,7 +89,7 @@ static void com20020_copy_to_card(struct
 int com20020_check(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr, status;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	ARCRESET0;
 	mdelay(RESETtime);
@@ -159,7 +159,7 @@ int com20020_found(struct net_device *de
 
 	/* Initialize the rest of the device structure. */
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	lp->hw.owner = THIS_MODULE;
 	lp->hw.command = com20020_command;
@@ -233,7 +233,7 @@ int com20020_found(struct net_device *de
  */
 static int com20020_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	u_int ioaddr = dev->base_addr;
 	u_char inbyte;
 
@@ -300,7 +300,7 @@ static int com20020_status(struct net_de
 
 static void com20020_close(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* disable transmitter */
@@ -317,7 +317,7 @@ static void com20020_close(struct net_de
  */
 static void com20020_set_mc_list(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	if ((dev->flags & IFF_PROMISC) && (dev->flags & IFF_UP)) {	/* Enable promiscuous mode */
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 1f03027..c6e373a 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -248,7 +248,7 @@ static int __init com90io_found(struct n
 		return -EBUSY;
 	}
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->card_name = "COM90xx I/O";
 	lp->hw.command = com90io_command;
 	lp->hw.status = com90io_status;
@@ -290,7 +290,7 @@ static int __init com90io_found(struct n
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
@@ -468,7 +468,7 @@ static int __init com90xx_found(int ioad
 		release_mem_region(shmem, MIRROR_SIZE);
 		return -ENOMEM;
 	}
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	/* find the real shared memory start/end points, including mirrors */
 
 	/* guess the actual size of one "memory mirror" - the number of
@@ -585,7 +585,7 @@ static void com90xx_setmask(struct net_d
  */
 int com90xx_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
 	BUGMSG(D_INIT, "Resetting (status=%02Xh)\n", ASTATUS());
@@ -621,7 +621,7 @@ int com90xx_reset(struct net_device *dev
 static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
 	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
@@ -630,7 +630,7 @@ static void com90xx_copy_to_card(struct 
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
index 2de8877..ba58089 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -88,7 +88,7 @@ MODULE_LICENSE("GPL");
  */
 static unsigned short type_trans(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
@@ -125,7 +125,7 @@ static unsigned short type_trans(struct 
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	int ofs;
@@ -169,7 +169,7 @@ static void rx(struct net_device *dev, i
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
@@ -220,7 +220,7 @@ static int build_header(struct sk_buff *
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 460a095..75998f4 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -92,7 +92,7 @@ static unsigned short type_trans(struct 
 {
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 
 	/* Pull off the arcnet header. */
@@ -134,7 +134,7 @@ static unsigned short type_trans(struct 
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	struct arc_rfc1201 *soft = &pkthdr->soft.rfc1201;
@@ -376,7 +376,7 @@ static void rx(struct net_device *dev, i
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
@@ -443,7 +443,7 @@ static int build_header(struct sk_buff *
 static void load_pkt(struct net_device *dev, struct arc_hardware *hard,
 		     struct arc_rfc1201 *soft, int softlen, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int ofs;
 
 	/* assume length <= XMTU: someone should have handled that by now. */
@@ -476,7 +476,7 @@ static void load_pkt(struct net_device *
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	const int maxsegsize = XMTU - RFC1201_HDR_SIZE;
 	struct Outgoing *out;
 
@@ -511,7 +511,7 @@ static int prepare_tx(struct net_device 
 
 static int continue_tx(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct Outgoing *out = &lp->outgoing;
 	struct arc_hardware *hard = &out->pkt->hard;
 	struct arc_rfc1201 *soft = &out->pkt->soft.rfc1201, *newsoft;

