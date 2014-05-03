From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v5 1/1] Driver for Beckhoff CX5020 EtherCAT master module.
Date: Sat, 3 May 2014 13:40:29 +0200
Message-ID: <20140503114029.GA19315@electric-eye.fr.zoreil.com>
References: <20140502175242.GB1156@newterm.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="h31gzZEtNLTqOjlF"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Darek Marcinkiewicz <reksio@newterm.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140502175242.GB1156@newterm.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Darek Marcinkiewicz <reksio@newterm.pl> :
[...]
> This driver adds support for EtherCAT master module located on CCAT
> FPGA found on Beckhoff CX series industrial PCs. The driver exposes
> EtherCAT master as an ethernet interface.
> 
> EtherCAT is a filedbus protocol defined on top of ethernet and Beckhoff

s/filedbus/fieldbus/ :o)

> CX5020 PCs come with built-in EtherCAT master module located on a FPGA,
> which in turn is connected to a PCI bus.
> 
> Signed-off-by: Dariusz Marcinkiewicz <reksio@newterm.pl>

I have attached four patches. Patch #3 / 4 contains a bugfix. Remaining
patches are small nits.

The points below are not showstoppers. Your answer will be welcome though.

If the tx_desc_free list can turn empty, I don't see much point for not
using an array as descriptor ring. It's quite common for linux ethernet
drivers.

Be it a list or an array, sizing it as the max count of descriptors that
could fit in the memory window through which packet descriptors _and_
ethernet data are copied seems overkill. It may be an upper bound though.
If you are not sure about a sane default value, ethtool API allows to
change the descriptor ring size.

Given the amount of debug messages, ethtool registers dump support could
be of some value.

I guess that the ASIC and the host CPU need some external polling to
communicate (no IRQ, really ?), whence the hrtimer. It should naturally
fit with NAPI. hrtimer could thus be disabled as soon as some ASIC event
is detected. It should save some hrtimer work when load increases and
the usual Tx lock avoidance patterns would kick in (current locking is
gross).

Did Beckhoff document their FPGA PCI interface ?

-- 
Ueimor

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-ec_bhf-inverted-xmas-tree.patch"

>From d2a5bfdc7854e9b3cffcab9249299354fa5037d0 Mon Sep 17 00:00:00 2001
Message-Id: <d2a5bfdc7854e9b3cffcab9249299354fa5037d0.1399110121.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 3 May 2014 11:15:26 +0200
Subject: [PATCH 1/4] ec_bhf: inverted xmas tree.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/ec_bhf.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
index 8e78b8d..9e1636b 100644
--- a/drivers/net/ethernet/ec_bhf.c
+++ b/drivers/net/ethernet/ec_bhf.c
@@ -205,8 +205,8 @@ static void ec_bhf_reset(struct ec_bhf_priv *priv)
 
 static void ec_bhf_send_packet(struct ec_bhf_priv *priv, struct tx_desc *desc)
 {
-	u32 addr = (u8 *)desc - priv->tx_buf.buf;
 	u32 len = le16_to_cpu(desc->header.len) + sizeof(desc->header);
+	u32 addr = (u8 *)desc - priv->tx_buf.buf;
 
 	iowrite32((ALIGN(len, 8) << 24) | addr, priv->fifo_io + FIFO_TX_REG);
 
@@ -598,11 +598,11 @@ static const struct net_device_ops ec_bhf_netdev_ops = {
 
 static int ec_bhf_probe(struct pci_dev *dev, const struct pci_device_id *id)
 {
-	int err = 0;
-	void * __iomem io;
-	void * __iomem dma_io;
 	struct net_device *net_dev;
 	struct ec_bhf_priv *priv;
+	void * __iomem dma_io;
+	void * __iomem io;
+	int err = 0;
 
 	err = pci_enable_device(dev);
 	if (err)
-- 
1.9.0


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0002-ec_bhf-line-breaks-and-indent.patch"

>From b64a35b7f4190a8126bc7b393370c711285f8c30 Mon Sep 17 00:00:00 2001
Message-Id: <b64a35b7f4190a8126bc7b393370c711285f8c30.1399110121.git.romieu@fr.zoreil.com>
In-Reply-To: <d2a5bfdc7854e9b3cffcab9249299354fa5037d0.1399110121.git.romieu@fr.zoreil.com>
References: <d2a5bfdc7854e9b3cffcab9249299354fa5037d0.1399110121.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 3 May 2014 11:31:55 +0200
Subject: [PATCH 2/4] ec_bhf: line breaks and indent.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/ec_bhf.c | 36 ++++++++++++++++--------------------
 1 file changed, 16 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
index 9e1636b..d33b691 100644
--- a/drivers/net/ethernet/ec_bhf.c
+++ b/drivers/net/ethernet/ec_bhf.c
@@ -168,23 +168,23 @@ static void ec_bhf_print_status(struct ec_bhf_priv *priv)
 	struct device *dev = PRIV_TO_DEV(priv);
 
 	dev_dbg(dev, "Frame error counter: %d\n",
-		 ioread8(priv->mac_io + MAC_FRAME_ERR_CNT));
+		ioread8(priv->mac_io + MAC_FRAME_ERR_CNT));
 	dev_dbg(dev, "RX error counter: %d\n",
-		 ioread8(priv->mac_io + MAC_RX_ERR_CNT));
+		ioread8(priv->mac_io + MAC_RX_ERR_CNT));
 	dev_dbg(dev, "CRC error counter: %d\n",
-		 ioread8(priv->mac_io + MAC_CRC_ERR_CNT));
+		ioread8(priv->mac_io + MAC_CRC_ERR_CNT));
 	dev_dbg(dev, "TX frame counter: %d\n",
-		 ioread32(priv->mac_io + MAC_TX_FRAME_CNT));
+		ioread32(priv->mac_io + MAC_TX_FRAME_CNT));
 	dev_dbg(dev, "RX frame counter: %d\n",
-		 ioread32(priv->mac_io + MAC_RX_FRAME_CNT));
+		ioread32(priv->mac_io + MAC_RX_FRAME_CNT));
 	dev_dbg(dev, "TX fifo level: %d\n",
-		 ioread8(priv->mac_io + MAC_TX_FIFO_LVL));
+		ioread8(priv->mac_io + MAC_TX_FIFO_LVL));
 	dev_dbg(dev, "Dropped frames: %d\n",
-		 ioread8(priv->mac_io + MAC_DROPPED_FRMS));
+		ioread8(priv->mac_io + MAC_DROPPED_FRMS));
 	dev_dbg(dev, "Connected with CCAT slot: %d\n",
-		 ioread8(priv->mac_io + MAC_CONNECTED_CCAT_FLAG));
+		ioread8(priv->mac_io + MAC_CONNECTED_CCAT_FLAG));
 	dev_dbg(dev, "Link status: %d\n",
-		 ioread8(priv->mii_io + MII_LINK_STATUS));
+		ioread8(priv->mii_io + MII_LINK_STATUS));
 }
 
 static void ec_bhf_reset(struct ec_bhf_priv *priv)
@@ -224,8 +224,7 @@ static void ec_bhf_process_tx(struct ec_bhf_priv *priv)
 	if (list_empty(&priv->tx_desc_queue))
 		goto out;
 
-	desc = list_first_entry(&priv->tx_desc_queue,
-				struct tx_desc, node);
+	desc = list_first_entry(&priv->tx_desc_queue, struct tx_desc, node);
 	sent = le32_to_cpu(desc->header.sent) & TX_HDR_SENT;
 	if (!sent)
 		goto out;
@@ -297,9 +296,8 @@ static void ec_bhf_process_rx(struct ec_bhf_priv *priv)
 
 static enum hrtimer_restart ec_bhf_timer_fun(struct hrtimer *timer)
 {
-	struct ec_bhf_priv *priv = container_of(timer,
-					struct ec_bhf_priv,
-					hrtimer);
+	struct ec_bhf_priv *priv = container_of(timer, struct ec_bhf_priv,
+						hrtimer);
 	ec_bhf_process_rx(priv);
 	ec_bhf_process_tx(priv);
 
@@ -429,8 +427,8 @@ static int ec_bhf_alloc_dma_mem(struct ec_bhf_priv *priv,
 
 	dev_info(dev, "Allocating %d bytes for channel %d",
 		(int)buf->alloc_len, channel);
-	buf->alloc = dma_alloc_coherent(dev, buf->alloc_len,
-					&buf->alloc_phys, GFP_KERNEL);
+	buf->alloc = dma_alloc_coherent(dev, buf->alloc_len, &buf->alloc_phys,
+					GFP_KERNEL);
 	if (buf->alloc == NULL) {
 		dev_info(dev, "Failed to allocate buffer\n");
 		return -ENOMEM;
@@ -529,8 +527,7 @@ static int ec_bhf_open(struct net_device *net_dev)
 
 	hrtimer_init(&priv->hrtimer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
 	priv->hrtimer.function = ec_bhf_timer_fun;
-	hrtimer_start(&priv->hrtimer,
-		      ktime_set(0, polling_frequency),
+	hrtimer_start(&priv->hrtimer, ktime_set(0, polling_frequency),
 		      HRTIMER_MODE_REL);
 
 	dev_info(PRIV_TO_DEV(priv), "Device open\n");
@@ -627,8 +624,7 @@ static int ec_bhf_probe(struct pci_dev *dev, const struct pci_device_id *id)
 
 	err = pci_request_regions(dev, "ec_bhf");
 	if (err) {
-		dev_err(&dev->dev,
-			"Failed to request pci memory regions\n");
+		dev_err(&dev->dev, "Failed to request pci memory regions\n");
 		goto err_disable_dev;
 	}
 
-- 
1.9.0


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0003-ec_bhf-rx_desc-vs-tx_desc-confusion.patch"

>From a687c964badc9d01e0d2ae269bc5d6996e508dd1 Mon Sep 17 00:00:00 2001
Message-Id: <a687c964badc9d01e0d2ae269bc5d6996e508dd1.1399110121.git.romieu@fr.zoreil.com>
In-Reply-To: <d2a5bfdc7854e9b3cffcab9249299354fa5037d0.1399110121.git.romieu@fr.zoreil.com>
References: <d2a5bfdc7854e9b3cffcab9249299354fa5037d0.1399110121.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 3 May 2014 11:36:12 +0200
Subject: [PATCH 3/4] ec_bhf: rx_desc vs tx_desc confusion.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/ec_bhf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
index d33b691..c697b48 100644
--- a/drivers/net/ethernet/ec_bhf.c
+++ b/drivers/net/ethernet/ec_bhf.c
@@ -453,7 +453,7 @@ static void ec_bhf_setup_tx_descs(struct ec_bhf_priv *priv)
 	INIT_LIST_HEAD(&priv->tx_desc_free);
 	INIT_LIST_HEAD(&priv->tx_desc_queue);
 
-	dcount = priv->tx_buf.len / sizeof(struct rx_desc);
+	dcount = priv->tx_buf.len / sizeof(struct tx_desc);
 	for (i = 0; i < dcount; i++) {
 		struct tx_desc *desc = descs + i;
 		list_add_tail(&desc->node, &priv->tx_desc_free);
-- 
1.9.0


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0004-ec_bhf-use-once-variable-removal.patch"

>From d47e13a4a22a5e5ebc32d88397acd702f1ae95d4 Mon Sep 17 00:00:00 2001
Message-Id: <d47e13a4a22a5e5ebc32d88397acd702f1ae95d4.1399110121.git.romieu@fr.zoreil.com>
In-Reply-To: <d2a5bfdc7854e9b3cffcab9249299354fa5037d0.1399110121.git.romieu@fr.zoreil.com>
References: <d2a5bfdc7854e9b3cffcab9249299354fa5037d0.1399110121.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 3 May 2014 11:40:37 +0200
Subject: [PATCH 4/4] ec_bhf: use once variable removal.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/ec_bhf.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
index c697b48..10dbcc4 100644
--- a/drivers/net/ethernet/ec_bhf.c
+++ b/drivers/net/ethernet/ec_bhf.c
@@ -448,16 +448,13 @@ static int ec_bhf_alloc_dma_mem(struct ec_bhf_priv *priv,
 static void ec_bhf_setup_tx_descs(struct ec_bhf_priv *priv)
 {
 	struct tx_desc *descs = (struct tx_desc *) priv->tx_buf.buf;
-	int dcount, i;
+	int i;
 
 	INIT_LIST_HEAD(&priv->tx_desc_free);
 	INIT_LIST_HEAD(&priv->tx_desc_queue);
 
-	dcount = priv->tx_buf.len / sizeof(struct tx_desc);
-	for (i = 0; i < dcount; i++) {
-		struct tx_desc *desc = descs + i;
-		list_add_tail(&desc->node, &priv->tx_desc_free);
-	}
+	for (i = 0; i < priv->tx_buf.len / sizeof(struct tx_desc); i++)
+		list_add_tail(&descs[i].node, &priv->tx_desc_free);
 }
 
 static void ec_bhf_setup_rx_descs(struct ec_bhf_priv *priv)
-- 
1.9.0


--h31gzZEtNLTqOjlF--
