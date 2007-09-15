From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'upstream-davem' branch of wireless-2.6
Date: Sat, 15 Sep 2007 09:20:47 -0400
Message-ID: <20070915132047.GC6060@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Some more stuff for 2.6.24...

Individual patches here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem/

I hope you had a nice time in .eu! :-)

John

P.S.  Jeff, there is a one-line change to rtl8187 in there too...

---

The following changes since commit c36c8b002265e1abb25d372556d6df738f6515c0:
  Ivo van Doorn (1):
        [RFKILL]: Add rfkill documentation

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem

Johannes Berg (10):
      mac80211: remove spy wext ioctls
      mac80211: don't send invalid QoS frames
      mac80211: fix race conditions with keys
      mac80211: remove turbo modes
      mac80211: rework hardware crypto flags
      mac80211: remove set_key_idx callback
      mac80211: some more documentation
      mac80211: remove HW_KEY_IDX_INVALID
      mac80211: remove TKIP mixing for hw accel again
      mac80211: remove/change some comments about Michael MIC hardware offload

Stephen Hemminger (1):
      mac80211: use internal network device stats

Tomas Winkler (1):
      mac80211: PS mode fix

Volker Braun (1):
      mac80211: ignore key index on pairwise key (WEP only)

warmcat (1):
      mac80211: get STA after tx radiotap snipped

 drivers/net/wireless/rtl8187_dev.c |    3 +-
 include/net/mac80211.h             |  215 +++++++++++++++++++-----------------
 net/mac80211/debugfs.c             |    2 -
 net/mac80211/ieee80211.c           |   32 +-----
 net/mac80211/ieee80211_common.h    |    2 -
 net/mac80211/ieee80211_i.h         |    2 -
 net/mac80211/ieee80211_ioctl.c     |   94 ++++++++++++----
 net/mac80211/ieee80211_sta.c       |   19 +---
 net/mac80211/key.c                 |   51 +++++----
 net/mac80211/regdomain.c           |    6 -
 net/mac80211/rx.c                  |   82 +++++++-------
 net/mac80211/tx.c                  |   69 +++++++++---
 net/mac80211/util.c                |   11 +--
 net/mac80211/wpa.c                 |   60 +++--------
 14 files changed, 328 insertions(+), 320 deletions(-)

diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index 9db9ece..7dbf11e 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -605,8 +605,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 	priv->modes[1].channels = priv->channels;
 	priv->mode = IEEE80211_IF_TYPE_MGMT;
 	dev->flags = IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
-		     IEEE80211_HW_RX_INCLUDES_FCS |
-		     IEEE80211_HW_WEP_INCLUDE_IV;
+		     IEEE80211_HW_RX_INCLUDES_FCS;
 	dev->extra_tx_headroom = sizeof(struct rtl8187_tx_hdr);
 	dev->queues = 1;
 	dev->max_rssi = 65;
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index ec8c739..a2c14f9 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -73,14 +73,13 @@ struct ieee80211_channel {
 #define IEEE80211_RATE_SUPPORTED 0x00000010
 #define IEEE80211_RATE_OFDM 0x00000020
 #define IEEE80211_RATE_CCK 0x00000040
-#define IEEE80211_RATE_TURBO 0x00000080
 #define IEEE80211_RATE_MANDATORY 0x00000100
 
 #define IEEE80211_RATE_CCK_2 (IEEE80211_RATE_CCK | IEEE80211_RATE_PREAMBLE2)
 #define IEEE80211_RATE_MODULATION(f) \
 	(f & (IEEE80211_RATE_CCK | IEEE80211_RATE_OFDM))
 
-/* Low-level driver should set PREAMBLE2, OFDM, CCK, and TURBO flags.
+/* Low-level driver should set PREAMBLE2, OFDM and CCK flags.
  * BASIC, SUPPORTED, ERP, and MANDATORY flags are set in 80211.o based on the
  * configuration. */
 struct ieee80211_rate {
@@ -101,12 +100,10 @@ struct ieee80211_rate {
 
 /* 802.11g is backwards-compatible with 802.11b, so a wlan card can
  * actually be both in 11b and 11g modes at the same time. */
-enum {
+enum ieee80211_phymode {
 	MODE_IEEE80211A, /* IEEE 802.11a */
 	MODE_IEEE80211B, /* IEEE 802.11b only */
-	MODE_ATHEROS_TURBO, /* Atheros Turbo mode (2x.11a at 5 GHz) */
 	MODE_IEEE80211G, /* IEEE 802.11g (and 802.11b compatibility) */
-	MODE_ATHEROS_TURBOG, /* Atheros Turbo mode (2x.11g at 2.4 GHz) */
 
 	/* keep last */
 	NUM_IEEE80211_MODES
@@ -167,7 +164,6 @@ struct ieee80211_low_level_stats {
 /* Transmit control fields. This data structure is passed to low-level driver
  * with each TX frame. The low-level driver is responsible for configuring
  * the hardware to use given values (depending on what is supported). */
-#define HW_KEY_IDX_INVALID -1
 
 struct ieee80211_tx_control {
 	int tx_rate; /* Transmit rate, given as the hw specific value for the
@@ -193,23 +189,21 @@ struct ieee80211_tx_control {
 #define IEEE80211_TXCTL_REQUEUE		(1<<7)
 #define IEEE80211_TXCTL_FIRST_FRAGMENT	(1<<8) /* this is a first fragment of
 						* the frame */
-#define IEEE80211_TXCTL_TKIP_NEW_PHASE1_KEY (1<<9)
 #define IEEE80211_TXCTL_LONG_RETRY_LIMIT (1<<10) /* this frame should be send
 						  * using the through
 						  * set_retry_limit configured
 						  * long retry value */
 	u32 flags;			       /* tx control flags defined
 						* above */
+	u8 key_idx;		/* keyidx from hw->set_key(), undefined if
+				 * IEEE80211_TXCTL_DO_NOT_ENCRYPT is set */
 	u8 retry_limit;		/* 1 = only first attempt, 2 = one retry, ..
 				 * This could be used when set_retry_limit
 				 * is not implemented by the driver */
 	u8 power_level;		/* per-packet transmit power level, in dBm */
 	u8 antenna_sel_tx; 	/* 0 = default/diversity, 1 = Ant0, 2 = Ant1 */
-	s8 key_idx;		/* HW_KEY_IDX_INVALID = do not encrypt,
-				 * other values: keyidx from hw->set_key() */
 	u8 icv_len;		/* length of the ICV/MIC field in octets */
 	u8 iv_len;		/* length of the IV field in octets */
-	u8 tkip_key[16];	/* generated phase2/phase1 key for hw TKIP */
 	u8 queue;		/* hardware queue to use for this frame;
 				 * 0 = highest, hw->queues-1 = lowest */
 	u8 sw_retry_attempt;	/* number of times hw has tried to
@@ -227,22 +221,56 @@ struct ieee80211_tx_control {
 	int ifindex;	/* internal */
 };
 
-/* Receive status. The low-level driver should provide this information
- * (the subset supported by hardware) to the 802.11 code with each received
- * frame. */
+
+/**
+ * enum mac80211_rx_flags - receive flags
+ *
+ * These flags are used with the @flag member of &struct ieee80211_rx_status.
+ * @RX_FLAG_MMIC_ERROR: Michael MIC error was reported on this frame.
+ *	Use together with %RX_FLAG_MMIC_STRIPPED.
+ * @RX_FLAG_DECRYPTED: This frame was decrypted in hardware.
+ * @RX_FLAG_RADIOTAP: This frame starts with a radiotap header.
+ * @RX_FLAG_MMIC_STRIPPED: the Michael MIC is stripped off this frame,
+ *	verification has been done by the hardware.
+ * @RX_FLAG_IV_STRIPPED: The IV/ICV are stripped from this frame.
+ *	If this flag is set, the stack cannot do any replay detection
+ *	hence the driver or hardware will have to do that.
+ */
+enum mac80211_rx_flags {
+	RX_FLAG_MMIC_ERROR	= 1<<0,
+	RX_FLAG_DECRYPTED	= 1<<1,
+	RX_FLAG_RADIOTAP	= 1<<2,
+	RX_FLAG_MMIC_STRIPPED	= 1<<3,
+	RX_FLAG_IV_STRIPPED	= 1<<4,
+};
+
+/**
+ * struct ieee80211_rx_status - receive status
+ *
+ * The low-level driver should provide this information (the subset
+ * supported by hardware) to the 802.11 code with each received
+ * frame.
+ * @mactime: MAC timestamp as defined by 802.11
+ * @freq: frequency the radio was tuned to when receiving this frame, in MHz
+ * @channel: channel the radio was tuned to
+ * @phymode: active PHY mode
+ * @ssi: signal strength when receiving this frame
+ * @signal: used as 'qual' in statistics reporting
+ * @noise: PHY noise when receiving this frame
+ * @antenna: antenna used
+ * @rate: data rate
+ * @flag: %RX_FLAG_*
+ */
 struct ieee80211_rx_status {
 	u64 mactime;
-	int freq; /* receive frequency in Mhz */
+	int freq;
 	int channel;
 	int phymode;
 	int ssi;
-	int signal; /* used as qual in statistics reporting */
+	int signal;
 	int noise;
 	int antenna;
 	int rate;
-#define RX_FLAG_MMIC_ERROR	(1<<0)
-#define RX_FLAG_DECRYPTED	(1<<1)
-#define RX_FLAG_RADIOTAP	(1<<2)
 	int flag;
 };
 
@@ -392,52 +420,86 @@ struct ieee80211_if_conf {
 	struct ieee80211_tx_control *beacon_control;
 };
 
-typedef enum {
+/**
+ * enum ieee80211_key_alg - key algorithm
+ * @ALG_NONE: Unset key algorithm, will never be passed to the driver
+ * @ALG_WEP: WEP40 or WEP104
+ * @ALG_TKIP: TKIP
+ * @ALG_CCMP: CCMP (AES)
+ */
+typedef enum ieee80211_key_alg {
 	ALG_NONE,
 	ALG_WEP,
 	ALG_TKIP,
 	ALG_CCMP,
 } ieee80211_key_alg;
 
-/*
- * This flag indiciates that the station this key is being
- * configured for may use QoS. If your hardware cannot handle
- * that situation it should reject that key.
+
+/**
+ * enum ieee80211_key_flags - key flags
+ *
+ * These flags are used for communication about keys between the driver
+ * and mac80211, with the @flags parameter of &struct ieee80211_key_conf.
+ *
+ * @IEEE80211_KEY_FLAG_WMM_STA: Set by mac80211, this flag indicates
+ *	that the STA this key will be used with could be using QoS.
+ * @IEEE80211_KEY_FLAG_GENERATE_IV: This flag should be set by the
+ *	driver to indicate that it requires IV generation for this
+ *	particular key.
+ * @IEEE80211_KEY_FLAG_GENERATE_MMIC: This flag should be set by
+ *	the driver for a TKIP key if it requires Michael MIC
+ *	generation in software.
  */
-#define IEEE80211_KEY_FLAG_WMM_STA	(1<<0)
+enum ieee80211_key_flags {
+	IEEE80211_KEY_FLAG_WMM_STA	= 1<<0,
+	IEEE80211_KEY_FLAG_GENERATE_IV	= 1<<1,
+	IEEE80211_KEY_FLAG_GENERATE_MMIC= 1<<2,
+};
 
+/**
+ * struct ieee80211_key_conf - key information
+ *
+ * This key information is given by mac80211 to the driver by
+ * the set_key() callback in &struct ieee80211_ops.
+ *
+ * @hw_key_idx: To be set by the driver, this is the key index the driver
+ *	wants to be given when a frame is transmitted and needs to be
+ *	encrypted in hardware.
+ * @alg: The key algorithm.
+ * @flags: key flags, see &enum ieee80211_key_flags.
+ * @keyidx: the key index (0-3)
+ * @keylen: key material length
+ * @key: key material
+ */
 struct ieee80211_key_conf {
-	/*
-	 * To be set by the driver to the key index it would like to
-	 * get in the ieee80211_tx_control.key_idx which defaults
-	 * to HW_KEY_IDX_INVALID so that shouldn't be used.
-	 */
-	int hw_key_idx;
-
-	/* key algorithm, ALG_NONE should never be seen by the driver */
 	ieee80211_key_alg alg;
-
-	/* key flags, see above */
+	u8 hw_key_idx;
 	u8 flags;
-
-	/* key index: 0-3 */
 	s8 keyidx;
-
-	/* length of key material */
 	u8 keylen;
-
-	/* the key material */
 	u8 key[0];
 };
 
 #define IEEE80211_SEQ_COUNTER_RX	0
 #define IEEE80211_SEQ_COUNTER_TX	1
 
-typedef enum {
+/**
+ * enum set_key_cmd - key command
+ *
+ * Used with the set_key() callback in &struct ieee80211_ops, this
+ * indicates whether a key is being removed or added.
+ *
+ * @SET_KEY: a key is set
+ * @DISABLE_KEY: a key must be disabled
+ */
+typedef enum set_key_cmd {
 	SET_KEY, DISABLE_KEY,
 } set_key_cmd;
 
-/* This is driver-visible part of the per-hw state the stack keeps. */
+/**
+ * struct ieee80211_hw - hardware information and state
+ * TODO: move documentation into kernel-doc format
+ */
 struct ieee80211_hw {
 	/* points to the cfg80211 wiphy for this piece. Note
 	 * that you must fill in the perm_addr and dev fields
@@ -468,17 +530,7 @@ struct ieee80211_hw {
 	 */
 #define IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE (1<<1)
 
-	/*
-	 * Some devices handle decryption internally and do not
-	 * indicate whether the frame was encrypted (unencrypted frames
-	 * will be dropped by the hardware, unless specifically allowed
-	 * through.)
-	 * It is permissible to not handle all encrypted frames and fall
-	 * back to software encryption; however, if this flag is set
-	 * unencrypted frames must be dropped unless the driver is told
-	 * otherwise via the set_ieee8021x() callback.
-	 */
-#define IEEE80211_HW_DEVICE_HIDES_WEP (1<<2)
+/* hole at 2 */
 
 	/* Whether RX frames passed to ieee80211_rx() include FCS in the end */
 #define IEEE80211_HW_RX_INCLUDES_FCS (1<<3)
@@ -491,32 +543,13 @@ struct ieee80211_hw {
 	 * can fetch them with ieee80211_get_buffered_bc(). */
 #define IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING (1<<4)
 
-	/*
-	 * This flag is only relevant if hardware encryption is used.
-	 * If set, it has two meanings:
-	 *  1) the IV and ICV are present in received frames that have
-	 *     been decrypted (unless IEEE80211_HW_DEVICE_HIDES_WEP is
-	 *     also set)
-	 *  2) on transmission, the IV should be generated in software.
-	 *
-	 * Please let us know if you *don't* use this flag, the stack would
-	 * really like to be able to get the IV to keep key statistics
-	 * accurate.
-	 */
-#define IEEE80211_HW_WEP_INCLUDE_IV (1<<5)
+/* hole at 5 */
 
 /* hole at 6 */
 
 /* hole at 7 */
 
-	/*
-	 * Some devices handle Michael MIC internally and do not include MIC in
-	 * the received packets passed up. This flag must be set for such
-	 * devices. The 'encryption' frame control bit is expected to be still
-	 * set in the IEEE 802.11 header with this option unlike with the
-	 * IEEE80211_HW_DEVICE_HIDES_WEP flag.
-	 */
-#define IEEE80211_HW_DEVICE_STRIPS_MIC (1<<8)
+/* hole at 8 */
 
 	/* Device is capable of performing full monitor mode even during
 	 * normal operation. */
@@ -530,15 +563,6 @@ struct ieee80211_hw {
 	 * specified in the device's EEPROM */
 #define IEEE80211_HW_DEFAULT_REG_DOMAIN_CONFIGURED (1<<11)
 
-	/* calculate Michael MIC for an MSDU when doing hwcrypto */
-#define IEEE80211_HW_TKIP_INCLUDE_MMIC (1<<12)
-	/* Do TKIP phase1 key mixing in stack to support cards only do
-	 * phase2 key mixing when doing hwcrypto */
-#define IEEE80211_HW_TKIP_REQ_PHASE1_KEY (1<<13)
-	/* Do TKIP phase1 and phase2 key mixing in stack and send the generated
-	 * per-packet RC4 key with each TX frame when doing hwcrypto */
-#define IEEE80211_HW_TKIP_REQ_PHASE2_KEY (1<<14)
-
 	u32 flags;			/* hardware flags defined above */
 
 	/* Set to the size of a needed device specific skb headroom for TX skbs. */
@@ -651,9 +675,15 @@ struct ieee80211_ops {
 	 * selected by the low-level driver.
 	 *
 	 * Return 0 if the key is now in use, -EOPNOTSUPP or -ENOSPC if it
-	 * couldn't be added; if you return 0 then hw_key_idx must be
-	 * assigned to something other than HW_KEY_IDX_INVALID. When the cmd
-	 * is DISABLE_KEY then it must succeed.
+	 * couldn't be added; if you return 0 then hw_key_idx must be assigned
+	 * to the hardware key index, you are free to use the full u8 range.
+	 *
+	 * When the cmd is DISABLE_KEY then it must succeed.
+	 *
+	 * Note that it is permissible to not decrypt a frame even if a key
+	 * for it has been uploaded to hardware, the stack will not make any
+	 * decision based on whether a key has been uploaded or not but rather
+	 * based on the receive flags.
 	 *
 	 * This callback can sleep, and is only called between add_interface
 	 * and remove_interface calls, i.e. while the interface with the
@@ -667,19 +697,6 @@ struct ieee80211_ops {
 		       const u8 *local_address, const u8 *address,
 		       struct ieee80211_key_conf *key);
 
-	/*
-	 * Set TX key index for default/broadcast keys. This is needed in cases
-	 * where wlan card is doing full WEP/TKIP encapsulation (wep_include_iv
-	 * is not set), in other cases, this function pointer can be set to
-	 * NULL since the IEEE 802.11 module takes care of selecting the key
-	 * index for each TX frame.
-	 *
-	 * TODO: If you use this callback in your driver tell us if you need
-	 *	 any other information from it to make it easier, like the
-	 *	 key_conf instead.
-	 */
-	int (*set_key_idx)(struct ieee80211_hw *hw, int idx);
-
 	/* Enable/disable IEEE 802.1X. This item requests wlan card to pass
 	 * unencrypted EAPOL-Key frames even when encryption is configured.
 	 * If the wlan card does not require such a configuration, this
diff --git a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
index dc5ed1a..12db9ad 100644
--- a/net/mac80211/debugfs.c
+++ b/net/mac80211/debugfs.c
@@ -28,8 +28,6 @@ static const char *ieee80211_mode_str(int mode)
 		return "IEEE 802.11b";
 	case MODE_IEEE80211G:
 		return "IEEE 802.11g";
-	case MODE_ATHEROS_TURBO:
-		return "Atheros Turbo (5 GHz)";
 	default:
 		return "UNKNOWN";
 	}
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 5ea86f5..cb5582f 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -47,13 +47,6 @@ struct ieee80211_tx_status_rtap_hdr {
 
 /* common interface routines */
 
-static struct net_device_stats *ieee80211_get_stats(struct net_device *dev)
-{
-	struct ieee80211_sub_if_data *sdata;
-	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	return &(sdata->stats);
-}
-
 static int header_parse_80211(struct sk_buff *skb, unsigned char *haddr)
 {
 	memcpy(haddr, skb_mac_header(skb) + 10, ETH_ALEN); /* addr2 */
@@ -118,10 +111,6 @@ ieee80211_fill_frame_info(struct ieee80211_local *local,
 		case MODE_IEEE80211G:
 			fi->phytype = htonl(ieee80211_phytype_pbcc_dot11_g);
 			break;
-		case MODE_ATHEROS_TURBO:
-			fi->phytype =
-				htonl(ieee80211_phytype_dsss_dot11_turbo);
-			break;
 		default:
 			fi->phytype = htonl(0xAAAAAAAA);
 			break;
@@ -172,11 +161,9 @@ ieee80211_rx_mgmt(struct ieee80211_local *local, struct sk_buff *skb,
 {
 	struct ieee80211_frame_info *fi;
 	const size_t hlen = sizeof(struct ieee80211_frame_info);
-	struct ieee80211_sub_if_data *sdata;
+	struct net_device *dev = local->apdev;
 
-	skb->dev = local->apdev;
-
-	sdata = IEEE80211_DEV_TO_SUB_IF(local->apdev);
+	skb->dev = dev;
 
 	if (skb_headroom(skb) < hlen) {
 		I802_DEBUG_INC(local->rx_expand_skb_head);
@@ -191,8 +178,8 @@ ieee80211_rx_mgmt(struct ieee80211_local *local, struct sk_buff *skb,
 	ieee80211_fill_frame_info(local, fi, status);
 	fi->msg_type = htonl(msg_type);
 
-	sdata->stats.rx_packets++;
-	sdata->stats.rx_bytes += skb->len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
 
 	skb_set_mac_header(skb, 0);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -273,7 +260,6 @@ void ieee80211_if_mgmt_setup(struct net_device *dev)
 	ether_setup(dev);
 	dev->hard_start_xmit = ieee80211_mgmt_start_xmit;
 	dev->change_mtu = ieee80211_change_mtu_apdev;
-	dev->get_stats = ieee80211_get_stats;
 	dev->open = ieee80211_mgmt_open;
 	dev->stop = ieee80211_mgmt_stop;
 	dev->type = ARPHRD_IEEE80211_PRISM;
@@ -603,7 +589,6 @@ void ieee80211_if_setup(struct net_device *dev)
 	dev->wireless_handlers = &ieee80211_iw_handler_def;
 	dev->set_multicast_list = ieee80211_set_multicast_list;
 	dev->change_mtu = ieee80211_change_mtu;
-	dev->get_stats = ieee80211_get_stats;
 	dev->open = ieee80211_open;
 	dev->stop = ieee80211_stop;
 	dev->uninit = ieee80211_if_reinit;
@@ -1225,7 +1210,7 @@ struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
 	local->long_retry_limit = 4;
 	local->hw.conf.radio_enabled = 1;
 
-	local->enabled_modes = (unsigned int) -1;
+	local->enabled_modes = ~0;
 
 	INIT_LIST_HEAD(&local->modes_list);
 
@@ -1465,13 +1450,6 @@ void ieee80211_free_hw(struct ieee80211_hw *hw)
 }
 EXPORT_SYMBOL(ieee80211_free_hw);
 
-struct net_device_stats *ieee80211_dev_stats(struct net_device *dev)
-{
-	struct ieee80211_sub_if_data *sdata;
-	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	return &sdata->stats;
-}
-
 static int __init ieee80211_init(void)
 {
 	struct sk_buff *skb;
diff --git a/net/mac80211/ieee80211_common.h b/net/mac80211/ieee80211_common.h
index d0bbd00..5b5fb7b 100644
--- a/net/mac80211/ieee80211_common.h
+++ b/net/mac80211/ieee80211_common.h
@@ -73,8 +73,6 @@ enum ieee80211_phytype {
 	ieee80211_phytype_ofdm_dot11_g   = 6,
 	ieee80211_phytype_pbcc_dot11_g   = 7,
 	ieee80211_phytype_ofdm_dot11_a   = 8,
-	ieee80211_phytype_dsss_dot11_turbog = 255,
-	ieee80211_phytype_dsss_dot11_turbo = 256,
 };
 
 enum ieee80211_ssi_type {
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 0149f90..14e8c36 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -301,7 +301,6 @@ struct ieee80211_sub_if_data {
 
 	unsigned int flags;
 
-	struct net_device_stats stats;
 	int drop_unencrypted;
 	int eapol; /* 0 = process EAPOL frames as normal data frames,
 		    * 1 = send EAPOL frames through wlan#ap to hostapd
@@ -723,7 +722,6 @@ void ieee80211_tx_set_iswep(struct ieee80211_txrx_data *tx);
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr);
 void ieee80211_if_setup(struct net_device *dev);
 void ieee80211_if_mgmt_setup(struct net_device *dev);
-struct net_device_stats *ieee80211_dev_stats(struct net_device *dev);
 struct ieee80211_rate *ieee80211_get_rate(struct ieee80211_local *local,
 					  int phymode, int hwrate);
 void ieee80211_key_threshold_notify(struct net_device *dev,
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 383ad5f..51dca21 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -26,6 +26,41 @@
 #include "wpa.h"
 #include "aes_ccm.h"
 
+
+/*
+ * Wow. This ioctl interface is such crap, it's tied
+ * to internal definitions. I hope it dies soon.
+ */
+static int mode_to_hostapd_mode(enum ieee80211_phymode mode)
+{
+	switch (mode) {
+	case MODE_IEEE80211A:
+		return 0;
+	case MODE_IEEE80211B:
+		return 1;
+	case MODE_IEEE80211G:
+		return 3;
+	case NUM_IEEE80211_MODES:
+		WARN_ON(1);
+		break;
+	}
+	WARN_ON(1);
+	return -1;
+}
+
+static enum ieee80211_phymode hostapd_mode_to_mode(int hostapd_mode)
+{
+	switch (hostapd_mode) {
+	case 0:
+		return MODE_IEEE80211A;
+	case 1:
+		return MODE_IEEE80211B;
+	case 3:
+		return MODE_IEEE80211G;
+	}
+	return NUM_IEEE80211_MODES;
+}
+
 static int ieee80211_set_encryption(struct net_device *dev, u8 *sta_addr,
 				    int idx, int alg, int set_tx_key,
 				    const u8 *_key, size_t key_len)
@@ -38,17 +73,23 @@ static int ieee80211_set_encryption(struct net_device *dev, u8 *sta_addr,
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
+	if (idx < 0 || idx >= NUM_DEFAULT_KEYS) {
+		printk(KERN_DEBUG "%s: set_encrypt - invalid idx=%d\n",
+		       dev->name, idx);
+		return -EINVAL;
+	}
+
 	if (is_broadcast_ether_addr(sta_addr)) {
 		sta = NULL;
-		if (idx >= NUM_DEFAULT_KEYS) {
-			printk(KERN_DEBUG "%s: set_encrypt - invalid idx=%d\n",
-			       dev->name, idx);
-			return -EINVAL;
-		}
 		key = sdata->keys[idx];
 	} else {
 		set_tx_key = 0;
-		if (idx != 0) {
+		/*
+		 * According to the standard, the key index of a pairwise
+		 * key must be zero. However, some AP are broken when it
+		 * comes to WEP key indices, so we work around this.
+		 */
+		if (idx != 0 && alg != ALG_WEP) {
 			printk(KERN_DEBUG "%s: set_encrypt - non-zero idx for "
 			       "individual key\n", dev->name);
 			return -EINVAL;
@@ -73,11 +114,8 @@ static int ieee80211_set_encryption(struct net_device *dev, u8 *sta_addr,
 		key = NULL;
 	} else {
 		/*
-		 * Need to free it before allocating a new one with
-		 * with the same index or the ordering to the driver's
-		 * set_key() callback becomes confused.
+		 * Automatically frees any old key if present.
 		 */
-		ieee80211_key_free(key);
 		key = ieee80211_key_alloc(sdata, sta, alg, idx, key_len, _key);
 		if (!key) {
 			ret = -ENOMEM;
@@ -144,9 +182,6 @@ static int ieee80211_ioctl_giwname(struct net_device *dev,
 	case MODE_IEEE80211G:
 		strcpy(name, "IEEE 802.11g");
 		break;
-	case MODE_ATHEROS_TURBO:
-		strcpy(name, "5GHz Turbo");
-		break;
 	default:
 		strcpy(name, "IEEE 802.11");
 		break;
@@ -597,9 +632,6 @@ static int ieee80211_ioctl_siwrate(struct net_device *dev,
 		struct ieee80211_rate *rates = &mode->rates[i];
 		int this_rate = rates->rate;
 
-		if (mode->mode == MODE_ATHEROS_TURBO ||
-		    mode->mode == MODE_ATHEROS_TURBOG)
-			this_rate *= 2;
 		if (target_rate == this_rate) {
 			sdata->bss->max_ratectrl_rateidx = i;
 			if (rate->fixed)
@@ -789,6 +821,7 @@ static int ieee80211_ioctl_prism2_param(struct net_device *dev,
 	int param = *i;
 	int value = *(i + 1);
 	int ret = 0;
+	int mode;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -843,7 +876,7 @@ static int ieee80211_ioctl_prism2_param(struct net_device *dev,
 		break;
 
 	case PRISM2_PARAM_NEXT_MODE:
-		local->next_mode = value;
+		local->next_mode = hostapd_mode_to_mode(value);
 		break;
 
 	case PRISM2_PARAM_KEY_TX_RX_THRESHOLD:
@@ -871,7 +904,15 @@ static int ieee80211_ioctl_prism2_param(struct net_device *dev,
 		break;
 
 	case PRISM2_PARAM_HW_MODES:
-		local->enabled_modes = value;
+		mode = 1;
+		local->enabled_modes = 0;
+		while (value) {
+			if (value & 1)
+				local->enabled_modes |=
+					hostapd_mode_to_mode(mode);
+			mode <<= 1;
+			value >>= 1;
+		}
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
@@ -912,6 +953,7 @@ static int ieee80211_ioctl_get_prism2_param(struct net_device *dev,
 	struct ieee80211_sub_if_data *sdata;
 	int *param = (int *) extra;
 	int ret = 0;
+	int mode;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
@@ -949,7 +991,13 @@ static int ieee80211_ioctl_get_prism2_param(struct net_device *dev,
 		break;
 
 	case PRISM2_PARAM_HW_MODES:
-		*param = local->enabled_modes;
+		mode = 0;
+		*param = 0;
+		while (mode < NUM_IEEE80211_MODES) {
+			if (local->enabled_modes & (1<<mode))
+				*param |= mode_to_hostapd_mode(1<<mode);
+			mode++;
+		}
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
@@ -1268,10 +1316,10 @@ static const iw_handler ieee80211_handler[] =
 	(iw_handler) NULL /* kernel code */,		/* SIOCGIWPRIV */
 	(iw_handler) NULL /* not used */,		/* SIOCSIWSTATS */
 	(iw_handler) NULL /* kernel code */,		/* SIOCGIWSTATS */
-	iw_handler_set_spy,				/* SIOCSIWSPY */
-	iw_handler_get_spy,				/* SIOCGIWSPY */
-	iw_handler_set_thrspy,				/* SIOCSIWTHRSPY */
-	iw_handler_get_thrspy,				/* SIOCGIWTHRSPY */
+	(iw_handler) NULL,				/* SIOCSIWSPY */
+	(iw_handler) NULL,				/* SIOCGIWSPY */
+	(iw_handler) NULL,				/* SIOCSIWTHRSPY */
+	(iw_handler) NULL,				/* SIOCGIWTHRSPY */
 	(iw_handler) ieee80211_ioctl_siwap,		/* SIOCSIWAP */
 	(iw_handler) ieee80211_ioctl_giwap,		/* SIOCGIWAP */
 	(iw_handler) ieee80211_ioctl_siwmlme,		/* SIOCSIWMLME */
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 1b4ebe8..8fdbd38 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -618,8 +618,6 @@ static void ieee80211_send_assoc(struct net_device *dev,
 	*pos++ = len;
 	for (i = 0; i < len; i++) {
 		int rate = mode->rates[i].rate;
-		if (mode->mode == MODE_ATHEROS_TURBO)
-			rate /= 2;
 		*pos++ = (u8) (rate / 5);
 	}
 
@@ -629,8 +627,6 @@ static void ieee80211_send_assoc(struct net_device *dev,
 		*pos++ = mode->num_rates - len;
 		for (i = len; i < mode->num_rates; i++) {
 			int rate = mode->rates[i].rate;
-			if (mode->mode == MODE_ATHEROS_TURBO)
-				rate /= 2;
 			*pos++ = (u8) (rate / 5);
 		}
 	}
@@ -889,10 +885,7 @@ static void ieee80211_send_probe_req(struct net_device *dev, u8 *dst,
 			pos = skb_put(skb, 1);
 			supp_rates[1]++;
 		}
-		if (mode->mode == MODE_ATHEROS_TURBO)
-			*pos = rate->rate / 10;
-		else
-			*pos = rate->rate / 5;
+		*pos = rate->rate / 5;
 	}
 
 	ieee80211_sta_tx(dev, skb, 0);
@@ -1285,16 +1278,12 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 	mode = local->oper_hw_mode;
 	for (i = 0; i < elems.supp_rates_len; i++) {
 		int rate = (elems.supp_rates[i] & 0x7f) * 5;
-		if (mode->mode == MODE_ATHEROS_TURBO)
-			rate *= 2;
 		for (j = 0; j < mode->num_rates; j++)
 			if (mode->rates[j].rate == rate)
 				rates |= BIT(j);
 	}
 	for (i = 0; i < elems.ext_supp_rates_len; i++) {
 		int rate = (elems.ext_supp_rates[i] & 0x7f) * 5;
-		if (mode->mode == MODE_ATHEROS_TURBO)
-			rate *= 2;
 		for (j = 0; j < mode->num_rates; j++)
 			if (mode->rates[j].rate == rate)
 				rates |= BIT(j);
@@ -1514,8 +1503,6 @@ static void ieee80211_rx_bss_info(struct net_device *dev,
 				rate = elems.ext_supp_rates
 					[i - elems.supp_rates_len];
 			own_rate = 5 * (rate & 0x7f);
-			if (mode->mode == MODE_ATHEROS_TURBO)
-				own_rate *= 2;
 			for (j = 0; j < num_rates; j++)
 				if (rates[j].rate == own_rate)
 					supp_rates |= BIT(j);
@@ -2344,8 +2331,6 @@ static int ieee80211_sta_join_ibss(struct net_device *dev,
 		mode = local->oper_hw_mode;
 		for (i = 0; i < bss->supp_rates_len; i++) {
 			int bitrate = (bss->supp_rates[i] & 0x7f) * 5;
-			if (mode->mode == MODE_ATHEROS_TURBO)
-				bitrate *= 2;
 			for (j = 0; j < mode->num_rates; j++)
 				if (mode->rates[j].rate == bitrate)
 					rates |= BIT(j);
@@ -2418,8 +2403,6 @@ static int ieee80211_sta_create_ibss(struct net_device *dev,
 	pos = bss->supp_rates;
 	for (i = 0; i < mode->num_rates; i++) {
 		int rate = mode->rates[i].rate;
-		if (mode->mode == MODE_ATHEROS_TURBO)
-			rate /= 2;
 		*pos++ = (u8) (rate / 5);
 	}
 
diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index 178f00c..dd6fc4a 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -12,6 +12,7 @@
 #include <linux/if_ether.h>
 #include <linux/etherdevice.h>
 #include <linux/list.h>
+#include <linux/rcupdate.h>
 #include <net/mac80211.h>
 #include "ieee80211_i.h"
 #include "debugfs_key.h"
@@ -72,8 +73,6 @@ static void ieee80211_key_enable_hw_accel(struct ieee80211_key *key)
 				       key->sdata->dev->dev_addr, addr,
 				       &key->conf);
 
-	WARN_ON(!ret && (key->conf.hw_key_idx == HW_KEY_IDX_INVALID));
-
 	if (!ret)
 		key->flags |= KEY_FLAG_UPLOADED_TO_HARDWARE;
 
@@ -108,7 +107,6 @@ static void ieee80211_key_disable_hw_accel(struct ieee80211_key *key)
 		       key->conf.keyidx, MAC_ARG(addr), ret);
 
 	key->flags &= ~KEY_FLAG_UPLOADED_TO_HARDWARE;
-	key->conf.hw_key_idx = HW_KEY_IDX_INVALID;
 }
 
 struct ieee80211_key *ieee80211_key_alloc(struct ieee80211_sub_if_data *sdata,
@@ -120,6 +118,7 @@ struct ieee80211_key *ieee80211_key_alloc(struct ieee80211_sub_if_data *sdata,
 {
 	struct ieee80211_key *key;
 
+	BUG_ON(idx < 0 || idx >= NUM_DEFAULT_KEYS);
 	BUG_ON(alg == ALG_NONE);
 
 	key = kzalloc(sizeof(struct ieee80211_key) + key_len, GFP_KERNEL);
@@ -130,7 +129,6 @@ struct ieee80211_key *ieee80211_key_alloc(struct ieee80211_sub_if_data *sdata,
 	 * Default to software encryption; we'll later upload the
 	 * key to the hardware if possible.
 	 */
-	key->conf.hw_key_idx = HW_KEY_IDX_INVALID;
 	key->conf.flags = 0;
 	key->flags = 0;
 
@@ -157,9 +155,15 @@ struct ieee80211_key *ieee80211_key_alloc(struct ieee80211_sub_if_data *sdata,
 
 	ieee80211_debugfs_key_add(key->local, key);
 
+	/* remove key first */
+	if (sta)
+		ieee80211_key_free(sta->key);
+	else
+		ieee80211_key_free(sdata->keys[idx]);
+
 	if (sta) {
 		ieee80211_debugfs_key_sta_link(key, sta);
-		sta->key = key;
+
 		/*
 		 * some hardware cannot handle TKIP with QoS, so
 		 * we indicate whether QoS could be in use.
@@ -179,21 +183,19 @@ struct ieee80211_key *ieee80211_key_alloc(struct ieee80211_sub_if_data *sdata,
 				sta_info_put(ap);
 			}
 		}
-
-		if (idx >= 0 && idx < NUM_DEFAULT_KEYS) {
-			if (!sdata->keys[idx])
-				sdata->keys[idx] = key;
-			else
-				WARN_ON(1);
-		} else
-			WARN_ON(1);
 	}
 
-	list_add(&key->list, &sdata->key_list);
-
+	/* enable hwaccel if appropriate */
 	if (netif_running(key->sdata->dev))
 		ieee80211_key_enable_hw_accel(key);
 
+	if (sta)
+		rcu_assign_pointer(sta->key, key);
+	else
+		rcu_assign_pointer(sdata->keys[idx], key);
+
+	list_add(&key->list, &sdata->key_list);
+
 	return key;
 }
 
@@ -202,20 +204,25 @@ void ieee80211_key_free(struct ieee80211_key *key)
 	if (!key)
 		return;
 
-	ieee80211_key_disable_hw_accel(key);
-
 	if (key->sta) {
-		key->sta->key = NULL;
+		rcu_assign_pointer(key->sta->key, NULL);
 	} else {
 		if (key->sdata->default_key == key)
 			ieee80211_set_default_key(key->sdata, -1);
 		if (key->conf.keyidx >= 0 &&
 		    key->conf.keyidx < NUM_DEFAULT_KEYS)
-			key->sdata->keys[key->conf.keyidx] = NULL;
+			rcu_assign_pointer(key->sdata->keys[key->conf.keyidx],
+					   NULL);
 		else
 			WARN_ON(1);
 	}
 
+	/* wait for all key users to complete */
+	synchronize_rcu();
+
+	/* remove from hwaccel if appropriate */
+	ieee80211_key_disable_hw_accel(key);
+
 	if (key->conf.alg == ALG_CCMP)
 		ieee80211_aes_key_free(key->u.ccmp.tfm);
 	ieee80211_debugfs_key_remove(key);
@@ -235,14 +242,10 @@ void ieee80211_set_default_key(struct ieee80211_sub_if_data *sdata, int idx)
 	if (sdata->default_key != key) {
 		ieee80211_debugfs_key_remove_default(sdata);
 
-		sdata->default_key = key;
+		rcu_assign_pointer(sdata->default_key, key);
 
 		if (sdata->default_key)
 			ieee80211_debugfs_key_add_default(sdata);
-
-		if (sdata->local->ops->set_key_idx)
-			sdata->local->ops->set_key_idx(
-				local_to_hw(sdata->local), idx);
 	}
 }
 
diff --git a/net/mac80211/regdomain.c b/net/mac80211/regdomain.c
index b697a2a..f42678f 100644
--- a/net/mac80211/regdomain.c
+++ b/net/mac80211/regdomain.c
@@ -82,12 +82,6 @@ static void ieee80211_unmask_channel(int mode, struct ieee80211_channel *chan)
 
 	chan->flag = 0;
 
-	if (ieee80211_regdom == 64 &&
-	    (mode == MODE_ATHEROS_TURBO || mode == MODE_ATHEROS_TURBOG)) {
-		/* Do not allow Turbo modes in Japan. */
-		return;
-	}
-
 	for (i = 0; channel_range[i].start_freq; i++) {
 		const struct ieee80211_channel_range *r = &channel_range[i];
 		if (r->start_freq <= chan->freq && r->end_freq >= chan->freq) {
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 4fb8c70..c985c7a 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -13,6 +13,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/rcupdate.h>
 #include <net/mac80211.h>
 #include <net/ieee80211_radiotap.h>
 
@@ -93,8 +94,6 @@ ieee80211_rx_h_load_stats(struct ieee80211_txrx_data *rx)
 	 * 1 usec = 1/8 * (1080 / 10) = 13.5 */
 
 	if (mode->mode == MODE_IEEE80211A ||
-	    mode->mode == MODE_ATHEROS_TURBO ||
-	    mode->mode == MODE_ATHEROS_TURBOG ||
 	    (mode->mode == MODE_IEEE80211G &&
 	     rate->flags & IEEE80211_RATE_ERP))
 		hdrtime = CHAN_UTIL_HDR_SHORT;
@@ -138,7 +137,6 @@ ieee80211_rx_monitor(struct net_device *dev, struct sk_buff *skb,
 		     struct ieee80211_rx_status *status)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_rate *rate;
 	struct ieee80211_rtap_hdr {
 		struct ieee80211_radiotap_header hdr;
@@ -151,8 +149,6 @@ ieee80211_rx_monitor(struct net_device *dev, struct sk_buff *skb,
 
 	skb->dev = dev;
 
-	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-
 	if (status->flag & RX_FLAG_RADIOTAP)
 		goto out;
 
@@ -185,8 +181,8 @@ ieee80211_rx_monitor(struct net_device *dev, struct sk_buff *skb,
 	rthdr->antsignal = status->ssi;
 
  out:
-	sdata->stats.rx_packets++;
-	sdata->stats.rx_bytes += skb->len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
 
 	skb_set_mac_header(skb, 0);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -311,6 +307,7 @@ ieee80211_rx_h_load_key(struct ieee80211_txrx_data *rx)
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) rx->skb->data;
 	int keyidx;
 	int hdrlen;
+	struct ieee80211_key *stakey = NULL;
 
 	/*
 	 * Key selection 101
@@ -348,8 +345,11 @@ ieee80211_rx_h_load_key(struct ieee80211_txrx_data *rx)
 	if (!(rx->flags & IEEE80211_TXRXD_RXRA_MATCH))
 		return TXRX_CONTINUE;
 
-	if (!is_multicast_ether_addr(hdr->addr1) && rx->sta && rx->sta->key) {
-		rx->key = rx->sta->key;
+	if (rx->sta)
+		stakey = rcu_dereference(rx->sta->key);
+
+	if (!is_multicast_ether_addr(hdr->addr1) && stakey) {
+		rx->key = stakey;
 	} else {
 		/*
 		 * The device doesn't give us the IV so we won't be
@@ -360,7 +360,8 @@ ieee80211_rx_h_load_key(struct ieee80211_txrx_data *rx)
 		 * we somehow allow the driver to tell us which key
 		 * the hardware used if this flag is set?
 		 */
-		if (!(rx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV))
+		if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
+		    (rx->u.rx.status->flag & RX_FLAG_IV_STRIPPED))
 			return TXRX_CONTINUE;
 
 		hdrlen = ieee80211_get_hdrlen(rx->fc);
@@ -374,7 +375,7 @@ ieee80211_rx_h_load_key(struct ieee80211_txrx_data *rx)
 		 */
 		keyidx = rx->skb->data[hdrlen + 3] >> 6;
 
-		rx->key = rx->sdata->keys[keyidx];
+		rx->key = rcu_dereference(rx->sdata->keys[keyidx]);
 
 		/*
 		 * RSNA-protected unicast frames should always be sent with
@@ -531,8 +532,8 @@ ieee80211_rx_h_wep_weak_iv_detection(struct ieee80211_txrx_data *rx)
 		return TXRX_CONTINUE;
 
 	/* Check for weak IVs, if hwaccel did not remove IV from the frame */
-	if ((rx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV) ||
-	    !(rx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE))
+	if (!(rx->u.rx.status->flag & RX_FLAG_IV_STRIPPED) ||
+	    !(rx->u.rx.status->flag & RX_FLAG_DECRYPTED))
 		if (ieee80211_wep_is_weak_iv(rx->skb, rx->key))
 			rx->sta->wep_weak_iv_count++;
 
@@ -556,15 +557,14 @@ ieee80211_rx_h_wep_decrypt(struct ieee80211_txrx_data *rx)
 		return TXRX_DROP;
 	}
 
-	if (!(rx->u.rx.status->flag & RX_FLAG_DECRYPTED) ||
-	    !(rx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE)) {
+	if (!(rx->u.rx.status->flag & RX_FLAG_DECRYPTED)) {
 		if (ieee80211_wep_decrypt(rx->local, rx->skb, rx->key)) {
 			if (net_ratelimit())
 				printk(KERN_DEBUG "%s: RX WEP frame, decrypt "
 				       "failed\n", rx->dev->name);
 			return TXRX_DROP;
 		}
-	} else if (rx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV) {
+	} else if (!(rx->u.rx.status->flag & RX_FLAG_IV_STRIPPED)) {
 		ieee80211_wep_remove_iv(rx->local, rx->skb, rx->key);
 		/* remove ICV */
 		skb_trim(rx->skb, rx->skb->len - 4);
@@ -895,13 +895,10 @@ static ieee80211_txrx_result
 ieee80211_rx_h_drop_unencrypted(struct ieee80211_txrx_data *rx)
 {
 	/*
-	 * Pass through unencrypted frames if the hardware might have
-	 * decrypted them already without telling us, but that can only
-	 * be true if we either didn't find a key or the found key is
-	 * uploaded to the hardware.
+	 * Pass through unencrypted frames if the hardware has
+	 * decrypted them already.
 	 */
-	if ((rx->local->hw.flags & IEEE80211_HW_DEVICE_HIDES_WEP) &&
-	    (!rx->key || (rx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE)))
+	if (rx->u.rx.status->flag & RX_FLAG_DECRYPTED)
 		return TXRX_CONTINUE;
 
 	/* Drop unencrypted frames if key is set. */
@@ -1053,8 +1050,8 @@ ieee80211_rx_h_data(struct ieee80211_txrx_data *rx)
 
 	skb2 = NULL;
 
-	sdata->stats.rx_packets++;
-	sdata->stats.rx_bytes += skb->len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
 
 	if (local->bridge_packets && (sdata->type == IEEE80211_IF_TYPE_AP
 	    || sdata->type == IEEE80211_IF_TYPE_VLAN) &&
@@ -1182,8 +1179,6 @@ static void ieee80211_rx_michael_mic_report(struct net_device *dev,
 	else
 		keyidx = -1;
 
-	/* TODO: verify that this is not triggered by fragmented
-	 * frames (hw does not verify MIC for them). */
 	if (net_ratelimit())
 		printk(KERN_DEBUG "%s: TKIP hwaccel reported Michael MIC "
 		       "failure from " MAC_FMT " to " MAC_FMT " keyidx=%d\n",
@@ -1191,9 +1186,10 @@ static void ieee80211_rx_michael_mic_report(struct net_device *dev,
 		       keyidx);
 
 	if (!sta) {
-		/* Some hardware versions seem to generate incorrect
-		 * Michael MIC reports; ignore them to avoid triggering
-		 * countermeasures. */
+		/*
+		 * Some hardware seem to generate incorrect Michael MIC
+		 * reports; ignore them to avoid triggering countermeasures.
+		 */
 		if (net_ratelimit())
 			printk(KERN_DEBUG "%s: ignored spurious Michael MIC "
 			       "error for unknown address " MAC_FMT "\n",
@@ -1204,17 +1200,18 @@ static void ieee80211_rx_michael_mic_report(struct net_device *dev,
 	if (!(rx->fc & IEEE80211_FCTL_PROTECTED)) {
 		if (net_ratelimit())
 			printk(KERN_DEBUG "%s: ignored spurious Michael MIC "
-			       "error for a frame with no ISWEP flag (src "
+			       "error for a frame with no PROTECTED flag (src "
 			       MAC_FMT ")\n", dev->name, MAC_ARG(hdr->addr2));
 		goto ignore;
 	}
 
-	if ((rx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV) &&
-	    rx->sdata->type == IEEE80211_IF_TYPE_AP && keyidx) {
-		/* AP with Pairwise keys support should never receive Michael
-		 * MIC errors for non-zero keyidx because these are reserved
-		 * for group keys and only the AP is sending real multicast
-		 * frames in BSS. */
+	if (rx->sdata->type == IEEE80211_IF_TYPE_AP && keyidx) {
+		/*
+		 * APs with pairwise keys should never receive Michael MIC
+		 * errors for non-zero keyidx because these are reserved for
+		 * group keys and only the AP is sending real multicast
+		 * frames in the BSS.
+		 */
 		if (net_ratelimit())
 			printk(KERN_DEBUG "%s: ignored Michael MIC error for "
 			       "a frame with non-zero keyidx (%d)"
@@ -1234,10 +1231,6 @@ static void ieee80211_rx_michael_mic_report(struct net_device *dev,
 		goto ignore;
 	}
 
-	/* TODO: consider verifying the MIC error report with software
-	 * implementation if we get too many spurious reports from the
-	 * hardware. */
-
 	mac80211_ev_michael_mic_failure(rx->dev, keyidx, hdr);
  ignore:
 	dev_kfree_skb(rx->skb);
@@ -1364,6 +1357,12 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 		skb_pull(skb, radiotap_len);
 	}
 
+	/*
+	 * key references are protected using RCU and this requires that
+	 * we are in a read-site RCU section during receive processing
+	 */
+	rcu_read_lock();
+
 	hdr = (struct ieee80211_hdr *) skb->data;
 	memset(&rx, 0, sizeof(rx));
 	rx.skb = skb;
@@ -1404,6 +1403,7 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 		ieee80211_invoke_rx_handlers(local, local->rx_handlers, &rx,
 					     rx.sta);
 		sta_info_put(sta);
+		rcu_read_unlock();
 		return;
 	}
 
@@ -1465,6 +1465,8 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 	read_unlock(&local->sub_if_lock);
 
  end:
+	rcu_read_unlock();
+
 	if (sta)
 		sta_info_put(sta);
 }
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 9e952e3..ca262a9 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -17,6 +17,7 @@
 #include <linux/skbuff.h>
 #include <linux/etherdevice.h>
 #include <linux/bitmap.h>
+#include <linux/rcupdate.h>
 #include <net/net_namespace.h>
 #include <net/ieee80211_radiotap.h>
 #include <net/cfg80211.h>
@@ -427,20 +428,22 @@ ieee80211_tx_h_ps_buf(struct ieee80211_txrx_data *tx)
 static ieee80211_txrx_result
 ieee80211_tx_h_select_key(struct ieee80211_txrx_data *tx)
 {
-	tx->u.tx.control->key_idx = HW_KEY_IDX_INVALID;
+	struct ieee80211_key *key;
 
 	if (unlikely(tx->u.tx.control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT))
 		tx->key = NULL;
-	else if (tx->sta && tx->sta->key)
-		tx->key = tx->sta->key;
-	else if (tx->sdata->default_key)
-		tx->key = tx->sdata->default_key;
+	else if (tx->sta && (key = rcu_dereference(tx->sta->key)))
+		tx->key = key;
+	else if ((key = rcu_dereference(tx->sdata->default_key)))
+		tx->key = key;
 	else if (tx->sdata->drop_unencrypted &&
 		 !(tx->sdata->eapol && ieee80211_is_eapol(tx->skb))) {
 		I802_DEBUG_INC(tx->local->tx_handlers_drop_unencrypted);
 		return TXRX_DROP;
-	} else
+	} else {
 		tx->key = NULL;
+		tx->u.tx.control->flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
+	}
 
 	if (tx->key) {
 		tx->key->tx_rx_count++;
@@ -542,9 +545,8 @@ static int wep_encrypt_skb(struct ieee80211_txrx_data *tx, struct sk_buff *skb)
 			return -1;
 	} else {
 		tx->u.tx.control->key_idx = tx->key->conf.hw_key_idx;
-		if (tx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV) {
-			if (ieee80211_wep_add_iv(tx->local, skb, tx->key) ==
-			    NULL)
+		if (tx->key->conf.flags & IEEE80211_KEY_FLAG_GENERATE_IV) {
+			if (!ieee80211_wep_add_iv(tx->local, skb, tx->key))
 				return -1;
 		}
 	}
@@ -722,6 +724,15 @@ ieee80211_tx_h_misc(struct ieee80211_txrx_data *tx)
 		}
 	}
 
+	/*
+	 * Tell hardware to not encrypt when we had sw crypto.
+	 * Because we use the same flag to internally indicate that
+	 * no (software) encryption should be done, we have to set it
+	 * after all crypto handlers.
+	 */
+	if (tx->key && !(tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE))
+		tx->u.tx.control->flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
+
 	return TXRX_CONTINUE;
 }
 
@@ -744,8 +755,6 @@ ieee80211_tx_h_load_stats(struct ieee80211_txrx_data *tx)
 	 * 1 usec = 1/8 * (1080 / 10) = 13.5 */
 
 	if (mode->mode == MODE_IEEE80211A ||
-	    mode->mode == MODE_ATHEROS_TURBO ||
-	    mode->mode == MODE_ATHEROS_TURBOG ||
 	    (mode->mode == MODE_IEEE80211G &&
 	     tx->u.tx.rate->flags & IEEE80211_RATE_ERP))
 		hdrtime = CHAN_UTIL_HDR_SHORT;
@@ -833,7 +842,6 @@ __ieee80211_parse_tx_radiotap(
 	 */
 
 	control->retry_limit = 1; /* no retry */
-	control->key_idx = HW_KEY_IDX_INVALID;
 	control->flags &= ~(IEEE80211_TXCTL_USE_RTS_CTS |
 			    IEEE80211_TXCTL_USE_CTS_PROTECT);
 	control->flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT |
@@ -951,8 +959,6 @@ __ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
 	tx->dev = dev; /* use original interface */
 	tx->local = local;
 	tx->sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	tx->sta = sta_info_get(local, hdr->addr1);
-	tx->fc = le16_to_cpu(hdr->frame_control);
 
 	/*
 	 * set defaults for things that can be set by
@@ -977,6 +983,8 @@ __ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
 		res = TXRX_QUEUED; /* indication it was monitor packet */
 	}
 
+	tx->sta = sta_info_get(local, hdr->addr1);
+	tx->fc = le16_to_cpu(hdr->frame_control);
 	tx->u.tx.control = control;
 	if (is_multicast_ether_addr(hdr->addr1)) {
 		tx->flags &= ~IEEE80211_TXRXD_TXUNICAST;
@@ -1112,6 +1120,12 @@ static int ieee80211_tx(struct net_device *dev, struct sk_buff *skb,
 		return 0;
 	}
 
+	/*
+	 * key references are protected using RCU and this requires that
+	 * we are in a read-site RCU section during receive processing
+	 */
+	rcu_read_lock();
+
 	sta = tx.sta;
 	tx.u.tx.mgmt_interface = mgmt;
 	tx.u.tx.mode = local->hw.conf.mode;
@@ -1139,6 +1153,7 @@ static int ieee80211_tx(struct net_device *dev, struct sk_buff *skb,
 
 	if (unlikely(res == TXRX_QUEUED)) {
 		I802_DEBUG_INC(local->tx_handlers_queued);
+		rcu_read_unlock();
 		return 0;
 	}
 
@@ -1196,6 +1211,7 @@ retry:
 		store->last_frag_rate_ctrl_probe =
 			!!(tx.flags & IEEE80211_TXRXD_TXPROBE_LAST_FRAG);
 	}
+	rcu_read_unlock();
 	return 0;
 
  drop:
@@ -1205,6 +1221,7 @@ retry:
 		if (tx.u.tx.extra_frag[i])
 			dev_kfree_skb(tx.u.tx.extra_frag[i]);
 	kfree(tx.u.tx.extra_frag);
+	rcu_read_unlock();
 	return 0;
 }
 
@@ -1487,7 +1504,20 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 		nh_pos += encaps_len;
 		h_pos += encaps_len;
 	}
-	memcpy(skb_push(skb, hdrlen), &hdr, hdrlen);
+
+	if (fc & IEEE80211_STYPE_QOS_DATA) {
+		__le16 *qos_control;
+
+		qos_control = (__le16*) skb_push(skb, 2);
+		memcpy(skb_push(skb, hdrlen - 2), &hdr, hdrlen - 2);
+		/*
+		 * Maybe we could actually set some fields here, for now just
+		 * initialise to zero to indicate no special operation.
+		 */
+		*qos_control = 0;
+	} else
+		memcpy(skb_push(skb, hdrlen), &hdr, hdrlen);
+
 	nh_pos += hdrlen;
 	h_pos += hdrlen;
 
@@ -1498,8 +1528,8 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 		pkt_data->flags |= IEEE80211_TXPD_MGMT_IFACE;
 
 	skb->dev = local->mdev;
-	sdata->stats.tx_packets++;
-	sdata->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	/* Update skb pointers to various headers since this modified frame
 	 * is going to go through Linux networking code that may potentially
@@ -1572,8 +1602,8 @@ int ieee80211_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!(fc & IEEE80211_FCTL_PROTECTED))
 		pkt_data->flags |= IEEE80211_TXPD_DO_NOT_ENCRYPT;
 
-	sdata->stats.tx_packets++;
-	sdata->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	dev_queue_xmit(skb);
 
@@ -1871,6 +1901,7 @@ ieee80211_get_buffered_bc(struct ieee80211_hw *hw, int if_id,
 	}
 	sta = tx.sta;
 	tx.flags |= IEEE80211_TXRXD_TXPS_BUFFERED;
+	tx.u.tx.mode = local->hw.conf.mode;
 
 	for (handler = local->tx_handlers; *handler != NULL; handler++) {
 		res = (*handler)(&tx);
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index c970996..29c0a0e 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -93,11 +93,6 @@ void ieee80211_prepare_rates(struct ieee80211_local *local,
 			if (rate->rate == 10 || rate->rate == 20)
 				rate->flags |= IEEE80211_RATE_BASIC;
 			break;
-		case MODE_ATHEROS_TURBO:
-			if (rate->rate == 120 || rate->rate == 240 ||
-			    rate->rate == 480)
-				rate->flags |= IEEE80211_RATE_BASIC;
-			break;
 		case MODE_IEEE80211G:
 			if (rate->rate == 10 || rate->rate == 20 ||
 			    rate->rate == 55 || rate->rate == 110)
@@ -116,8 +111,6 @@ void ieee80211_prepare_rates(struct ieee80211_local *local,
 			if (rate->rate == 10)
 				rate->flags |= IEEE80211_RATE_MANDATORY;
 			break;
-		case MODE_ATHEROS_TURBO:
-			break;
 		case MODE_IEEE80211G:
 			if (rate->rate == 10 || rate->rate == 20 ||
 			    rate->rate == 55 || rate->rate == 110 ||
@@ -273,8 +266,7 @@ int ieee80211_frame_duration(struct ieee80211_local *local, size_t len,
 	 * DIV_ROUND_UP() operations.
 	 */
 
-	if (local->hw.conf.phymode == MODE_IEEE80211A || erp ||
-	    local->hw.conf.phymode == MODE_ATHEROS_TURBO) {
+	if (local->hw.conf.phymode == MODE_IEEE80211A || erp) {
 		/*
 		 * OFDM:
 		 *
@@ -288,7 +280,6 @@ int ieee80211_frame_duration(struct ieee80211_local *local, size_t len,
 		 * 802.11g - 19.8.4: aSIFSTime = 10 usec +
 		 *	signal ext = 6 usec
 		 */
-		/* FIX: Atheros Turbo may have different (shorter) duration? */
 		dur = 16; /* SIFS + signal ext */
 		dur += 16; /* 17.3.2.3: T_PREAMBLE = 16 usec */
 		dur += 4; /* 17.3.2.3: T_SIGNAL = 4 usec */
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 775f89e..6e12638 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -91,7 +91,7 @@ ieee80211_tx_h_michael_mic_add(struct ieee80211_txrx_data *tx)
 
 	if ((tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE) &&
 	    !(tx->flags & IEEE80211_TXRXD_FRAGMENTED) &&
-	    !(tx->local->hw.flags & IEEE80211_HW_TKIP_INCLUDE_MMIC) &&
+	    !(tx->key->conf.flags & IEEE80211_KEY_FLAG_GENERATE_MMIC) &&
 	    !wpa_test) {
 		/* hwaccel - with no need for preallocated room for Michael MIC
 		 */
@@ -138,26 +138,13 @@ ieee80211_rx_h_michael_mic_verify(struct ieee80211_txrx_data *rx)
 	/*
 	 * No way to verify the MIC if the hardware stripped it
 	 */
-	if (rx->local->hw.flags & IEEE80211_HW_DEVICE_STRIPS_MIC)
+	if (rx->u.rx.status->flag & RX_FLAG_MMIC_STRIPPED)
 		return TXRX_CONTINUE;
 
 	if (!rx->key || rx->key->conf.alg != ALG_TKIP ||
 	    !(rx->fc & IEEE80211_FCTL_PROTECTED) || !WLAN_FC_DATA_PRESENT(fc))
 		return TXRX_CONTINUE;
 
-	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    (rx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE)) {
-		if (rx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV) {
-			if (skb->len < MICHAEL_MIC_LEN)
-				return TXRX_DROP;
-		}
-		/* Need to verify Michael MIC sometimes in software even when
-		 * hwaccel is used. Atheros ar5212: fragmented frames and QoS
-		 * frames. */
-		if (!(rx->flags & IEEE80211_TXRXD_FRAGMENTED) && !wpa_test)
-			goto remove_mic;
-	}
-
 	if (ieee80211_get_hdr_info(skb, &sa, &da, &qos_tid, &data, &data_len)
 	    || data_len < MICHAEL_MIC_LEN)
 		return TXRX_DROP;
@@ -184,7 +171,6 @@ ieee80211_rx_h_michael_mic_verify(struct ieee80211_txrx_data *rx)
 		return TXRX_DROP;
 	}
 
- remove_mic:
 	/* remove Michael MIC from payload */
 	skb_trim(skb, skb->len - MICHAEL_MIC_LEN);
 
@@ -228,7 +214,6 @@ static int tkip_encrypt_skb(struct ieee80211_txrx_data *tx,
 		key->u.tkip.iv32++;
 
 	if (tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE) {
-		u32 flags = tx->local->hw.flags;
 		hdr = (struct ieee80211_hdr *)skb->data;
 
 		/* hwaccel - with preallocated room for IV */
@@ -238,22 +223,6 @@ static int tkip_encrypt_skb(struct ieee80211_txrx_data *tx,
 					    0x7f),
 				      (u8) key->u.tkip.iv16);
 
-		if (flags & IEEE80211_HW_TKIP_REQ_PHASE2_KEY)
-			ieee80211_tkip_gen_rc4key(key, hdr->addr2,
-						  tx->u.tx.control->tkip_key);
-		else if (flags & IEEE80211_HW_TKIP_REQ_PHASE1_KEY) {
-			if (key->u.tkip.iv16 == 0 ||
-			    !key->u.tkip.tx_initialized) {
-				ieee80211_tkip_gen_phase1key(key, hdr->addr2,
-					    (u16 *)tx->u.tx.control->tkip_key);
-				key->u.tkip.tx_initialized = 1;
-				tx->u.tx.control->flags |=
-					    IEEE80211_TXCTL_TKIP_NEW_PHASE1_KEY;
-			} else
-				tx->u.tx.control->flags &=
-					    ~IEEE80211_TXCTL_TKIP_NEW_PHASE1_KEY;
-		}
-
 		tx->u.tx.control->key_idx = tx->key->conf.hw_key_idx;
 		return 0;
 	}
@@ -287,7 +256,7 @@ ieee80211_tx_h_tkip_encrypt(struct ieee80211_txrx_data *tx)
 	ieee80211_tx_set_iswep(tx);
 
 	if ((tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE) &&
-	    !(tx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV) &&
+	    !(tx->key->conf.flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
 	    !wpa_test) {
 		/* hwaccel - with no need for preallocated room for IV/ICV */
 		tx->u.tx.control->key_idx = tx->key->conf.hw_key_idx;
@@ -330,11 +299,13 @@ ieee80211_rx_h_tkip_decrypt(struct ieee80211_txrx_data *rx)
 	if (!rx->sta || skb->len - hdrlen < 12)
 		return TXRX_DROP;
 
-	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    (key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE)) {
-		if (!(rx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV)) {
-			/* Hardware takes care of all processing, including
-			 * replay protection, so no need to continue here. */
+	if (rx->u.rx.status->flag & RX_FLAG_DECRYPTED) {
+		if (rx->u.rx.status->flag & RX_FLAG_IV_STRIPPED) {
+			/*
+			 * Hardware took care of all processing, including
+			 * replay protection, and stripped the ICV/IV so
+			 * we cannot do any checks here.
+			 */
 			return TXRX_CONTINUE;
 		}
 
@@ -538,7 +509,7 @@ ieee80211_tx_h_ccmp_encrypt(struct ieee80211_txrx_data *tx)
 	ieee80211_tx_set_iswep(tx);
 
 	if ((tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE) &&
-	    !(tx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV)) {
+	    !(tx->key->conf.flags & IEEE80211_KEY_FLAG_GENERATE_IV)) {
 		/* hwaccel - with no need for preallocated room for CCMP "
 		 * header or MIC fields */
 		tx->u.tx.control->key_idx = tx->key->conf.hw_key_idx;
@@ -585,8 +556,7 @@ ieee80211_rx_h_ccmp_decrypt(struct ieee80211_txrx_data *rx)
 		return TXRX_DROP;
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    (key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE) &&
-	    !(rx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV))
+	    (rx->u.rx.status->flag & RX_FLAG_IV_STRIPPED))
 		return TXRX_CONTINUE;
 
 	(void) ccmp_hdr2pn(pn, skb->data + hdrlen);
@@ -605,10 +575,8 @@ ieee80211_rx_h_ccmp_decrypt(struct ieee80211_txrx_data *rx)
 		return TXRX_DROP;
 	}
 
-	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    (key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE)) {
-		/* hwaccel has already decrypted frame and verified MIC */
-	} else {
+	if (!(rx->u.rx.status->flag & RX_FLAG_DECRYPTED)) {
+		/* hardware didn't decrypt/verify MIC */
 		u8 *scratch, *b_0, *aad;
 
 		scratch = key->u.ccmp.rx_crypto_buf;
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
