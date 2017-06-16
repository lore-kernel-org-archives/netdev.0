From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/5] networking: convert many more places to skb_put_zero()
Date: Fri, 16 Jun 2017 09:07:43 +0200
Message-ID: <20170616070747.3332-2-johannes@sipsolutions.net>
References: <20170616070747.3332-1-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57660 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752017AbdFPHHw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 03:07:52 -0400
In-Reply-To: <20170616070747.3332-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

There were many places that my previous spatch didn't find,
as pointed out by yuan linyu in various patches.

The following spatch found many more and also removes the
now unnecessary casts:

    @@
    identifier p, p2;
    expression len;
    expression skb;
    type t, t2;
    @@
    (
    -p = skb_put(skb, len);
    +p = skb_put_zero(skb, len);
    |
    -p = (t)skb_put(skb, len);
    +p = skb_put_zero(skb, len);
    )
    ... when != p
    (
    p2 = (t2)p;
    -memset(p2, 0, len);
    |
    -memset(p, 0, len);
    )

    @@
    type t, t2;
    identifier p, p2;
    expression skb;
    @@
    t *p;
    ...
    (
    -p = skb_put(skb, sizeof(t));
    +p = skb_put_zero(skb, sizeof(t));
    |
    -p = (t *)skb_put(skb, sizeof(t));
    +p = skb_put_zero(skb, sizeof(t));
    )
    ... when != p
    (
    p2 = (t2)p;
    -memset(p2, 0, sizeof(*p));
    |
    -memset(p, 0, sizeof(*p));
    )

    @@
    expression skb, len;
    @@
    -memset(skb_put(skb, len), 0, len);
    +skb_put_zero(skb, len);

Apply it to the tree (with one manual fixup to keep the
comment in vxlan.c, which spatch removed.)

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
v2: add "... when != p" clauses to catch more things
---
 drivers/infiniband/hw/cxgb3/cxio_hal.c             |  6 ++--
 drivers/infiniband/hw/cxgb3/iwch_cm.c              |  3 +-
 drivers/infiniband/hw/cxgb3/iwch_qp.c              |  6 ++--
 drivers/infiniband/hw/cxgb4/cm.c                   |  9 ++----
 .../net/ethernet/mellanox/mlx5/core/en_selftest.c  |  2 +-
 drivers/net/usb/cdc_ncm.c                          |  4 +--
 drivers/net/usb/kalmia.c                           |  2 +-
 drivers/net/vxlan.c                                |  4 +--
 drivers/net/wireless/ath/ath9k/channel.c           |  3 +-
 drivers/net/wireless/intersil/hostap/hostap_ap.c   |  7 ++---
 drivers/net/wireless/intersil/hostap/hostap_main.c |  4 +--
 drivers/net/wireless/intersil/p54/txrx.c           |  3 +-
 drivers/net/wireless/marvell/mwifiex/cmdevt.c      |  3 +-
 drivers/net/wireless/marvell/mwifiex/tdls.c        |  3 +-
 drivers/net/wireless/quantenna/qtnfmac/commands.c  | 10 ++----
 drivers/net/wireless/realtek/rtlwifi/base.c        |  6 ++--
 drivers/net/wireless/ti/wlcore/cmd.c               |  3 +-
 drivers/net/wireless/ti/wlcore/main.c              |  5 ++-
 drivers/scsi/fcoe/fcoe_ctlr.c                      |  3 +-
 drivers/scsi/libfc/fc_libfc.c                      |  2 +-
 drivers/usb/gadget/function/f_ncm.c                | 15 +++------
 net/atm/signaling.c                                |  3 +-
 net/batman-adv/bat_v_elp.c                         |  3 +-
 net/bridge/netfilter/nft_reject_bridge.c           |  6 ++--
 net/core/pktgen.c                                  |  4 +--
 net/ipv4/ipconfig.c                                |  3 +-
 net/ipv4/netfilter/nf_reject_ipv4.c                |  3 +-
 net/ipv6/mcast.c                                   |  3 +-
 net/key/af_key.c                                   |  9 ++----
 net/mac80211/agg-rx.c                              |  3 +-
 net/mac80211/agg-tx.c                              |  6 ++--
 net/mac80211/debugfs_netdev.c                      |  5 ++-
 net/mac80211/ht.c                                  |  3 +-
 net/mac80211/mesh.c                                |  3 +-
 net/mac80211/mesh_hwmp.c                           |  6 ++--
 net/mac80211/mesh_plink.c                          |  3 +-
 net/mac80211/mesh_ps.c                             |  2 +-
 net/mac80211/mlme.c                                |  6 ++--
 net/mac80211/rx.c                                  |  3 +-
 net/mac80211/spectmgmt.c                           |  3 +-
 net/mac80211/tdls.c                                |  6 ++--
 net/mac80211/tx.c                                  | 12 +++-----
 net/mac80211/util.c                                |  6 ++--
 net/ncsi/ncsi-cmd.c                                | 36 ++++++++--------------
 net/openvswitch/datapath.c                         |  2 +-
 net/qrtr/qrtr.c                                    |  9 ++----
 net/rxrpc/sendmsg.c                                |  2 +-
 net/sctp/output.c                                  |  2 +-
 net/sctp/sm_make_chunk.c                           |  3 +-
 49 files changed, 89 insertions(+), 169 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.c b/drivers/infiniband/hw/cxgb3/cxio_hal.c
index 558d6a03375d..97f7f9544e70 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.c
@@ -142,8 +142,7 @@ static int cxio_hal_clear_qp_ctx(struct cxio_rdev *rdev_p, u32 qpid)
 		pr_debug("%s alloc_skb failed\n", __func__);
 		return -ENOMEM;
 	}
-	wqe = (struct t3_modify_qp_wr *) skb_put(skb, sizeof(*wqe));
-	memset(wqe, 0, sizeof(*wqe));
+	wqe = skb_put_zero(skb, sizeof(*wqe));
 	build_fw_riwrh((struct fw_riwrh *) wqe, T3_WR_QP_MOD,
 		       T3_COMPLETION_FLAG | T3_NOTIFY_FLAG, 0, qpid, 7,
 		       T3_SOPEOP);
@@ -561,8 +560,7 @@ static int cxio_hal_init_ctrl_qp(struct cxio_rdev *rdev_p)
 	ctx1 |= ((u64) (V_EC_BASE_HI((u32) base_addr & 0xf) | V_EC_RESPQ(0) |
 			V_EC_TYPE(0) | V_EC_GEN(1) |
 			V_EC_UP_TOKEN(T3_CTL_QP_TID) | F_EC_VALID)) << 32;
-	wqe = (struct t3_modify_qp_wr *) skb_put(skb, sizeof(*wqe));
-	memset(wqe, 0, sizeof(*wqe));
+	wqe = skb_put_zero(skb, sizeof(*wqe));
 	build_fw_riwrh((struct fw_riwrh *) wqe, T3_WR_QP_MOD, 0, 0,
 		       T3_CTL_QP_TID, 7, T3_SOPEOP);
 	wqe->flags = cpu_to_be32(MODQP_WRITE_EC);
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index b61630eba912..f4c23a74f18c 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -417,8 +417,7 @@ static int send_abort(struct iwch_ep *ep, struct sk_buff *skb, gfp_t gfp)
 	}
 	skb->priority = CPL_PRIORITY_DATA;
 	set_arp_failure_handler(skb, abort_arp_failure);
-	req = (struct cpl_abort_req *) skb_put(skb, sizeof(*req));
-	memset(req, 0, sizeof(*req));
+	req = skb_put_zero(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_HOST_ABORT_CON_REQ));
 	req->wr.wr_lo = htonl(V_WR_TID(ep->hwtid));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_ABORT_REQ, ep->hwtid));
diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/hw/cxgb3/iwch_qp.c
index ba6d5d281b03..7f633da0185d 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -670,8 +670,7 @@ int iwch_post_zb_read(struct iwch_ep *ep)
 		pr_err("%s cannot send zb_read!!\n", __func__);
 		return -ENOMEM;
 	}
-	wqe = (union t3_wr *)skb_put(skb, sizeof(struct t3_rdma_read_wr));
-	memset(wqe, 0, sizeof(struct t3_rdma_read_wr));
+	wqe = skb_put_zero(skb, sizeof(struct t3_rdma_read_wr));
 	wqe->read.rdmaop = T3_READ_REQ;
 	wqe->read.reserved[0] = 0;
 	wqe->read.reserved[1] = 0;
@@ -702,8 +701,7 @@ int iwch_post_terminate(struct iwch_qp *qhp, struct respQ_msg_t *rsp_msg)
 		pr_err("%s cannot send TERMINATE!\n", __func__);
 		return -ENOMEM;
 	}
-	wqe = (union t3_wr *)skb_put(skb, 40);
-	memset(wqe, 0, 40);
+	wqe = skb_put_zero(skb, 40);
 	wqe->send.rdmaop = T3_TERMINATE;
 
 	/* immediate data length */
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 2f1136bf7b1f..7c32a7c7977d 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -927,8 +927,7 @@ static int send_mpa_req(struct c4iw_ep *ep, struct sk_buff *skb,
 	}
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ep->txq_idx);
 
-	req = (struct fw_ofld_tx_data_wr *)skb_put(skb, wrlen);
-	memset(req, 0, wrlen);
+	req = skb_put_zero(skb, wrlen);
 	req->op_to_immdlen = cpu_to_be32(
 		FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
 		FW_WR_COMPL_F |
@@ -1034,8 +1033,7 @@ static int send_mpa_reject(struct c4iw_ep *ep, const void *pdata, u8 plen)
 	}
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ep->txq_idx);
 
-	req = (struct fw_ofld_tx_data_wr *)skb_put(skb, wrlen);
-	memset(req, 0, wrlen);
+	req = skb_put_zero(skb, wrlen);
 	req->op_to_immdlen = cpu_to_be32(
 		FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
 		FW_WR_COMPL_F |
@@ -1115,8 +1113,7 @@ static int send_mpa_reply(struct c4iw_ep *ep, const void *pdata, u8 plen)
 	}
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ep->txq_idx);
 
-	req = (struct fw_ofld_tx_data_wr *) skb_put(skb, wrlen);
-	memset(req, 0, wrlen);
+	req = skb_put_zero(skb, wrlen);
 	req->op_to_immdlen = cpu_to_be32(
 		FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
 		FW_WR_COMPL_F |
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
index 5225f2226a67..601abf240d63 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
@@ -172,7 +172,7 @@ static struct sk_buff *mlx5e_test_get_udp_skb(struct mlx5e_priv *priv)
 	mlxh->magic = cpu_to_be64(MLX5E_TEST_MAGIC);
 	strlcpy(mlxh->text, mlx5e_test_text, sizeof(mlxh->text));
 	datalen -= sizeof(*mlxh);
-	memset(skb_put(skb, datalen), 0, datalen);
+	skb_put_zero(skb, datalen);
 
 	skb->csum = 0;
 	skb->ip_summed = CHECKSUM_PARTIAL;
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index b5cec1824a78..7f02954772c6 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1017,7 +1017,7 @@ static void cdc_ncm_align_tail(struct sk_buff *skb, size_t modulus, size_t remai
 	if (skb->len + align > max)
 		align = max - skb->len;
 	if (align && skb_tailroom(skb) >= align)
-		memset(skb_put(skb, align), 0, align);
+		skb_put_zero(skb, align);
 }
 
 /* return a pointer to a valid struct usb_cdc_ncm_ndp16 of type sign, possibly
@@ -1247,7 +1247,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 	if (!(dev->driver_info->flags & FLAG_SEND_ZLP) &&
 	    skb_out->len > ctx->min_tx_pkt) {
 		padding_count = ctx->tx_max - skb_out->len;
-		memset(skb_put(skb_out, padding_count), 0, padding_count);
+		skb_put_zero(skb_out, padding_count);
 	} else if (skb_out->len < ctx->tx_max &&
 		   (skb_out->len % dev->maxpacket) == 0) {
 		*skb_put(skb_out, 1) = 0;	/* force short packet */
diff --git a/drivers/net/usb/kalmia.c b/drivers/net/usb/kalmia.c
index 8aefb282c862..ce0b0b4e3a57 100644
--- a/drivers/net/usb/kalmia.c
+++ b/drivers/net/usb/kalmia.c
@@ -217,7 +217,7 @@ kalmia_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 	remainder = skb->len % KALMIA_ALIGN_SIZE;
 	if (remainder > 0) {
 		padlen = KALMIA_ALIGN_SIZE - remainder;
-		memset(skb_put(skb, padlen), 0, padlen);
+		skb_put_zero(skb, padlen);
 	}
 
 	netdev_dbg(dev->net,
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 25b70cad055c..4e1d427d340c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1584,10 +1584,8 @@ static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	skb_pull(reply, sizeof(struct ipv6hdr));
 	skb_reset_transport_header(reply);
 
-	na = (struct nd_msg *)skb_put(reply, sizeof(*na) + na_olen);
-
 	/* Neighbor Advertisement */
-	memset(na, 0, sizeof(*na)+na_olen);
+	na = skb_put_zero(reply, sizeof(*na) + na_olen);
 	na->icmph.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT;
 	na->icmph.icmp6_router = isrouter;
 	na->icmph.icmp6_override = 1;
diff --git a/drivers/net/wireless/ath/ath9k/channel.c b/drivers/net/wireless/ath/ath9k/channel.c
index b84539d89f1a..373b1e9457fd 100644
--- a/drivers/net/wireless/ath/ath9k/channel.c
+++ b/drivers/net/wireless/ath/ath9k/channel.c
@@ -1526,8 +1526,7 @@ void ath9k_beacon_add_noa(struct ath_softc *sc, struct ath_vif *avp,
 	hdr[1] = sizeof(noa_ie_hdr) + noa_len - 2;
 	hdr[7] = noa_len;
 
-	noa = (void *) skb_put(skb, noa_len);
-	memset(noa, 0, noa_len);
+	noa = skb_put_zero(skb, noa_len);
 
 	noa->index = avp->noa_index;
 	noa->oppps_ctwindow = ath9k_get_ctwin(sc, avp);
diff --git a/drivers/net/wireless/intersil/hostap/hostap_ap.c b/drivers/net/wireless/intersil/hostap/hostap_ap.c
index c995ace153ee..89b5987303a4 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_ap.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_ap.c
@@ -998,12 +998,10 @@ static void prism2_send_mgmt(struct net_device *dev,
 
 	fc = type_subtype;
 	hdrlen = hostap_80211_get_hdrlen(cpu_to_le16(type_subtype));
-	hdr = (struct ieee80211_hdr *) skb_put(skb, hdrlen);
+	hdr = skb_put_zero(skb, hdrlen);
 	if (body)
 		memcpy(skb_put(skb, body_len), body, body_len);
 
-	memset(hdr, 0, hdrlen);
-
 	/* FIX: ctrl::ack sending used special HFA384X_TX_CTRL_802_11
 	 * tx_control instead of using local->tx_control */
 
@@ -1325,8 +1323,7 @@ static char * ap_auth_make_challenge(struct ap_data *ap)
 	}
 
 	skb_reserve(skb, ap->crypt->extra_mpdu_prefix_len);
-	memset(skb_put(skb, WLAN_AUTH_CHALLENGE_LEN), 0,
-	       WLAN_AUTH_CHALLENGE_LEN);
+	skb_put_zero(skb, WLAN_AUTH_CHALLENGE_LEN);
 	if (ap->crypt->encrypt_mpdu(skb, 0, ap->crypt_priv)) {
 		dev_kfree_skb(skb);
 		kfree(tmpbuf);
diff --git a/drivers/net/wireless/intersil/hostap/hostap_main.c b/drivers/net/wireless/intersil/hostap/hostap_main.c
index 1372b20f931e..400f9b5d620e 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_main.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_main.c
@@ -1039,9 +1039,7 @@ int prism2_sta_send_mgmt(local_info_t *local, u8 *dst, u16 stype,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	mgmt = (struct hostap_ieee80211_mgmt *)
-		skb_put(skb, IEEE80211_MGMT_HDR_LEN);
-	memset(mgmt, 0, IEEE80211_MGMT_HDR_LEN);
+	mgmt = skb_put_zero(skb, IEEE80211_MGMT_HDR_LEN);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT | stype);
 	memcpy(mgmt->da, dst, ETH_ALEN);
 	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
diff --git a/drivers/net/wireless/intersil/p54/txrx.c b/drivers/net/wireless/intersil/p54/txrx.c
index 5e1c91a80c58..60f9b678ef74 100644
--- a/drivers/net/wireless/intersil/p54/txrx.c
+++ b/drivers/net/wireless/intersil/p54/txrx.c
@@ -910,8 +910,7 @@ void p54_tx_80211(struct ieee80211_hw *dev,
 		}
 		/* reserve some space for ICV */
 		len += info->control.hw_key->icv_len;
-		memset(skb_put(skb, info->control.hw_key->icv_len), 0,
-		       info->control.hw_key->icv_len);
+		skb_put_zero(skb, info->control.hw_key->icv_len);
 	} else {
 		txhdr->key_type = 0;
 		txhdr->key_len = 0;
diff --git a/drivers/net/wireless/marvell/mwifiex/cmdevt.c b/drivers/net/wireless/marvell/mwifiex/cmdevt.c
index 40c3fe5ab8ca..8dad52886034 100644
--- a/drivers/net/wireless/marvell/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/marvell/mwifiex/cmdevt.c
@@ -622,8 +622,7 @@ int mwifiex_send_cmd(struct mwifiex_private *priv, u16 cmd_no,
 		return -1;
 	}
 
-	memset(skb_put(cmd_node->cmd_skb, sizeof(struct host_cmd_ds_command)),
-	       0, sizeof(struct host_cmd_ds_command));
+	skb_put_zero(cmd_node->cmd_skb, sizeof(struct host_cmd_ds_command));
 
 	cmd_ptr = (struct host_cmd_ds_command *) (cmd_node->cmd_skb->data);
 	cmd_ptr->command = cpu_to_le16(cmd_no);
diff --git a/drivers/net/wireless/marvell/mwifiex/tdls.c b/drivers/net/wireless/marvell/mwifiex/tdls.c
index b7d124dbef0c..c76b7315af55 100644
--- a/drivers/net/wireless/marvell/mwifiex/tdls.c
+++ b/drivers/net/wireless/marvell/mwifiex/tdls.c
@@ -388,8 +388,7 @@ mwifiex_tdls_add_wmm_param_ie(struct mwifiex_private *priv, struct sk_buff *skb)
 	u8 ac_be[] = {0x03, 0xa4, 0x00, 0x00};
 	u8 ac_bk[] = {0x27, 0xa4, 0x00, 0x00};
 
-	wmm = (void *)skb_put(skb, sizeof(*wmm));
-	memset(wmm, 0, sizeof(*wmm));
+	wmm = skb_put_zero(skb, sizeof(*wmm));
 
 	wmm->element_id = WLAN_EID_VENDOR_SPECIFIC;
 	wmm->len = sizeof(*wmm) - 2;
diff --git a/drivers/net/wireless/quantenna/qtnfmac/commands.c b/drivers/net/wireless/quantenna/qtnfmac/commands.c
index f0a0cfa7d8a1..37c3bececa1f 100644
--- a/drivers/net/wireless/quantenna/qtnfmac/commands.c
+++ b/drivers/net/wireless/quantenna/qtnfmac/commands.c
@@ -135,7 +135,7 @@ static struct sk_buff *qtnf_cmd_alloc_new_cmdskb(u8 macid, u8 vifid, u16 cmd_no,
 		return NULL;
 	}
 
-	memset(skb_put(cmd_skb, cmd_size), 0, cmd_size);
+	skb_put_zero(cmd_skb, cmd_size);
 
 	cmd = (struct qlink_cmd *)cmd_skb->data;
 	cmd->mhdr.len = cpu_to_le16(cmd_skb->len);
@@ -238,9 +238,7 @@ int qtnf_cmd_send_config_ap(struct qtnf_vif *vif)
 				 bss_cfg->bcn_period);
 	qtnf_cmd_skb_put_tlv_u8(cmd_skb, QTN_TLV_ID_DTIM, bss_cfg->dtim);
 
-	qchan = (struct qlink_tlv_channel *)skb_put(cmd_skb, sizeof(*qchan));
-
-	memset(qchan, 0, sizeof(*qchan));
+	qchan = skb_put_zero(cmd_skb, sizeof(*qchan));
 	qchan->hdr.type = cpu_to_le16(QTN_TLV_ID_CHANNEL);
 	qchan->hdr.len = cpu_to_le16(sizeof(*qchan) -
 			sizeof(struct qlink_tlv_hdr));
@@ -1794,9 +1792,7 @@ int qtnf_cmd_send_scan(struct qtnf_wmac *mac)
 			pr_debug("MAC%u: scan chan=%d, freq=%d, flags=%#x\n",
 				 mac->macid, sc->hw_value, sc->center_freq,
 				 sc->flags);
-			qchan = (struct qlink_tlv_channel *)
-					skb_put(cmd_skb, sizeof(*qchan));
-			memset(qchan, 0, sizeof(*qchan));
+			qchan = skb_put_zero(cmd_skb, sizeof(*qchan));
 			flags = 0;
 
 			qchan->hdr.type = cpu_to_le16(QTN_TLV_ID_CHANNEL);
diff --git a/drivers/net/wireless/realtek/rtlwifi/base.c b/drivers/net/wireless/realtek/rtlwifi/base.c
index bdc379178e87..710e5b447cff 100644
--- a/drivers/net/wireless/realtek/rtlwifi/base.c
+++ b/drivers/net/wireless/realtek/rtlwifi/base.c
@@ -1875,8 +1875,7 @@ static struct sk_buff *rtl_make_smps_action(struct ieee80211_hw *hw,
 		return NULL;
 
 	skb_reserve(skb, hw->extra_tx_headroom);
-	action_frame = (void *)skb_put(skb, 27);
-	memset(action_frame, 0, 27);
+	action_frame = skb_put_zero(skb, 27);
 	memcpy(action_frame->da, da, ETH_ALEN);
 	memcpy(action_frame->sa, rtlefuse->dev_addr, ETH_ALEN);
 	memcpy(action_frame->bssid, bssid, ETH_ALEN);
@@ -2005,8 +2004,7 @@ struct sk_buff *rtl_make_del_ba(struct ieee80211_hw *hw,
 		return NULL;
 
 	skb_reserve(skb, hw->extra_tx_headroom);
-	action_frame = (void *)skb_put(skb, 34);
-	memset(action_frame, 0, 34);
+	action_frame = skb_put_zero(skb, 34);
 	memcpy(action_frame->sa, sa, ETH_ALEN);
 	memcpy(action_frame->da, rtlefuse->dev_addr, ETH_ALEN);
 	memcpy(action_frame->bssid, bssid, ETH_ALEN);
diff --git a/drivers/net/wireless/ti/wlcore/cmd.c b/drivers/net/wireless/ti/wlcore/cmd.c
index 7f4da727bb7b..4a39fb13c478 100644
--- a/drivers/net/wireless/ti/wlcore/cmd.c
+++ b/drivers/net/wireless/ti/wlcore/cmd.c
@@ -1233,8 +1233,7 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	skb_reserve(skb, sizeof(*hdr) + WL1271_EXTRA_SPACE_MAX);
 
-	tmpl = (struct wl12xx_arp_rsp_template *)skb_put(skb, sizeof(*tmpl));
-	memset(tmpl, 0, sizeof(*tmpl));
+	tmpl = skb_put_zero(skb, sizeof(*tmpl));
 
 	/* llc layer */
 	memcpy(tmpl->llc_hdr, rfc1042_header, sizeof(rfc1042_header));
diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 382ec15ec1af..60aaa850fbd1 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -1308,13 +1308,12 @@ static struct sk_buff *wl12xx_alloc_dummy_packet(struct wl1271 *wl)
 
 	skb_reserve(skb, sizeof(struct wl1271_tx_hw_descr));
 
-	hdr = (struct ieee80211_hdr_3addr *) skb_put(skb, sizeof(*hdr));
-	memset(hdr, 0, sizeof(*hdr));
+	hdr = skb_put_zero(skb, sizeof(*hdr));
 	hdr->frame_control = cpu_to_le16(IEEE80211_FTYPE_DATA |
 					 IEEE80211_STYPE_NULLFUNC |
 					 IEEE80211_FCTL_TODS);
 
-	memset(skb_put(skb, dummy_packet_size), 0, dummy_packet_size);
+	skb_put_zero(skb, dummy_packet_size);
 
 	/* Dummy packets require the TID to be management */
 	skb->priority = WL1271_TID_MGMT;
diff --git a/drivers/scsi/fcoe/fcoe_ctlr.c b/drivers/scsi/fcoe/fcoe_ctlr.c
index 656463ff9ccb..e17bdb3adf9e 100644
--- a/drivers/scsi/fcoe/fcoe_ctlr.c
+++ b/drivers/scsi/fcoe/fcoe_ctlr.c
@@ -660,8 +660,7 @@ static int fcoe_ctlr_encaps(struct fcoe_ctlr *fip, struct fc_lport *lport,
 
 	if (op != ELS_LS_RJT) {
 		dlen += sizeof(*mac);
-		mac = (struct fip_mac_desc *)skb_put(skb, sizeof(*mac));
-		memset(mac, 0, sizeof(*mac));
+		mac = skb_put_zero(skb, sizeof(*mac));
 		mac->fd_desc.fip_dtype = FIP_DT_MAC;
 		mac->fd_desc.fip_dlen = sizeof(*mac) / FIP_BPW;
 		if (dtype != FIP_DT_FLOGI && dtype != FIP_DT_FDISC) {
diff --git a/drivers/scsi/libfc/fc_libfc.c b/drivers/scsi/libfc/fc_libfc.c
index d623d084b7ec..dbadbc81b24b 100644
--- a/drivers/scsi/libfc/fc_libfc.c
+++ b/drivers/scsi/libfc/fc_libfc.c
@@ -178,7 +178,7 @@ void fc_fill_hdr(struct fc_frame *fp, const struct fc_frame *in_fp,
 		fill = -fr_len(fp) & 3;
 		if (fill) {
 			/* TODO, this may be a problem with fragmented skb */
-			memset(skb_put(fp_skb(fp), fill), 0, fill);
+			skb_put_zero(fp_skb(fp), fill);
 			f_ctl |= fill;
 		}
 		fr_eof(fp) = FC_EOF_T;
diff --git a/drivers/usb/gadget/function/f_ncm.c b/drivers/usb/gadget/function/f_ncm.c
index 864819ff9a7d..2882c6d3ae66 100644
--- a/drivers/usb/gadget/function/f_ncm.c
+++ b/drivers/usb/gadget/function/f_ncm.c
@@ -1004,8 +1004,7 @@ static struct sk_buff *package_for_tx(struct f_ncm *ncm)
 	}
 
 	/* Insert NDP alignment. */
-	ntb_iter = (void *) skb_put(skb2, ndp_pad);
-	memset(ntb_iter, 0, ndp_pad);
+	ntb_iter = skb_put_zero(skb2, ndp_pad);
 
 	/* Copy NTB across. */
 	ntb_iter = (void *) skb_put(skb2, ncm->skb_tx_ndp->len);
@@ -1014,8 +1013,7 @@ static struct sk_buff *package_for_tx(struct f_ncm *ncm)
 	ncm->skb_tx_ndp = NULL;
 
 	/* Insert zero'd datagram. */
-	ntb_iter = (void *) skb_put(skb2, dgram_idx_len);
-	memset(ntb_iter, 0, dgram_idx_len);
+	ntb_iter = skb_put_zero(skb2, dgram_idx_len);
 
 	return skb2;
 }
@@ -1080,8 +1078,7 @@ static struct sk_buff *ncm_wrap_ntb(struct gether *port,
 				goto err;
 
 			ncm->skb_tx_data->dev = ncm->netdev;
-			ntb_data = (void *) skb_put(ncm->skb_tx_data, ncb_len);
-			memset(ntb_data, 0, ncb_len);
+			ntb_data = skb_put_zero(ncm->skb_tx_data, ncb_len);
 			/* dwSignature */
 			put_unaligned_le32(opts->nth_sign, ntb_data);
 			ntb_data += 2;
@@ -1118,8 +1115,7 @@ static struct sk_buff *ncm_wrap_ntb(struct gether *port,
 			      HRTIMER_MODE_REL);
 
 		/* Add the datagram position entries */
-		ntb_ndp = (void *) skb_put(ncm->skb_tx_ndp, dgram_idx_len);
-		memset(ntb_ndp, 0, dgram_idx_len);
+		ntb_ndp = skb_put_zero(ncm->skb_tx_ndp, dgram_idx_len);
 
 		ncb_len = ncm->skb_tx_data->len;
 		dgram_pad = ALIGN(ncb_len, div) + rem - ncb_len;
@@ -1132,8 +1128,7 @@ static struct sk_buff *ncm_wrap_ntb(struct gether *port,
 		ncm->ndp_dgram_count++;
 
 		/* Add the new data to the skb */
-		ntb_data = (void *) skb_put(ncm->skb_tx_data, dgram_pad);
-		memset(ntb_data, 0, dgram_pad);
+		ntb_data = skb_put_zero(ncm->skb_tx_data, dgram_pad);
 		ntb_data = (void *) skb_put(ncm->skb_tx_data, skb->len);
 		memcpy(ntb_data, skb->data, skb->len);
 		dev_consume_skb_any(skb);
diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index adb6e3d21b1e..f640a99e14b8 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -150,8 +150,7 @@ void sigd_enq2(struct atm_vcc *vcc, enum atmsvc_msg_type type,
 	pr_debug("%d (0x%p)\n", (int)type, vcc);
 	while (!(skb = alloc_skb(sizeof(struct atmsvc_msg), GFP_KERNEL)))
 		schedule();
-	msg = (struct atmsvc_msg *)skb_put(skb, sizeof(struct atmsvc_msg));
-	memset(msg, 0, sizeof(*msg));
+	msg = skb_put_zero(skb, sizeof(struct atmsvc_msg));
 	msg->type = type;
 	*(struct atm_vcc **) &msg->vcc = vcc;
 	*(struct atm_vcc **) &msg->listen_vcc = listen_vcc;
diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index b58007b79e3a..bd1064d98e16 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -346,9 +346,8 @@ int batadv_v_elp_iface_enable(struct batadv_hard_iface *hard_iface)
 		goto out;
 
 	skb_reserve(hard_iface->bat_v.elp_skb, ETH_HLEN + NET_IP_ALIGN);
-	elp_buff = skb_put(hard_iface->bat_v.elp_skb, BATADV_ELP_HLEN);
+	elp_buff = skb_put_zero(hard_iface->bat_v.elp_skb, BATADV_ELP_HLEN);
 	elp_packet = (struct batadv_elp_packet *)elp_buff;
-	memset(elp_packet, 0, BATADV_ELP_HLEN);
 
 	elp_packet->packet_type = BATADV_ELP;
 	elp_packet->version = BATADV_COMPAT_VERSION;
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index c16dd3a47fc6..bb6ed8e97580 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -147,8 +147,7 @@ static void nft_reject_br_send_v4_unreach(struct net *net,
 				   net->ipv4.sysctl_ip_default_ttl);
 
 	skb_reset_transport_header(nskb);
-	icmph = (struct icmphdr *)skb_put(nskb, sizeof(struct icmphdr));
-	memset(icmph, 0, sizeof(*icmph));
+	icmph = skb_put_zero(nskb, sizeof(struct icmphdr));
 	icmph->type     = ICMP_DEST_UNREACH;
 	icmph->code	= code;
 
@@ -275,8 +274,7 @@ static void nft_reject_br_send_v6_unreach(struct net *net,
 				     net->ipv6.devconf_all->hop_limit);
 
 	skb_reset_transport_header(nskb);
-	icmp6h = (struct icmp6hdr *)skb_put(nskb, sizeof(struct icmp6hdr));
-	memset(icmp6h, 0, sizeof(*icmp6h));
+	icmp6h = skb_put_zero(nskb, sizeof(struct icmp6hdr));
 	icmp6h->icmp6_type = ICMPV6_DEST_UNREACH;
 	icmp6h->icmp6_code = code;
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 96947f5d41e4..8860ad985d68 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2718,7 +2718,7 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 	datalen -= sizeof(*pgh);
 
 	if (pkt_dev->nfrags <= 0) {
-		memset(skb_put(skb, datalen), 0, datalen);
+		skb_put_zero(skb, datalen);
 	} else {
 		int frags = pkt_dev->nfrags;
 		int i, len;
@@ -2729,7 +2729,7 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 			frags = MAX_SKB_FRAGS;
 		len = datalen - frags * PAGE_SIZE;
 		if (len > 0) {
-			memset(skb_put(skb, len), 0, len);
+			skb_put_zero(skb, len);
 			datalen = frags * PAGE_SIZE;
 		}
 
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index c3b12b1c7162..4c5dfe6bd34d 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -813,8 +813,7 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
 	if (!skb)
 		return;
 	skb_reserve(skb, hlen);
-	b = (struct bootp_pkt *) skb_put(skb, sizeof(struct bootp_pkt));
-	memset(b, 0, sizeof(struct bootp_pkt));
+	b = skb_put_zero(skb, sizeof(struct bootp_pkt));
 
 	/* Construct IP header */
 	skb_reset_network_header(skb);
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index 6f8d9e5e062b..52b7dcc5aaf3 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -76,8 +76,7 @@ void nf_reject_ip_tcphdr_put(struct sk_buff *nskb, const struct sk_buff *oldskb,
 	struct tcphdr *tcph;
 
 	skb_reset_transport_header(nskb);
-	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
-	memset(tcph, 0, sizeof(*tcph));
+	tcph = skb_put_zero(nskb, sizeof(struct tcphdr));
 	tcph->source	= oth->dest;
 	tcph->dest	= oth->source;
 	tcph->doff	= sizeof(struct tcphdr) / 4;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 07403fa164e1..9098429e38bc 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2008,8 +2008,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
 	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
 
-	hdr = (struct mld_msg *) skb_put(skb, sizeof(struct mld_msg));
-	memset(hdr, 0, sizeof(struct mld_msg));
+	hdr = skb_put_zero(skb, sizeof(struct mld_msg));
 	hdr->mld_type = type;
 	hdr->mld_mca = *addr;
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 512dc43d0ce6..8ad430edb5b8 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2934,8 +2934,7 @@ static void dump_ah_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 
 		if (aalg_tmpl_set(t, aalg) && aalg->available) {
 			struct sadb_comb *c;
-			c = (struct sadb_comb*)skb_put(skb, sizeof(struct sadb_comb));
-			memset(c, 0, sizeof(*c));
+			c = skb_put_zero(skb, sizeof(struct sadb_comb));
 			p->sadb_prop_len += sizeof(struct sadb_comb)/8;
 			c->sadb_comb_auth = aalg->desc.sadb_alg_id;
 			c->sadb_comb_auth_minbits = aalg->desc.sadb_alg_minbits;
@@ -3461,8 +3460,7 @@ static int set_sadb_kmaddress(struct sk_buff *skb, const struct xfrm_kmaddress *
 	size_req = (sizeof(struct sadb_x_kmaddress) +
 		    pfkey_sockaddr_pair_size(family));
 
-	kma = (struct sadb_x_kmaddress *)skb_put(skb, size_req);
-	memset(kma, 0, size_req);
+	kma = skb_put_zero(skb, size_req);
 	kma->sadb_x_kmaddress_len = size_req / 8;
 	kma->sadb_x_kmaddress_exttype = SADB_X_EXT_KMADDRESS;
 	kma->sadb_x_kmaddress_reserved = k->reserved;
@@ -3488,8 +3486,7 @@ static int set_ipsecrequest(struct sk_buff *skb,
 	size_req = sizeof(struct sadb_x_ipsecrequest) +
 		   pfkey_sockaddr_pair_size(family);
 
-	rq = (struct sadb_x_ipsecrequest *)skb_put(skb, size_req);
-	memset(rq, 0, size_req);
+	rq = skb_put_zero(skb, size_req);
 	rq->sadb_x_ipsecrequest_len = size_req;
 	rq->sadb_x_ipsecrequest_proto = proto;
 	rq->sadb_x_ipsecrequest_mode = mode;
diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index 3a0282188ad6..8708cbe8af5b 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -213,8 +213,7 @@ static void ieee80211_send_addba_resp(struct ieee80211_sub_if_data *sdata, u8 *d
 		return;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
-	memset(mgmt, 0, 24);
+	mgmt = skb_put_zero(skb, 24);
 	memcpy(mgmt->da, da, ETH_ALEN);
 	memcpy(mgmt->sa, sdata->vif.addr, ETH_ALEN);
 	if (sdata->vif.type == NL80211_IFTYPE_AP ||
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index cf2392b2ac71..cbd48762256c 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -76,8 +76,7 @@ static void ieee80211_send_addba_request(struct ieee80211_sub_if_data *sdata,
 		return;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
-	memset(mgmt, 0, 24);
+	mgmt = skb_put_zero(skb, 24);
 	memcpy(mgmt->da, da, ETH_ALEN);
 	memcpy(mgmt->sa, sdata->vif.addr, ETH_ALEN);
 	if (sdata->vif.type == NL80211_IFTYPE_AP ||
@@ -125,8 +124,7 @@ void ieee80211_send_bar(struct ieee80211_vif *vif, u8 *ra, u16 tid, u16 ssn)
 		return;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	bar = (struct ieee80211_bar *)skb_put(skb, sizeof(*bar));
-	memset(bar, 0, sizeof(*bar));
+	bar = skb_put_zero(skb, sizeof(*bar));
 	bar->frame_control = cpu_to_le16(IEEE80211_FTYPE_CTL |
 					 IEEE80211_STYPE_BACK_REQ);
 	memcpy(bar->ra, ra, ETH_ALEN);
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index 8f5fff8b2040..c813207bb123 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -330,8 +330,7 @@ static ssize_t ieee80211_if_parse_tkip_mic_test(
 		return -ENOMEM;
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	hdr = (struct ieee80211_hdr *) skb_put(skb, 24);
-	memset(hdr, 0, 24);
+	hdr = skb_put_zero(skb, 24);
 	fc = cpu_to_le16(IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA);
 
 	switch (sdata->vif.type) {
@@ -367,7 +366,7 @@ static ssize_t ieee80211_if_parse_tkip_mic_test(
 	 * The exact contents does not matter since the recipient is required
 	 * to drop this because of the Michael MIC failure.
 	 */
-	memset(skb_put(skb, 50), 0, 50);
+	skb_put_zero(skb, 50);
 
 	IEEE80211_SKB_CB(skb)->flags |= IEEE80211_TX_INTFL_TKIP_MIC_FAILURE;
 
diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index 9e71226c2d25..927215d4dd8f 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -394,8 +394,7 @@ void ieee80211_send_delba(struct ieee80211_sub_if_data *sdata,
 		return;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
-	memset(mgmt, 0, 24);
+	mgmt = skb_put_zero(skb, 24);
 	memcpy(mgmt->da, da, ETH_ALEN);
 	memcpy(mgmt->sa, sdata->vif.addr, ETH_ALEN);
 	if (sdata->vif.type == NL80211_IFTYPE_AP ||
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index ad5d1cf39190..e45c8d94952e 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -719,8 +719,7 @@ ieee80211_mesh_build_beacon(struct ieee80211_if_mesh *ifmsh)
 	bcn->head = ((u8 *) bcn) + sizeof(*bcn);
 
 	/* fill in the head */
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, hdr_len);
-	memset(mgmt, 0, hdr_len);
+	mgmt = skb_put_zero(skb, hdr_len);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					  IEEE80211_STYPE_BEACON);
 	eth_broadcast_addr(mgmt->da);
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 4005edd71fe8..d8bbd0d2225a 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -120,8 +120,7 @@ static int mesh_path_sel_frame_tx(enum mpath_frame_type action, u8 flags,
 	if (!skb)
 		return -1;
 	skb_reserve(skb, local->tx_headroom);
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, hdr_len);
-	memset(mgmt, 0, hdr_len);
+	mgmt = skb_put_zero(skb, hdr_len);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					  IEEE80211_STYPE_ACTION);
 
@@ -257,8 +256,7 @@ int mesh_path_error_tx(struct ieee80211_sub_if_data *sdata,
 	if (!skb)
 		return -1;
 	skb_reserve(skb, local->tx_headroom + sdata->encrypt_headroom);
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, hdr_len);
-	memset(mgmt, 0, hdr_len);
+	mgmt = skb_put_zero(skb, hdr_len);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					  IEEE80211_STYPE_ACTION);
 
diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index 82cfd232a25e..f69c6c38ca43 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -242,8 +242,7 @@ static int mesh_plink_frame_tx(struct ieee80211_sub_if_data *sdata,
 		return err;
 	info = IEEE80211_SKB_CB(skb);
 	skb_reserve(skb, local->tx_headroom);
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, hdr_len);
-	memset(mgmt, 0, hdr_len);
+	mgmt = skb_put_zero(skb, hdr_len);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					  IEEE80211_STYPE_ACTION);
 	memcpy(mgmt->da, da, ETH_ALEN);
diff --git a/net/mac80211/mesh_ps.c b/net/mac80211/mesh_ps.c
index 90a268abea17..96c987e641b3 100644
--- a/net/mac80211/mesh_ps.c
+++ b/net/mac80211/mesh_ps.c
@@ -39,7 +39,7 @@ static struct sk_buff *mps_qos_null_get(struct sta_info *sta)
 	nullfunc->seq_ctrl = 0;
 	/* no address resolution for this frame -> set addr 1 immediately */
 	memcpy(nullfunc->addr1, sta->sta.addr, ETH_ALEN);
-	memset(skb_put(skb, 2), 0, 2); /* append QoS control field */
+	skb_put_zero(skb, 2); /* append QoS control field */
 	ieee80211_mps_set_frame_flags(sdata, sta, nullfunc);
 
 	return skb;
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 1929bce8e518..e810334595ff 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -674,8 +674,7 @@ static void ieee80211_send_assoc(struct ieee80211_sub_if_data *sdata)
 	if (ifmgd->flags & IEEE80211_STA_ENABLE_RRM)
 		capab |= WLAN_CAPABILITY_RADIO_MEASURE;
 
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
-	memset(mgmt, 0, 24);
+	mgmt = skb_put_zero(skb, 24);
 	memcpy(mgmt->da, assoc_data->bss->bssid, ETH_ALEN);
 	memcpy(mgmt->sa, sdata->vif.addr, ETH_ALEN);
 	memcpy(mgmt->bssid, assoc_data->bss->bssid, ETH_ALEN);
@@ -949,8 +948,7 @@ static void ieee80211_send_4addr_nullfunc(struct ieee80211_local *local,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	nullfunc = (struct ieee80211_hdr *) skb_put(skb, 30);
-	memset(nullfunc, 0, 30);
+	nullfunc = skb_put_zero(skb, 30);
 	fc = cpu_to_le16(IEEE80211_FTYPE_DATA | IEEE80211_STYPE_NULLFUNC |
 			 IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS);
 	nullfunc->frame_control = fc;
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 004a2283c5d9..e1ab1c4af33c 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2760,8 +2760,7 @@ static void ieee80211_process_sa_query_req(struct ieee80211_sub_if_data *sdata,
 		return;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	resp = (struct ieee80211_mgmt *) skb_put(skb, 24);
-	memset(resp, 0, 24);
+	resp = skb_put_zero(skb, 24);
 	memcpy(resp->da, mgmt->sa, ETH_ALEN);
 	memcpy(resp->sa, sdata->vif.addr, ETH_ALEN);
 	memcpy(resp->bssid, sdata->u.mgd.bssid, ETH_ALEN);
diff --git a/net/mac80211/spectmgmt.c b/net/mac80211/spectmgmt.c
index bf8f5dcea1c4..ee0181778a42 100644
--- a/net/mac80211/spectmgmt.c
+++ b/net/mac80211/spectmgmt.c
@@ -193,8 +193,7 @@ static void ieee80211_send_refuse_measurement_request(struct ieee80211_sub_if_da
 		return;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	msr_report = (struct ieee80211_mgmt *)skb_put(skb, 24);
-	memset(msr_report, 0, 24);
+	msr_report = skb_put_zero(skb, 24);
 	memcpy(msr_report->da, da, ETH_ALEN);
 	memcpy(msr_report->sa, sdata->vif.addr, ETH_ALEN);
 	memcpy(msr_report->bssid, bssid, ETH_ALEN);
diff --git a/net/mac80211/tdls.c b/net/mac80211/tdls.c
index f20dcf1b1830..c379c99cd1d8 100644
--- a/net/mac80211/tdls.c
+++ b/net/mac80211/tdls.c
@@ -271,8 +271,7 @@ static void ieee80211_tdls_add_wmm_param_ie(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_tx_queue_params *txq;
 	int i;
 
-	wmm = (void *)skb_put(skb, sizeof(*wmm));
-	memset(wmm, 0, sizeof(*wmm));
+	wmm = skb_put_zero(skb, sizeof(*wmm));
 
 	wmm->element_id = WLAN_EID_VENDOR_SPECIFIC;
 	wmm->len = sizeof(*wmm) - 2;
@@ -838,8 +837,7 @@ ieee80211_prep_tdls_direct(struct wiphy *wiphy, struct net_device *dev,
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_mgmt *mgmt;
 
-	mgmt = (void *)skb_put(skb, 24);
-	memset(mgmt, 0, 24);
+	mgmt = skb_put_zero(skb, 24);
 	memcpy(mgmt->da, peer, ETH_ALEN);
 	memcpy(mgmt->sa, sdata->vif.addr, ETH_ALEN);
 	memcpy(mgmt->bssid, sdata->u.mgd.bssid, ETH_ALEN);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index b8dc41191835..1af9ed29a915 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -3044,7 +3044,7 @@ static bool ieee80211_amsdu_realloc_pad(struct ieee80211_local *local,
 
 	if (padding) {
 		*subframe_len += padding;
-		memset(skb_put(skb, padding), 0, padding);
+		skb_put_zero(skb, padding);
 	}
 
 	return true;
@@ -4370,8 +4370,7 @@ struct sk_buff *ieee80211_pspoll_get(struct ieee80211_hw *hw,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	pspoll = (struct ieee80211_pspoll *) skb_put(skb, sizeof(*pspoll));
-	memset(pspoll, 0, sizeof(*pspoll));
+	pspoll = skb_put_zero(skb, sizeof(*pspoll));
 	pspoll->frame_control = cpu_to_le16(IEEE80211_FTYPE_CTL |
 					    IEEE80211_STYPE_PSPOLL);
 	pspoll->aid = cpu_to_le16(ifmgd->aid);
@@ -4408,9 +4407,7 @@ struct sk_buff *ieee80211_nullfunc_get(struct ieee80211_hw *hw,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	nullfunc = (struct ieee80211_hdr_3addr *) skb_put(skb,
-							  sizeof(*nullfunc));
-	memset(nullfunc, 0, sizeof(*nullfunc));
+	nullfunc = skb_put_zero(skb, sizeof(*nullfunc));
 	nullfunc->frame_control = cpu_to_le16(IEEE80211_FTYPE_DATA |
 					      IEEE80211_STYPE_NULLFUNC |
 					      IEEE80211_FCTL_TODS);
@@ -4442,8 +4439,7 @@ struct sk_buff *ieee80211_probereq_get(struct ieee80211_hw *hw,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	hdr = (struct ieee80211_hdr_3addr *) skb_put(skb, sizeof(*hdr));
-	memset(hdr, 0, sizeof(*hdr));
+	hdr = skb_put_zero(skb, sizeof(*hdr));
 	hdr->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					 IEEE80211_STYPE_PROBE_REQ);
 	eth_broadcast_addr(hdr->addr1);
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index de0f1cdb64d4..148c7276869c 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1242,8 +1242,7 @@ void ieee80211_send_auth(struct ieee80211_sub_if_data *sdata,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom + IEEE80211_WEP_IV_LEN);
 
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24 + 6);
-	memset(mgmt, 0, 24 + 6);
+	mgmt = skb_put_zero(skb, 24 + 6);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					  IEEE80211_STYPE_AUTH);
 	memcpy(mgmt->da, da, ETH_ALEN);
@@ -2999,8 +2998,7 @@ int ieee80211_send_action_csa(struct ieee80211_sub_if_data *sdata,
 		return -ENOMEM;
 
 	skb_reserve(skb, local->tx_headroom);
-	mgmt = (struct ieee80211_mgmt *)skb_put(skb, hdr_len);
-	memset(mgmt, 0, hdr_len);
+	mgmt = skb_put_zero(skb, hdr_len);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					  IEEE80211_STYPE_ACTION);
 
diff --git a/net/ncsi/ncsi-cmd.c b/net/ncsi/ncsi-cmd.c
index db7083bfd476..b010ae94175b 100644
--- a/net/ncsi/ncsi-cmd.c
+++ b/net/ncsi/ncsi-cmd.c
@@ -66,8 +66,7 @@ static int ncsi_cmd_handler_default(struct sk_buff *skb,
 {
 	struct ncsi_cmd_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = skb_put_zero(skb, sizeof(*cmd));
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
 	return 0;
@@ -78,8 +77,7 @@ static int ncsi_cmd_handler_sp(struct sk_buff *skb,
 {
 	struct ncsi_cmd_sp_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_sp_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = skb_put_zero(skb, sizeof(*cmd));
 	cmd->hw_arbitration = nca->bytes[0];
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
@@ -91,8 +89,7 @@ static int ncsi_cmd_handler_dc(struct sk_buff *skb,
 {
 	struct ncsi_cmd_dc_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_dc_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = skb_put_zero(skb, sizeof(*cmd));
 	cmd->ald = nca->bytes[0];
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
@@ -104,8 +101,7 @@ static int ncsi_cmd_handler_rc(struct sk_buff *skb,
 {
 	struct ncsi_cmd_rc_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_rc_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = skb_put_zero(skb, sizeof(*cmd));
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
 	return 0;
@@ -116,8 +112,7 @@ static int ncsi_cmd_handler_ae(struct sk_buff *skb,
 {
 	struct ncsi_cmd_ae_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_ae_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = skb_put_zero(skb, sizeof(*cmd));
 	cmd->mc_id = nca->bytes[0];
 	cmd->mode = htonl(nca->dwords[1]);
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
@@ -130,8 +125,7 @@ static int ncsi_cmd_handler_sl(struct sk_buff *skb,
 {
 	struct ncsi_cmd_sl_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_sl_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = skb_put_zero(skb, sizeof(*cmd));
 	cmd->mode = htonl(nca->dwords[0]);
 	cmd->oem_mode = htonl(nca->dwords[1]);
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
@@ -144,8 +138,7 @@ static int ncsi_cmd_handler_svf(struct sk_buff *skb,
 {
 	struct ncsi_cmd_svf_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_svf_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = skb_put_zero(skb, sizeof(*cmd));
 	cmd->vlan = htons(nca->words[0]);
 	cmd->index = nca->bytes[2];
 	cmd->enable = nca->bytes[3];
@@ -159,8 +152,7 @@ static int ncsi_cmd_handler_ev(struct sk_buff *skb,
 {
 	struct ncsi_cmd_ev_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_ev_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = skb_put_zero(skb, sizeof(*cmd));
 	cmd->mode = nca->bytes[0];
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
@@ -173,8 +165,7 @@ static int ncsi_cmd_handler_sma(struct sk_buff *skb,
 	struct ncsi_cmd_sma_pkt *cmd;
 	int i;
 
-	cmd = (struct ncsi_cmd_sma_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = skb_put_zero(skb, sizeof(*cmd));
 	for (i = 0; i < 6; i++)
 		cmd->mac[i] = nca->bytes[i];
 	cmd->index = nca->bytes[6];
@@ -189,8 +180,7 @@ static int ncsi_cmd_handler_ebf(struct sk_buff *skb,
 {
 	struct ncsi_cmd_ebf_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_ebf_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = skb_put_zero(skb, sizeof(*cmd));
 	cmd->mode = htonl(nca->dwords[0]);
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
@@ -202,8 +192,7 @@ static int ncsi_cmd_handler_egmf(struct sk_buff *skb,
 {
 	struct ncsi_cmd_egmf_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_egmf_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = skb_put_zero(skb, sizeof(*cmd));
 	cmd->mode = htonl(nca->dwords[0]);
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
@@ -215,8 +204,7 @@ static int ncsi_cmd_handler_snfc(struct sk_buff *skb,
 {
 	struct ncsi_cmd_snfc_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_snfc_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = skb_put_zero(skb, sizeof(*cmd));
 	cmd->mode = nca->bytes[0];
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 9ddc9f8412a2..d772e9a4b4f8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -413,7 +413,7 @@ static void pad_packet(struct datapath *dp, struct sk_buff *skb)
 		size_t plen = NLA_ALIGN(skb->len) - skb->len;
 
 		if (plen > 0)
-			memset(skb_put(skb, plen), 0, plen);
+			skb_put_zero(skb, plen);
 	}
 }
 
diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index c7a5d861906b..825f97671591 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -285,8 +285,7 @@ static struct sk_buff *qrtr_alloc_resume_tx(u32 src_node,
 	if (!skb)
 		return NULL;
 
-	buf = (__le32 *)skb_put(skb, pkt_len);
-	memset(buf, 0, pkt_len);
+	buf = skb_put_zero(skb, pkt_len);
 	buf[0] = cpu_to_le32(QRTR_TYPE_RESUME_TX);
 	buf[1] = cpu_to_le32(src_node);
 	buf[2] = cpu_to_le32(port);
@@ -306,8 +305,7 @@ static struct sk_buff *qrtr_alloc_local_bye(u32 src_node)
 	if (!skb)
 		return NULL;
 
-	buf = (__le32 *)skb_put(skb, pkt_len);
-	memset(buf, 0, pkt_len);
+	buf = skb_put_zero(skb, pkt_len);
 	buf[0] = cpu_to_le32(QRTR_TYPE_BYE);
 
 	return skb;
@@ -324,8 +322,7 @@ static struct sk_buff *qrtr_alloc_del_client(struct sockaddr_qrtr *sq)
 	if (!skb)
 		return NULL;
 
-	buf = (__le32 *)skb_put(skb, pkt_len);
-	memset(buf, 0, pkt_len);
+	buf = skb_put_zero(skb, pkt_len);
 	buf[0] = cpu_to_le32(QRTR_TYPE_DEL_CLIENT);
 	buf[1] = cpu_to_le32(sq->sq_node);
 	buf[2] = cpu_to_le32(sq->sq_port);
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 2e636a525a65..b0d2cda6ec0a 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -330,7 +330,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 				pad &= conn->size_align - 1;
 				_debug("pad %zu", pad);
 				if (pad)
-					memset(skb_put(skb, pad), 0, pad);
+					skb_put_zero(skb, pad);
 			}
 
 			seq = call->tx_top + 1;
diff --git a/net/sctp/output.c b/net/sctp/output.c
index e2edf2ebbade..c339c682675a 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -463,7 +463,7 @@ static int sctp_packet_pack(struct sctp_packet *packet,
 
 			padding = SCTP_PAD4(chunk->skb->len) - chunk->skb->len;
 			if (padding)
-				memset(skb_put(chunk->skb, padding), 0, padding);
+				skb_put_zero(chunk->skb, padding);
 
 			if (chunk == packet->auth)
 				auth = (struct sctp_auth_chunk *)
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index ea2601501654..aaac2660aaf7 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1478,10 +1478,9 @@ void *sctp_addto_chunk(struct sctp_chunk *chunk, int len, const void *data)
 	int chunklen = ntohs(chunk->chunk_hdr->length);
 	int padlen = SCTP_PAD4(chunklen) - chunklen;
 
-	padding = skb_put(chunk->skb, padlen);
+	padding = skb_put_zero(chunk->skb, padlen);
 	target = skb_put(chunk->skb, len);
 
-	memset(padding, 0, padlen);
 	memcpy(target, data, len);
 
 	/* Adjust the chunk length field.  */
-- 
2.11.0
