From: Darek Marcinkiewicz <reksio@newterm.pl>
Subject: Re: [PATCH v5 1/1] Driver for Beckhoff CX5020 EtherCAT master module.
Date: Sun, 4 May 2014 13:04:14 +0200
Message-ID: <20140504110413.GE1156@newterm.pl>
References: <20140502175242.GB1156@newterm.pl>
 <20140503114029.GA19315@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140503114029.GA19315@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, May 03, 2014 at 01:40:29PM +0200, Francois Romieu wrote:
> Darek Marcinkiewicz <reksio@newterm.pl> :
> [...]
> > This driver adds support for EtherCAT master module located on CCAT
> > FPGA found on Beckhoff CX series industrial PCs. The driver exposes
> > EtherCAT master as an ethernet interface.
> > 
> > EtherCAT is a filedbus protocol defined on top of ethernet and Beckhoff
> 
> s/filedbus/fieldbus/ :o)
> 
Ops :) Fixed in next revision of the patch.
> > CX5020 PCs come with built-in EtherCAT master module located on a FPGA,
> > which in turn is connected to a PCI bus.
> > 
> > Signed-off-by: Dariusz Marcinkiewicz <reksio@newterm.pl>
> 
> I have attached four patches. Patch #3 / 4 contains a bugfix. Remaining
> patches are small nits.
> 
Thank you. I am attaching 2 of thse to this repsonse - the other two 
are no longer relevant due to the changes I made into the driver.
One of the attached patches is slightly modfied by simply having one hunk
removed (that hunk was applying to the code that was removed in next rev 
of the driver). Not sure how to proceed with those patches, shall I simply
sent out these patches to this list as a separate messages?

> The points below are not showstoppers. Your answer will be welcome though.
> 
> If the tx_desc_free list can turn empty, I don't see much point for not
> using an array as descriptor ring. It's quite common for linux ethernet
> drivers.
> 
I have switched the code to use array of descriptors. Yep, lists do
not make too much sense here.

> Be it a list or an array, sizing it as the max count of descriptors that
> could fit in the memory window through which packet descriptors _and_
> ethernet data are copied seems overkill. It may be an upper bound though.
> If you are not sure about a sane default value, ethtool API allows to
> change the descriptor ring size.
> 
I have changed the code to use much modest value - it is set to be of the
size of the fifo now. I think that this value is much better, but of course
having this configurable would be even better.

> Given the amount of debug messages, ethtool registers dump support could
> be of some value.
> 
> I guess that the ASIC and the host CPU need some external polling to
> communicate (no IRQ, really ?), whence the hrtimer. It should naturally
> fit with NAPI. hrtimer could thus be disabled as soon as some ASIC event
> is detected. It should save some hrtimer work when load increases and
> the usual Tx lock avoidance patterns would kick in (current locking is
> gross).
> 
No, there is really no interrupt, hence the timer. Also on this device I wouldn't 
expect any bursts of data. What happens here, during regular operation of the 
device, is a periodic exchange of (few) ethernet packets between host cpu and
terminals attached to the EtherCAT bus. As for the locking on the tx path,
I have removed that completely on receiving path. I simply didn't know 
that it is such a big no-no here :)

> Did Beckhoff document their FPGA PCI interface ?
> 

Yes. It took a lot of nagging but I got some documentation from them, together
with a sample code showing how to use dma interface and generally interact with
the device.


Thank you!
-- 
DM

--zYM0uCDKw75PZbzx
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-ec_bhf-inverted-xmas-tree.patch"

>From 4254a10cb8407634c94882f0f64c8e4a7f84b852 Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 3 May 2014 11:15:26 +0200
Subject: [PATCH 1/2] ec_bhf: inverted xmas tree.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/ec_bhf.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
index feb40cd..e6e303c 100644
--- a/drivers/net/ethernet/ec_bhf.c
+++ b/drivers/net/ethernet/ec_bhf.c
@@ -204,8 +204,8 @@ static void ec_bhf_reset(struct ec_bhf_priv *priv)
 
 static void ec_bhf_send_packet(struct ec_bhf_priv *priv, struct tx_desc *desc)
 {
-	u32 addr = (u8 *)desc - priv->tx_buf.buf;
 	u32 len = le16_to_cpu(desc->header.len) + sizeof(desc->header);
+	u32 addr = (u8 *)desc - priv->tx_buf.buf;
 
 	iowrite32((ALIGN(len, 8) << 24) | addr, priv->fifo_io + FIFO_TX_REG);
 
@@ -561,11 +561,11 @@ static const struct net_device_ops ec_bhf_netdev_ops = {
 
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
1.7.10.4


--zYM0uCDKw75PZbzx
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0002-ec_bhf-line-breaks-and-indent.patch"

>From d20cec3758521de9c5c9c7a35c0a96a3671bc2c2 Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 3 May 2014 11:31:55 +0200
Subject: [PATCH 2/2] ec_bhf: line breaks and indent.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/ec_bhf.c |   33 +++++++++++++++------------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
index e6e303c..46618b9 100644
--- a/drivers/net/ethernet/ec_bhf.c
+++ b/drivers/net/ethernet/ec_bhf.c
@@ -167,23 +167,23 @@ static void ec_bhf_print_status(struct ec_bhf_priv *priv)
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
@@ -277,9 +277,8 @@ static void ec_bhf_process_rx(struct ec_bhf_priv *priv)
 
 static enum hrtimer_restart ec_bhf_timer_fun(struct hrtimer *timer)
 {
-	struct ec_bhf_priv *priv = container_of(timer,
-					struct ec_bhf_priv,
-					hrtimer);
+	struct ec_bhf_priv *priv = container_of(timer, struct ec_bhf_priv,
+						hrtimer);
 	ec_bhf_process_rx(priv);
 	ec_bhf_process_tx(priv);
 
@@ -401,8 +400,8 @@ static int ec_bhf_alloc_dma_mem(struct ec_bhf_priv *priv,
 
 	dev_info(dev, "Allocating %d bytes for channel %d",
 		(int)buf->alloc_len, channel);
-	buf->alloc = dma_alloc_coherent(dev, buf->alloc_len,
-					&buf->alloc_phys, GFP_KERNEL);
+	buf->alloc = dma_alloc_coherent(dev, buf->alloc_len, &buf->alloc_phys,
+					GFP_KERNEL);
 	if (buf->alloc == NULL) {
 		dev_info(dev, "Failed to allocate buffer\n");
 		return -ENOMEM;
@@ -492,8 +491,7 @@ static int ec_bhf_open(struct net_device *net_dev)
 
 	hrtimer_init(&priv->hrtimer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
 	priv->hrtimer.function = ec_bhf_timer_fun;
-	hrtimer_start(&priv->hrtimer,
-		      ktime_set(0, polling_frequency),
+	hrtimer_start(&priv->hrtimer, ktime_set(0, polling_frequency),
 		      HRTIMER_MODE_REL);
 
 	dev_info(PRIV_TO_DEV(priv), "Device open\n");
@@ -590,8 +588,7 @@ static int ec_bhf_probe(struct pci_dev *dev, const struct pci_device_id *id)
 
 	err = pci_request_regions(dev, "ec_bhf");
 	if (err) {
-		dev_err(&dev->dev,
-			"Failed to request pci memory regions\n");
+		dev_err(&dev->dev, "Failed to request pci memory regions\n");
 		goto err_disable_dev;
 	}
 
-- 
1.7.10.4


--zYM0uCDKw75PZbzx--
