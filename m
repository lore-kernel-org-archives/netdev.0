From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 3/3] bnx2x: expose HW RX VLAN stripping toggle
Date: Wed, 31 Aug 2011 17:00:36 +0200
Message-ID: <1314802836-9862-4-git-send-email-mschmidt@redhat.com>
References: <1314802836-9862-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vladz@broadcom.com, dmitry@broadcom.com, eilong@broadcom.com,
	mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63905 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755745Ab1HaPAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 11:00:49 -0400
In-Reply-To: <1314802836-9862-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow disabling of HW RX VLAN stripping with ethtool.

[v3: per-queue flag was overkill, store the HW config in bp.
     Suggestions by Vlad Zolotarov and Micha=C5=82 Miros=C5=82aw.]

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   20 ++++++++++++++=
+-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   10 +++++-----
 3 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/=
ethernet/broadcom/bnx2x/bnx2x.h
index 5d5f323..b85017e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1174,7 +1174,7 @@ struct bnx2x {
 #define USING_MSIX_FLAG			(1 << 5)
 #define USING_MSI_FLAG			(1 << 6)
 #define DISABLE_MSI_FLAG		(1 << 7)
-
+#define RX_VLAN_STRIP_FLAG		(1 << 8)
 #define NO_MCP_FLAG			(1 << 9)
=20
 #define BP_NOMCP(bp)			(bp->flags & NO_MCP_FLAG)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index c660317..6e1b4b4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -385,6 +385,10 @@ static inline u16 bnx2x_set_lro_mss(struct bnx2x *=
bp, u16 parsing_flags,
 	else /* IPv4 */
 		hdrs_len +=3D sizeof(struct iphdr);
=20
+	/* VLAN header present and not stripped by HW */
+	if ((parsing_flags & PARSING_FLAGS_VLAN) &&
+	    !(bp->flags & RX_VLAN_STRIP_FLAG))
+		hdrs_len +=3D VLAN_HLEN;
=20
 	/* Check if there was a TCP timestamp, if there is it's will
 	 * always be 12 bytes length: nop nop kind length echo val.
@@ -412,7 +416,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, st=
ruct bnx2x_fastpath *fp,
 	frag_size =3D le16_to_cpu(cqe->pkt_len) - len_on_bd;
 	pages =3D SGE_PAGE_ALIGN(frag_size) >> SGE_PAGE_SHIFT;
=20
-	/* This is needed in order to enable forwarding support */
+	/* Doing LRO, let TCP know the receive MSS */
 	if (frag_size)
 		skb_shinfo(skb)->gso_size =3D bnx2x_set_lro_mss(bp,
 					tpa_info->parsing_flags, len_on_bd);
@@ -514,7 +518,8 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct=
 bnx2x_fastpath *fp,
 		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
=20
 		if (!bnx2x_fill_frag_skb(bp, fp, queue, skb, cqe, cqe_idx)) {
-			if (tpa_info->parsing_flags & PARSING_FLAGS_VLAN)
+			if ((tpa_info->parsing_flags & PARSING_FLAGS_VLAN) &&
+			    (bp->flags & RX_VLAN_STRIP_FLAG))
 				__vlan_hwaccel_put_tag(skb, tpa_info->vlan_tag);
 			napi_gro_receive(&fp->napi, skb);
 		} else {
@@ -745,8 +750,8 @@ reuse_rx:
=20
 		skb_record_rx_queue(skb, fp->index);
=20
-		if (le16_to_cpu(cqe_fp->pars_flags.flags) &
-		    PARSING_FLAGS_VLAN)
+		if ((le16_to_cpu(cqe_fp->pars_flags.flags) &
+		    PARSING_FLAGS_VLAN) && (bp->flags & RX_VLAN_STRIP_FLAG))
 			__vlan_hwaccel_put_tag(skb,
 					       le16_to_cpu(cqe_fp->vlan_tag));
 		napi_gro_receive(&fp->napi, skb);
@@ -1711,6 +1716,11 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mo=
de)
=20
 	bp->state =3D BNX2X_STATE_OPENING_WAIT4_LOAD;
=20
+	if (bp->dev->features & NETIF_F_HW_VLAN_RX)
+		bp->flags |=3D RX_VLAN_STRIP_FLAG;
+	else
+		bp->flags &=3D ~RX_VLAN_STRIP_FLAG;
+
 	/* Set the initial link reported state to link down */
 	bnx2x_acquire_phy_lock(bp);
 	memset(&bp->last_reported_link, 0, sizeof(bp->last_reported_link));
@@ -3412,7 +3422,7 @@ int bnx2x_set_features(struct net_device *dev, u3=
2 features)
 	struct bnx2x *bp =3D netdev_priv(dev);
 	bool bnx2x_reload =3D false;
=20
-	if ((features ^ dev->features) & NETIF_F_LRO)
+	if ((features ^ dev->features) & (NETIF_F_LRO | NETIF_F_HW_VLAN_RX))
 		bnx2x_reload =3D true;
=20
 	if (features & NETIF_F_LOOPBACK) {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c1285db..e61be4e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2720,9 +2720,8 @@ static inline unsigned long bnx2x_get_q_flags(str=
uct bnx2x *bp,
 		__set_bit(BNX2X_Q_FLG_MCAST, &flags);
 	}
=20
-	/* Always set HW VLAN stripping */
-	__set_bit(BNX2X_Q_FLG_VLAN, &flags);
-
+	if (bp->flags & RX_VLAN_STRIP_FLAG)
+		__set_bit(BNX2X_Q_FLG_VLAN, &flags);
=20
 	return flags | bnx2x_get_common_flags(bp, fp, true);
 }
@@ -10265,12 +10264,13 @@ static int __devinit bnx2x_init_dev(struct pc=
i_dev *pdev,
=20
 	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM=
 |
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_LRO |
-		NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_HW_VLAN_TX;
+		NETIF_F_RXCSUM | NETIF_F_RXHASH |
+		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
=20
 	dev->vlan_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CS=
UM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
=20
-	dev->features |=3D dev->hw_features | NETIF_F_HW_VLAN_RX;
+	dev->features |=3D dev->hw_features;
 	if (bp->flags & USING_DAC_FLAG)
 		dev->features |=3D NETIF_F_HIGHDMA;
=20
--=20
1.7.6
