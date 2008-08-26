From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 15/15] netdevice sbni: Convert directly reference of netdev->priv
 to netdev_priv()
Date: Tue, 26 Aug 2008 18:30:12 +0800
Message-ID: <48B3DB34.2090004@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60467 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755062AbYHZKci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 06:32:38 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/wan/sbni.c |   99 +++++++++++++++++++++++++-----------------------
 1 files changed, 52 insertions(+), 47 deletions(-)

diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index e59255a..d144daf 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -186,6 +186,7 @@ static unsigned int  netcard_portlist[ ] __initdata = {
 	0x2b0, 0x2b4, 0x2c0, 0x2c4, 0x2d0, 0x2d4, 0x2e0, 0x2e4, 0x2f0, 0x2f4,
 	0 };
 
+#define NET_LOCAL_LOCK(dev) (((struct net_local *)netdev_priv(dev))->lock)
 
 /*
  * Look for SBNI card which addr stored in dev->base_addr, if nonzero.
@@ -287,7 +288,7 @@ static int __init sbni_init(struct net_device *dev)
 }
 
 
-int __init
+static int __init
 sbni_pci_probe( struct net_device  *dev )
 {
 	struct pci_dev  *pdev = NULL;
@@ -378,22 +379,23 @@ sbni_probe1( struct net_device  *dev,  unsigned long  ioaddr,  int  irq )
 	dev->irq = irq;
 	dev->base_addr = ioaddr;
 
-	/* Allocate dev->priv and fill in sbni-specific dev fields. */
-	nl = dev->priv;
+	/* Fill in sbni-specific dev fields. */
+	nl = netdev_priv(dev);
 	if( !nl ) {
 		printk( KERN_ERR "%s: unable to get memory!\n", dev->name );
 		release_region( ioaddr, SBNI_IO_EXTENT );
 		return NULL;
 	}
 
-	dev->priv = nl;
 	memset( nl, 0, sizeof(struct net_local) );
 	spin_lock_init( &nl->lock );
 
 	/* store MAC address (generate if that isn't known) */
 	*(__be16 *)dev->dev_addr = htons( 0x00ff );
 	*(__be32 *)(dev->dev_addr + 2) = htonl( 0x01000000 |
-		( (mac[num]  ?  mac[num]  :  (u32)((long)dev->priv)) & 0x00ffffff) );
+		((mac[num] ?
+		mac[num] :
+		(u32)((long)netdev_priv(dev))) & 0x00ffffff));
 
 	/* store link settings (speed, receive level ) */
 	nl->maxframe  = DEFAULT_FRAME_LEN;
@@ -447,7 +449,7 @@ sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 
 	/* Looking for idle device in the list */
 	for( p = dev;  p; ) {
-		struct net_local  *nl = (struct net_local *) p->priv;
+		struct net_local  *nl = netdev_priv(p);
 		spin_lock( &nl->lock );
 		if( nl->tx_buf_p  ||  (nl->state & FL_LINE_DOWN) ) {
 			p = nl->link;
@@ -469,7 +471,7 @@ sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 static int
 sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 {
-	struct net_local  *nl  = (struct net_local *) dev->priv;
+	struct net_local  *nl  = netdev_priv(dev);
 
 	netif_stop_queue( dev );
 	spin_lock( &nl->lock );
@@ -503,12 +505,12 @@ static irqreturn_t
 sbni_interrupt( int  irq,  void  *dev_id )
 {
 	struct net_device	  *dev = dev_id;
-	struct net_local  *nl  = dev->priv;
+	struct net_local  *nl  = netdev_priv(dev);
 	int	repeat;
 
 	spin_lock( &nl->lock );
 	if( nl->second )
-		spin_lock( &((struct net_local *) nl->second->priv)->lock );
+		spin_lock(&NET_LOCAL_LOCK(nl->second));
 
 	do {
 		repeat = 0;
@@ -522,7 +524,7 @@ sbni_interrupt( int  irq,  void  *dev_id )
 	} while( repeat );
 
 	if( nl->second )
-		spin_unlock( &((struct net_local *)nl->second->priv)->lock );
+		spin_unlock(&NET_LOCAL_LOCK(nl->second));
 	spin_unlock( &nl->lock );
 	return IRQ_HANDLED;
 }
@@ -531,7 +533,7 @@ sbni_interrupt( int  irq,  void  *dev_id )
 static void
 handle_channel( struct net_device  *dev )
 {
-	struct net_local	*nl    = (struct net_local *) dev->priv;
+	struct net_local	*nl    = netdev_priv(dev);
 	unsigned long		ioaddr = dev->base_addr;
 
 	int  req_ans;
@@ -540,7 +542,7 @@ handle_channel( struct net_device  *dev )
 #ifdef CONFIG_SBNI_MULTILINE
 	/* Lock the master device because we going to change its local data */
 	if( nl->state & FL_SLAVE )
-		spin_lock( &((struct net_local *) nl->master->priv)->lock );
+		spin_lock(&NET_LOCAL_LOCK(nl->master));
 #endif
 
 	outb( (inb( ioaddr + CSR0 ) & ~EN_INT) | TR_REQ, ioaddr + CSR0 );
@@ -576,7 +578,7 @@ handle_channel( struct net_device  *dev )
 
 #ifdef CONFIG_SBNI_MULTILINE
 	if( nl->state & FL_SLAVE )
-		spin_unlock( &((struct net_local *) nl->master->priv)->lock );
+		spin_unlock(&NET_LOCAL_LOCK(nl->master));
 #endif
 }
 
@@ -589,7 +591,7 @@ handle_channel( struct net_device  *dev )
 static int
 recv_frame( struct net_device  *dev )
 {
-	struct net_local  *nl   = (struct net_local *) dev->priv;
+	struct net_local  *nl   = netdev_priv(dev);
 	unsigned long  ioaddr	= dev->base_addr;
 
 	u32  crc = CRC32_INITIAL;
@@ -623,7 +625,7 @@ recv_frame( struct net_device  *dev )
 static void
 send_frame( struct net_device  *dev )
 {
-	struct net_local  *nl    = (struct net_local *) dev->priv;
+	struct net_local  *nl    = netdev_priv(dev);
 
 	u32  crc = CRC32_INITIAL;
 
@@ -680,7 +682,7 @@ do_send:
 static void
 download_data( struct net_device  *dev,  u32  *crc_p )
 {
-	struct net_local  *nl    = (struct net_local *) dev->priv;
+	struct net_local  *nl    = netdev_priv(dev);
 	struct sk_buff    *skb	 = nl->tx_buf_p;
 
 	unsigned  len = min_t(unsigned int, skb->len - nl->outpos, nl->framelen);
@@ -699,7 +701,7 @@ static int
 upload_data( struct net_device  *dev,  unsigned  framelen,  unsigned  frameno,
 	     unsigned  is_first,  u32  crc )
 {
-	struct net_local  *nl = (struct net_local *) dev->priv;
+	struct net_local  *nl = netdev_priv(dev);
 
 	int  frame_ok;
 
@@ -721,9 +723,9 @@ upload_data( struct net_device  *dev,  unsigned  framelen,  unsigned  frameno,
 			nl->wait_frameno = 0,
 			nl->inppos = 0,
 #ifdef CONFIG_SBNI_MULTILINE
-			((struct net_local *) nl->master->priv)
+			((struct net_local *)netdev_priv(nl->master))
 				->stats.rx_errors++,
-			((struct net_local *) nl->master->priv)
+			((struct net_local *)netdev_priv(nl->master))
 				->stats.rx_missed_errors++;
 #else
 			nl->stats.rx_errors++,
@@ -740,8 +742,10 @@ upload_data( struct net_device  *dev,  unsigned  framelen,  unsigned  frameno,
 		 */
 		nl->wait_frameno = 0,
 #ifdef CONFIG_SBNI_MULTILINE
-		((struct net_local *) nl->master->priv)->stats.rx_errors++,
-		((struct net_local *) nl->master->priv)->stats.rx_crc_errors++;
+		((struct net_local *)netdev_priv(nl->master))
+			->stats.rx_errors++,
+		((struct net_local *)netdev_priv(nl->master))
+			->stats.rx_crc_errors++;
 #else
 		nl->stats.rx_errors++,
 		nl->stats.rx_crc_errors++;
@@ -755,8 +759,8 @@ static inline void
 send_complete( struct net_local  *nl )
 {
 #ifdef CONFIG_SBNI_MULTILINE
-	((struct net_local *) nl->master->priv)->stats.tx_packets++;
-	((struct net_local *) nl->master->priv)->stats.tx_bytes
+	((struct net_local *)netdev_priv(nl->master))->stats.tx_packets++;
+	((struct net_local *)netdev_priv(nl->master))->stats.tx_bytes
 		+= nl->tx_buf_p->len;
 #else
 	nl->stats.tx_packets++;
@@ -775,7 +779,7 @@ send_complete( struct net_local  *nl )
 static void
 interpret_ack( struct net_device  *dev,  unsigned  ack )
 {
-	struct net_local  *nl = (struct net_local *) dev->priv;
+	struct net_local  *nl = netdev_priv(dev);
 
 	if( ack == FRAME_SENT_OK ) {
 		nl->state &= ~FL_NEED_RESEND;
@@ -809,7 +813,7 @@ interpret_ack( struct net_device  *dev,  unsigned  ack )
 static int
 append_frame_to_pkt( struct net_device  *dev,  unsigned  framelen,  u32  crc )
 {
-	struct net_local  *nl = (struct net_local *) dev->priv;
+	struct net_local  *nl = netdev_priv(dev);
 
 	u8  *p;
 
@@ -840,7 +844,7 @@ append_frame_to_pkt( struct net_device  *dev,  unsigned  framelen,  u32  crc )
 static void
 prepare_to_send( struct sk_buff  *skb,  struct net_device  *dev )
 {
-	struct net_local  *nl = (struct net_local *) dev->priv;
+	struct net_local  *nl = netdev_priv(dev);
 
 	unsigned int  len;
 
@@ -871,15 +875,15 @@ prepare_to_send( struct sk_buff  *skb,  struct net_device  *dev )
 static void
 drop_xmit_queue( struct net_device  *dev )
 {
-	struct net_local  *nl = (struct net_local *) dev->priv;
+	struct net_local  *nl = netdev_priv(dev);
 
 	if( nl->tx_buf_p )
 		dev_kfree_skb_any( nl->tx_buf_p ),
 		nl->tx_buf_p = NULL,
 #ifdef CONFIG_SBNI_MULTILINE
-		((struct net_local *) nl->master->priv)
+		((struct net_local *)netdev_priv(nl->master))
 			->stats.tx_errors++,
-		((struct net_local *) nl->master->priv)
+		((struct net_local *)netdev_priv(nl->master))
 			->stats.tx_carrier_errors++;
 #else
 		nl->stats.tx_errors++,
@@ -903,7 +907,7 @@ drop_xmit_queue( struct net_device  *dev )
 static void
 send_frame_header( struct net_device  *dev,  u32  *crc_p )
 {
-	struct net_local  *nl  = (struct net_local *) dev->priv;
+	struct net_local  *nl  = netdev_priv(dev);
 
 	u32  crc = *crc_p;
 	u32  len_field = nl->framelen + 6;	/* CRC + frameno + reserved */
@@ -1005,7 +1009,7 @@ get_rx_buf( struct net_device  *dev )
 static void
 indicate_pkt( struct net_device  *dev )
 {
-	struct net_local  *nl  = (struct net_local *) dev->priv;
+	struct net_local  *nl  = netdev_priv(dev);
 	struct sk_buff    *skb = nl->rx_buf_p;
 
 	skb_put( skb, nl->inppos );
@@ -1014,8 +1018,9 @@ indicate_pkt( struct net_device  *dev )
 	skb->protocol = eth_type_trans( skb, nl->master );
 	netif_rx( skb );
 	dev->last_rx = jiffies;
-	++((struct net_local *) nl->master->priv)->stats.rx_packets;
-	((struct net_local *) nl->master->priv)->stats.rx_bytes += nl->inppos;
+	++((struct net_local *)netdev_priv(nl->master))->stats.rx_packets;
+	((struct net_local *)netdev_priv(nl->master))->stats.rx_bytes +=
+		nl->inppos;
 #else
 	skb->protocol = eth_type_trans( skb, dev );
 	netif_rx( skb );
@@ -1038,7 +1043,7 @@ static void
 sbni_watchdog( unsigned long  arg )
 {
 	struct net_device  *dev = (struct net_device *) arg;
-	struct net_local   *nl  = (struct net_local *) dev->priv;
+	struct net_local   *nl  = netdev_priv(dev);
 	struct timer_list  *w   = &nl->watchdog; 
 	unsigned long	   flags;
 	unsigned char	   csr0;
@@ -1091,7 +1096,7 @@ static unsigned char  timeout_rxl_tab[] = {
 static void
 card_start( struct net_device  *dev )
 {
-	struct net_local  *nl = (struct net_local *) dev->priv;
+	struct net_local  *nl = netdev_priv(dev);
 
 	nl->timer_ticks = CHANGE_LEVEL_START_TICKS;
 	nl->state &= ~(FL_WAIT_ACK | FL_NEED_RESEND);
@@ -1113,7 +1118,7 @@ card_start( struct net_device  *dev )
 static void
 change_level( struct net_device  *dev )
 {
-	struct net_local  *nl = (struct net_local *) dev->priv;
+	struct net_local  *nl = netdev_priv(dev);
 
 	if( nl->delta_rxl == 0 )	/* do not auto-negotiate RxL */
 		return;
@@ -1137,7 +1142,7 @@ change_level( struct net_device  *dev )
 static void
 timeout_change_level( struct net_device  *dev )
 {
-	struct net_local  *nl = (struct net_local *) dev->priv;
+	struct net_local  *nl = netdev_priv(dev);
 
 	nl->cur_rxl_index = timeout_rxl_tab[ nl->timeout_rxl ];
 	if( ++nl->timeout_rxl >= 4 )
@@ -1160,7 +1165,7 @@ timeout_change_level( struct net_device  *dev )
 static int
 sbni_open( struct net_device  *dev )
 {
-	struct net_local	*nl = (struct net_local *) dev->priv;
+	struct net_local	*nl = netdev_priv(dev);
 	struct timer_list	*w  = &nl->watchdog;
 
 	/*
@@ -1176,7 +1181,7 @@ sbni_open( struct net_device  *dev )
 				 ||  (*p)->base_addr == dev->base_addr - 4)
 			    &&  (*p)->flags & IFF_UP ) {
 
-				((struct net_local *) ((*p)->priv))
+				((struct net_local *) (netdev_priv(*p)))
 					->second = dev;
 				printk( KERN_NOTICE "%s: using shared irq "
 					"with %s\n", dev->name, (*p)->name );
@@ -1216,7 +1221,7 @@ handler_attached:
 static int
 sbni_close( struct net_device  *dev )
 {
-	struct net_local  *nl = (struct net_local *) dev->priv;
+	struct net_local  *nl = netdev_priv(dev);
 
 	if( nl->second  &&  nl->second->flags & IFF_UP ) {
 		printk( KERN_NOTICE "Secondary channel (%s) is active!\n",
@@ -1300,7 +1305,7 @@ sbni_card_probe( unsigned long  ioaddr )
 static int
 sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 {
-	struct net_local  *nl = (struct net_local *) dev->priv; 
+	struct net_local  *nl = netdev_priv(dev);
 	struct sbni_flags  flags;
 	int  error = 0;
 
@@ -1390,8 +1395,8 @@ sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 static int
 enslave( struct net_device  *dev,  struct net_device  *slave_dev )
 {
-	struct net_local  *nl  = (struct net_local *) dev->priv;
-	struct net_local  *snl = (struct net_local *) slave_dev->priv;
+	struct net_local  *nl  = netdev_priv(dev);
+	struct net_local  *snl = netdev_priv(slave_dev);
 
 	if( nl->state & FL_SLAVE )	/* This isn't master or free device */
 		return  -EBUSY;
@@ -1425,9 +1430,9 @@ enslave( struct net_device  *dev,  struct net_device  *slave_dev )
 static int
 emancipate( struct net_device  *dev )
 {
-	struct net_local   *snl = (struct net_local *) dev->priv;
+	struct net_local   *snl = netdev_priv(dev);
 	struct net_device  *p   = snl->master;
-	struct net_local   *nl  = (struct net_local *) p->priv;
+	struct net_local   *nl  = netdev_priv(p);
 
 	if( !(snl->state & FL_SLAVE) )
 		return  -EINVAL;
@@ -1438,7 +1443,7 @@ emancipate( struct net_device  *dev )
 
 	/* exclude from list */
 	for(;;) {	/* must be in list */
-		struct net_local  *t = (struct net_local *) p->priv;
+		struct net_local  *t = netdev_priv(p);
 		if( t->link == dev ) {
 			t->link = snl->link;
 			break;
@@ -1465,7 +1470,7 @@ emancipate( struct net_device  *dev )
 static struct net_device_stats *
 sbni_get_stats( struct net_device  *dev )
 {
-	return  &((struct net_local *) dev->priv)->stats;
+	return  &((struct net_local *)netdev_priv(dev))->stats;
 }
 
 
-- 
1.5.3.4


