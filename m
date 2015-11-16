From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] via-velocity: unconditionally drop frames with bad l2 length
Date: Mon, 16 Nov 2015 14:36:32 +0200
Message-ID: <1447677392-17400-1-git-send-email-timo.teras@iki.fi>
References: <20151113232133.GA21633@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34296 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbbKPMgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 07:36:51 -0500
Received: by lffu14 with SMTP id u14so85766876lff.1
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 04:36:49 -0800 (PST)
In-Reply-To: <20151113232133.GA21633@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default the driver allowed incorrect frames to be received. What is
worse the code does not handle very short frames correctly. The FCS
length is unconditionally subtracted, and the underflow can cause
skb_put to be called with large number after implicit cast to unsigned.
And indeed, an skb_over_panic() was observed with via-velocity.

This removes the module parameter as it does not work in it's
current state, and should be implemented via NETIF_F_RXALL if needed.

Suggested-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
=46rancois, is this something like you had in mind? I can try give this
a test spin in the known bad location, if this looks otherwise ok.

 drivers/net/ethernet/via/via-velocity.c | 24 +++---------------------
 1 file changed, 3 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethe=
rnet/via/via-velocity.c
index a43e849..03ce386 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -345,13 +345,6 @@ VELOCITY_PARAM(flow_control, "Enable flow control =
ability");
 */
 VELOCITY_PARAM(speed_duplex, "Setting the speed and duplex mode");
=20
-#define VAL_PKT_LEN_DEF     0
-/* ValPktLen[] is used for setting the checksum offload ability of NIC=
=2E
-   0: Receive frame with invalid layer 2 length (Default)
-   1: Drop frame with invalid layer 2 length
-*/
-VELOCITY_PARAM(ValPktLen, "Receiving or Drop invalid 802.3 frame");
-
 #define WOL_OPT_DEF     0
 #define WOL_OPT_MIN     0
 #define WOL_OPT_MAX     7
@@ -494,7 +487,6 @@ static void velocity_get_options(struct velocity_op=
t *opts, int index,
=20
 	velocity_set_int_opt(&opts->flow_cntl, flow_control[index], FLOW_CNTL=
_MIN, FLOW_CNTL_MAX, FLOW_CNTL_DEF, "flow_control", devname);
 	velocity_set_bool_opt(&opts->flags, IP_byte_align[index], IP_ALIG_DEF=
, VELOCITY_FLAGS_IP_ALIGN, "IP_byte_align", devname);
-	velocity_set_bool_opt(&opts->flags, ValPktLen[index], VAL_PKT_LEN_DEF=
, VELOCITY_FLAGS_VAL_PKT_LEN, "ValPktLen", devname);
 	velocity_set_int_opt((int *) &opts->spd_dpx, speed_duplex[index], MED=
_LNK_MIN, MED_LNK_MAX, MED_LNK_DEF, "Media link mode", devname);
 	velocity_set_int_opt(&opts->wol_opts, wol_opts[index], WOL_OPT_MIN, W=
OL_OPT_MAX, WOL_OPT_DEF, "Wake On Lan options", devname);
 	opts->numrx =3D (opts->numrx & ~3);
@@ -2055,8 +2047,9 @@ static int velocity_receive_frame(struct velocity=
_info *vptr, int idx)
 	int pkt_len =3D le16_to_cpu(rd->rdesc0.len) & 0x3fff;
 	struct sk_buff *skb;
=20
-	if (rd->rdesc0.RSR & (RSR_STP | RSR_EDP)) {
-		VELOCITY_PRT(MSG_LEVEL_VERBOSE, KERN_ERR " %s : the received frame s=
pans multiple RDs.\n", vptr->netdev->name);
+	if (unlikely(rd->rdesc0.RSR & (RSR_STP | RSR_EDP | RSR_RL))) {
+		if (rd->rdesc0.RSR & (RSR_STP | RSR_EDP))
+			VELOCITY_PRT(MSG_LEVEL_VERBOSE, KERN_ERR " %s : the received frame =
spans multiple RDs.\n", vptr->netdev->name);
 		stats->rx_length_errors++;
 		return -EINVAL;
 	}
@@ -2069,17 +2062,6 @@ static int velocity_receive_frame(struct velocit=
y_info *vptr, int idx)
 	dma_sync_single_for_cpu(vptr->dev, rd_info->skb_dma,
 				    vptr->rx.buf_sz, DMA_FROM_DEVICE);
=20
-	/*
-	 *	Drop frame not meeting IEEE 802.3
-	 */
-
-	if (vptr->flags & VELOCITY_FLAGS_VAL_PKT_LEN) {
-		if (rd->rdesc0.RSR & RSR_RL) {
-			stats->rx_length_errors++;
-			return -EINVAL;
-		}
-	}
-
 	velocity_rx_csum(rd, skb);
=20
 	if (velocity_rx_copy(&skb, pkt_len, vptr) < 0) {
--=20
2.6.3
