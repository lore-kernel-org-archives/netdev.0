From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-10-31
Date: Wed, 31 Oct 2012 13:37:40 -0400
Message-ID: <20121031173740.GB30910@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="n8g4imXOkfNTN/H1"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34959 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935693Ab2JaRqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 13:46:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 06272911485850b4a336122958c50af0f8ea7c13

Dave,

This is a batch of fixes intended for 3.7...

The biggest portion of this is a pull request from Johannes Berg:

"Please pull my mac80211.git tree per below to get a number of fixes. I
have included a patch from Antonio to fix a memcpy overrun, Felix's
patches for the antenna gain/tx power issues, a few mesh-related fixes
=66rom Javier for mac80211 and my own patches to not access data that
might not be present in an skb at all as well as a patch (the duplicate
IE check one) to make mac80211 forward-compatible with potential future
spec extensions that use the same IE multiple times.

It's a bit bigger than I'd like maybe, but I think all of these are
worthwhile fixes at this point."

In addition...

Felix Fietkau fixes an ath9k use-after-free issue.

Stanislaw Gruszka adds a valid value check to rt2800.

Sven Eckelmann adds a check to only check a TID value in a BlockAck, for
frames that could be either a BlockAck or a normal Ack.

Please let me know if there are problems!

John

P.S.  Stay safe in NYC!  It must be tough there right now.  Let me know
if I can somehow be helpful to you!  Anyway, I wanted to go ahead and
post this now for when you do find the means to process pull requests.
If you would prefer that I do something else, then please let me know!

---

The following changes since commit e657e078d3dfa9f96976db7a2b5fd7d7c9f1f1a6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-10-26=
 15:00:48 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 06272911485850b4a336122958c50af0f8ea7c13:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2012-10-31 13:10:01 -0400)

----------------------------------------------------------------

Antonio Quartulli (1):
      mac80211: fix SSID copy on IBSS JOIN

Felix Fietkau (3):
      cfg80211: fix antenna gain handling
      cfg80211: fix initialization of chan->max_reg_power
      ath9k: fix stale pointers potentially causing access to free'd skbs

Javier Cardona (3):
      mac80211: Only process mesh config header on frames that RA_MATCH
      mac80211: Don't drop frames received with mesh ttl =3D=3D 1
      mac80211: don't inspect Sequence Control field on control frames

Johannes Berg (5):
      mac80211: use blacklist for duplicate IE check
      wireless: drop invalid mesh address extension frames
      mac80211: check management frame header length
      mac80211: verify that skb data is present
      mac80211: make sure data is accessible in EAPOL check

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Stanislaw Gruszka (1):
      rt2800: validate step value for temperature compensation

Sven Eckelmann (1):
      ath9k: Test for TID only in BlockAcks while checking tx status

 drivers/net/wireless/ath/ath9k/xmit.c   | 10 ++++-
 drivers/net/wireless/rt2x00/rt2800lib.c |  2 +-
 include/net/cfg80211.h                  |  9 ++++
 net/mac80211/ibss.c                     |  2 +-
 net/mac80211/rx.c                       | 74 +++++++++++++++++++++++++----=
----
 net/mac80211/util.c                     | 42 +++++++++++++++----
 net/wireless/core.c                     |  3 +-
 net/wireless/reg.c                      |  5 ++-
 net/wireless/util.c                     | 14 ++++---
 9 files changed, 122 insertions(+), 39 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 378bd70..741918a 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -312,6 +312,7 @@ static struct ath_buf *ath_tx_get_buffer(struct ath_sof=
tc *sc)
 	}
=20
 	bf =3D list_first_entry(&sc->tx.txbuf, struct ath_buf, list);
+	bf->bf_next =3D NULL;
 	list_del(&bf->list);
=20
 	spin_unlock_bh(&sc->tx.txbuflock);
@@ -393,7 +394,7 @@ static void ath_tx_complete_aggr(struct ath_softc *sc, =
struct ath_txq *txq,
 	u16 seq_st =3D 0, acked_cnt =3D 0, txfail_cnt =3D 0, seq_first;
 	u32 ba[WME_BA_BMP_SIZE >> 5];
 	int isaggr, txfail, txpending, sendbar =3D 0, needreset =3D 0, nbad =3D 0;
-	bool rc_update =3D true;
+	bool rc_update =3D true, isba;
 	struct ieee80211_tx_rate rates[4];
 	struct ath_frame_info *fi;
 	int nframes;
@@ -437,13 +438,17 @@ static void ath_tx_complete_aggr(struct ath_softc *sc=
, struct ath_txq *txq,
 	tidno =3D ieee80211_get_qos_ctl(hdr)[0] & IEEE80211_QOS_CTL_TID_MASK;
 	tid =3D ATH_AN_2_TID(an, tidno);
 	seq_first =3D tid->seq_start;
+	isba =3D ts->ts_flags & ATH9K_TX_BA;
=20
 	/*
 	 * The hardware occasionally sends a tx status for the wrong TID.
 	 * In this case, the BA status cannot be considered valid and all
 	 * subframes need to be retransmitted
+	 *
+	 * Only BlockAcks have a TID and therefore normal Acks cannot be
+	 * checked
 	 */
-	if (tidno !=3D ts->tid)
+	if (isba && tidno !=3D ts->tid)
 		txok =3D false;
=20
 	isaggr =3D bf_isaggr(bf);
@@ -1774,6 +1779,7 @@ static void ath_tx_send_normal(struct ath_softc *sc, =
struct ath_txq *txq,
 	list_add_tail(&bf->list, &bf_head);
 	bf->bf_state.bf_type =3D 0;
=20
+	bf->bf_next =3D NULL;
 	bf->bf_lastbf =3D bf;
 	ath_tx_fill_desc(sc, bf, txq, fi->framelen);
 	ath_tx_txqaddbuf(sc, txq, &bf_head, false);
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless=
/rt2x00/rt2800lib.c
index 01dc889..59474ae 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -2449,7 +2449,7 @@ static int rt2800_get_gain_calibration_delta(struct r=
t2x00_dev *rt2x00dev)
 	/*
 	 * Check if temperature compensation is supported.
 	 */
-	if (tssi_bounds[4] =3D=3D 0xff)
+	if (tssi_bounds[4] =3D=3D 0xff || step =3D=3D 0xff)
 		return 0;
=20
 	/*
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index f8cd4cf..7d5b600 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2652,6 +2652,15 @@ unsigned int ieee80211_get_hdrlen_from_skb(const str=
uct sk_buff *skb);
 unsigned int __attribute_const__ ieee80211_hdrlen(__le16 fc);
=20
 /**
+ * ieee80211_get_mesh_hdrlen - get mesh extension header length
+ * @meshhdr: the mesh extension header, only the flags field
+ *	(first byte) will be accessed
+ * Returns the length of the extension header, which is always at
+ * least 6 bytes and at most 18 if address 5 and 6 are present.
+ */
+unsigned int ieee80211_get_mesh_hdrlen(struct ieee80211s_hdr *meshhdr);
+
+/**
  * DOC: Data path helpers
  *
  * In addition to generic utilities, cfg80211 also offers
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 5f3620f..bf87c70 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -1108,7 +1108,7 @@ int ieee80211_ibss_join(struct ieee80211_sub_if_data =
*sdata,
 	sdata->u.ibss.state =3D IEEE80211_IBSS_MLME_SEARCH;
 	sdata->u.ibss.ibss_join_req =3D jiffies;
=20
-	memcpy(sdata->u.ibss.ssid, params->ssid, IEEE80211_MAX_SSID_LEN);
+	memcpy(sdata->u.ibss.ssid, params->ssid, params->ssid_len);
 	sdata->u.ibss.ssid_len =3D params->ssid_len;
=20
 	mutex_unlock(&sdata->u.ibss.mtx);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 61c621e..00ade7f 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -531,6 +531,11 @@ ieee80211_rx_mesh_check(struct ieee80211_rx_data *rx)
=20
 		if (ieee80211_is_action(hdr->frame_control)) {
 			u8 category;
+
+			/* make sure category field is present */
+			if (rx->skb->len < IEEE80211_MIN_ACTION_SIZE)
+				return RX_DROP_MONITOR;
+
 			mgmt =3D (struct ieee80211_mgmt *)hdr;
 			category =3D mgmt->u.action.category;
 			if (category !=3D WLAN_CATEGORY_MESH_ACTION &&
@@ -883,14 +888,16 @@ ieee80211_rx_h_check(struct ieee80211_rx_data *rx)
 		 */
 		if (rx->sta && rx->sdata->vif.type =3D=3D NL80211_IFTYPE_STATION &&
 		    ieee80211_is_data_present(hdr->frame_control)) {
-			u16 ethertype;
-			u8 *payload;
-
-			payload =3D rx->skb->data +
-				ieee80211_hdrlen(hdr->frame_control);
-			ethertype =3D (payload[6] << 8) | payload[7];
-			if (cpu_to_be16(ethertype) =3D=3D
-			    rx->sdata->control_port_protocol)
+			unsigned int hdrlen;
+			__be16 ethertype;
+
+			hdrlen =3D ieee80211_hdrlen(hdr->frame_control);
+
+			if (rx->skb->len < hdrlen + 8)
+				return RX_DROP_MONITOR;
+
+			skb_copy_bits(rx->skb, hdrlen + 6, &ethertype, 2);
+			if (ethertype =3D=3D rx->sdata->control_port_protocol)
 				return RX_CONTINUE;
 		}
=20
@@ -1462,11 +1469,14 @@ ieee80211_rx_h_defragment(struct ieee80211_rx_data =
*rx)
=20
 	hdr =3D (struct ieee80211_hdr *)rx->skb->data;
 	fc =3D hdr->frame_control;
+
+	if (ieee80211_is_ctl(fc))
+		return RX_CONTINUE;
+
 	sc =3D le16_to_cpu(hdr->seq_ctrl);
 	frag =3D sc & IEEE80211_SCTL_FRAG;
=20
 	if (likely((!ieee80211_has_morefrags(fc) && frag =3D=3D 0) ||
-		   (rx->skb)->len < 24 ||
 		   is_multicast_ether_addr(hdr->addr1))) {
 		/* not fragmented */
 		goto out;
@@ -1889,6 +1899,20 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data =
*rx)
=20
 	hdr =3D (struct ieee80211_hdr *) skb->data;
 	hdrlen =3D ieee80211_hdrlen(hdr->frame_control);
+
+	/* make sure fixed part of mesh header is there, also checks skb len */
+	if (!pskb_may_pull(rx->skb, hdrlen + 6))
+		return RX_DROP_MONITOR;
+
+	mesh_hdr =3D (struct ieee80211s_hdr *) (skb->data + hdrlen);
+
+	/* make sure full mesh header is there, also checks skb len */
+	if (!pskb_may_pull(rx->skb,
+			   hdrlen + ieee80211_get_mesh_hdrlen(mesh_hdr)))
+		return RX_DROP_MONITOR;
+
+	/* reload pointers */
+	hdr =3D (struct ieee80211_hdr *) skb->data;
 	mesh_hdr =3D (struct ieee80211s_hdr *) (skb->data + hdrlen);
=20
 	/* frame is in RMC, don't forward */
@@ -1897,7 +1921,8 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *=
rx)
 	    mesh_rmc_check(hdr->addr3, mesh_hdr, rx->sdata))
 		return RX_DROP_MONITOR;
=20
-	if (!ieee80211_is_data(hdr->frame_control))
+	if (!ieee80211_is_data(hdr->frame_control) ||
+	    !(status->rx_flags & IEEE80211_RX_RA_MATCH))
 		return RX_CONTINUE;
=20
 	if (!mesh_hdr->ttl)
@@ -1911,9 +1936,12 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data =
*rx)
 		if (is_multicast_ether_addr(hdr->addr1)) {
 			mpp_addr =3D hdr->addr3;
 			proxied_addr =3D mesh_hdr->eaddr1;
-		} else {
+		} else if (mesh_hdr->flags & MESH_FLAGS_AE_A5_A6) {
+			/* has_a4 already checked in ieee80211_rx_mesh_check */
 			mpp_addr =3D hdr->addr4;
 			proxied_addr =3D mesh_hdr->eaddr2;
+		} else {
+			return RX_DROP_MONITOR;
 		}
=20
 		rcu_read_lock();
@@ -1941,12 +1969,9 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data =
*rx)
 	}
 	skb_set_queue_mapping(skb, q);
=20
-	if (!(status->rx_flags & IEEE80211_RX_RA_MATCH))
-		goto out;
-
 	if (!--mesh_hdr->ttl) {
 		IEEE80211_IFSTA_MESH_CTR_INC(ifmsh, dropped_frames_ttl);
-		return RX_DROP_MONITOR;
+		goto out;
 	}
=20
 	if (!ifmsh->mshcfg.dot11MeshForwarding)
@@ -2353,6 +2378,10 @@ ieee80211_rx_h_action(struct ieee80211_rx_data *rx)
 		}
 		break;
 	case WLAN_CATEGORY_SELF_PROTECTED:
+		if (len < (IEEE80211_MIN_ACTION_SIZE +
+			   sizeof(mgmt->u.action.u.self_prot.action_code)))
+			break;
+
 		switch (mgmt->u.action.u.self_prot.action_code) {
 		case WLAN_SP_MESH_PEERING_OPEN:
 		case WLAN_SP_MESH_PEERING_CLOSE:
@@ -2371,6 +2400,10 @@ ieee80211_rx_h_action(struct ieee80211_rx_data *rx)
 		}
 		break;
 	case WLAN_CATEGORY_MESH_ACTION:
+		if (len < (IEEE80211_MIN_ACTION_SIZE +
+			   sizeof(mgmt->u.action.u.mesh_action.action_code)))
+			break;
+
 		if (!ieee80211_vif_is_mesh(&sdata->vif))
 			break;
 		if (mesh_action_is_path_sel(mgmt) &&
@@ -2913,10 +2946,15 @@ static void __ieee80211_rx_handle_packet(struct iee=
e80211_hw *hw,
 	if (ieee80211_is_data(fc) || ieee80211_is_mgmt(fc))
 		local->dot11ReceivedFragmentCount++;
=20
-	if (ieee80211_is_mgmt(fc))
-		err =3D skb_linearize(skb);
-	else
+	if (ieee80211_is_mgmt(fc)) {
+		/* drop frame if too short for header */
+		if (skb->len < ieee80211_hdrlen(fc))
+			err =3D -ENOBUFS;
+		else
+			err =3D skb_linearize(skb);
+	} else {
 		err =3D !pskb_may_pull(skb, ieee80211_hdrlen(fc));
+	}
=20
 	if (err) {
 		dev_kfree_skb(skb);
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 94e5868..2393918 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -643,13 +643,41 @@ u32 ieee802_11_parse_elems_crc(u8 *start, size_t len,
 			break;
 		}
=20
-		if (id !=3D WLAN_EID_VENDOR_SPECIFIC &&
-		    id !=3D WLAN_EID_QUIET &&
-		    test_bit(id, seen_elems)) {
-			elems->parse_error =3D true;
-			left -=3D elen;
-			pos +=3D elen;
-			continue;
+		switch (id) {
+		case WLAN_EID_SSID:
+		case WLAN_EID_SUPP_RATES:
+		case WLAN_EID_FH_PARAMS:
+		case WLAN_EID_DS_PARAMS:
+		case WLAN_EID_CF_PARAMS:
+		case WLAN_EID_TIM:
+		case WLAN_EID_IBSS_PARAMS:
+		case WLAN_EID_CHALLENGE:
+		case WLAN_EID_RSN:
+		case WLAN_EID_ERP_INFO:
+		case WLAN_EID_EXT_SUPP_RATES:
+		case WLAN_EID_HT_CAPABILITY:
+		case WLAN_EID_HT_OPERATION:
+		case WLAN_EID_VHT_CAPABILITY:
+		case WLAN_EID_VHT_OPERATION:
+		case WLAN_EID_MESH_ID:
+		case WLAN_EID_MESH_CONFIG:
+		case WLAN_EID_PEER_MGMT:
+		case WLAN_EID_PREQ:
+		case WLAN_EID_PREP:
+		case WLAN_EID_PERR:
+		case WLAN_EID_RANN:
+		case WLAN_EID_CHANNEL_SWITCH:
+		case WLAN_EID_EXT_CHANSWITCH_ANN:
+		case WLAN_EID_COUNTRY:
+		case WLAN_EID_PWR_CONSTRAINT:
+		case WLAN_EID_TIMEOUT_INTERVAL:
+			if (test_bit(id, seen_elems)) {
+				elems->parse_error =3D true;
+				left -=3D elen;
+				pos +=3D elen;
+				continue;
+			}
+			break;
 		}
=20
 		if (calc_crc && id < 64 && (filter & (1ULL << id)))
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 443d4d7..3f72530 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -526,8 +526,7 @@ int wiphy_register(struct wiphy *wiphy)
 		for (i =3D 0; i < sband->n_channels; i++) {
 			sband->channels[i].orig_flags =3D
 				sband->channels[i].flags;
-			sband->channels[i].orig_mag =3D
-				sband->channels[i].max_antenna_gain;
+			sband->channels[i].orig_mag =3D INT_MAX;
 			sband->channels[i].orig_mpwr =3D
 				sband->channels[i].max_power;
 			sband->channels[i].band =3D band;
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 3b8cbbc..bcc7d7e 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -908,7 +908,7 @@ static void handle_channel(struct wiphy *wiphy,
 			map_regdom_flags(reg_rule->flags) | bw_flags;
 		chan->max_antenna_gain =3D chan->orig_mag =3D
 			(int) MBI_TO_DBI(power_rule->max_antenna_gain);
-		chan->max_power =3D chan->orig_mpwr =3D
+		chan->max_reg_power =3D chan->max_power =3D chan->orig_mpwr =3D
 			(int) MBM_TO_DBM(power_rule->max_eirp);
 		return;
 	}
@@ -1331,7 +1331,8 @@ static void handle_channel_custom(struct wiphy *wiphy,
=20
 	chan->flags |=3D map_regdom_flags(reg_rule->flags) | bw_flags;
 	chan->max_antenna_gain =3D (int) MBI_TO_DBI(power_rule->max_antenna_gain);
-	chan->max_power =3D (int) MBM_TO_DBM(power_rule->max_eirp);
+	chan->max_reg_power =3D chan->max_power =3D
+		(int) MBM_TO_DBM(power_rule->max_eirp);
 }
=20
 static void handle_band_custom(struct wiphy *wiphy, enum ieee80211_band ba=
nd,
diff --git a/net/wireless/util.c b/net/wireless/util.c
index ef35f4e..2762e83 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -309,23 +309,21 @@ unsigned int ieee80211_get_hdrlen_from_skb(const stru=
ct sk_buff *skb)
 }
 EXPORT_SYMBOL(ieee80211_get_hdrlen_from_skb);
=20
-static int ieee80211_get_mesh_hdrlen(struct ieee80211s_hdr *meshhdr)
+unsigned int ieee80211_get_mesh_hdrlen(struct ieee80211s_hdr *meshhdr)
 {
 	int ae =3D meshhdr->flags & MESH_FLAGS_AE;
-	/* 7.1.3.5a.2 */
+	/* 802.11-2012, 8.2.4.7.3 */
 	switch (ae) {
+	default:
 	case 0:
 		return 6;
 	case MESH_FLAGS_AE_A4:
 		return 12;
 	case MESH_FLAGS_AE_A5_A6:
 		return 18;
-	case (MESH_FLAGS_AE_A4 | MESH_FLAGS_AE_A5_A6):
-		return 24;
-	default:
-		return 6;
 	}
 }
+EXPORT_SYMBOL(ieee80211_get_mesh_hdrlen);
=20
 int ieee80211_data_to_8023(struct sk_buff *skb, const u8 *addr,
 			   enum nl80211_iftype iftype)
@@ -373,6 +371,8 @@ int ieee80211_data_to_8023(struct sk_buff *skb, const u=
8 *addr,
 			/* make sure meshdr->flags is on the linear part */
 			if (!pskb_may_pull(skb, hdrlen + 1))
 				return -1;
+			if (meshdr->flags & MESH_FLAGS_AE_A4)
+				return -1;
 			if (meshdr->flags & MESH_FLAGS_AE_A5_A6) {
 				skb_copy_bits(skb, hdrlen +
 					offsetof(struct ieee80211s_hdr, eaddr1),
@@ -397,6 +397,8 @@ int ieee80211_data_to_8023(struct sk_buff *skb, const u=
8 *addr,
 			/* make sure meshdr->flags is on the linear part */
 			if (!pskb_may_pull(skb, hdrlen + 1))
 				return -1;
+			if (meshdr->flags & MESH_FLAGS_AE_A5_A6)
+				return -1;
 			if (meshdr->flags & MESH_FLAGS_AE_A4)
 				skb_copy_bits(skb, hdrlen +
 					offsetof(struct ieee80211s_hdr, eaddr1),
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--n8g4imXOkfNTN/H1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQkWHkAAoJEJctW/TcYTgGvfIP/iVmzH6NST3TfO3TenTulqBq
QSox61VEoigATX68B0a+LVFt5bHDSZEdIhrVq1ORDvgwp6SbSoZyBl8RcB0o/DKG
fH9txQfUTO1AAszGErwp9t49ZguCBvbkDncI2pOjkNVZUP+zaf01a/mxBjyY+dAy
z+HDcZptVr8AmNlwq5fMIU/UZjiG4gSXV/3erdwAezIjK/Q6bEeo0W8q2I4U87eD
YHhiKhZ+ubvY+nYtvKTv0AUpFifCEamkL17ZNdf0niZ7DTPggiTDISi6TmNySIfZ
PFW3NyG8oUoc9q9biyVPtQXlswluJxYDuFpHRRlwEz/DB5z8dsxeYhBy+MgnDFLU
T3c6UeOVIqrGSbLvqpWqVBsX6BbipxmXNMuch3jkn2MAdTAJZk1inpVjvmOt7zli
bZf1fA4B17nOcRdXvcYAhLuQlCNMUXKXytP8UeDY/6+XyD5WnO7+vej9p0csi713
ft0vzNf4ST9gYgyFuDJdBRAtvYGCQR4ZKd6AAFyydemfWwYSSLVN1mN+ZQAqzm4R
DiSQs5zHzyFIVFnByAdJ+stxFBvPbF/FLOaty3JEzLVC+kqB709CoXLQ61L2CzFZ
WI0JgBwLAdUG74GfBuHjEgjRNhIC9lULrBSqD9aSxuywR03VxLR93QV+IGxTy3kP
7M6l8my7GM1+GPYnZ8go
=gHCq
-----END PGP SIGNATURE-----

--n8g4imXOkfNTN/H1--
