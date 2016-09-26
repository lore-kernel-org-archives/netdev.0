From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] brcmfmac: implement more accurate skb tracking
Date: Mon, 26 Sep 2016 12:23:48 +0200
Message-ID: <20160926102348.8695-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Pieter-Paul Giesberts <pieter-paul.giesberts-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Rafał Miłecki <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>

We need to track 802.1x packets to know if there are any pending ones
for transmission. This is required for performing key update in the
firmware.

Unfortunately our old tracking code wasn't very accurate. It was
treating skb as pending as soon as it was passed by the netif. Actual
handling packet to the firmware was happening later as brcmfmac
internally queues them and uses its own worker(s).

Other than that it was hard to handle freeing packets. Everytime we had
to determine (in more generic funcions) if packet was counted as pending
802.1x one or not. It was causing some problems, e.g. it wasn't clear if
brcmf_flowring_delete should free skb directly or not.

This patch introduces 2 separated functions for tracking skbs. This
simplifies logic, fixes brcmf_flowring_delete (maybe other hidden bugs
as well) and allows further simplifications. Thanks to better accuracy
is also increases time window for key update (and lowers timeout risk).

Signed-off-by: Rafał Miłecki <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>
---
This was successfully tested with 4366b1. Can someone give it a try with
some USB/SDIO device, please?
---
 .../wireless/broadcom/brcm80211/brcmfmac/bcdc.c    | 11 +++++++
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  | 12 +++++++-
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    | 36 ++++++++++++++++------
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |  2 ++
 .../wireless/broadcom/brcm80211/brcmfmac/msgbuf.c  | 14 +++++++--
 .../wireless/broadcom/brcm80211/brcmfmac/proto.h   | 11 +++++++
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |  8 +++++
 .../net/wireless/broadcom/brcm80211/brcmfmac/usb.c | 10 ++++++
 8 files changed, 91 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcdc.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcdc.c
index d1bc51f..3e40244 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcdc.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcdc.c
@@ -326,6 +326,16 @@ brcmf_proto_bcdc_hdrpull(struct brcmf_pub *drvr, bool do_fws,
 	return 0;
 }
 
+static int brcmf_proto_bcdc_hdr_get_ifidx(struct brcmf_pub *drvr,
+					  struct sk_buff *skb)
+{
+	struct brcmf_proto_bcdc_header *h;
+
+	h = (struct brcmf_proto_bcdc_header *)(skb->data);
+
+	return BCDC_GET_IF_IDX(h);
+}
+
 static int
 brcmf_proto_bcdc_txdata(struct brcmf_pub *drvr, int ifidx, u8 offset,
 			struct sk_buff *pktbuf)
@@ -373,6 +383,7 @@ int brcmf_proto_bcdc_attach(struct brcmf_pub *drvr)
 	}
 
 	drvr->proto->hdrpull = brcmf_proto_bcdc_hdrpull;
+	drvr->proto->hdr_get_ifidx = brcmf_proto_bcdc_hdr_get_ifidx;
 	drvr->proto->query_dcmd = brcmf_proto_bcdc_query_dcmd;
 	drvr->proto->set_dcmd = brcmf_proto_bcdc_set_dcmd;
 	drvr->proto->txdata = brcmf_proto_bcdc_txdata;
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
index 03404cb..fef9d02 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
@@ -43,6 +43,7 @@
 #include "chip.h"
 #include "bus.h"
 #include "debug.h"
+#include "proto.h"
 #include "sdio.h"
 #include "core.h"
 #include "common.h"
@@ -772,6 +773,7 @@ int brcmf_sdiod_send_buf(struct brcmf_sdio_dev *sdiodev, u8 *buf, uint nbytes)
 int brcmf_sdiod_send_pkt(struct brcmf_sdio_dev *sdiodev,
 			 struct sk_buff_head *pktq)
 {
+	struct brcmf_pub *pub = sdiodev->bus_if->drvr;
 	struct sk_buff *skb;
 	u32 addr = sdiodev->sbwad;
 	int err;
@@ -784,10 +786,18 @@ int brcmf_sdiod_send_pkt(struct brcmf_sdio_dev *sdiodev,
 
 	if (pktq->qlen == 1 || !sdiodev->sg_support)
 		skb_queue_walk(pktq, skb) {
+			struct brcmf_if *ifp;
+			int ifidx;
+
+			ifidx = brcmf_proto_hdr_get_ifidx(pub, skb);
+			ifp = brcmf_get_ifp(pub, ifidx);
+			brcmf_tx_passing_skb(ifp, skb);
 			err = brcmf_sdiod_buffrw(sdiodev, SDIO_FUNC_2, true,
 						 addr, skb);
-			if (err)
+			if (err) {
+				brcmf_tx_regained_skb(ifp, skb);
 				break;
+			}
 		}
 	else
 		err = brcmf_sdiod_sglist_rw(sdiodev, SDIO_FUNC_2, true, addr,
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
index bc3d8ab..7cdc1f6 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
@@ -247,9 +247,6 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
 		goto done;
 	}
 
-	if (eh->h_proto == htons(ETH_P_PAE))
-		atomic_inc(&ifp->pend_8021x_cnt);
-
 	/* determine the priority */
 	if (skb->priority == 0 || skb->priority > 7)
 		skb->priority = cfg80211_classify8021d(skb, NULL);
@@ -388,20 +385,41 @@ void brcmf_rx_event(struct device *dev, struct sk_buff *skb)
 	brcmu_pkt_buf_free_skb(skb);
 }
 
-void brcmf_txfinalize(struct brcmf_if *ifp, struct sk_buff *txp, bool success)
+/**
+ * brcmf_tx_passing_skb - Let core know skb is being passed to the firmware
+ *
+ * Core code needs to track state of some skbs. This function should be called
+ * every time skb is going to be passed to the firmware for transmitting.
+ */
+void brcmf_tx_passing_skb(struct brcmf_if *ifp, struct sk_buff *skb)
 {
-	struct ethhdr *eh;
-	u16 type;
+	struct ethhdr *eh = (struct ethhdr *)(skb->data);
 
-	eh = (struct ethhdr *)(txp->data);
-	type = ntohs(eh->h_proto);
+	if (eh->h_proto == htons(ETH_P_PAE))
+		atomic_inc(&ifp->pend_8021x_cnt);
+}
 
-	if (type == ETH_P_PAE) {
+/**
+ * brcmf_tx_regained_skb - Let core know skb is not being fw processed anymore
+ *
+ * This function should be called every time skb is returned from the firmware
+ * processing for whatever reason. It usually happens after successful
+ * transmission but may be also due to some error.
+ */
+void brcmf_tx_regained_skb(struct brcmf_if *ifp, struct sk_buff *skb)
+{
+	struct ethhdr *eh = (struct ethhdr *)(skb->data);
+
+	if (eh->h_proto == htons(ETH_P_PAE)) {
 		atomic_dec(&ifp->pend_8021x_cnt);
+
 		if (waitqueue_active(&ifp->pend_8021x_wait))
 			wake_up(&ifp->pend_8021x_wait);
 	}
+}
 
+void brcmf_txfinalize(struct brcmf_if *ifp, struct sk_buff *txp, bool success)
+{
 	if (!success)
 		ifp->stats.tx_errors++;
 
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
index f16cfc9..80478b5 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
@@ -215,6 +215,8 @@ struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bsscfgidx, s32 ifidx,
 void brcmf_remove_interface(struct brcmf_if *ifp, bool rtnl_locked);
 void brcmf_txflowblock_if(struct brcmf_if *ifp,
 			  enum brcmf_netif_stop_reason reason, bool state);
+void brcmf_tx_passing_skb(struct brcmf_if *ifp, struct sk_buff *skb);
+void brcmf_tx_regained_skb(struct brcmf_if *ifp, struct sk_buff *skb);
 void brcmf_txfinalize(struct brcmf_if *ifp, struct sk_buff *txp, bool success);
 void brcmf_netif_rx(struct brcmf_if *ifp, struct sk_buff *skb);
 void brcmf_net_setcarrier(struct brcmf_if *ifp, bool on);
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.c
index 2b9a2bc..2a25eea 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.c
@@ -701,17 +701,22 @@ static void brcmf_msgbuf_txflow(struct brcmf_msgbuf *msgbuf, u16 flowid)
 
 	count = BRCMF_MSGBUF_TX_FLUSH_CNT2 - BRCMF_MSGBUF_TX_FLUSH_CNT1;
 	while (brcmf_flowring_qlen(flow, flowid)) {
+		u8 ifidx = brcmf_flowring_ifidx_get(flow, flowid);
+		struct brcmf_if *ifp = brcmf_get_ifp(msgbuf->drvr, ifidx);
+
 		skb = brcmf_flowring_dequeue(flow, flowid);
 		if (skb == NULL) {
 			brcmf_err("No SKB, but qlen %d\n",
 				  brcmf_flowring_qlen(flow, flowid));
 			break;
 		}
+		brcmf_tx_passing_skb(ifp, skb);
 		skb_orphan(skb);
 		if (brcmf_msgbuf_alloc_pktid(msgbuf->drvr->bus_if->dev,
 					     msgbuf->tx_pktids, skb, ETH_HLEN,
 					     &physaddr, &pktid)) {
 			brcmf_flowring_reinsert(flow, flowid, skb);
+			brcmf_tx_regained_skb(ifp, skb);
 			brcmf_err("No PKTID available !!\n");
 			break;
 		}
@@ -720,6 +725,7 @@ static void brcmf_msgbuf_txflow(struct brcmf_msgbuf *msgbuf, u16 flowid)
 			brcmf_msgbuf_get_pktid(msgbuf->drvr->bus_if->dev,
 					       msgbuf->tx_pktids, pktid);
 			brcmf_flowring_reinsert(flow, flowid, skb);
+			brcmf_tx_regained_skb(ifp, skb);
 			break;
 		}
 		count++;
@@ -728,7 +734,7 @@ static void brcmf_msgbuf_txflow(struct brcmf_msgbuf *msgbuf, u16 flowid)
 
 		tx_msghdr->msg.msgtype = MSGBUF_TYPE_TX_POST;
 		tx_msghdr->msg.request_id = cpu_to_le32(pktid);
-		tx_msghdr->msg.ifidx = brcmf_flowring_ifidx_get(flow, flowid);
+		tx_msghdr->msg.ifidx = ifidx;
 		tx_msghdr->flags = BRCMF_MSGBUF_PKT_FLAGS_FRAME_802_3;
 		tx_msghdr->flags |= (skb->priority & 0x07) <<
 				    BRCMF_MSGBUF_PKT_FLAGS_PRIO_SHIFT;
@@ -857,6 +863,7 @@ brcmf_msgbuf_process_ioctl_complete(struct brcmf_msgbuf *msgbuf, void *buf)
 static void
 brcmf_msgbuf_process_txstatus(struct brcmf_msgbuf *msgbuf, void *buf)
 {
+	struct brcmf_if *ifp;
 	struct brcmf_commonring *commonring;
 	struct msgbuf_tx_status *tx_status;
 	u32 idx;
@@ -876,8 +883,9 @@ brcmf_msgbuf_process_txstatus(struct brcmf_msgbuf *msgbuf, void *buf)
 	commonring = msgbuf->flowrings[flowid];
 	atomic_dec(&commonring->outstanding_tx);
 
-	brcmf_txfinalize(brcmf_get_ifp(msgbuf->drvr, tx_status->msg.ifidx),
-			 skb, true);
+	ifp = brcmf_get_ifp(msgbuf->drvr, tx_status->msg.ifidx);
+	brcmf_tx_regained_skb(ifp, skb);
+	brcmf_txfinalize(ifp, skb, true);
 }
 
 
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/proto.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/proto.h
index 57531f4..453cc5a 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/proto.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/proto.h
@@ -16,6 +16,7 @@
 #ifndef BRCMFMAC_PROTO_H
 #define BRCMFMAC_PROTO_H
 
+#include "core.h"
 
 enum proto_addr_mode {
 	ADDR_INDIRECT	= 0,
@@ -29,6 +30,7 @@ struct brcmf_skb_reorder_data {
 struct brcmf_proto {
 	int (*hdrpull)(struct brcmf_pub *drvr, bool do_fws,
 		       struct sk_buff *skb, struct brcmf_if **ifp);
+	int (*hdr_get_ifidx)(struct brcmf_pub *drvr, struct sk_buff *skb);
 	int (*query_dcmd)(struct brcmf_pub *drvr, int ifidx, uint cmd,
 			  void *buf, uint len);
 	int (*set_dcmd)(struct brcmf_pub *drvr, int ifidx, uint cmd, void *buf,
@@ -64,6 +66,15 @@ static inline int brcmf_proto_hdrpull(struct brcmf_pub *drvr, bool do_fws,
 		ifp = &tmp;
 	return drvr->proto->hdrpull(drvr, do_fws, skb, ifp);
 }
+
+static inline int brcmf_proto_hdr_get_ifidx(struct brcmf_pub *drvr,
+					    struct sk_buff *skb)
+{
+	if (!drvr->proto->hdr_get_ifidx)
+		return -ENOTSUPP;
+	return drvr->proto->hdr_get_ifidx(drvr, skb);
+}
+
 static inline int brcmf_proto_query_dcmd(struct brcmf_pub *drvr, int ifidx,
 					 uint cmd, void *buf, uint len)
 {
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
index b892dac..4dc96bd 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
@@ -42,6 +42,7 @@
 #include "sdio.h"
 #include "chip.h"
 #include "firmware.h"
+#include "proto.h"
 #include "core.h"
 #include "common.h"
 
@@ -2240,6 +2241,7 @@ brcmf_sdio_txpkt_postp(struct brcmf_sdio *bus, struct sk_buff_head *pktq)
 static int brcmf_sdio_txpkt(struct brcmf_sdio *bus, struct sk_buff_head *pktq,
 			    uint chan)
 {
+	struct brcmf_pub *pub = bus->sdiodev->bus_if->drvr;
 	int ret;
 	struct sk_buff *pkt_next, *tmp;
 
@@ -2263,7 +2265,13 @@ done:
 	if (ret == 0)
 		bus->tx_seq = (bus->tx_seq + pktq->qlen) % SDPCM_SEQ_WRAP;
 	skb_queue_walk_safe(pktq, pkt_next, tmp) {
+		struct brcmf_if *ifp;
+		int ifidx;
+
 		__skb_unlink(pkt_next, pktq);
+		ifidx = brcmf_proto_hdr_get_ifidx(pub, pkt_next);
+		ifp = brcmf_get_ifp(pub, ifidx);
+		brcmf_tx_regained_skb(ifp, pkt_next);
 		brcmf_txcomplete(bus->sdiodev->dev, pkt_next, ret == 0);
 	}
 	return ret;
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
index 2f978a3..d2f81c7 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
@@ -26,6 +26,7 @@
 #include "bus.h"
 #include "debug.h"
 #include "firmware.h"
+#include "proto.h"
 #include "usb.h"
 #include "core.h"
 #include "common.h"
@@ -476,12 +477,16 @@ static void brcmf_usb_tx_complete(struct urb *urb)
 {
 	struct brcmf_usbreq *req = (struct brcmf_usbreq *)urb->context;
 	struct brcmf_usbdev_info *devinfo = req->devinfo;
+	struct brcmf_pub *pub = devinfo->bus_pub.bus->drvr;
+	struct brcmf_if *ifp;
 	unsigned long flags;
 
 	brcmf_dbg(USB, "Enter, urb->status=%d, skb=%p\n", urb->status,
 		  req->skb);
 	brcmf_usb_del_fromq(devinfo, req);
 
+	ifp = brcmf_get_ifp(pub, brcmf_proto_hdr_get_ifidx(pub, req->skb));
+	brcmf_tx_regained_skb(ifp, req->skb);
 	brcmf_txcomplete(devinfo->dev, req->skb, urb->status == 0);
 	req->skb = NULL;
 	brcmf_usb_enq(devinfo, &devinfo->tx_freeq, req, &devinfo->tx_freecount);
@@ -598,7 +603,9 @@ brcmf_usb_state_change(struct brcmf_usbdev_info *devinfo, int state)
 static int brcmf_usb_tx(struct device *dev, struct sk_buff *skb)
 {
 	struct brcmf_usbdev_info *devinfo = brcmf_usb_get_businfo(dev);
+	struct brcmf_pub *pub = devinfo->bus_pub.bus->drvr;
 	struct brcmf_usbreq  *req;
+	struct brcmf_if *ifp;
 	int ret;
 	unsigned long flags;
 
@@ -622,6 +629,8 @@ static int brcmf_usb_tx(struct device *dev, struct sk_buff *skb)
 			  skb->data, skb->len, brcmf_usb_tx_complete, req);
 	req->urb->transfer_flags |= URB_ZERO_PACKET;
 	brcmf_usb_enq(devinfo, &devinfo->tx_postq, req, NULL);
+	ifp = brcmf_get_ifp(pub, brcmf_proto_hdr_get_ifidx(pub, skb));
+	brcmf_tx_passing_skb(ifp, skb);
 	ret = usb_submit_urb(req->urb, GFP_ATOMIC);
 	if (ret) {
 		brcmf_err("brcmf_usb_tx usb_submit_urb FAILED\n");
@@ -629,6 +638,7 @@ static int brcmf_usb_tx(struct device *dev, struct sk_buff *skb)
 		req->skb = NULL;
 		brcmf_usb_enq(devinfo, &devinfo->tx_freeq, req,
 			      &devinfo->tx_freecount);
+		brcmf_tx_regained_skb(ifp, skb);
 		goto fail;
 	}
 
-- 
2.9.3
