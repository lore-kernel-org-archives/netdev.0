From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [RFCv2 9/9] caif-xshm: Add CAIF driver for Shared memory for M7400
Date: Tue, 29 Nov 2011 20:39:10 +0100
Message-ID: <1322595550-6473-10-git-send-email-sjur.brandeland@stericsson.com>
References: <1322595550-6473-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Walleij <linus.walleij@linaro.org>, sjurbren@gmail.com,
	Paul Bolle <pebolle@tiscali.nl>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322595550-6473-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces a caif shared memory link layer driver
for ST-Ericsson's Thor M7400 LTE modem.

M7400 uses a ring-buffer in shared memory for transporting data from th=
e modem.
Each ring-buffer element contains an array of caif frames. caif_xshm ca=
lls
napi_schedule() when receiving notification about incoming data.
The napi-poll function copies data from the ring-buffer to SKBs until
ring-buffer is empty, or quota is exceeded.

If transmit ring-buffer is full, it also uses napi for scheduling trans=
mission
of queued transmit buffer.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
cc: netdev@vger.kernel.org
---
 drivers/net/caif/Kconfig     |   10 +
 drivers/net/caif/Makefile    |    1 +
 drivers/net/caif/caif_xshm.c |  935 ++++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 946 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/caif/caif_xshm.c

diff --git a/drivers/net/caif/Kconfig b/drivers/net/caif/Kconfig
index abf4d7a..2861374 100644
--- a/drivers/net/caif/Kconfig
+++ b/drivers/net/caif/Kconfig
@@ -47,3 +47,13 @@ config CAIF_HSI
        The caif low level driver for CAIF over HSI.
        Be aware that if you enable this then you also need to
        enable a low-level HSI driver.
+
+config CAIF_XSHM
+	tristate "CAIF external memory protocol driver"
+	depends on XSHM && CAIF
+	default n
+	---help---
+	Say "yes" if you want to support CAIF over External Shared Memory (XS=
HM)
+	IPC mechanism (e.g. over Chip to Chip).
+	This will normally be built-in, loadable module is used for testing.
+	If unsure say N.
diff --git a/drivers/net/caif/Makefile b/drivers/net/caif/Makefile
index 91dff86..9310b24 100644
--- a/drivers/net/caif/Makefile
+++ b/drivers/net/caif/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_CAIF_SPI_SLAVE) +=3D cfspi_slave.o
 # Shared memory
 caif_shm-objs :=3D caif_shmcore.o caif_shm_u5500.o
 obj-$(CONFIG_CAIF_SHM) +=3D caif_shm.o
+obj-$(CONFIG_CAIF_XSHM) +=3D caif_xshm.o
=20
 # HSI interface
 obj-$(CONFIG_CAIF_HSI) +=3D caif_hsi.o
diff --git a/drivers/net/caif/caif_xshm.c b/drivers/net/caif/caif_xshm.=
c
new file mode 100644
index 0000000..35cff94
--- /dev/null
+++ b/drivers/net/caif/caif_xshm.c
@@ -0,0 +1,935 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Contact: Sjur Brendeland / sjur.brandeland@stericsson.com
+ * Authors: Sjur Brendeland / sjur.brandeland@stericsson.com
+ *	   Daniel Martensson / daniel.martensson@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": %s() :" fmt, __func__
+#include <linux/kernel.h>
+#include <linux/spinlock.h>
+#include <linux/sched.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <net/rtnetlink.h>
+#include <linux/if_arp.h>
+#include <net/caif/caif_device.h>
+#include <net/caif/caif_layer.h>
+#include <linux/xshm/xshm_pdev.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Daniel Martensson <daniel.martensson@stericsson.com>");
+MODULE_AUTHOR("Sjur Brendeland <sjur.brandeland@stericsson.com>");
+MODULE_DESCRIPTION("CAIF SHM driver");
+
+#define CONNECT_TIMEOUT (3 * HZ)
+#define CAIF_NEEDED_HEADROOM	32
+#define CAIF_FLOW_ON		1
+#define CAIF_FLOW_OFF		0
+
+#define LOW_XOFF_WATERMARK	50
+#define HIGH_XOFF_WATERMARK	70
+#define STUFF_MARK		30
+
+struct ringbuf {
+	__le32	*rip;
+	__le32	*wip;
+	u32	size;
+	__le32	*bufsize;
+};
+
+struct shm_pck_desc {
+	/* Offset from start of channel to CAIF frame. */
+	u32 offset;
+	u32 length;
+} __packed;
+
+struct shm_caif_frm {
+	/* Number of bytes of padding before the CAIF frame. */
+	u8 hdr_ofs;
+} __packed;
+
+#define SHM_HDR_LEN sizeof(struct shm_caif_frm)
+
+struct shmbuffer {
+/* Static part: */
+	u8 *addr;
+	u32 index;
+	u32 len;
+/* Dynamic part: */
+	u32 frames;
+	/* Offset from start of buffer to CAIF frame. */
+	u32 frm_ofs;
+};
+
+enum CFSHM_STATE {
+	CFSHM_CLOSED =3D 1,
+	CFSHM_OPENING,
+	CFSHM_OPEN
+};
+
+struct cfshm {
+	/* caif_dev_common must always be first in the structure*/
+	struct caif_dev_common cfdev;
+	struct xshm_dev *xshm;
+	struct napi_struct napi;
+	struct ringbuf tx;
+	struct sk_buff_head sk_qhead;
+	spinlock_t lock;
+	struct ringbuf rx;
+	u8 *rx_ringbuf;
+	u32 rx_frms_pr_buf;
+	u32 rx_alignment;
+	struct shmbuffer **rx_bufs;
+	struct net_device *ndev;
+
+	u32 tx_frms_pr_buf;
+	u32 tx_alignment;
+	struct shmbuffer **tx_bufs;
+	u8 *tx_ringbuf;
+	u32 tx_flow_on;
+	u32 high_xoff_water;
+	u32 low_xoff_water;
+	u32 stuff_mark;
+	atomic_t dbg_smp_rxactive;
+	enum CFSHM_STATE state;
+	struct platform_device *pdev;
+	struct list_head node;
+	wait_queue_head_t netmgmt_wq;
+};
+
+static LIST_HEAD(cfshm_list);
+static spinlock_t cfshm_list_lock;
+
+static unsigned int ringbuf_used(struct ringbuf *rb)
+{
+	if (le32_to_cpu(*rb->wip) >=3D le32_to_cpu(*rb->rip))
+		return le32_to_cpu(*rb->wip) - le32_to_cpu(*rb->rip);
+	else
+		return rb->size - le32_to_cpu(*rb->rip) + le32_to_cpu(*rb->wip);
+}
+
+static int ringbuf_get_writepos(struct ringbuf *rb)
+{
+	if ((le32_to_cpu(*rb->wip) + 1) % rb->size =3D=3D le32_to_cpu(*rb->ri=
p))
+		return -1;
+	else
+		return le32_to_cpu(*rb->wip);
+}
+
+static int ringbuf_get_readpos(struct ringbuf *rb)
+{
+
+	if (le32_to_cpu(*rb->wip) =3D=3D le32_to_cpu(*rb->rip))
+		return -1;
+	else
+		return le32_to_cpu(*rb->rip);
+}
+
+static int ringbuf_upd_writeptr(struct ringbuf *rb)
+{
+	if (!WARN_ON((le32_to_cpu(*rb->wip) + 1) % rb->size =3D=3D le32_to_cp=
u(*rb->rip))) {
+		*rb->wip =3D cpu_to_le32((le32_to_cpu(*rb->wip) + 1) % rb->size);
+		/* Do write barrier before updating index */
+		smp_wmb();
+	}
+	return le32_to_cpu(*rb->wip);
+}
+
+static void ringbuf_upd_readptr(struct ringbuf *rb)
+{
+	if (!WARN_ON(le32_to_cpu(*rb->wip) =3D=3D le32_to_cpu(*rb->rip))) {
+		*rb->rip =3D cpu_to_le32((le32_to_cpu(*rb->rip) + 1) % rb->size);
+		/* Do write barrier before updating index */
+		smp_wmb();
+	}
+}
+
+
+
+static struct shmbuffer *get_rx_buf(struct cfshm *cfshm)
+{
+	struct shmbuffer *pbuf =3D NULL;
+	int idx =3D ringbuf_get_readpos(&cfshm->rx);
+
+	if (idx < 0)
+		goto out;
+	pbuf =3D cfshm->rx_bufs[idx];
+out:
+	return pbuf;
+}
+
+static struct shmbuffer *new_rx_buf(struct cfshm *cfshm)
+{
+	struct shmbuffer *pbuf =3D get_rx_buf(cfshm);
+
+	WARN_ON(!spin_is_locked(&cfshm->lock));
+	if (pbuf)
+		pbuf->frames =3D 0;
+
+	return pbuf;
+}
+
+static struct shmbuffer *get_tx_buf(struct cfshm *cfshm)
+{
+	int idx =3D ringbuf_get_writepos(&cfshm->tx);
+
+	if (idx < 0)
+		return NULL;
+	return cfshm->tx_bufs[idx];
+}
+
+inline struct shmbuffer *tx_bump_buf(struct cfshm *cfshm,
+			struct shmbuffer *pbuf)
+{
+	u32 desc_size;
+	struct shmbuffer *newpbuf =3D pbuf;
+
+	WARN_ON(!spin_is_locked(&cfshm->lock));
+	if (pbuf) {
+		cfshm->xshm->cfg.tx.buf_size[pbuf->index] =3D
+			cpu_to_le32(pbuf->frm_ofs);
+		ringbuf_upd_writeptr(&cfshm->tx);
+		newpbuf =3D get_tx_buf(cfshm);
+		/* Reset buffer parameters. */
+		desc_size =3D (cfshm->tx_frms_pr_buf + 1) *
+			sizeof(struct shm_pck_desc);
+		pbuf->frm_ofs =3D desc_size + (desc_size % cfshm->rx_alignment);
+		pbuf->frames =3D 0;
+
+	}
+	return newpbuf;
+}
+
+static struct shmbuffer *shm_rx_func(struct cfshm *cfshm, int quota)
+{
+	struct shmbuffer *pbuf;
+	struct sk_buff *skb;
+	int ret;
+	unsigned long flags;
+
+	pbuf =3D get_rx_buf(cfshm);
+	while (pbuf) {
+		/* Retrieve pointer to start of the packet descriptor area. */
+		struct shm_pck_desc *pck_desc =3D
+			((struct shm_pck_desc *) pbuf->addr) + pbuf->frames;
+		u32 offset;
+
+		/* Loop until descriptor contains zero offset */
+		while ((offset =3D pck_desc->offset)) {
+			unsigned int caif_len;
+			struct shm_caif_frm *frm;
+			u32 length =3D pck_desc->length;
+			u8 hdr_ofs;
+			frm =3D (struct shm_caif_frm *)(pbuf->addr + offset);
+			hdr_ofs =3D frm->hdr_ofs;
+			caif_len =3D
+				length - SHM_HDR_LEN -
+				hdr_ofs;
+
+			pr_devel("copy data buf:%d frm:%d offs:%d @%x len:%d\n",
+					pbuf->index, pbuf->frames, offset,
+					(u32) (SHM_HDR_LEN + hdr_ofs + offset +
+						pbuf->addr - cfshm->rx_ringbuf),
+					length);
+
+			/* Check whether number of frames is below limit */
+			if (pbuf->frames > cfshm->rx_frms_pr_buf) {
+				pr_warn("Too many frames in buffer.\n");
+				++cfshm->ndev->stats.rx_frame_errors;
+				goto desc_err;
+			}
+
+			/* Check whether offset is below low limits */
+			if (pbuf->addr + offset
+					<=3D (u8 *)(pck_desc + 1)) {
+				pr_warn("Offset in desc. below buffer area.\n");
+				++cfshm->ndev->stats.rx_frame_errors;
+				goto desc_err;
+			}
+
+			/* Check whether offset above upper limit */
+			if (offset + length > pbuf->len) {
+				pr_warn("Offset outside buffer area:\n");
+				++cfshm->ndev->stats.rx_frame_errors;
+				goto desc_err;
+			}
+
+			skb =3D netdev_alloc_skb(cfshm->ndev,
+							caif_len + 1);
+			if (skb =3D=3D NULL) {
+				pr_debug("Couldn't allocate SKB\n");
+				++cfshm->ndev->stats.rx_dropped;
+				goto out;
+			}
+
+			memcpy(skb_put(skb, caif_len),
+					SHM_HDR_LEN + hdr_ofs +
+					offset + pbuf->addr,
+					caif_len);
+
+			skb->protocol =3D htons(ETH_P_CAIF);
+			skb_reset_mac_header(skb);
+			skb->dev =3D cfshm->ndev;
+
+			/* Push received packet up the stack. */
+			ret =3D netif_receive_skb(skb);
+
+			if (!ret) {
+				cfshm->ndev->stats.rx_packets++;
+				cfshm->ndev->stats.rx_bytes +=3D
+					length;
+			} else
+				++cfshm->ndev->stats.rx_dropped;
+			/* Move to next packet descriptor. */
+			pck_desc++;
+
+			pbuf->frames++;
+			if (--quota <=3D 0) {
+				pr_devel("Quota exeeded (pbuf:%p)\n", pbuf);
+				goto out;
+			}
+		}
+desc_err:
+		pbuf->frames =3D 0;
+
+		spin_lock_irqsave(&cfshm->lock, flags);
+		ringbuf_upd_readptr(&cfshm->rx);
+		pbuf =3D new_rx_buf(cfshm);
+		spin_unlock_irqrestore(&cfshm->lock, flags);
+
+	}
+	cfshm->xshm->ipc_rx_release(cfshm->xshm, false);
+out:
+	return pbuf;
+}
+
+static int insert_skb_in_buf(struct cfshm *cfshm, struct sk_buff *skb,
+					struct shmbuffer *pbuf)
+{
+	struct shm_pck_desc *pck_desc;
+	unsigned int frmlen;
+	struct shm_caif_frm *frm;
+	u8 hdr_ofs;
+	struct caif_payload_info *info =3D (struct caif_payload_info *)&skb->=
cb;
+
+	WARN_ON(!spin_is_locked(&cfshm->lock));
+
+	if (unlikely(pbuf->frames >=3D cfshm->tx_frms_pr_buf)) {
+		pr_devel("-ENOSPC exeeded frames: %d >=3D %d\n",
+				pbuf->frames, cfshm->tx_frms_pr_buf);
+		return -ENOSPC;
+	}
+
+	/*
+	 * Align the address of the entire CAIF frame (incl padding),
+	 * so the modem can do efficient DMA of this frame
+	 * FIXME: Alignment is power of to, so it could use binary ops.
+	 */
+	pbuf->frm_ofs =3D roundup(pbuf->frm_ofs, cfshm->tx_alignment);
+
+
+	/* Make the payload (IP packet) inside the frame aligned */
+	hdr_ofs =3D (unsigned long) &pbuf->frm_ofs;
+	hdr_ofs =3D roundup(hdr_ofs + SHM_HDR_LEN + info->hdr_len,
+			cfshm->tx_alignment);
+
+	frm =3D (struct shm_caif_frm *)
+		(pbuf->addr + pbuf->frm_ofs);
+
+	frmlen =3D SHM_HDR_LEN + hdr_ofs + skb->len;
+
+	/*
+	 * Verify that packet, header and additional padding
+	 * can fit within the buffer frame area.
+	 */
+	if (pbuf->len < pbuf->frm_ofs + frmlen) {
+		pr_devel("-ENOSPC exeeded offset %d < %d\n",
+				pbuf->len, pbuf->frm_ofs + frmlen);
+		return -ENOSPC;
+	}
+
+	/* Copy in CAIF frame. */
+	frm->hdr_ofs =3D hdr_ofs;
+	skb_copy_bits(skb, 0, pbuf->addr +
+			pbuf->frm_ofs + SHM_HDR_LEN +
+			hdr_ofs, skb->len);
+
+	pr_devel("copy data buf:%d frm:%d offs:%d @%d len:%d\n",
+			pbuf->index, pbuf->frames,
+			pbuf->frm_ofs,
+			(u32) (pbuf->addr + pbuf->frm_ofs +
+				SHM_HDR_LEN + hdr_ofs - cfshm->tx_ringbuf),
+			skb->len);
+
+	cfshm->ndev->stats.tx_packets++;
+	cfshm->ndev->stats.tx_bytes +=3D frmlen;
+	/* Fill in the shared memory packet descriptor area. */
+	pck_desc =3D (struct shm_pck_desc *) (pbuf->addr);
+	/* Forward to current frame. */
+	pck_desc +=3D pbuf->frames;
+	pck_desc->offset =3D pbuf->frm_ofs;
+	pck_desc->length =3D frmlen;
+	/* Terminate packet descriptor area. */
+	pck_desc++;
+	pck_desc->offset =3D 0;
+	pck_desc->length =3D 0;
+	/* Update buffer parameters. */
+	pbuf->frames++;
+	pbuf->frm_ofs +=3D frmlen;
+
+	return 0;
+}
+
+static struct shmbuffer *queue_to_ringbuf(struct cfshm *cfshm, int *ne=
w_bufs)
+{
+	struct shmbuffer *pbuf;
+	struct sk_buff *skb;
+	int err;
+
+	WARN_ON(!spin_is_locked(&cfshm->lock));
+
+	pbuf =3D get_tx_buf(cfshm);
+	while (pbuf !=3D NULL) {
+		skb =3D skb_peek(&cfshm->sk_qhead);
+		if (skb =3D=3D NULL)
+			break;
+		err =3D insert_skb_in_buf(cfshm, skb, pbuf);
+		if (unlikely(err =3D=3D -ENOSPC)) {
+			pr_devel("No more space in buffer\n");
+			++(*new_bufs);
+			pbuf =3D tx_bump_buf(cfshm, pbuf);
+			continue;
+		}
+		skb =3D skb_dequeue(&cfshm->sk_qhead);
+		/* We're always in NET_*_SOFTIRQ */
+		dev_kfree_skb(skb);
+	}
+	return pbuf;
+}
+
+static int shm_netdev_open(struct net_device *netdev)
+{
+	struct cfshm *cfshm =3D netdev_priv(netdev);
+	int ret, err =3D 0;
+
+	cfshm->state =3D CFSHM_OPENING;
+	if (cfshm->xshm !=3D NULL && cfshm->xshm->open !=3D NULL)
+		err =3D cfshm->xshm->open(cfshm->xshm);
+	if (err)
+		goto error;
+
+	rtnl_unlock();  /* Release RTNL lock during connect wait */
+	ret =3D wait_event_interruptible_timeout(cfshm->netmgmt_wq,
+			cfshm->state !=3D CFSHM_OPENING,
+			CONNECT_TIMEOUT);
+	rtnl_lock();
+
+	if (ret =3D=3D 0) {
+		pr_debug("connect timeout\n");
+		err =3D -ETIMEDOUT;
+		goto error;
+	}
+
+	if (cfshm->state !=3D  CFSHM_OPEN) {
+		pr_debug("connect failed\n");
+		err =3D -ECONNREFUSED;
+		goto error;
+	}
+
+	napi_enable(&cfshm->napi);
+	return 0;
+error:
+	if (cfshm->xshm !=3D NULL && cfshm->xshm->close !=3D NULL)
+		cfshm->xshm->close(cfshm->xshm);
+	return err;
+}
+
+static int shm_netdev_close(struct net_device *netdev)
+{
+	struct cfshm *cfshm =3D netdev_priv(netdev);
+
+	napi_disable(&cfshm->napi);
+
+	if (cfshm->xshm !=3D NULL && cfshm->xshm->close !=3D NULL)
+		cfshm->xshm->close(cfshm->xshm);
+
+	return 0;
+}
+
+static int open_cb(void *drv)
+{
+	struct cfshm *cfshm =3D drv;
+
+	cfshm->state =3D CFSHM_OPEN;
+	netif_carrier_on(cfshm->ndev);
+	wake_up_interruptible(&cfshm->netmgmt_wq);
+	return 0;
+}
+
+static void close_cb(void *drv)
+{
+	struct cfshm *cfshm =3D drv;
+
+	cfshm->state =3D CFSHM_CLOSED;
+	netif_carrier_off(cfshm->ndev);
+	wake_up_interruptible(&cfshm->netmgmt_wq);
+}
+
+static int caif_shmdrv_rx_cb(void *drv)
+{
+	struct cfshm *cfshm =3D drv;
+
+	if (unlikely(*cfshm->xshm->cfg.rx.state =3D=3D cpu_to_le32(XSHM_CLOSE=
D)))
+		return -ESHUTDOWN;
+
+	napi_schedule(&cfshm->napi);
+	return 0;
+}
+
+static int send_pending_txbufs(struct cfshm *cfshm, int usedbufs)
+{
+	unsigned long flags;
+
+	/* Send the started buffer if used buffers are low enough */
+	WARN_ON(!spin_is_locked(&cfshm->lock));
+	if (likely(usedbufs < cfshm->stuff_mark)) {
+		struct shmbuffer *pbuf =3D get_tx_buf(cfshm);
+		if (unlikely(pbuf->frames > 0)) {
+			if (spin_trylock_irqsave(&cfshm->lock, flags)) {
+				WARN_ON(!spin_is_locked(&cfshm->lock));
+				pbuf =3D get_tx_buf(cfshm);
+				tx_bump_buf(cfshm, pbuf);
+				spin_unlock_irqrestore(&cfshm->lock, flags);
+				cfshm->xshm->ipc_tx(cfshm->xshm);
+				return 0;
+			} else {
+				return -EBUSY;
+			}
+		}
+	}
+	return 0;
+}
+
+static int caif_shmdrv_tx_release_cb(void *drv)
+{
+	struct cfshm *cfshm =3D drv;
+	int usedbufs;
+
+	usedbufs =3D ringbuf_used(&cfshm->tx);
+
+	/* Send flow-on if we have sent flow-off and get below low-water */
+	if (usedbufs <=3D cfshm->low_xoff_water && !cfshm->tx_flow_on) {
+		pr_debug("Flow on\n");
+		cfshm->tx_flow_on =3D true;
+		cfshm->cfdev.flowctrl(cfshm->ndev, CAIF_FLOW_ON);
+	}
+
+	/* If ringbuf is full, schedule NAPI to start sending */
+	if (skb_peek(&cfshm->sk_qhead) !=3D NULL) {
+		pr_debug("Schedule NAPI to empty queue\n");
+		napi_schedule(&cfshm->napi);
+		return 0;
+	}
+
+	/* Send the started buffer if used buffers are low enough */
+	if (usedbufs < cfshm->stuff_mark) {
+		struct shmbuffer *pbuf =3D get_tx_buf(cfshm);
+		if (pbuf !=3D NULL && pbuf->frames > 0)
+			napi_schedule(&cfshm->napi);
+	}
+	return 0;
+}
+
+static int shm_rx_poll(struct napi_struct *napi, int quota)
+{
+	struct cfshm *cfshm =3D container_of(napi, struct cfshm, napi);
+	int new_bufs;
+	struct shmbuffer *pbuf;
+	int usedbufs;
+	unsigned long flags;
+
+	/* Simply return if rx_poll is already called on other CPU */
+	if (atomic_read(&cfshm->dbg_smp_rxactive) > 0)
+		return quota;
+
+	WARN_ON(atomic_inc_return(&cfshm->dbg_smp_rxactive) > 1);
+
+	pbuf =3D shm_rx_func(cfshm, quota);
+
+	usedbufs =3D ringbuf_used(&cfshm->tx);
+
+	if (spin_trylock_irqsave(&cfshm->lock, flags)) {
+
+		/* Check if we're below "Stuff" limit, and send pending data */
+		send_pending_txbufs(cfshm, usedbufs);
+
+		/* Check if we have queued packets */
+		if (unlikely(skb_peek(&cfshm->sk_qhead) !=3D NULL)) {
+			struct shmbuffer *txbuf;
+			WARN_ON(!spin_is_locked(&cfshm->lock));
+			pr_debug("Try to empty tx-queue\n");
+			new_bufs =3D 0;
+			txbuf =3D queue_to_ringbuf(cfshm, &new_bufs);
+
+			/* Bump out if we are configured with few buffers */
+			if (txbuf && cfshm->xshm->cfg.tx.buffers < 3) {
+				tx_bump_buf(cfshm, txbuf);
+
+				spin_unlock_irqrestore(&cfshm->lock, flags);
+				cfshm->xshm->ipc_tx(cfshm->xshm);
+				goto txdone;
+			}
+		}
+		spin_unlock_irqrestore(&cfshm->lock, flags);
+	}
+txdone:
+
+	if (pbuf =3D=3D NULL)
+		napi_complete(&cfshm->napi);
+
+	atomic_dec(&cfshm->dbg_smp_rxactive);
+	return 0;
+}
+
+static int shm_netdev_tx(struct sk_buff *skb, struct net_device *shm_n=
etdev)
+{
+	struct shmbuffer *pbuf =3D NULL;
+	int usedbufs;
+	int new_bufs =3D 0;
+	struct cfshm *cfshm =3D netdev_priv(shm_netdev);
+	unsigned long flags;
+
+	/*
+	 * If we have packets in queue, keep queueing to avoid
+	 * out-of-order delivery
+	 */
+	spin_lock_irqsave(&cfshm->lock, flags);
+
+	skb_queue_tail(&cfshm->sk_qhead, skb);
+	pbuf =3D queue_to_ringbuf(cfshm, &new_bufs);
+
+	usedbufs =3D ringbuf_used(&cfshm->tx);
+
+	if (usedbufs > cfshm->high_xoff_water && cfshm->tx_flow_on) {
+		pr_debug("Flow off\n");
+		cfshm->tx_flow_on =3D false;
+		spin_unlock_irqrestore(&cfshm->lock, flags);
+		cfshm->cfdev.flowctrl(cfshm->ndev, CAIF_FLOW_OFF);
+		return 0;
+	}
+
+	/* Check if we should accumulate more packets */
+	if (new_bufs =3D=3D 0 && usedbufs > cfshm->stuff_mark) {
+		spin_unlock_irqrestore(&cfshm->lock, flags);
+		return 0;
+	}
+	tx_bump_buf(cfshm, pbuf);
+	spin_unlock_irqrestore(&cfshm->lock, flags);
+	cfshm->xshm->ipc_tx(cfshm->xshm);
+	return 0;
+}
+
+static const struct net_device_ops netdev_ops =3D {
+	.ndo_open =3D shm_netdev_open,
+	.ndo_stop =3D shm_netdev_close,
+	.ndo_start_xmit =3D shm_netdev_tx,
+};
+
+static void shm_netdev_setup(struct net_device *pshm_netdev)
+{
+	struct cfshm *cfshm;
+
+	cfshm =3D netdev_priv(pshm_netdev);
+	pshm_netdev->netdev_ops =3D &netdev_ops;
+	pshm_netdev->type =3D ARPHRD_CAIF;
+	pshm_netdev->hard_header_len =3D CAIF_NEEDED_HEADROOM;
+	pshm_netdev->tx_queue_len =3D 0;
+	pshm_netdev->destructor =3D free_netdev;
+
+	/* Initialize structures in a clean state. */
+	memset(cfshm, 0, sizeof(struct cfshm));
+}
+
+static void deinit_bufs(struct cfshm *cfshm)
+{
+	int j;
+
+	if (cfshm =3D=3D NULL)
+		return;
+
+	for (j =3D 0; j < cfshm->xshm->cfg.rx.buffers; j++)
+		kfree(cfshm->rx_bufs[j]);
+	kfree(cfshm->rx_bufs);
+
+	for (j =3D 0; j < cfshm->xshm->cfg.tx.buffers; j++)
+		kfree(cfshm->tx_bufs[j]);
+	kfree(cfshm->tx_bufs);
+}
+
+static int cfshm_probe(struct platform_device *pdev)
+{
+	int err, j;
+	struct xshm_dev *xshm =3D pdev->dev.platform_data;
+	struct cfshm *cfshm =3D NULL;
+	struct net_device *netdev;
+	u32 buf_size;
+	unsigned long flags;
+
+	if (xshm =3D=3D NULL)
+		return -EINVAL;
+	if (xshm->cfg.tx.addr =3D=3D NULL || xshm->cfg.rx.addr =3D=3D NULL) {
+		pr_debug("Shared Memory are not configured\n");
+		return -EINVAL;
+	}
+
+	if (xshm->cfg.tx.ch_size / xshm->cfg.tx.buffers <
+			xshm->cfg.tx.packets * sizeof(struct shm_pck_desc) +
+				xshm->cfg.tx.mtu) {
+		pr_warn("Bad packet TX-channel size");
+		return -EINVAL;
+	}
+
+	if (xshm->cfg.rx.ch_size / xshm->cfg.rx.buffers <
+			sizeof(struct shm_pck_desc) + xshm->cfg.rx.mtu) {
+		pr_warn("Bad packet RX-channel size");
+		return -EINVAL;
+	}
+
+	if (xshm->cfg.rx.buffers < 2 || xshm->cfg.tx.buffers < 2) {
+		pr_warn("Too few buffers in channel");
+		return -EINVAL;
+	}
+
+	err =3D -ENOMEM;
+	netdev =3D alloc_netdev(sizeof(struct cfshm), xshm->cfg.name,
+			shm_netdev_setup);
+
+	if (netdev =3D=3D NULL)
+		goto error;
+
+	cfshm =3D netdev_priv(netdev);
+	cfshm->state =3D CFSHM_CLOSED;
+	init_waitqueue_head(&cfshm->netmgmt_wq);
+
+	cfshm->xshm =3D xshm;
+	xshm->driver_data =3D cfshm;
+	cfshm->ndev =3D netdev;
+	netdev->mtu =3D xshm->cfg.tx.mtu;
+	cfshm->high_xoff_water =3D
+		(xshm->cfg.rx.buffers * HIGH_XOFF_WATERMARK) / 100;
+	cfshm->low_xoff_water =3D
+		(xshm->cfg.rx.buffers * LOW_XOFF_WATERMARK) / 100;
+	cfshm->stuff_mark =3D (xshm->cfg.rx.buffers * STUFF_MARK) / 100;
+
+	cfshm->tx_frms_pr_buf =3D xshm->cfg.tx.packets;
+	cfshm->rx_frms_pr_buf =3D xshm->cfg.rx.packets;
+	cfshm->rx_alignment =3D xshm->cfg.rx.alignment;
+	cfshm->tx_alignment =3D xshm->cfg.tx.alignment;
+
+	if (xshm->cfg.latency)
+		cfshm->cfdev.link_select =3D CAIF_LINK_LOW_LATENCY;
+	else
+		cfshm->cfdev.link_select =3D CAIF_LINK_HIGH_BANDW;
+
+	cfshm->tx.rip =3D xshm->cfg.tx.read;
+	cfshm->tx.wip =3D xshm->cfg.tx.write;
+	cfshm->tx.bufsize =3D xshm->cfg.tx.buf_size;
+	cfshm->tx.size =3D xshm->cfg.tx.buffers;
+
+	cfshm->rx.rip =3D xshm->cfg.rx.read;
+	cfshm->rx.wip =3D xshm->cfg.rx.write;
+	cfshm->rx.bufsize =3D xshm->cfg.rx.buf_size;
+	cfshm->rx.size =3D xshm->cfg.rx.buffers;
+	pr_devel("RX ri:%d wi:%d size:%d\n",
+		le32_to_cpu(*cfshm->rx.rip),
+			le32_to_cpu(*cfshm->rx.wip), cfshm->rx.size);
+	pr_devel("TX ri:%d wi:%d size:%d\n",
+		le32_to_cpu(*cfshm->tx.rip),
+			le32_to_cpu(*cfshm->tx.wip), cfshm->rx.size);
+	pr_devel("frms_pr_buf:%d %d\n", cfshm->rx_frms_pr_buf,
+			cfshm->tx_frms_pr_buf);
+
+	spin_lock_init(&cfshm->lock);
+	netif_carrier_off(netdev);
+	skb_queue_head_init(&cfshm->sk_qhead);
+
+	pr_devel("SHM DEVICE[%p] PROBED BY DRIVER, NEW SHM DRIVER"
+			" INSTANCE AT cfshm =3D0x%p\n",
+			cfshm->xshm, cfshm);
+
+	cfshm->tx_ringbuf =3D xshm->cfg.tx.addr;
+	cfshm->rx_ringbuf =3D xshm->cfg.rx.addr;
+
+	pr_devel("TX-BASE:%p RX-BASE:%p\n",
+			cfshm->tx_ringbuf,
+			cfshm->rx_ringbuf);
+
+	cfshm->tx_bufs =3D kzalloc(sizeof(struct shmbuffer *) *
+			xshm->cfg.tx.buffers, GFP_KERNEL);
+	if (cfshm->tx_bufs =3D=3D NULL)
+		goto error;
+	buf_size =3D xshm->cfg.tx.ch_size / xshm->cfg.tx.buffers;
+
+	pr_devel("TX: buffers:%d buf_size:%d frms:%d mtu:%d\n",
+			xshm->cfg.tx.buffers, buf_size,
+			cfshm->tx_frms_pr_buf, netdev->mtu);
+
+	for (j =3D 0; j < xshm->cfg.tx.buffers; j++) {
+		u32 desc_size;
+		struct shmbuffer *tx_buf =3D
+				kzalloc(sizeof(struct shmbuffer), GFP_KERNEL);
+
+		if (tx_buf =3D=3D NULL) {
+			pr_warn("ERROR, Could not"
+					" allocate dynamic mem. for tx_buf, "
+					" Bailing out ...\n");
+			goto error;
+		}
+
+		tx_buf->index =3D j;
+
+		tx_buf->addr =3D cfshm->tx_ringbuf + (buf_size * j);
+		tx_buf->len =3D buf_size;
+		tx_buf->frames =3D 0;
+		desc_size =3D (cfshm->tx_frms_pr_buf + 1) *
+				sizeof(struct shm_pck_desc);
+
+		tx_buf->frm_ofs =3D desc_size + (desc_size % cfshm->tx_alignment);
+
+		cfshm->tx_bufs[j] =3D tx_buf;
+
+		pr_devel("tx_buf[%d] addr:%p len:%d\n",
+				tx_buf->index,
+				tx_buf->addr,
+				tx_buf->len);
+	}
+
+	cfshm->rx_bufs =3D kzalloc(sizeof(struct shmbuffer *) *
+				xshm->cfg.rx.buffers, GFP_KERNEL);
+	if (cfshm->rx_bufs =3D=3D NULL)
+		goto error;
+	buf_size =3D xshm->cfg.tx.ch_size / xshm->cfg.tx.buffers;
+	pr_devel("RX: buffers:%d buf_size:%d frms:%d mtu:%d\n",
+			xshm->cfg.rx.buffers, buf_size,
+			cfshm->rx_frms_pr_buf, netdev->mtu);
+
+	for (j =3D 0; j < xshm->cfg.rx.buffers; j++) {
+		struct shmbuffer *rx_buf =3D
+				kzalloc(sizeof(struct shmbuffer), GFP_KERNEL);
+
+		if (rx_buf =3D=3D NULL) {
+			pr_warn("ERROR, Could not"
+					" allocate dynamic mem.for rx_buf, "
+					" Bailing out ...\n");
+			goto error;
+		}
+
+		rx_buf->index =3D j;
+
+		rx_buf->addr =3D cfshm->rx_ringbuf + (buf_size * j);
+		rx_buf->len =3D buf_size;
+		cfshm->rx_bufs[j] =3D rx_buf;
+		pr_devel("rx_buf[%d] addr:%p len:%d\n",
+				rx_buf->index,
+				rx_buf->addr,
+				rx_buf->len);
+	}
+
+	cfshm->tx_flow_on =3D 1;
+	cfshm->xshm->ipc_rx_cb =3D caif_shmdrv_rx_cb;
+	cfshm->xshm->ipc_tx_release_cb =3D caif_shmdrv_tx_release_cb;
+	cfshm->xshm->open_cb =3D open_cb;
+	cfshm->xshm->close_cb =3D close_cb;
+
+	spin_lock_irqsave(&cfshm->lock, flags);
+	get_tx_buf(cfshm);
+	new_rx_buf(cfshm);
+	spin_unlock_irqrestore(&cfshm->lock, flags);
+
+	netif_napi_add(netdev, &cfshm->napi, shm_rx_poll,
+			2 * cfshm->rx_frms_pr_buf);
+
+	err =3D register_netdev(netdev);
+	if (err) {
+		pr_warn("ERROR[%d], SHM could not, "
+			"register with NW FRMWK Bailing out ...\n", err);
+		goto error;
+	}
+
+	/* Add CAIF SHM device to list. */
+	spin_lock(&cfshm_list_lock);
+	list_add_tail(&cfshm->node, &cfshm_list);
+	spin_unlock(&cfshm_list_lock);
+
+	return err;
+error:
+	deinit_bufs(cfshm);
+	free_netdev(netdev);
+	return err;
+}
+
+static int cfshm_remove(struct platform_device *pdev)
+{
+	struct xshm_dev *xshm;
+	struct cfshm *cfshm;
+
+	xshm =3D pdev->dev.platform_data;
+
+	if (xshm =3D=3D NULL || xshm->driver_data =3D=3D NULL)
+		return 0;
+
+	cfshm =3D xshm->driver_data;
+
+	spin_lock(&cfshm_list_lock);
+	list_del(&cfshm->node);
+	spin_unlock(&cfshm_list_lock);
+
+	deinit_bufs(cfshm);
+
+	unregister_netdev(cfshm->ndev);
+
+	xshm->ipc_rx_cb =3D NULL;
+	xshm->ipc_tx_release_cb =3D NULL;
+	xshm->open_cb =3D NULL;
+	xshm->close_cb =3D NULL;
+	xshm->driver_data =3D NULL;
+
+	return 0;
+}
+
+static struct platform_driver cfshm_plat_drv =3D {
+	.probe =3D cfshm_probe,
+	.remove =3D cfshm_remove,
+	.driver =3D {
+		.name =3D "xshmp",
+		.owner =3D THIS_MODULE,
+	},
+};
+
+static void __exit cfshm_exit_module(void)
+{
+	platform_driver_unregister(&cfshm_plat_drv);
+}
+
+static int __init cfshm_init_module(void)
+{
+	int err;
+
+	spin_lock_init(&cfshm_list_lock);
+
+	err =3D platform_driver_register(&cfshm_plat_drv);
+	if (err) {
+		printk(KERN_ERR "Could not register platform SHM driver: %d.\n",
+			err);
+		goto err_dev_register;
+	}
+	return err;
+
+ err_dev_register:
+	return err;
+}
+
+module_init(cfshm_init_module);
+module_exit(cfshm_exit_module);
--=20
1.7.0.4
