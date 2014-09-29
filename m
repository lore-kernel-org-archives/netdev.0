From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCHv9 net-next 2/4] sunvnet: make transmit path zero-copy in the
 kernel
Date: Mon, 29 Sep 2014 19:48:11 -0400
Message-ID: <5429EFBB.2090909@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Raghuram Kothahota <raghuram.kothakota@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34342 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151AbaI2Xrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 19:47:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes pre-allocated transmit buffers and instead directly maps
pending packets on demand. This saves O(n^2) maximum-sized transmit buffers,
for n hosts on a vswitch, as well as a copy to those buffers.

Single-stream TCP throughput linux-solaris dropped ~5% for 1500-byte MTU,
but linux-linux at 1500-bytes increased ~20%.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |  218 ++++++++++++++++++++++++++++-------
 drivers/net/ethernet/sun/sunvnet.h |    9 ++-
 2 files changed, 182 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index b1abcad..8f5f4e3 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -780,6 +780,117 @@ struct vnet_port *tx_port_find(struct vnet *vp, struct sk_buff *skb)
 	return ret;
 }
 
+static struct sk_buff *vnet_clean_tx_ring(struct vnet_port *port,
+					  unsigned *pending)
+{
+	struct vio_dring_state *dr = &port->vio.drings[VIO_DRIVER_TX_RING];
+	struct sk_buff *skb = NULL;
+	int i, txi;
+
+	*pending = 0;
+
+	txi = dr->prod-1;
+	if (txi < 0)
+		txi = VNET_TX_RING_SIZE-1;
+
+	for (i = 0; i < VNET_TX_RING_SIZE; ++i) {
+		struct vio_net_desc *d;
+
+		d = vio_dring_entry(dr, txi);
+
+		if (d->hdr.state == VIO_DESC_DONE) {
+			if (port->tx_bufs[txi].skb) {
+				BUG_ON(port->tx_bufs[txi].skb->next);
+
+				port->tx_bufs[txi].skb->next = skb;
+				skb = port->tx_bufs[txi].skb;
+				port->tx_bufs[txi].skb = NULL;
+
+				ldc_unmap(port->vio.lp,
+					  port->tx_bufs[txi].cookies,
+					  port->tx_bufs[txi].ncookies);
+			}
+			d->hdr.state = VIO_DESC_FREE;
+		} else if (d->hdr.state == VIO_DESC_READY) {
+			(*pending)++;
+		} else if (d->hdr.state == VIO_DESC_FREE) {
+			break;
+		}
+		--txi;
+		if (txi < 0)
+			txi = VNET_TX_RING_SIZE-1;
+	}
+	return skb;
+}
+
+static inline void vnet_free_skbs(struct sk_buff *skb)
+{
+	struct sk_buff *next;
+
+	while (skb) {
+		next = skb->next;
+		skb->next = NULL;
+		dev_kfree_skb(skb);
+		skb = next;
+	}
+}
+
+static void vnet_clean_timer_expire(unsigned long port0)
+{
+	struct vnet_port *port = (struct vnet_port *)port0;
+	struct sk_buff *freeskbs;
+	unsigned pending;
+	unsigned long flags;
+
+	spin_lock_irqsave(&port->vio.lock, flags);
+	freeskbs = vnet_clean_tx_ring(port, &pending);
+	spin_unlock_irqrestore(&port->vio.lock, flags);
+
+	vnet_free_skbs(freeskbs);
+
+	if (pending)
+		(void)mod_timer(&port->clean_timer,
+				jiffies + VNET_CLEAN_TIMEOUT);
+	 else
+		del_timer(&port->clean_timer);
+}
+
+static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, void **pstart,
+					     int *plen)
+{
+	struct sk_buff *nskb;
+	int len, pad;
+
+	len = skb->len;
+	pad = 0;
+	if (len < ETH_ZLEN) {
+		pad += ETH_ZLEN - skb->len;
+		len += pad;
+	}
+	len += VNET_PACKET_SKIP;
+	pad += 8 - (len & 7);
+	len += 8 - (len & 7);
+
+	if (((unsigned long)skb->data & 7) != VNET_PACKET_SKIP ||
+	    skb_tailroom(skb) < pad ||
+	    skb_headroom(skb) < VNET_PACKET_SKIP) {
+		nskb = alloc_and_align_skb(skb->dev, skb->len);
+		skb_reserve(nskb, VNET_PACKET_SKIP);
+		if (skb_copy_bits(skb, 0, nskb->data, skb->len)) {
+			dev_kfree_skb(nskb);
+			dev_kfree_skb(skb);
+			return NULL;
+		}
+		(void)skb_put(nskb, skb->len);
+		dev_kfree_skb(skb);
+		skb = nskb;
+	}
+
+	*pstart = skb->data - VNET_PACKET_SKIP;
+	*plen = len;
+	return skb;
+}
+
 static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vnet *vp = netdev_priv(dev);
@@ -788,12 +899,20 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct vio_net_desc *d;
 	unsigned long flags;
 	unsigned int len;
-	void *tx_buf;
-	int i, err;
+	struct sk_buff *freeskbs = NULL;
+	int i, err, txi;
+	void *start = NULL;
+	int nlen = 0;
+	unsigned pending = 0;
 
 	if (unlikely(!port))
 		goto out_dropped;
 
+	skb = vnet_skb_shape(skb, &start, &nlen);
+
+	if (unlikely(!skb))
+		goto out_dropped;
+
 	spin_lock_irqsave(&port->vio.lock, flags);
 
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
@@ -811,14 +930,27 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	d = vio_dring_cur(dr);
 
-	tx_buf = port->tx_bufs[dr->prod].buf;
-	skb_copy_from_linear_data(skb, tx_buf + VNET_PACKET_SKIP, skb->len);
+	txi = dr->prod;
+
+	freeskbs = vnet_clean_tx_ring(port, &pending);
+
+	BUG_ON(port->tx_bufs[txi].skb);
 
 	len = skb->len;
-	if (len < ETH_ZLEN) {
+	if (len < ETH_ZLEN)
 		len = ETH_ZLEN;
-		memset(tx_buf+VNET_PACKET_SKIP+skb->len, 0, len - skb->len);
+
+	port->tx_bufs[txi].skb = skb;
+	skb = NULL;
+
+	err = ldc_map_single(port->vio.lp, start, nlen,
+			     port->tx_bufs[txi].cookies, 2,
+			     (LDC_MAP_SHADOW | LDC_MAP_DIRECT | LDC_MAP_RW));
+	if (err < 0) {
+		netdev_info(dev, "tx buffer map error %d\n", err);
+		goto out_dropped_unlock;
 	}
+	port->tx_bufs[txi].ncookies = err;
 
 	/* We don't rely on the ACKs to free the skb in vnet_start_xmit(),
 	 * thus it is safe to not set VIO_ACK_ENABLE for each transmission:
@@ -830,9 +962,9 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	d->hdr.ack = VIO_ACK_DISABLE;
 	d->size = len;
-	d->ncookies = port->tx_bufs[dr->prod].ncookies;
+	d->ncookies = port->tx_bufs[txi].ncookies;
 	for (i = 0; i < d->ncookies; i++)
-		d->cookies[i] = port->tx_bufs[dr->prod].cookies[i];
+		d->cookies[i] = port->tx_bufs[txi].cookies[i];
 
 	/* This has to be a non-SMP write barrier because we are writing
 	 * to memory which is shared with the peer LDOM.
@@ -876,7 +1008,7 @@ ldc_start_done:
 	port->start_cons = false;
 
 	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += port->tx_bufs[txi].skb->len;
 
 	dr->prod = (dr->prod + 1) & (VNET_TX_RING_SIZE - 1);
 	if (unlikely(vnet_tx_dring_avail(dr) < 2)) {
@@ -887,7 +1019,9 @@ ldc_start_done:
 
 	spin_unlock_irqrestore(&port->vio.lock, flags);
 
-	dev_kfree_skb(skb);
+	vnet_free_skbs(freeskbs);
+
+	(void)mod_timer(&port->clean_timer, jiffies + VNET_CLEAN_TIMEOUT);
 
 	return NETDEV_TX_OK;
 
@@ -895,7 +1029,14 @@ out_dropped_unlock:
 	spin_unlock_irqrestore(&port->vio.lock, flags);
 
 out_dropped:
-	dev_kfree_skb(skb);
+	if (skb)
+		dev_kfree_skb(skb);
+	vnet_free_skbs(freeskbs);
+	if (pending)
+		(void)mod_timer(&port->clean_timer,
+				jiffies + VNET_CLEAN_TIMEOUT);
+	else
+		del_timer(&port->clean_timer);
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_OK;
 }
@@ -1097,17 +1238,22 @@ static void vnet_port_free_tx_bufs(struct vnet_port *port)
 	}
 
 	for (i = 0; i < VNET_TX_RING_SIZE; i++) {
-		void *buf = port->tx_bufs[i].buf;
+		struct vio_net_desc *d;
+		void *skb = port->tx_bufs[i].skb;
 
-		if (!buf)
+		if (!skb)
 			continue;
 
+		d = vio_dring_entry(dr, i);
+		if (d->hdr.state == VIO_DESC_READY)
+			pr_warn("active transmit buffers freed\n");
+
 		ldc_unmap(port->vio.lp,
 			  port->tx_bufs[i].cookies,
 			  port->tx_bufs[i].ncookies);
-
-		kfree(buf);
-		port->tx_bufs[i].buf = NULL;
+		dev_kfree_skb(skb);
+		port->tx_bufs[i].skb = NULL;
+		d->hdr.state = VIO_DESC_FREE;
 	}
 }
 
@@ -1118,34 +1264,6 @@ static int vnet_port_alloc_tx_bufs(struct vnet_port *port)
 	int i, err, ncookies;
 	void *dring;
 
-	for (i = 0; i < VNET_TX_RING_SIZE; i++) {
-		void *buf = kzalloc(VNET_MAXPACKET + 8, GFP_KERNEL);
-		int map_len = (VNET_MAXPACKET + 7) & ~7;
-
-		err = -ENOMEM;
-		if (!buf)
-			goto err_out;
-
-		err = -EFAULT;
-		if ((unsigned long)buf & (8UL - 1)) {
-			pr_err("TX buffer misaligned\n");
-			kfree(buf);
-			goto err_out;
-		}
-
-		err = ldc_map_single(port->vio.lp, buf, map_len,
-				     port->tx_bufs[i].cookies, 2,
-				     (LDC_MAP_SHADOW |
-				      LDC_MAP_DIRECT |
-				      LDC_MAP_RW));
-		if (err < 0) {
-			kfree(buf);
-			goto err_out;
-		}
-		port->tx_bufs[i].buf = buf;
-		port->tx_bufs[i].ncookies = err;
-	}
-
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
 
 	len = (VNET_TX_RING_SIZE *
@@ -1172,6 +1290,12 @@ static int vnet_port_alloc_tx_bufs(struct vnet_port *port)
 	dr->pending = VNET_TX_RING_SIZE;
 	dr->ncookies = ncookies;
 
+	for (i = 0; i < VNET_TX_RING_SIZE; ++i) {
+		struct vio_net_desc *d;
+
+		d = vio_dring_entry(dr, i);
+		d->hdr.state = VIO_DESC_FREE;
+	}
 	return 0;
 
 err_out:
@@ -1203,6 +1327,8 @@ static struct vnet *vnet_new(const u64 *local_mac)
 	dev = alloc_etherdev(sizeof(*vp));
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
+	dev->needed_headroom = VNET_PACKET_SKIP + 8;
+	dev->needed_tailroom = 8;
 
 	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = (*local_mac >> (5 - i) * 8) & 0xff;
@@ -1397,6 +1523,9 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	pr_info("%s: PORT ( remote-mac %pM%s )\n",
 		vp->dev->name, port->raddr, switch_port ? " switch-port" : "");
 
+	setup_timer(&port->clean_timer, vnet_clean_timer_expire,
+		    (unsigned long)port);
+
 	vio_port_up(&port->vio);
 
 	mdesc_release(hp);
@@ -1423,6 +1552,7 @@ static int vnet_port_remove(struct vio_dev *vdev)
 		unsigned long flags;
 
 		del_timer_sync(&port->vio.timer);
+		del_timer_sync(&port->clean_timer);
 
 		spin_lock_irqsave(&vp->lock, flags);
 		list_del(&port->list);
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index 986e04b..02f507d 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -11,6 +11,11 @@
  */
 #define VNET_TX_TIMEOUT			(5 * HZ)
 
+/* length of time (or less) we expect pending descriptors to be marked
+ * as VIO_DESC_DONE and skbs ready to be freed
+ */
+#define	VNET_CLEAN_TIMEOUT		((HZ/100)+1)
+
 #define VNET_MAXPACKET			1518ULL /* ETH_FRAMELEN + VLAN_HDR */
 #define VNET_TX_RING_SIZE		512
 #define VNET_TX_WAKEUP_THRESH(dr)	((dr)->pending / 4)
@@ -22,7 +27,7 @@
 #define VNET_PACKET_SKIP		6
 
 struct vnet_tx_entry {
-	void			*buf;
+	struct sk_buff		*skb;
 	unsigned int		ncookies;
 	struct ldc_trans_cookie	cookies[2];
 };
@@ -46,6 +51,8 @@ struct vnet_port {
 	bool			stop_rx;
 	bool			start_cons;
 
+	struct timer_list	clean_timer;
+
 	u64			rmtu;
 };
 
-- 
1.7.1
