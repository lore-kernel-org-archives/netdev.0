From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next] netdevice ni65: Convert directly reference of netdev->priv
Date: Thu, 20 Nov 2008 17:16:08 +0800
Message-ID: <49252AD8.4030306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50726 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752145AbYKTJQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 04:16:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to kill directly reference of netdev->priv too.
Because the private data needs special memory: lower 16MB DMA.
alloc_etherdev() can do this work.
So we can't use netdev->priv to point to netdev's private data.
Use netdev->ml_priv instead.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/ni65.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ni65.c b/drivers/net/ni65.c
index 24e393b..1142c77 100644
--- a/drivers/net/ni65.c
+++ b/drivers/net/ni65.c
@@ -295,7 +295,7 @@ static void ni65_set_performance(struct priv *p)
  */
 static int ni65_open(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = dev->ml_priv;
 	int irqval = request_irq(dev->irq, &ni65_interrupt,0,
                         cards[p->cardno].cardname,dev);
 	if (irqval) {
@@ -321,7 +321,7 @@ static int ni65_open(struct net_device *dev)
  */
 static int ni65_close(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = dev->ml_priv;
 
 	netif_stop_queue(dev);
 
@@ -345,7 +345,7 @@ static int ni65_close(struct net_device *dev)
 
 static void cleanup_card(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = dev->ml_priv;
 	disable_dma(dev->dma);
 	free_dma(dev->dma);
 	release_region(dev->base_addr, cards[p->cardno].total_size);
@@ -444,7 +444,7 @@ static int __init ni65_probe1(struct net_device *dev,int ioaddr)
 		release_region(ioaddr, cards[i].total_size);
 		return j;
 	}
-	p = (struct priv *) dev->priv;
+	p = dev->ml_priv;
 	p->cmdr_addr = ioaddr + cards[i].cmd_offset;
 	p->cardno = i;
 	spin_lock_init(&p->ring_lock);
@@ -647,8 +647,8 @@ static int ni65_alloc_buffer(struct net_device *dev)
 	if(!ptr)
 		return -ENOMEM;
 
-	p = dev->priv = (struct priv *) (((unsigned long) ptr + 7) & ~0x7);
-	memset((char *) dev->priv,0,sizeof(struct priv));
+	p = dev->ml_priv = (struct priv *) (((unsigned long) ptr + 7) & ~0x7);
+	memset((char *)p, 0, sizeof(struct priv));
 	p->self = ptr;
 
 	for(i=0;i<TMDNUM;i++)
@@ -790,7 +790,7 @@ static void ni65_stop_start(struct net_device *dev,struct priv *p)
 static int ni65_lance_reinit(struct net_device *dev)
 {
 	 int i;
-	 struct priv *p = (struct priv *) dev->priv;
+	 struct priv *p = dev->ml_priv;
 	 unsigned long flags;
 
 	 p->lock = 0;
@@ -876,7 +876,7 @@ static irqreturn_t ni65_interrupt(int irq, void * dev_id)
 	struct priv *p;
 	int bcnt = 32;
 
-	p = (struct priv *) dev->priv;
+	p = dev->ml_priv;
 
 	spin_lock(&p->ring_lock);
 
@@ -899,7 +899,7 @@ static irqreturn_t ni65_interrupt(int irq, void * dev_id)
 
 		if(csr0 & CSR0_ERR)
 		{
-			struct priv *p = (struct priv *) dev->priv;
+			struct priv *p = dev->ml_priv;
 			if(debuglevel > 1)
 				printk(KERN_ERR "%s: general error: %04x.\n",dev->name,csr0);
 			if(csr0 & CSR0_BABL)
@@ -924,7 +924,7 @@ static irqreturn_t ni65_interrupt(int irq, void * dev_id)
  int j;
  for(j=0;j<RMDNUM;j++)
  {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = dev->ml_priv;
 	int i,k,num1,num2;
 	for(i=RMDNUM-1;i>0;i--) {
 		 num2 = (p->rmdnum + i) & (RMDNUM-1);
@@ -982,7 +982,7 @@ static irqreturn_t ni65_interrupt(int irq, void * dev_id)
  */
 static void ni65_xmit_intr(struct net_device *dev,int csr0)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = dev->ml_priv;
 
 	while(p->xmit_queued)
 	{
@@ -1049,7 +1049,7 @@ static void ni65_recv_intr(struct net_device *dev,int csr0)
 	struct rmd *rmdp;
 	int rmdstat,len;
 	int cnt=0;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = dev->ml_priv;
 
 	rmdp = p->rmdhead + p->rmdnum;
 	while(!( (rmdstat = rmdp->u.s.status) & RCV_OWN))
@@ -1139,7 +1139,7 @@ static void ni65_recv_intr(struct net_device *dev,int csr0)
 static void ni65_timeout(struct net_device *dev)
 {
 	int i;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = dev->ml_priv;
 
 	printk(KERN_ERR "%s: xmitter timed out, try to restart!\n",dev->name);
 	for(i=0;i<TMDNUM;i++)
@@ -1156,7 +1156,7 @@ static void ni65_timeout(struct net_device *dev)
 
 static int ni65_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = dev->ml_priv;
 
 	netif_stop_queue(dev);
 
@@ -1221,7 +1221,7 @@ static struct net_device_stats *ni65_get_stats(struct net_device *dev)
 
 #if 0
 	int i;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = dev->ml_priv;
 	for(i=0;i<RMDNUM;i++)
 	{
 		struct rmd *rmdp = p->rmdhead + ((p->rmdnum + i) & (RMDNUM-1));
@@ -1230,7 +1230,7 @@ static struct net_device_stats *ni65_get_stats(struct net_device *dev)
 	printk("\n");
 #endif
 
-	return &((struct priv *) dev->priv)->stats;
+	return &((struct priv *)dev->ml_priv)->stats;
 }
 
 static void set_multicast_list(struct net_device *dev)
-- 
1.5.3.4


