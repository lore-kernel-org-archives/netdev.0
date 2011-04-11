From: sjur.brandeland@stericsson.com
Subject: [PATCHv2] caif: Add CAIF HSI Link Layer
Date: Mon, 11 Apr 2011 22:05:20 +0200
Message-ID: <1302552320-11549-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linus.walleij@stericsson.com,
	sjurbren@gmail.com,
	Daniel Martensson <daniel.martensson@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:63238 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507Ab1DKVFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 17:05:30 -0400
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI009XM7T0EF70@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:05:24 +0200 (CEST)
Received: from localhost.localdomain ([80.203.137.187])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI008LL7SYJMS0@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:05:24 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Martensson <daniel.martensson@stericsson.com>

This patch introduces the CAIF HSI Protocol Driver for the
CAIF Link Layer.

This driver implements a platform driver to accommodate for a
platform specific HSI devices. A general platform driver is not
possible as there are no HSI side Kernel API defined.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---

Hi Dave,

>> +static int cfhsi_tx_frm(struct cfhsi_desc *desc, struct cfhsi *cfhs=
i)
>
>I do not see what kind of locking prevents multiple threads of control
>from entering this function at the same time, making your skb_peek()
>sequences illegal.

Thanks, good catch.
I've made cfhsi_tx_frm lock protected (by moving some spin_unlock)
and added a WARN_ON(!spin_is_locked(...)) to be safe.

Regards,
Sjur

 drivers/net/caif/Kconfig    |    9 +
 drivers/net/caif/Makefile   |    3 +
 drivers/net/caif/caif_hsi.c |  623 +++++++++++++++++++++++++++++++++++=
++++++++
 include/net/caif/caif_hsi.h |  105 ++++++++
 4 files changed, 740 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/caif/caif_hsi.c
 create mode 100644 include/net/caif/caif_hsi.h

diff --git a/drivers/net/caif/Kconfig b/drivers/net/caif/Kconfig
index 09ed3f4..0d4427e 100644
--- a/drivers/net/caif/Kconfig
+++ b/drivers/net/caif/Kconfig
@@ -38,3 +38,12 @@ config CAIF_SHM
 	default n
 	---help---
 	The CAIF shared memory protocol driver for the STE UX5500 platform.
+
+config CAIF_HSI
+	tristate "CAIF HSI transport driver"
+	depends on CAIF
+	default n
+	---help---
+	The caif low level driver for CAIF over HSI.
+	Be aware that if you enable this then you also need to
+	enable a low-level HSI driver.
diff --git a/drivers/net/caif/Makefile b/drivers/net/caif/Makefile
index 9560b9d..91dff86 100644
--- a/drivers/net/caif/Makefile
+++ b/drivers/net/caif/Makefile
@@ -10,3 +10,6 @@ obj-$(CONFIG_CAIF_SPI_SLAVE) +=3D cfspi_slave.o
 # Shared memory
 caif_shm-objs :=3D caif_shmcore.o caif_shm_u5500.o
 obj-$(CONFIG_CAIF_SHM) +=3D caif_shm.o
+
+# HSI interface
+obj-$(CONFIG_CAIF_HSI) +=3D caif_hsi.o
diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
new file mode 100644
index 0000000..0df0e01
--- /dev/null
+++ b/drivers/net/caif/caif_hsi.c
@@ -0,0 +1,623 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2011
+ * Contact: Sjur Brendeland / sjur.brandeland@stericsson.com
+ * Author:  Daniel Martensson / Daniel.Martensson@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2.
+ */
+
+#include <linux/module.h>
+#include <linux/platform_device.h>
+#include <linux/list.h>
+#include <linux/if_arp.h>
+#include <net/caif/caif_hsi.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Daniel Martensson<daniel.martensson@stericsson.com>");
+MODULE_DESCRIPTION("CAIF HSI driver");
+
+/* Returns the number of padding bytes for alignment. */
+#define PAD_POW2(x, pow) ((((x)&((pow)-1)) =3D=3D 0) ? 0 : \
+				(((pow)-((x)&((pow)-1)))))
+
+/*
+ * HSI padding options.
+ * Warning: must be a base of 2 (& operation used) and can not be zero=
 !
+ */
+static int hsi_head_align =3D 4;
+module_param(hsi_head_align, int, S_IRUGO);
+MODULE_PARM_DESC(hsi_head_align, "HSI head alignment.");
+
+static int hsi_tail_align =3D 4;
+module_param(hsi_tail_align, int, S_IRUGO);
+MODULE_PARM_DESC(hsi_tail_align, "HSI tail alignment.");
+
+/*
+ * HSI link layer flowcontrol thresholds.
+ * Warning: A high threshold value migth increase throughput but it wi=
ll at
+ * the same time prevent channel prioritization and increase the risk =
of
+ * flooding the modem. The high threshold should be above the low.
+ */
+static int hsi_high_threshold =3D 100;
+module_param(hsi_high_threshold, int, S_IRUGO);
+MODULE_PARM_DESC(hsi_high_threshold, "HSI high threshold (FLOW OFF).")=
;
+
+static int hsi_low_threshold =3D 50;
+module_param(hsi_low_threshold, int, S_IRUGO);
+MODULE_PARM_DESC(hsi_low_threshold, "HSI high threshold (FLOW ON).");
+
+#define ON 1
+#define OFF 0
+
+/*
+ * Threshold values for the HSI packet queue. Flowcontrol will be asse=
rted
+ * when the number of packets exceeds HIGH_WATER_MARK. It will not be
+ * de-asserted before the number of packets drops below LOW_WATER_MARK=
=2E
+ */
+#define LOW_WATER_MARK   hsi_low_threshold
+#define HIGH_WATER_MARK  hsi_high_threshold
+
+static LIST_HEAD(cfhsi_list);
+static spinlock_t cfhsi_list_lock;
+
+static int cfhsi_tx_frm(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
+{
+	int nfrms =3D 0;
+	int pld_len =3D 0;
+	struct sk_buff *skb;
+	u8 *pfrm =3D desc->emb_frm + CFHSI_MAX_EMB_FRM_SZ;
+
+	WARN_ON(!spin_is_locked(&cfhsi->lock));
+	skb =3D skb_peek(&cfhsi->qhead);
+	if (!skb)
+		return 0;
+
+	/* Check if we can embed a CAIF frame. */
+	if (skb->len < CFHSI_MAX_EMB_FRM_SZ) {
+		struct caif_payload_info *info;
+		int hpad =3D 0;
+		int tpad =3D 0;
+
+		/* Calculate needed head alignment and tail alignment. */
+		info =3D (struct caif_payload_info *)&skb->cb;
+
+		hpad =3D 1 + PAD_POW2((info->hdr_len + 1), hsi_head_align);
+		tpad =3D PAD_POW2((skb->len + hpad), hsi_tail_align);
+
+		/* Check if frame still fits with added alignment. */
+		if ((skb->len + hpad + tpad) <=3D CFHSI_MAX_EMB_FRM_SZ) {
+			u8 *pemb =3D desc->emb_frm;
+			skb =3D skb_dequeue(&cfhsi->qhead);
+			desc->offset =3D CFHSI_DESC_SHORT_SZ;
+			*pemb =3D (u8)(hpad - 1);
+			pemb +=3D hpad;
+
+			/* Copy in embedded CAIF frame. */
+			skb_copy_bits(skb, 0, pemb, skb->len);
+			kfree_skb(skb);
+		}
+	} else
+		/* Clear offset. */
+		desc->offset =3D 0;
+
+
+	/* Create payload CAIF frames. */
+	pfrm =3D desc->emb_frm + CFHSI_MAX_EMB_FRM_SZ;
+	while (skb_peek(&cfhsi->qhead) && nfrms < CFHSI_MAX_PKTS) {
+		struct caif_payload_info *info;
+		int hpad =3D 0;
+		int tpad =3D 0;
+
+		skb =3D skb_dequeue(&cfhsi->qhead);
+
+		/* Calculate needed head alignment and tail alignment. */
+		info =3D (struct caif_payload_info *)&skb->cb;
+
+		hpad =3D 1 + PAD_POW2((info->hdr_len + 1), hsi_head_align);
+		tpad =3D PAD_POW2((skb->len + hpad), hsi_tail_align);
+
+		/* Fill in CAIF frame length in descriptor. */
+		desc->cffrm_len[nfrms] =3D hpad + skb->len + tpad;
+
+		/* Fill head padding information. */
+		*pfrm =3D (u8)(hpad - 1);
+		pfrm +=3D hpad;
+
+		/* Copy in CAIF frame. */
+		skb_copy_bits(skb, 0, pfrm, skb->len);
+		kfree_skb(skb);
+
+		/* Update payload length. */
+		pld_len +=3D desc->cffrm_len[nfrms];
+
+		/* Update frame pointer. */
+		pfrm +=3D skb->len + tpad;
+
+		/* Update number of frames. */
+		nfrms++;
+	}
+
+	/* Unused length fields should be zero-filled (according to SPEC). */
+	while (nfrms < CFHSI_MAX_PKTS) {
+		desc->cffrm_len[nfrms] =3D 0x0000;
+		nfrms++;
+	}
+
+	/* Check if we can piggy-back another descriptor. */
+	skb =3D skb_peek(&cfhsi->qhead);
+	if (skb)
+		desc->header |=3D CFHSI_PIGGY_DESC;
+	else
+		desc->header &=3D ~CFHSI_PIGGY_DESC;
+
+	return CFHSI_DESC_SZ + pld_len;
+}
+
+static void cfhsi_tx_done_cb(struct cfhsi_drv *drv)
+{
+	struct cfhsi *cfhsi =3D NULL;
+	struct cfhsi_desc *desc =3D NULL;
+	struct sk_buff *skb;
+	unsigned long flags;
+	int len =3D 0;
+
+	cfhsi =3D container_of(drv, struct cfhsi, drv);
+	desc =3D (struct cfhsi_desc *)cfhsi->tx_buf;
+
+	spin_lock_irqsave(&cfhsi->lock, flags);
+
+	/*
+	 * Send flow on if flow off has been previously signalled
+	 * and number of packets is below low water mark.
+	 */
+	if (cfhsi->flow_off_sent && cfhsi->qhead.qlen <=3D cfhsi->q_low_mark =
&&
+		cfhsi->cfdev.flowctrl) {
+		cfhsi->flow_off_sent =3D 0;
+		cfhsi->cfdev.flowctrl(cfhsi->ndev, ON);
+	}
+
+	skb =3D skb_peek(&cfhsi->qhead);
+	if (!skb) {
+		cfhsi->tx_state =3D CFHSI_TX_STATE_IDLE;
+		spin_unlock_irqrestore(&cfhsi->lock, flags);
+		return;
+	}
+
+
+	/* Create HSI frame. */
+	len =3D cfhsi_tx_frm(desc, cfhsi);
+	BUG_ON(!len);
+	spin_unlock_irqrestore(&cfhsi->lock, flags);
+
+	/* Set up new transfer. */
+	cfhsi->dev->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->dev);
+}
+
+static int cfhsi_rx_desc(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
+{
+	int xfer_sz =3D 0;
+	int nfrms =3D 0;
+	u16 *plen =3D NULL;
+	u8 *pfrm =3D NULL;
+
+	/* Sanity check header and offset. */
+	BUG_ON(desc->header & ~CFHSI_PIGGY_DESC);
+	BUG_ON(desc->offset > CFHSI_MAX_EMB_FRM_SZ);
+
+	/* Check for embedded CAIF frame. */
+	if (desc->offset) {
+		struct sk_buff *skb =3D NULL;
+		u8 *dst =3D NULL;
+		int len =3D 0;
+		pfrm =3D ((u8 *)desc) + desc->offset;
+
+		/* Remove offset padding. */
+		pfrm +=3D *pfrm + 1;
+
+		/* Read length of CAIF frame (little endian). */
+		len =3D *pfrm;
+		len |=3D ((*(pfrm+1)) << 8) & 0xFF00;
+		/* Add FCS fields. */
+		len +=3D 2;
+
+		/* Allocate SKB (OK even in IRQ context). */
+		skb =3D netdev_alloc_skb(cfhsi->ndev, len + 1);
+		if (skb =3D=3D NULL)
+			goto err;
+
+		dst =3D skb_put(skb, len);
+		memcpy(dst, pfrm, len);
+
+		skb->protocol =3D htons(ETH_P_CAIF);
+		skb_reset_mac_header(skb);
+		skb->dev =3D cfhsi->ndev;
+
+		/*
+		 * We are called from a arch specific platform device.
+		 * Unfortunately we don't know what context we're
+		 * running in. HSI might well run in a work queue as
+		 * the HSI protocol might require the driver to sleep.
+		 */
+		if (in_interrupt())
+			(void)netif_rx(skb);
+		else
+			(void)netif_rx_ni(skb);
+
+		/* Update statistics. */
+		cfhsi->ndev->stats.rx_packets++;
+		cfhsi->ndev->stats.rx_bytes +=3D len;
+	}
+
+	/* Calculate transfer length. */
+	plen =3D desc->cffrm_len;
+	while (nfrms < CFHSI_MAX_PKTS && *plen) {
+		xfer_sz +=3D *plen;
+		plen++;
+		nfrms++;
+	}
+
+	/* Check for piggy-backed descriptor. */
+	if (desc->header & CFHSI_PIGGY_DESC)
+		xfer_sz +=3D CFHSI_DESC_SZ;
+
+err:
+	return xfer_sz;
+}
+
+static int cfhsi_rx_pld(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
+{
+	int rx_sz =3D 0;
+	int nfrms =3D 0;
+	u16 *plen =3D NULL;
+	u8 *pfrm =3D NULL;
+
+	/* Sanity check header and offset. */
+	BUG_ON(desc->header & ~CFHSI_PIGGY_DESC);
+	BUG_ON(desc->offset > CFHSI_MAX_EMB_FRM_SZ);
+
+	/* Set frame pointer to start of payload. */
+	pfrm =3D desc->emb_frm + CFHSI_MAX_EMB_FRM_SZ;
+	plen =3D desc->cffrm_len;
+	while (nfrms < CFHSI_MAX_PKTS && *plen) {
+		struct sk_buff *skb;
+		u8 *dst =3D NULL;
+		u8 *pcffrm =3D NULL;
+		int len =3D 0;
+
+		BUG_ON(desc->cffrm_len[nfrms] > CFHSI_MAX_PAYLOAD_SZ);
+
+		/* CAIF frame starts after head padding. */
+		pcffrm =3D pfrm + *pfrm + 1;
+
+		/* Read length of CAIF frame (little endian). */
+		len =3D *pcffrm;
+		len |=3D ((*(pcffrm + 1)) << 8) & 0xFF00;
+		/* Add FCS fields. */
+		len +=3D 2;
+
+		/* Allocate SKB (OK even in IRQ context). */
+		skb =3D netdev_alloc_skb(cfhsi->ndev, len + 1);
+		if (skb =3D=3D NULL)
+			goto err;
+
+		dst =3D skb_put(skb, len);
+		memcpy(dst, pcffrm, len);
+
+		skb->protocol =3D htons(ETH_P_CAIF);
+		skb_reset_mac_header(skb);
+		skb->dev =3D cfhsi->ndev;
+
+		/*
+		 * As explained above we're called from a platform
+		 * device, and don't know the context we're running in.
+		 */
+		if (in_interrupt())
+			(void)netif_rx(skb);
+		else
+			(void)netif_rx_ni(skb);
+
+		/* Update statistics. */
+		cfhsi->ndev->stats.rx_packets++;
+		cfhsi->ndev->stats.rx_bytes +=3D len;
+
+		pfrm +=3D *plen;
+		rx_sz +=3D *plen;
+		plen++;
+		nfrms++;
+	}
+
+err:
+	return rx_sz;
+}
+
+static void cfhsi_rx_done_cb(struct cfhsi_drv *drv)
+{
+	struct cfhsi *cfhsi =3D NULL;
+	struct cfhsi_desc *desc =3D NULL;
+	int len =3D 0;
+	u8 *ptr =3D NULL;
+
+	cfhsi =3D container_of(drv, struct cfhsi, drv);
+	desc =3D (struct cfhsi_desc *)cfhsi->rx_buf;
+
+	if (cfhsi->rx_state =3D=3D CFHSI_RX_STATE_DESC)
+		len =3D cfhsi_rx_desc(desc, cfhsi);
+	else {
+		int pld_len =3D cfhsi_rx_pld(desc, cfhsi);
+
+		if (desc->header & CFHSI_PIGGY_DESC) {
+			struct cfhsi_desc *piggy_desc;
+			piggy_desc =3D (struct cfhsi_desc *)(desc->emb_frm +
+						CFHSI_MAX_EMB_FRM_SZ + pld_len);
+
+			/* Extract piggy-backed descriptor. */
+			len =3D cfhsi_rx_desc(piggy_desc, cfhsi);
+
+			/*
+			 * Copy needed information from the piggy-backed
+			 * descriptor to the descriptor in the start.
+			 */
+			memcpy((u8 *)desc, (u8 *)piggy_desc,
+					CFHSI_DESC_SHORT_SZ);
+		}
+	}
+
+	if (len) {
+		cfhsi->rx_state =3D CFHSI_RX_STATE_PAYLOAD;
+		ptr =3D cfhsi->rx_buf + CFHSI_DESC_SZ;
+	} else {
+		len =3D CFHSI_DESC_SZ;
+		cfhsi->rx_state =3D CFHSI_RX_STATE_DESC;
+		ptr =3D cfhsi->rx_buf;
+	}
+
+	/* Set up new transfer. */
+	cfhsi->dev->cfhsi_rx(ptr, len, cfhsi->dev);
+}
+
+static int cfhsi_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct cfhsi *cfhsi =3D NULL;
+	unsigned long flags;
+	int start_xfer =3D 0;
+
+	if (!dev)
+		return -EINVAL;
+
+	cfhsi =3D netdev_priv(dev);
+
+	spin_lock_irqsave(&cfhsi->lock, flags);
+
+	skb_queue_tail(&cfhsi->qhead, skb);
+
+	/* Send flow off if number of packets is above high water mark. */
+	if (!cfhsi->flow_off_sent &&
+		cfhsi->qhead.qlen > cfhsi->q_high_mark &&
+		cfhsi->cfdev.flowctrl) {
+		cfhsi->flow_off_sent =3D 1;
+		cfhsi->cfdev.flowctrl(cfhsi->ndev, OFF);
+	}
+
+	if (cfhsi->tx_state =3D=3D CFHSI_TX_STATE_IDLE) {
+		cfhsi->tx_state =3D CFHSI_TX_STATE_XFER;
+		start_xfer =3D 1;
+	}
+
+	if (start_xfer) {
+		struct cfhsi_desc *desc =3D (struct cfhsi_desc *) cfhsi->tx_buf;
+		int len;
+
+		/* Create HSI frame. */
+		len =3D cfhsi_tx_frm(desc, cfhsi);
+		BUG_ON(!len);
+
+		spin_unlock_irqrestore(&cfhsi->lock, flags);
+
+		/* Set up new transfer. */
+		cfhsi->dev->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->dev);
+		return 0;
+	}
+
+	spin_unlock_irqrestore(&cfhsi->lock, flags);
+	return 0;
+}
+
+static int cfhsi_open(struct net_device *dev)
+{
+	netif_wake_queue(dev);
+
+	return 0;
+}
+
+static int cfhsi_close(struct net_device *dev)
+{
+	netif_stop_queue(dev);
+
+	return 0;
+}
+static const struct net_device_ops cfhsi_ops =3D {
+	.ndo_open =3D cfhsi_open,
+	.ndo_stop =3D cfhsi_close,
+	.ndo_start_xmit =3D cfhsi_xmit
+};
+
+static void cfhsi_setup(struct net_device *dev)
+{
+	struct cfhsi *cfhsi =3D netdev_priv(dev);
+	dev->features =3D 0;
+	dev->netdev_ops =3D &cfhsi_ops;
+	dev->type =3D ARPHRD_CAIF;
+	dev->flags =3D IFF_POINTOPOINT | IFF_NOARP;
+	dev->mtu =3D CFHSI_MAX_PAYLOAD_SZ;
+	dev->tx_queue_len =3D 0;
+	dev->destructor =3D free_netdev;
+	skb_queue_head_init(&cfhsi->qhead);
+	cfhsi->cfdev.link_select =3D CAIF_LINK_HIGH_BANDW;
+	cfhsi->cfdev.use_frag =3D false;
+	cfhsi->cfdev.use_stx =3D false;
+	cfhsi->cfdev.use_fcs =3D false;
+	cfhsi->ndev =3D dev;
+}
+
+static int cfhsi_probe(struct platform_device *pdev)
+{
+	struct cfhsi *cfhsi =3D NULL;
+	struct net_device *ndev;
+	struct cfhsi_dev *dev;
+	int res;
+
+	ndev =3D alloc_netdev(sizeof(struct cfhsi), "cfhsi%d", cfhsi_setup);
+	if (!ndev) {
+		printk(KERN_INFO "cfhsi_probe: alloc_netdev failed.\n");
+		return -ENODEV;
+	}
+
+	cfhsi =3D netdev_priv(ndev);
+	netif_stop_queue(ndev);
+	cfhsi->ndev =3D ndev;
+	cfhsi->pdev =3D pdev;
+
+	/* Initialize state vaiables. */
+	cfhsi->tx_state =3D CFHSI_TX_STATE_IDLE;
+	cfhsi->rx_state =3D CFHSI_RX_STATE_DESC;
+
+	/* Set flow info */
+	cfhsi->flow_off_sent =3D 0;
+	cfhsi->q_low_mark =3D LOW_WATER_MARK;
+	cfhsi->q_high_mark =3D HIGH_WATER_MARK;
+
+	/* Assign the HSI device. */
+	dev =3D (struct cfhsi_dev *)pdev->dev.platform_data;
+	cfhsi->dev =3D dev;
+
+	/* Assign the driver to this HSI device. */
+	dev->drv =3D &cfhsi->drv;
+
+	/*
+	 * Allocate a TX buffer with the size of a HSI packet descriptors
+	 * and the necessary room for CAIF payload frames.
+	 */
+	cfhsi->tx_buf =3D kzalloc(CFHSI_BUF_SZ_TX, GFP_KERNEL);
+	if (!cfhsi->tx_buf) {
+		printk(KERN_ERR "cfhsi: failed to allocate TX buffer.\n");
+		res =3D -ENODEV;
+		goto err_alloc_tx;
+	}
+
+	/*
+	 * Allocate a RX buffer with the size of two HSI packet descriptors a=
nd
+	 * the necessary room for CAIF payload frames.
+	 */
+	cfhsi->rx_buf =3D kzalloc(CFHSI_BUF_SZ_RX, GFP_KERNEL);
+	if (!cfhsi->rx_buf) {
+		printk(KERN_ERR "cfhsi: failed to allocate RX buffer.\n");
+		res =3D -ENODEV;
+		goto err_alloc_rx;
+	}
+
+	/* Initialize spin locks. */
+	spin_lock_init(&cfhsi->lock);
+
+	/* Set up the driver. */
+	cfhsi->drv.tx_done_cb =3D cfhsi_tx_done_cb;
+	cfhsi->drv.rx_done_cb =3D cfhsi_rx_done_cb;
+
+	/* Add CAIF HSI device to list. */
+	spin_lock(&cfhsi_list_lock);
+	list_add_tail(&cfhsi->list, &cfhsi_list);
+	spin_unlock(&cfhsi_list_lock);
+
+	/* Register network device. */
+	res =3D register_netdev(ndev);
+	if (res) {
+		printk(KERN_ERR "cfhsi: Reg. error: %d.\n", res);
+		goto err_net_reg;
+	}
+
+	/* Start an initial read operation. */
+	cfhsi->dev->cfhsi_rx(cfhsi->rx_buf, CFHSI_DESC_SZ, cfhsi->dev);
+
+	return res;
+
+ err_net_reg:
+	kfree(cfhsi->rx_buf);
+ err_alloc_rx:
+	kfree(cfhsi->tx_buf);
+ err_alloc_tx:
+	free_netdev(ndev);
+
+	return res;
+}
+
+static int cfhsi_remove(struct platform_device *pdev)
+{
+	struct list_head *list_node;
+	struct list_head *n;
+	struct cfhsi *cfhsi =3D NULL;
+	struct cfhsi_dev *dev;
+
+	dev =3D (struct cfhsi_dev *)pdev->dev.platform_data;
+	spin_lock(&cfhsi_list_lock);
+	list_for_each_safe(list_node, n, &cfhsi_list) {
+		cfhsi =3D list_entry(list_node, struct cfhsi, list);
+		/* Find the corresponding device. */
+		if (cfhsi->dev =3D=3D dev) {
+			/* Remove from list. */
+			list_del(list_node);
+			/* Free buffers. */
+			kfree(cfhsi->tx_buf);
+			kfree(cfhsi->rx_buf);
+			unregister_netdev(cfhsi->ndev);
+			spin_unlock(&cfhsi_list_lock);
+			return 0;
+		}
+	}
+	spin_unlock(&cfhsi_list_lock);
+	return -ENODEV;
+}
+
+struct platform_driver cfhsi_plat_drv =3D {
+	.probe =3D cfhsi_probe,
+	.remove =3D cfhsi_remove,
+	.driver =3D {
+		   .name =3D "cfhsi",
+		   .owner =3D THIS_MODULE,
+		   },
+};
+
+static void __exit cfhsi_exit_module(void)
+{
+	struct list_head *list_node;
+	struct list_head *n;
+	struct cfhsi *cfhsi =3D NULL;
+
+	list_for_each_safe(list_node, n, &cfhsi_list) {
+		cfhsi =3D list_entry(list_node, struct cfhsi, list);
+		platform_device_unregister(cfhsi->pdev);
+	}
+
+	/* Unregister platform driver. */
+	platform_driver_unregister(&cfhsi_plat_drv);
+}
+
+static int __init cfhsi_init_module(void)
+{
+	int result;
+
+	/* Initialize spin lock. */
+	spin_lock_init(&cfhsi_list_lock);
+
+	/* Register platform driver. */
+	result =3D platform_driver_register(&cfhsi_plat_drv);
+	if (result) {
+		printk(KERN_ERR "Could not register platform HSI driver.\n");
+		goto err_dev_register;
+	}
+
+	return result;
+
+ err_dev_register:
+	return result;
+}
+
+module_init(cfhsi_init_module);
+module_exit(cfhsi_exit_module);
diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
new file mode 100644
index 0000000..493967c
--- /dev/null
+++ b/include/net/caif/caif_hsi.h
@@ -0,0 +1,105 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Daniel Martensson / Daniel.Martensson@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_HSI_H_
+#define CAIF_HSI_H_
+
+#include <net/caif/caif_layer.h>
+#include <net/caif/caif_device.h>
+
+/*
+ * Maximum number of CAIF frames that can reside in the same HSI frame=
=2E
+ */
+#define CFHSI_MAX_PKTS 15
+
+/*
+ * Maximum number of bytes used for the frame that can be embedded in =
the
+ * HSI descriptor.
+ */
+#define CFHSI_MAX_EMB_FRM_SZ 96
+
+/*
+ * Decides if HSI buffers should be prefilled with 0xFF pattern for ea=
sier
+ * debugging. Both TX and RX buffers will be filled before the transfe=
r.
+ */
+#define CFHSI_DBG_PREFILL		0
+
+/* Structure describing a HSI packet descriptor. */
+#pragma pack(1) /* Byte alignment. */
+struct cfhsi_desc {
+	u8 header;
+	u8 offset;
+	u16 cffrm_len[CFHSI_MAX_PKTS];
+	u8 emb_frm[CFHSI_MAX_EMB_FRM_SZ];
+};
+#pragma pack() /* Default alignment. */
+
+/* Size of the complete HSI packet descriptor. */
+#define CFHSI_DESC_SZ (sizeof(struct cfhsi_desc))
+
+/*
+ * Size of the complete HSI packet descriptor excluding the optional e=
mbedded
+ * CAIF frame.
+ */
+#define CFHSI_DESC_SHORT_SZ (CFHSI_DESC_SZ - CFHSI_MAX_EMB_FRM_SZ)
+
+/*
+ * Maximum bytes transferred in one transfer.
+ */
+/* TODO: 4096 is temporary... */
+#define CFHSI_MAX_PAYLOAD_SZ (CFHSI_MAX_PKTS * 4096)
+
+/* Size of the complete HSI TX buffer. */
+#define CFHSI_BUF_SZ_TX (CFHSI_DESC_SZ + CFHSI_MAX_PAYLOAD_SZ)
+
+/* Size of the complete HSI RX buffer. */
+#define CFHSI_BUF_SZ_RX ((2 * CFHSI_DESC_SZ) + CFHSI_MAX_PAYLOAD_SZ)
+
+/* Bitmasks for the HSI descriptor. */
+#define CFHSI_PIGGY_DESC		(0x01 << 7)
+
+#define CFHSI_TX_STATE_IDLE			0
+#define CFHSI_TX_STATE_XFER			1
+
+#define CFHSI_RX_STATE_DESC			0
+#define CFHSI_RX_STATE_PAYLOAD		1
+
+/* Structure implemented by the CAIF HSI driver. */
+struct cfhsi_drv {
+	void (*tx_done_cb) (struct cfhsi_drv *drv);
+	void (*rx_done_cb) (struct cfhsi_drv *drv);
+};
+
+/* Structure implemented by HSI device. */
+struct cfhsi_dev {
+	int (*cfhsi_tx) (u8 *ptr, int len, struct cfhsi_dev *dev);
+	int (*cfhsi_rx) (u8 *ptr, int len, struct cfhsi_dev *dev);
+	struct cfhsi_drv *drv;
+};
+
+/* Structure implemented by CAIF HSI drivers. */
+struct cfhsi {
+	struct caif_dev_common cfdev;
+	struct net_device *ndev;
+	struct platform_device *pdev;
+	struct sk_buff_head qhead;
+	struct cfhsi_drv drv;
+	struct cfhsi_dev *dev;
+	int tx_state;
+	int rx_state;
+	u8 *tx_buf;
+	u8 *rx_buf;
+	spinlock_t lock;
+	int flow_off_sent;
+	u32 q_low_mark;
+	u32 q_high_mark;
+	bool flow_stop;
+	struct list_head list;
+};
+
+extern struct platform_driver cfhsi_driver;
+
+#endif		/* CAIF_HSI_H_ */
--=20
1.7.0.4

