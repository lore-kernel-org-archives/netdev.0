From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'upstream-davem' branch of wireless-2.6
Date: Thu, 12 Jul 2007 16:41:38 -0400
Message-ID: <20070712204137.GB14486@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

This request is based off net-2.6, as it requires a patch that is in
net-2.6 but not yet in Linus' tree (b3d88ad49a0623d09efcf998beb26288c8029f75).

Individual patches available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem/

Let me know if you want individual patches by email -- hopefully the URL
above is sufficient?

John

---

The following changes since commit 15028aad00ddf241581fbe74a02ec89cbb28d35d:
  Michael Chan (1):
        [TG3]: Update version to 3.78.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem

Andy Green (3):
      mac80211: Monitor mode radiotap injection docs
      cfg80211: Radiotap parser
      mac80211: Monitor mode radiotap-based packet injection

Daniel Drake (2):
      mac80211: ERP IE handling improvements
      mac80211: improved 802.11g CTS protection

Hong Liu (1):
      mac80211: add support for iwlist channel

Johannes Berg (10):
      mac80211: show transmitted frames on monitor interfaces
      mac80211: remove ieee80211_msg_passive_scan
      mac80211: remove ieee80211_set_aid_for_sta
      mac80211: separate monitor/subif_start_xmit
      mac80211: kill rate control ioctls
      mac80211: kill antenna select ioctls
      mac80211: remove PRISM2_PARAM_DROP_UNENCRYPTED ioctl
      mac80211: kill PRISM2_PARAM_CLEAR_KEYS
      mac80211: conserve stack space due to padding
      mac80211: clarify some mac80211 things

Larry Finger (1):
      mac80211: Implementation of SIOCSIWRATE

 Documentation/networking/mac80211-injection.txt |   59 +++
 Documentation/networking/radiotap-headers.txt   |  152 ++++++++
 include/linux/ieee80211.h                       |   11 +
 include/net/cfg80211.h                          |   38 ++
 include/net/mac80211.h                          |   22 +-
 net/mac80211/debugfs_netdev.c                   |    2 +-
 net/mac80211/hostapd_ioctl.h                    |    8 -
 net/mac80211/ieee80211.c                        |  449 ++++++++++++++++++-----
 net/mac80211/ieee80211_common.h                 |    9 +-
 net/mac80211/ieee80211_i.h                      |   14 +-
 net/mac80211/ieee80211_iface.c                  |    3 +
 net/mac80211/ieee80211_ioctl.c                  |  240 ++++---------
 net/mac80211/ieee80211_sta.c                    |   98 ++++--
 net/mac80211/rc80211_simple.c                   |    8 +-
 net/wireless/Makefile                           |    2 +-
 net/wireless/radiotap.c                         |  257 +++++++++++++
 16 files changed, 1050 insertions(+), 322 deletions(-)
 create mode 100644 Documentation/networking/mac80211-injection.txt
 create mode 100644 Documentation/networking/radiotap-headers.txt
 create mode 100644 net/wireless/radiotap.c

diff --git a/Documentation/networking/mac80211-injection.txt b/Documentation/networking/mac80211-injection.txt
new file mode 100644
index 0000000..53ef7a0
--- /dev/null
+++ b/Documentation/networking/mac80211-injection.txt
@@ -0,0 +1,59 @@
+How to use packet injection with mac80211
+=========================================
+
+mac80211 now allows arbitrary packets to be injected down any Monitor Mode
+interface from userland.  The packet you inject needs to be composed in the
+following format:
+
+ [ radiotap header  ]
+ [ ieee80211 header ]
+ [ payload ]
+
+The radiotap format is discussed in
+./Documentation/networking/radiotap-headers.txt.
+
+Despite 13 radiotap argument types are currently defined, most only make sense
+to appear on received packets.  Currently three kinds of argument are used by
+the injection code, although it knows to skip any other arguments that are
+present (facilitating replay of captured radiotap headers directly):
+
+ - IEEE80211_RADIOTAP_RATE - u8 arg in 500kbps units (0x02 --> 1Mbps)
+
+ - IEEE80211_RADIOTAP_ANTENNA - u8 arg, 0x00 = ant1, 0x01 = ant2
+
+ - IEEE80211_RADIOTAP_DBM_TX_POWER - u8 arg, dBm
+
+Here is an example valid radiotap header defining these three parameters
+
+	0x00, 0x00, // <-- radiotap version
+	0x0b, 0x00, // <- radiotap header length
+	0x04, 0x0c, 0x00, 0x00, // <-- bitmap
+	0x6c, // <-- rate
+	0x0c, //<-- tx power
+	0x01 //<-- antenna
+
+The ieee80211 header follows immediately afterwards, looking for example like
+this:
+
+	0x08, 0x01, 0x00, 0x00,
+	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
+	0x13, 0x22, 0x33, 0x44, 0x55, 0x66,
+	0x13, 0x22, 0x33, 0x44, 0x55, 0x66,
+	0x10, 0x86
+
+Then lastly there is the payload.
+
+After composing the packet contents, it is sent by send()-ing it to a logical
+mac80211 interface that is in Monitor mode.  Libpcap can also be used,
+(which is easier than doing the work to bind the socket to the right
+interface), along the following lines:
+
+	ppcap = pcap_open_live(szInterfaceName, 800, 1, 20, szErrbuf);
+...
+	r = pcap_inject(ppcap, u8aSendBuffer, nLength);
+
+You can also find sources for a complete inject test applet here:
+
+http://penumbra.warmcat.com/_twk/tiki-index.php?page=packetspammer
+
+Andy Green <andy-/Zus8d0mwwtBDgjK7y7TUQ@public.gmane.org>
diff --git a/Documentation/networking/radiotap-headers.txt b/Documentation/networking/radiotap-headers.txt
new file mode 100644
index 0000000..953331c
--- /dev/null
+++ b/Documentation/networking/radiotap-headers.txt
@@ -0,0 +1,152 @@
+How to use radiotap headers
+===========================
+
+Pointer to the radiotap include file
+------------------------------------
+
+Radiotap headers are variable-length and extensible, you can get most of the
+information you need to know on them from:
+
+./include/net/ieee80211_radiotap.h
+
+This document gives an overview and warns on some corner cases.
+
+
+Structure of the header
+-----------------------
+
+There is a fixed portion at the start which contains a u32 bitmap that defines
+if the possible argument associated with that bit is present or not.  So if b0
+of the it_present member of ieee80211_radiotap_header is set, it means that
+the header for argument index 0 (IEEE80211_RADIOTAP_TSFT) is present in the
+argument area.
+
+   < 8-byte ieee80211_radiotap_header >
+   [ <possible argument bitmap extensions ... > ]
+   [ <argument> ... ]
+
+At the moment there are only 13 possible argument indexes defined, but in case
+we run out of space in the u32 it_present member, it is defined that b31 set
+indicates that there is another u32 bitmap following (shown as "possible
+argument bitmap extensions..." above), and the start of the arguments is moved
+forward 4 bytes each time.
+
+Note also that the it_len member __le16 is set to the total number of bytes
+covered by the ieee80211_radiotap_header and any arguments following.
+
+
+Requirements for arguments
+--------------------------
+
+After the fixed part of the header, the arguments follow for each argument
+index whose matching bit is set in the it_present member of
+ieee80211_radiotap_header.
+
+ - the arguments are all stored little-endian!
+
+ - the argument payload for a given argument index has a fixed size.  So
+   IEEE80211_RADIOTAP_TSFT being present always indicates an 8-byte argument is
+   present.  See the comments in ./include/net/ieee80211_radiotap.h for a nice
+   breakdown of all the argument sizes
+
+ - the arguments must be aligned to a boundary of the argument size using
+   padding.  So a u16 argument must start on the next u16 boundary if it isn't
+   already on one, a u32 must start on the next u32 boundary and so on.
+
+ - "alignment" is relative to the start of the ieee80211_radiotap_header, ie,
+   the first byte of the radiotap header.  The absolute alignment of that first
+   byte isn't defined.  So even if the whole radiotap header is starting at, eg,
+   address 0x00000003, still the first byte of the radiotap header is treated as
+   0 for alignment purposes.
+
+ - the above point that there may be no absolute alignment for multibyte
+   entities in the fixed radiotap header or the argument region means that you
+   have to take special evasive action when trying to access these multibyte
+   entities.  Some arches like Blackfin cannot deal with an attempt to
+   dereference, eg, a u16 pointer that is pointing to an odd address.  Instead
+   you have to use a kernel API get_unaligned() to dereference the pointer,
+   which will do it bytewise on the arches that require that.
+
+ - The arguments for a given argument index can be a compound of multiple types
+   together.  For example IEEE80211_RADIOTAP_CHANNEL has an argument payload
+   consisting of two u16s of total length 4.  When this happens, the padding
+   rule is applied dealing with a u16, NOT dealing with a 4-byte single entity.
+
+
+Example valid radiotap header
+-----------------------------
+
+	0x00, 0x00, // <-- radiotap version + pad byte
+	0x0b, 0x00, // <- radiotap header length
+	0x04, 0x0c, 0x00, 0x00, // <-- bitmap
+	0x6c, // <-- rate (in 500kHz units)
+	0x0c, //<-- tx power
+	0x01 //<-- antenna
+
+
+Using the Radiotap Parser
+-------------------------
+
+If you are having to parse a radiotap struct, you can radically simplify the
+job by using the radiotap parser that lives in net/wireless/radiotap.c and has
+its prototypes available in include/net/cfg80211.h.  You use it like this:
+
+#include <net/cfg80211.h>
+
+/* buf points to the start of the radiotap header part */
+
+int MyFunction(u8 * buf, int buflen)
+{
+	int pkt_rate_100kHz = 0, antenna = 0, pwr = 0;
+	struct ieee80211_radiotap_iterator iterator;
+	int ret = ieee80211_radiotap_iterator_init(&iterator, buf, buflen);
+
+	while (!ret) {
+
+		ret = ieee80211_radiotap_iterator_next(&iterator);
+
+		if (ret)
+			continue;
+
+		/* see if this argument is something we can use */
+
+		switch (iterator.this_arg_index) {
+		/*
+		 * You must take care when dereferencing iterator.this_arg
+		 * for multibyte types... the pointer is not aligned.  Use
+		 * get_unaligned((type *)iterator.this_arg) to dereference
+		 * iterator.this_arg for type "type" safely on all arches.
+		 */
+		case IEEE80211_RADIOTAP_RATE:
+			/* radiotap "rate" u8 is in
+			 * 500kbps units, eg, 0x02=1Mbps
+			 */
+			pkt_rate_100kHz = (*iterator.this_arg) * 5;
+			break;
+
+		case IEEE80211_RADIOTAP_ANTENNA:
+			/* radiotap uses 0 for 1st ant */
+			antenna = *iterator.this_arg);
+			break;
+
+		case IEEE80211_RADIOTAP_DBM_TX_POWER:
+			pwr = *iterator.this_arg;
+			break;
+
+		default:
+			break;
+		}
+	}  /* while more rt headers */
+
+	if (ret != -ENOENT)
+		return TXRX_DROP;
+
+	/* discard the radiotap header part */
+	buf += iterator.max_length;
+	buflen -= iterator.max_length;
+
+	...
+
+}
+
+Andy Green <andy-/Zus8d0mwwtBDgjK7y7TUQ@public.gmane.org>
diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index ecd61e8..272f8c8 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -227,6 +227,17 @@ struct ieee80211_cts {
 #define WLAN_CAPABILITY_SHORT_SLOT_TIME	(1<<10)
 #define WLAN_CAPABILITY_DSSS_OFDM	(1<<13)
 
+/* 802.11g ERP information element */
+#define WLAN_ERP_NON_ERP_PRESENT (1<<0)
+#define WLAN_ERP_USE_PROTECTION (1<<1)
+#define WLAN_ERP_BARKER_PREAMBLE (1<<2)
+
+/* WLAN_ERP_BARKER_PREAMBLE values */
+enum {
+	WLAN_ERP_PREAMBLE_SHORT = 0,
+	WLAN_ERP_PREAMBLE_LONG = 1,
+};
+
 /* Status codes */
 enum ieee80211_statuscode {
 	WLAN_STATUS_SUCCESS = 0,
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 88171f8..7edaef6 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -11,6 +11,44 @@
  * Copyright 2006 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
  */
 
+
+/* Radiotap header iteration
+ *   implemented in net/wireless/radiotap.c
+ *   docs in Documentation/networking/radiotap-headers.txt
+ */
+/**
+ * struct ieee80211_radiotap_iterator - tracks walk thru present radiotap args
+ * @rtheader: pointer to the radiotap header we are walking through
+ * @max_length: length of radiotap header in cpu byte ordering
+ * @this_arg_index: IEEE80211_RADIOTAP_... index of current arg
+ * @this_arg: pointer to current radiotap arg
+ * @arg_index: internal next argument index
+ * @arg: internal next argument pointer
+ * @next_bitmap: internal pointer to next present u32
+ * @bitmap_shifter: internal shifter for curr u32 bitmap, b0 set == arg present
+ */
+
+struct ieee80211_radiotap_iterator {
+	struct ieee80211_radiotap_header *rtheader;
+	int max_length;
+	int this_arg_index;
+	u8 *this_arg;
+
+	int arg_index;
+	u8 *arg;
+	__le32 *next_bitmap;
+	u32 bitmap_shifter;
+};
+
+extern int ieee80211_radiotap_iterator_init(
+   struct ieee80211_radiotap_iterator *iterator,
+   struct ieee80211_radiotap_header *radiotap_header,
+   int max_length);
+
+extern int ieee80211_radiotap_iterator_next(
+   struct ieee80211_radiotap_iterator *iterator);
+
+
 /* from net/wireless.h */
 struct wiphy;
 
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index a7f122b..c34fd9a 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -347,9 +347,16 @@ enum ieee80211_if_types {
  * @mac_addr: pointer to MAC address of the interface. This pointer is valid
  *	until the interface is removed (i.e. it cannot be used after
  *	remove_interface() callback was called for this interface).
+ *	This pointer will be %NULL for monitor interfaces, be careful.
  *
  * This structure is used in add_interface() and remove_interface()
  * callbacks of &struct ieee80211_hw.
+ *
+ * When you allow multiple interfaces to be added to your PHY, take care
+ * that the hardware can actually handle multiple MAC addresses. However,
+ * also take care that when there's no interface left with mac_addr != %NULL
+ * you remove the MAC address from the device to avoid acknowledging packets
+ * in pure monitor mode.
  */
 struct ieee80211_if_init_conf {
 	int if_id;
@@ -574,10 +581,11 @@ struct ieee80211_ops {
 	 * to returning zero. By returning non-zero addition of the interface
 	 * is inhibited. Unless monitor_during_oper is set, it is guaranteed
 	 * that monitor interfaces and normal interfaces are mutually
-	 * exclusive. The open() handler is called after add_interface()
-	 * if this is the first device added. At least one of the open()
-	 * open() and add_interface() callbacks has to be assigned. If
-	 * add_interface() is NULL, one STA interface is permitted only. */
+	 * exclusive. If assigned, the open() handler is called after
+	 * add_interface() if this is the first device added. The
+	 * add_interface() callback has to be assigned because it is the only
+	 * way to obtain the requested MAC address for any interface.
+	 */
 	int (*add_interface)(struct ieee80211_hw *hw,
 			     struct ieee80211_if_init_conf *conf);
 
@@ -921,12 +929,6 @@ struct sk_buff *
 ieee80211_get_buffered_bc(struct ieee80211_hw *hw, int if_id,
 			  struct ieee80211_tx_control *control);
 
-/* Low level drivers that have their own MLME and MAC indicate
- * the aid for an associating station with this call */
-int ieee80211_set_aid_for_sta(struct ieee80211_hw *hw,
-			      u8 *peer_address, u16 aid);
-
-
 /* Given an sk_buff with a raw 802.11 header at the data pointer this function
  * returns the 802.11 header length in bytes (not including encryption
  * headers). If the data in the sk_buff is too short to contain a valid 802.11
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index 9e39646..a3e01d7 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -118,7 +118,7 @@ static ssize_t ieee80211_if_fmt_flags(
 			 sdata->u.sta.authenticated ? "AUTH\n" : "",
 			 sdata->u.sta.associated ? "ASSOC\n" : "",
 			 sdata->u.sta.probereq_poll ? "PROBEREQ POLL\n" : "",
-			 sdata->u.sta.use_protection ? "CTS prot\n" : "");
+			 sdata->use_protection ? "CTS prot\n" : "");
 }
 __IEEE80211_IF_FILE(flags);
 
diff --git a/net/mac80211/hostapd_ioctl.h b/net/mac80211/hostapd_ioctl.h
index 34fa128..52da513 100644
--- a/net/mac80211/hostapd_ioctl.h
+++ b/net/mac80211/hostapd_ioctl.h
@@ -26,24 +26,16 @@
  * mess shall be deleted completely. */
 enum {
 	PRISM2_PARAM_IEEE_802_1X = 23,
-	PRISM2_PARAM_ANTSEL_TX = 24,
-	PRISM2_PARAM_ANTSEL_RX = 25,
 
 	/* Instant802 additions */
 	PRISM2_PARAM_CTS_PROTECT_ERP_FRAMES = 1001,
-	PRISM2_PARAM_DROP_UNENCRYPTED = 1002,
 	PRISM2_PARAM_PREAMBLE = 1003,
 	PRISM2_PARAM_SHORT_SLOT_TIME = 1006,
 	PRISM2_PARAM_NEXT_MODE = 1008,
-	PRISM2_PARAM_CLEAR_KEYS = 1009,
 	PRISM2_PARAM_RADIO_ENABLED = 1010,
 	PRISM2_PARAM_ANTENNA_MODE = 1013,
 	PRISM2_PARAM_STAT_TIME = 1016,
 	PRISM2_PARAM_STA_ANTENNA_SEL = 1017,
-	PRISM2_PARAM_FORCE_UNICAST_RATE = 1018,
-	PRISM2_PARAM_RATE_CTRL_NUM_UP = 1019,
-	PRISM2_PARAM_RATE_CTRL_NUM_DOWN = 1020,
-	PRISM2_PARAM_MAX_RATECTRL_RATE = 1021,
 	PRISM2_PARAM_TX_POWER_REDUCTION = 1022,
 	PRISM2_PARAM_KEY_TX_RX_THRESHOLD = 1024,
 	PRISM2_PARAM_DEFAULT_WEP_ONLY = 1026,
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 4e84f24..2ddf4ef 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -24,6 +24,7 @@
 #include <linux/compiler.h>
 #include <linux/bitmap.h>
 #include <net/cfg80211.h>
+#include <asm/unaligned.h>
 
 #include "ieee80211_common.h"
 #include "ieee80211_i.h"
@@ -56,6 +57,17 @@ static const unsigned char eapol_header[] =
 	{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00, 0x88, 0x8e };
 
 
+/*
+ * For seeing transmitted packets on monitor interfaces
+ * we have a radiotap header too.
+ */
+struct ieee80211_tx_status_rtap_hdr {
+	struct ieee80211_radiotap_header hdr;
+	__le16 tx_flags;
+	u8 data_retries;
+} __attribute__ ((packed));
+
+
 static inline void ieee80211_include_sequence(struct ieee80211_sub_if_data *sdata,
 					      struct ieee80211_hdr *hdr)
 {
@@ -430,7 +442,7 @@ ieee80211_tx_h_rate_ctrl(struct ieee80211_txrx_data *tx)
 	if (!tx->u.tx.rate)
 		return TXRX_DROP;
 	if (tx->u.tx.mode->mode == MODE_IEEE80211G &&
-	    tx->local->cts_protect_erp_frames && tx->fragmented &&
+	    tx->sdata->use_protection && tx->fragmented &&
 	    extra.nonerp) {
 		tx->u.tx.last_frag_rate = tx->u.tx.rate;
 		tx->u.tx.probe_last_frag = extra.probe ? 1 : 0;
@@ -528,7 +540,7 @@ ieee80211_tx_h_fragment(struct ieee80211_txrx_data *tx)
 		/* reserve enough extra head and tail room for possible
 		 * encryption */
 		frag = frags[i] =
-			dev_alloc_skb(tx->local->hw.extra_tx_headroom +
+			dev_alloc_skb(tx->local->tx_headroom +
 				      frag_threshold +
 				      IEEE80211_ENCRYPT_HEADROOM +
 				      IEEE80211_ENCRYPT_TAILROOM);
@@ -537,8 +549,8 @@ ieee80211_tx_h_fragment(struct ieee80211_txrx_data *tx)
 		/* Make sure that all fragments use the same priority so
 		 * that they end up using the same TX queue */
 		frag->priority = first->priority;
-		skb_reserve(frag, tx->local->hw.extra_tx_headroom +
-			IEEE80211_ENCRYPT_HEADROOM);
+		skb_reserve(frag, tx->local->tx_headroom +
+				  IEEE80211_ENCRYPT_HEADROOM);
 		fhdr = (struct ieee80211_hdr *) skb_put(frag, hdrlen);
 		memcpy(fhdr, first->data, hdrlen);
 		if (i == num_fragm - 2)
@@ -856,8 +868,7 @@ ieee80211_tx_h_misc(struct ieee80211_txrx_data *tx)
 	 * for the frame. */
 	if (mode->mode == MODE_IEEE80211G &&
 	    (tx->u.tx.rate->flags & IEEE80211_RATE_ERP) &&
-	    tx->u.tx.unicast &&
-	    tx->local->cts_protect_erp_frames &&
+	    tx->u.tx.unicast && tx->sdata->use_protection &&
 	    !(control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
 		control->flags |= IEEE80211_TXCTL_USE_CTS_PROTECT;
 
@@ -1118,7 +1129,138 @@ ieee80211_tx_h_ps_buf(struct ieee80211_txrx_data *tx)
 }
 
 
-static void inline
+/*
+ * deal with packet injection down monitor interface
+ * with Radiotap Header -- only called for monitor mode interface
+ */
+
+static ieee80211_txrx_result
+__ieee80211_parse_tx_radiotap(
+	struct ieee80211_txrx_data *tx,
+	struct sk_buff *skb, struct ieee80211_tx_control *control)
+{
+	/*
+	 * this is the moment to interpret and discard the radiotap header that
+	 * must be at the start of the packet injected in Monitor mode
+	 *
+	 * Need to take some care with endian-ness since radiotap
+	 * args are little-endian
+	 */
+
+	struct ieee80211_radiotap_iterator iterator;
+	struct ieee80211_radiotap_header *rthdr =
+		(struct ieee80211_radiotap_header *) skb->data;
+	struct ieee80211_hw_mode *mode = tx->local->hw.conf.mode;
+	int ret = ieee80211_radiotap_iterator_init(&iterator, rthdr, skb->len);
+
+	/*
+	 * default control situation for all injected packets
+	 * FIXME: this does not suit all usage cases, expand to allow control
+	 */
+
+	control->retry_limit = 1; /* no retry */
+	control->key_idx = -1; /* no encryption key */
+	control->flags &= ~(IEEE80211_TXCTL_USE_RTS_CTS |
+			    IEEE80211_TXCTL_USE_CTS_PROTECT);
+	control->flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT |
+			  IEEE80211_TXCTL_NO_ACK;
+	control->antenna_sel_tx = 0; /* default to default antenna */
+
+	/*
+	 * for every radiotap entry that is present
+	 * (ieee80211_radiotap_iterator_next returns -ENOENT when no more
+	 * entries present, or -EINVAL on error)
+	 */
+
+	while (!ret) {
+		int i, target_rate;
+
+		ret = ieee80211_radiotap_iterator_next(&iterator);
+
+		if (ret)
+			continue;
+
+		/* see if this argument is something we can use */
+		switch (iterator.this_arg_index) {
+		/*
+		 * You must take care when dereferencing iterator.this_arg
+		 * for multibyte types... the pointer is not aligned.  Use
+		 * get_unaligned((type *)iterator.this_arg) to dereference
+		 * iterator.this_arg for type "type" safely on all arches.
+		*/
+		case IEEE80211_RADIOTAP_RATE:
+			/*
+			 * radiotap rate u8 is in 500kbps units eg, 0x02=1Mbps
+			 * ieee80211 rate int is in 100kbps units eg, 0x0a=1Mbps
+			 */
+			target_rate = (*iterator.this_arg) * 5;
+			for (i = 0; i < mode->num_rates; i++) {
+				struct ieee80211_rate *r = &mode->rates[i];
+
+				if (r->rate > target_rate)
+					continue;
+
+				control->rate = r;
+
+				if (r->flags & IEEE80211_RATE_PREAMBLE2)
+					control->tx_rate = r->val2;
+				else
+					control->tx_rate = r->val;
+
+				/* end on exact match */
+				if (r->rate == target_rate)
+					i = mode->num_rates;
+			}
+			break;
+
+		case IEEE80211_RADIOTAP_ANTENNA:
+			/*
+			 * radiotap uses 0 for 1st ant, mac80211 is 1 for
+			 * 1st ant
+			 */
+			control->antenna_sel_tx = (*iterator.this_arg) + 1;
+			break;
+
+		case IEEE80211_RADIOTAP_DBM_TX_POWER:
+			control->power_level = *iterator.this_arg;
+			break;
+
+		case IEEE80211_RADIOTAP_FLAGS:
+			if (*iterator.this_arg & IEEE80211_RADIOTAP_F_FCS) {
+				/*
+				 * this indicates that the skb we have been
+				 * handed has the 32-bit FCS CRC at the end...
+				 * we should react to that by snipping it off
+				 * because it will be recomputed and added
+				 * on transmission
+				 */
+				if (skb->len < (iterator.max_length + FCS_LEN))
+					return TXRX_DROP;
+
+				skb_trim(skb, skb->len - FCS_LEN);
+			}
+			break;
+
+		default:
+			break;
+		}
+	}
+
+	if (ret != -ENOENT) /* ie, if we didn't simply run out of fields */
+		return TXRX_DROP;
+
+	/*
+	 * remove the radiotap header
+	 * iterator->max_length was sanity-checked against
+	 * skb->len by iterator init
+	 */
+	skb_pull(skb, iterator.max_length);
+
+	return TXRX_CONTINUE;
+}
+
+
+static ieee80211_txrx_result inline
 __ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
 		       struct sk_buff *skb,
 		       struct net_device *dev,
@@ -1126,6 +1268,9 @@ __ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	struct ieee80211_sub_if_data *sdata;
+	ieee80211_txrx_result res = TXRX_CONTINUE;
+
 	int hdrlen;
 
 	memset(tx, 0, sizeof(*tx));
@@ -1135,7 +1280,32 @@ __ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
 	tx->sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	tx->sta = sta_info_get(local, hdr->addr1);
 	tx->fc = le16_to_cpu(hdr->frame_control);
+
+	/*
+	 * set defaults for things that can be set by
+	 * injected radiotap headers
+	 */
 	control->power_level = local->hw.conf.power_level;
+	control->antenna_sel_tx = local->hw.conf.antenna_sel_tx;
+	if (local->sta_antenna_sel != STA_ANTENNA_SEL_AUTO && tx->sta)
+		control->antenna_sel_tx = tx->sta->antenna_sel_tx;
+
+	/* process and remove the injection radiotap header */
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	if (unlikely(sdata->type == IEEE80211_IF_TYPE_MNTR)) {
+		if (__ieee80211_parse_tx_radiotap(tx, skb, control) ==
+								TXRX_DROP) {
+			return TXRX_DROP;
+		}
+		/*
+		 * we removed the radiotap header after this point,
+		 * we filled control with what we could use
+		 * set to the actual ieee header now
+		 */
+		hdr = (struct ieee80211_hdr *) skb->data;
+		res = TXRX_QUEUED; /* indication it was monitor packet */
+	}
+
 	tx->u.tx.control = control;
 	tx->u.tx.unicast = !is_multicast_ether_addr(hdr->addr1);
 	if (is_multicast_ether_addr(hdr->addr1))
@@ -1152,9 +1322,6 @@ __ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
 		control->flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
 		tx->sta->clear_dst_mask = 0;
 	}
-	control->antenna_sel_tx = local->hw.conf.antenna_sel_tx;
-	if (local->sta_antenna_sel != STA_ANTENNA_SEL_AUTO && tx->sta)
-		control->antenna_sel_tx = tx->sta->antenna_sel_tx;
 	hdrlen = ieee80211_get_hdrlen(tx->fc);
 	if (skb->len > hdrlen + sizeof(rfc1042_header) + 2) {
 		u8 *pos = &skb->data[hdrlen + sizeof(rfc1042_header)];
@@ -1162,6 +1329,7 @@ __ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
 	}
 	control->flags |= IEEE80211_TXCTL_FIRST_FRAGMENT;
 
+	return res;
 }
 
 static int inline is_ieee80211_device(struct net_device *dev,
@@ -1274,7 +1442,7 @@ static int ieee80211_tx(struct net_device *dev, struct sk_buff *skb,
 	struct sta_info *sta;
 	ieee80211_tx_handler *handler;
 	struct ieee80211_txrx_data tx;
-	ieee80211_txrx_result res = TXRX_DROP;
+	ieee80211_txrx_result res = TXRX_DROP, res_prepare;
 	int ret, i;
 
 	WARN_ON(__ieee80211_queue_pending(local, control->queue));
@@ -1284,15 +1452,26 @@ static int ieee80211_tx(struct net_device *dev, struct sk_buff *skb,
 		return 0;
 	}
 
-	__ieee80211_tx_prepare(&tx, skb, dev, control);
+	res_prepare = __ieee80211_tx_prepare(&tx, skb, dev, control);
+
+	if (res_prepare == TXRX_DROP) {
+		dev_kfree_skb(skb);
+		return 0;
+	}
+
 	sta = tx.sta;
 	tx.u.tx.mgmt_interface = mgmt;
 	tx.u.tx.mode = local->hw.conf.mode;
 
-	for (handler = local->tx_handlers; *handler != NULL; handler++) {
-		res = (*handler)(&tx);
-		if (res != TXRX_CONTINUE)
-			break;
+	if (res_prepare == TXRX_QUEUED) { /* if it was an injected packet */
+		res = TXRX_CONTINUE;
+	} else {
+		for (handler = local->tx_handlers; *handler != NULL;
+		     handler++) {
+			res = (*handler)(&tx);
+			if (res != TXRX_CONTINUE)
+				break;
+		}
 	}
 
 	skb = tx.skb; /* handlers are allowed to change skb */
@@ -1467,8 +1646,7 @@ static int ieee80211_master_start_xmit(struct sk_buff *skb,
 	}
 	osdata = IEEE80211_DEV_TO_SUB_IF(odev);
 
-	headroom = osdata->local->hw.extra_tx_headroom +
-		IEEE80211_ENCRYPT_HEADROOM;
+	headroom = osdata->local->tx_headroom + IEEE80211_ENCRYPT_HEADROOM;
 	if (skb_headroom(skb) < headroom) {
 		if (pskb_expand_head(skb, headroom, 0, GFP_ATOMIC)) {
 			dev_kfree_skb(skb);
@@ -1494,6 +1672,56 @@ static int ieee80211_master_start_xmit(struct sk_buff *skb,
 }
 
 
+int ieee80211_monitor_start_xmit(struct sk_buff *skb,
+				 struct net_device *dev)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_tx_packet_data *pkt_data;
+	struct ieee80211_radiotap_header *prthdr =
+		(struct ieee80211_radiotap_header *)skb->data;
+	u16 len;
+
+	/*
+	 * there must be a radiotap header at the
+	 * start in this case
+	 */
+	if (unlikely(prthdr->it_version)) {
+		/* only version 0 is supported */
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	skb->dev = local->mdev;
+
+	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
+	memset(pkt_data, 0, sizeof(*pkt_data));
+	pkt_data->ifindex = dev->ifindex;
+	pkt_data->mgmt_iface = 0;
+	pkt_data->do_not_encrypt = 1;
+
+	/* above needed because we set skb device to master */
+
+	/*
+	 * fix up the pointers accounting for the radiotap
+	 * header still being in there.  We are being given
+	 * a precooked IEEE80211 header so no need for
+	 * normal processing
+	 */
+	len = le16_to_cpu(get_unaligned(&prthdr->it_len));
+	skb_set_mac_header(skb, len);
+	skb_set_network_header(skb, len + sizeof(struct ieee80211_hdr));
+	skb_set_transport_header(skb, len + sizeof(struct ieee80211_hdr));
+
+	/*
+	 * pass the radiotap header up to
+	 * the next stage intact
+	 */
+	dev_queue_xmit(skb);
+
+	return NETDEV_TX_OK;
+}
+
+
 /**
  * ieee80211_subif_start_xmit - netif start_xmit function for Ethernet-type
  * subinterfaces (wlan#, WDS, and VLAN interfaces)
@@ -1509,8 +1737,8 @@ static int ieee80211_master_start_xmit(struct sk_buff *skb,
  * encapsulated packet will then be passed to master interface, wlan#.11, for
  * transmission (through low-level driver).
  */
-static int ieee80211_subif_start_xmit(struct sk_buff *skb,
-				      struct net_device *dev)
+int ieee80211_subif_start_xmit(struct sk_buff *skb,
+			       struct net_device *dev)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_tx_packet_data *pkt_data;
@@ -1619,7 +1847,7 @@ static int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	 * build in headroom in __dev_alloc_skb() (linux/skbuff.h) and
 	 * alloc_skb() (net/core/skbuff.c)
 	 */
-	head_need = hdrlen + encaps_len + local->hw.extra_tx_headroom;
+	head_need = hdrlen + encaps_len + local->tx_headroom;
 	head_need -= skb_headroom(skb);
 
 	/* We are going to modify skb data, so make a copy of it if happens to
@@ -1658,7 +1886,7 @@ static int ieee80211_subif_start_xmit(struct sk_buff *skb,
 
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
-	pkt_data->ifindex = sdata->dev->ifindex;
+	pkt_data->ifindex = dev->ifindex;
 	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
 	pkt_data->do_not_encrypt = no_encrypt;
 
@@ -1706,9 +1934,9 @@ ieee80211_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return 0;
 	}
 
-	if (skb_headroom(skb) < sdata->local->hw.extra_tx_headroom) {
-		if (pskb_expand_head(skb,
-		    sdata->local->hw.extra_tx_headroom, 0, GFP_ATOMIC)) {
+	if (skb_headroom(skb) < sdata->local->tx_headroom) {
+		if (pskb_expand_head(skb, sdata->local->tx_headroom,
+				     0, GFP_ATOMIC)) {
 			dev_kfree_skb(skb);
 			return 0;
 		}
@@ -1847,12 +2075,12 @@ struct sk_buff * ieee80211_beacon_get(struct ieee80211_hw *hw, int if_id,
 	bh_len = ap->beacon_head_len;
 	bt_len = ap->beacon_tail_len;
 
-	skb = dev_alloc_skb(local->hw.extra_tx_headroom +
+	skb = dev_alloc_skb(local->tx_headroom +
 		bh_len + bt_len + 256 /* maximum TIM len */);
 	if (!skb)
 		return NULL;
 
-	skb_reserve(skb, local->hw.extra_tx_headroom);
+	skb_reserve(skb, local->tx_headroom);
 	memcpy(skb_put(skb, bh_len), b_head, bh_len);
 
 	ieee80211_include_sequence(sdata, (struct ieee80211_hdr *)skb->data);
@@ -2376,8 +2604,7 @@ static void ieee80211_start_hard_monitor(struct ieee80211_local *local)
 	struct ieee80211_if_init_conf conf;
 
 	if (local->open_count && local->open_count == local->monitors &&
-	    !(local->hw.flags & IEEE80211_HW_MONITOR_DURING_OPER) &&
-	    local->ops->add_interface) {
+	    !(local->hw.flags & IEEE80211_HW_MONITOR_DURING_OPER)) {
 		conf.if_id = -1;
 		conf.type = IEEE80211_IF_TYPE_MNTR;
 		conf.mac_addr = NULL;
@@ -2420,21 +2647,14 @@ static int ieee80211_open(struct net_device *dev)
 	}
 	ieee80211_start_soft_monitor(local);
 
-	if (local->ops->add_interface) {
-		conf.if_id = dev->ifindex;
-		conf.type = sdata->type;
-		conf.mac_addr = dev->dev_addr;
-		res = local->ops->add_interface(local_to_hw(local), &conf);
-		if (res) {
-			if (sdata->type == IEEE80211_IF_TYPE_MNTR)
-				ieee80211_start_hard_monitor(local);
-			return res;
-		}
-	} else {
-		if (sdata->type != IEEE80211_IF_TYPE_STA)
-			return -EOPNOTSUPP;
-		if (local->open_count > 0)
-			return -ENOBUFS;
+	conf.if_id = dev->ifindex;
+	conf.type = sdata->type;
+	conf.mac_addr = dev->dev_addr;
+	res = local->ops->add_interface(local_to_hw(local), &conf);
+	if (res) {
+		if (sdata->type == IEEE80211_IF_TYPE_MNTR)
+			ieee80211_start_hard_monitor(local);
+		return res;
 	}
 
 	if (local->open_count == 0) {
@@ -2941,34 +3161,6 @@ int ieee80211_radar_status(struct ieee80211_hw *hw, int channel,
 }
 EXPORT_SYMBOL(ieee80211_radar_status);
 
-int ieee80211_set_aid_for_sta(struct ieee80211_hw *hw, u8 *peer_address,
-			      u16 aid)
-{
-	struct sk_buff *skb;
-	struct ieee80211_msg_set_aid_for_sta *msg;
-	struct ieee80211_local *local = hw_to_local(hw);
-
-	/* unlikely because if this event only happens for APs,
-	 * which require an open ap device. */
-	if (unlikely(!local->apdev))
-		return 0;
-
-	skb = dev_alloc_skb(sizeof(struct ieee80211_frame_info) +
-			    sizeof(struct ieee80211_msg_set_aid_for_sta));
-
-	if (!skb)
-		return -ENOMEM;
-	skb_reserve(skb, sizeof(struct ieee80211_frame_info));
-
-	msg = (struct ieee80211_msg_set_aid_for_sta *)
-		skb_put(skb, sizeof(struct ieee80211_msg_set_aid_for_sta));
-	memcpy(msg->sta_address, peer_address, ETH_ALEN);
-	msg->aid = aid;
-
-	ieee80211_rx_mgmt(local, skb, NULL, ieee80211_msg_set_aid_for_sta);
-	return 0;
-}
-EXPORT_SYMBOL(ieee80211_set_aid_for_sta);
 
 static void ap_sta_ps_start(struct net_device *dev, struct sta_info *sta)
 {
@@ -4284,6 +4476,9 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb,
 	struct ieee80211_local *local = hw_to_local(hw);
 	u16 frag, type;
 	u32 msg_type;
+	struct ieee80211_tx_status_rtap_hdr *rthdr;
+	struct ieee80211_sub_if_data *sdata;
+	int monitors;
 
 	if (!status) {
 		printk(KERN_ERR
@@ -4395,27 +4590,100 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb,
 			local->dot11FailedCount++;
 	}
 
-	if (!(status->control.flags & IEEE80211_TXCTL_REQ_TX_STATUS)
-	    || unlikely(!local->apdev)) {
+	msg_type = (status->flags & IEEE80211_TX_STATUS_ACK) ?
+		ieee80211_msg_tx_callback_ack : ieee80211_msg_tx_callback_fail;
+
+	/* this was a transmitted frame, but now we want to reuse it */
+	skb_orphan(skb);
+
+	if ((status->control.flags & IEEE80211_TXCTL_REQ_TX_STATUS) &&
+	    local->apdev) {
+		if (local->monitors) {
+			skb2 = skb_clone(skb, GFP_ATOMIC);
+		} else {
+			skb2 = skb;
+			skb = NULL;
+		}
+
+		if (skb2)
+			/* Send frame to hostapd */
+			ieee80211_rx_mgmt(local, skb2, NULL, msg_type);
+
+		if (!skb)
+			return;
+	}
+
+	if (!local->monitors) {
 		dev_kfree_skb(skb);
 		return;
 	}
 
-	msg_type = (status->flags & IEEE80211_TX_STATUS_ACK) ?
-		ieee80211_msg_tx_callback_ack : ieee80211_msg_tx_callback_fail;
+	/* send frame to monitor interfaces now */
 
-	/* skb was the original skb used for TX. Clone it and give the clone
-	 * to netif_rx(). Free original skb. */
-	skb2 = skb_copy(skb, GFP_ATOMIC);
-	if (!skb2) {
+	if (skb_headroom(skb) < sizeof(*rthdr)) {
+		printk(KERN_ERR "ieee80211_tx_status: headroom too small\n");
 		dev_kfree_skb(skb);
 		return;
 	}
-	dev_kfree_skb(skb);
-	skb = skb2;
 
-	/* Send frame to hostapd */
-	ieee80211_rx_mgmt(local, skb, NULL, msg_type);
+	rthdr = (struct ieee80211_tx_status_rtap_hdr*)
+				skb_push(skb, sizeof(*rthdr));
+
+	memset(rthdr, 0, sizeof(*rthdr));
+	rthdr->hdr.it_len = cpu_to_le16(sizeof(*rthdr));
+	rthdr->hdr.it_present =
+		cpu_to_le32((1 << IEEE80211_RADIOTAP_TX_FLAGS) |
+			    (1 << IEEE80211_RADIOTAP_DATA_RETRIES));
+
+	if (!(status->flags & IEEE80211_TX_STATUS_ACK) &&
+	    !is_multicast_ether_addr(hdr->addr1))
+		rthdr->tx_flags |= cpu_to_le16(IEEE80211_RADIOTAP_F_TX_FAIL);
+
+	if ((status->control.flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
+	    (status->control.flags & IEEE80211_TXCTL_USE_CTS_PROTECT))
+		rthdr->tx_flags |= cpu_to_le16(IEEE80211_RADIOTAP_F_TX_CTS);
+	else if (status->control.flags & IEEE80211_TXCTL_USE_RTS_CTS)
+		rthdr->tx_flags |= cpu_to_le16(IEEE80211_RADIOTAP_F_TX_RTS);
+
+	rthdr->data_retries = status->retry_count;
+
+	read_lock(&local->sub_if_lock);
+	monitors = local->monitors;
+	list_for_each_entry(sdata, &local->sub_if_list, list) {
+		/*
+		 * Using the monitors counter is possibly racy, but
+		 * if the value is wrong we simply either clone the skb
+		 * once too much or forget sending it to one monitor iface
+		 * The latter case isn't nice but fixing the race is much
+		 * more complicated.
+		 */
+		if (!monitors || !skb)
+			goto out;
+
+		if (sdata->type == IEEE80211_IF_TYPE_MNTR) {
+			if (!netif_running(sdata->dev))
+				continue;
+			monitors--;
+			if (monitors)
+				skb2 = skb_clone(skb, GFP_KERNEL);
+			else
+				skb2 = NULL;
+			skb->dev = sdata->dev;
+			/* XXX: is this sufficient for BPF? */
+			skb_set_mac_header(skb, 0);
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			skb->pkt_type = PACKET_OTHERHOST;
+			skb->protocol = htons(ETH_P_802_2);
+			memset(skb->cb, 0, sizeof(skb->cb));
+			netif_rx(skb);
+			skb = skb2;
+			break;
+		}
+	}
+ out:
+	read_unlock(&local->sub_if_lock);
+	if (skb)
+		dev_kfree_skb(skb);
 }
 EXPORT_SYMBOL(ieee80211_tx_status);
 
@@ -4619,6 +4887,9 @@ struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
 			 ((sizeof(struct ieee80211_local) +
 			   NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 
+	BUG_ON(!ops->tx);
+	BUG_ON(!ops->config);
+	BUG_ON(!ops->add_interface);
 	local->ops = ops;
 
 	/* for now, mdev needs sub_if_data :/ */
@@ -4647,8 +4918,6 @@ struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
 	local->short_retry_limit = 7;
 	local->long_retry_limit = 4;
 	local->hw.conf.radio_enabled = 1;
-	local->rate_ctrl_num_up = RATE_CONTROL_NUM_UP;
-	local->rate_ctrl_num_down = RATE_CONTROL_NUM_DOWN;
 
 	local->enabled_modes = (unsigned int) -1;
 
@@ -4712,6 +4981,14 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 		goto fail_workqueue;
 	}
 
+	/*
+	 * The hardware needs headroom for sending the frame,
+	 * and we need some headroom for passing the frame to monitor
+	 * interfaces, but never both at the same time.
+	 */
+	local->tx_headroom = max(local->hw.extra_tx_headroom,
+				 sizeof(struct ieee80211_tx_status_rtap_hdr));
+
 	debugfs_hw_add(local);
 
 	local->hw.conf.beacon_int = 1000;
diff --git a/net/mac80211/ieee80211_common.h b/net/mac80211/ieee80211_common.h
index b9a73e7..77c6afb 100644
--- a/net/mac80211/ieee80211_common.h
+++ b/net/mac80211/ieee80211_common.h
@@ -47,21 +47,16 @@ enum ieee80211_msg_type {
 	ieee80211_msg_normal = 0,
 	ieee80211_msg_tx_callback_ack = 1,
 	ieee80211_msg_tx_callback_fail = 2,
-	ieee80211_msg_passive_scan = 3,
+	/* hole at 3, was ieee80211_msg_passive_scan but unused */
 	ieee80211_msg_wep_frame_unknown_key = 4,
 	ieee80211_msg_michael_mic_failure = 5,
 	/* hole at 6, was monitor but never sent to userspace */
 	ieee80211_msg_sta_not_assoc = 7,
-	ieee80211_msg_set_aid_for_sta = 8 /* used by Intersil MVC driver */,
+	/* 8 was ieee80211_msg_set_aid_for_sta */
 	ieee80211_msg_key_threshold_notification = 9,
 	ieee80211_msg_radar = 11,
 };
 
-struct ieee80211_msg_set_aid_for_sta {
-	char	sta_address[ETH_ALEN];
-	u16	aid;
-};
-
 struct ieee80211_msg_key_notification {
 	int tx_rx_count;
 	char ifname[IFNAMSIZ];
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index af4d14d..055a2a9 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -99,6 +99,12 @@ struct ieee80211_sta_bss {
 	int probe_resp;
 	unsigned long last_update;
 
+	/* during assocation, we save an ERP value from a probe response so
+	 * that we can feed ERP info to the driver when handling the
+	 * association completes. these fields probably won't be up-to-date
+	 * otherwise, you probably don't want to use them. */
+	int has_erp_value;
+	u8 erp_value;
 };
 
 
@@ -235,7 +241,6 @@ struct ieee80211_if_sta {
 	unsigned int authenticated:1;
 	unsigned int associated:1;
 	unsigned int probereq_poll:1;
-	unsigned int use_protection:1;
 	unsigned int create_ibss:1;
 	unsigned int mixed_cell:1;
 	unsigned int wmm_enabled:1;
@@ -278,6 +283,7 @@ struct ieee80211_sub_if_data {
 	int mc_count;
 	unsigned int allmulti:1;
 	unsigned int promisc:1;
+	unsigned int use_protection:1; /* CTS protect ERP frames */
 
 	struct net_device_stats stats;
 	int drop_unencrypted;
@@ -392,6 +398,7 @@ struct ieee80211_local {
 	int monitors;
 	struct iw_statistics wstats;
 	u8 wstats_flags;
+	int tx_headroom; /* required headroom for hardware/radiotap */
 
 	enum {
 		IEEE80211_DEV_UNINITIALIZED = 0,
@@ -437,7 +444,6 @@ struct ieee80211_local {
 	int *basic_rates[NUM_IEEE80211_MODES];
 
 	int rts_threshold;
-	int cts_protect_erp_frames;
 	int fragmentation_threshold;
 	int short_retry_limit; /* dot11ShortRetryLimit */
 	int long_retry_limit; /* dot11LongRetryLimit */
@@ -513,8 +519,6 @@ struct ieee80211_local {
 		STA_ANTENNA_SEL_SW_CTRL_DEBUG = 2
 	} sta_antenna_sel;
 
-	int rate_ctrl_num_up, rate_ctrl_num_down;
-
 #ifdef CONFIG_MAC80211_DEBUG_COUNTERS
 	/* TX/RX handler statistics */
 	unsigned int tx_handlers_drop;
@@ -719,6 +723,8 @@ void ieee80211_prepare_rates(struct ieee80211_local *local,
 			     struct ieee80211_hw_mode *mode);
 void ieee80211_tx_set_iswep(struct ieee80211_txrx_data *tx);
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr);
+int ieee80211_monitor_start_xmit(struct sk_buff *skb, struct net_device *dev);
+int ieee80211_subif_start_xmit(struct sk_buff *skb, struct net_device *dev);
 void ieee80211_if_setup(struct net_device *dev);
 void ieee80211_if_mgmt_setup(struct net_device *dev);
 int ieee80211_init_rate_ctrl_alg(struct ieee80211_local *local,
diff --git a/net/mac80211/ieee80211_iface.c b/net/mac80211/ieee80211_iface.c
index cf0f32e..8532a5c 100644
--- a/net/mac80211/ieee80211_iface.c
+++ b/net/mac80211/ieee80211_iface.c
@@ -157,6 +157,8 @@ void ieee80211_if_set_type(struct net_device *dev, int type)
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	int oldtype = sdata->type;
 
+	dev->hard_start_xmit = ieee80211_subif_start_xmit;
+
 	sdata->type = type;
 	switch (type) {
 	case IEEE80211_IF_TYPE_WDS:
@@ -196,6 +198,7 @@ void ieee80211_if_set_type(struct net_device *dev, int type)
 	}
 	case IEEE80211_IF_TYPE_MNTR:
 		dev->type = ARPHRD_IEEE80211_RADIOTAP;
+		dev->hard_start_xmit = ieee80211_monitor_start_xmit;
 		break;
 	default:
 		printk(KERN_WARNING "%s: %s: Unknown interface type 0x%x",
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 66e8a97..5918dd0 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -345,6 +345,8 @@ static int ieee80211_ioctl_giwrange(struct net_device *dev,
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct iw_range *range = (struct iw_range *) extra;
+	struct ieee80211_hw_mode *mode = NULL;
+	int c = 0;
 
 	data->length = sizeof(struct iw_range);
 	memset(range, 0, sizeof(struct iw_range));
@@ -378,6 +380,29 @@ static int ieee80211_ioctl_giwrange(struct net_device *dev,
 	range->enc_capa = IW_ENC_CAPA_WPA | IW_ENC_CAPA_WPA2 |
 			  IW_ENC_CAPA_CIPHER_TKIP | IW_ENC_CAPA_CIPHER_CCMP;
 
+	list_for_each_entry(mode, &local->modes_list, list) {
+		int i = 0;
+
+		if (!(local->enabled_modes & (1 << mode->mode)) ||
+		    (local->hw_modes & local->enabled_modes &
+		     (1 << MODE_IEEE80211G) && mode->mode == MODE_IEEE80211B))
+			continue;
+
+		while (i < mode->num_channels && c < IW_MAX_FREQUENCIES) {
+			struct ieee80211_channel *chan = &mode->channels[i];
+
+			if (chan->flag & IEEE80211_CHAN_W_SCAN) {
+				range->freq[c].i = chan->chan;
+				range->freq[c].m = chan->freq * 100000;
+				range->freq[c].e = 1;
+				c++;
+			}
+			i++;
+		}
+	}
+	range->num_channels = c;
+	range->num_frequency = c;
+
 	IW_EVENT_CAPA_SET_KERNEL(range->event_capa);
 	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWTHRSPY);
 	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWAP);
@@ -838,6 +863,44 @@ static int ieee80211_ioctl_giwscan(struct net_device *dev,
 }
 
 
+static int ieee80211_ioctl_siwrate(struct net_device *dev,
+				  struct iw_request_info *info,
+				  struct iw_param *rate, char *extra)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_hw_mode *mode;
+	int i;
+	u32 target_rate = rate->value / 100000;
+	struct ieee80211_sub_if_data *sdata;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	if (!sdata->bss)
+		return -ENODEV;
+	mode = local->oper_hw_mode;
+	/* target_rate = -1, rate->fixed = 0 means auto only, so use all rates
+	 * target_rate = X, rate->fixed = 1 means only rate X
+	 * target_rate = X, rate->fixed = 0 means all rates <= X */
+	sdata->bss->max_ratectrl_rateidx = -1;
+	sdata->bss->force_unicast_rateidx = -1;
+	if (rate->value < 0)
+		return 0;
+	for (i=0; i< mode->num_rates; i++) {
+		struct ieee80211_rate *rates = &mode->rates[i];
+		int this_rate = rates->rate;
+
+		if (mode->mode == MODE_ATHEROS_TURBO ||
+		    mode->mode == MODE_ATHEROS_TURBOG)
+			this_rate *= 2;
+		if (target_rate == this_rate) {
+			sdata->bss->max_ratectrl_rateidx = i;
+			if (rate->fixed)
+				sdata->bss->force_unicast_rateidx = i;
+			break;
+		}
+	}
+	return 0;
+}
+
 static int ieee80211_ioctl_giwrate(struct net_device *dev,
 				  struct iw_request_info *info,
 				  struct iw_param *rate, char *extra)
@@ -993,118 +1056,6 @@ static int ieee80211_ioctl_giwretry(struct net_device *dev,
 	return 0;
 }
 
-static int ieee80211_ioctl_clear_keys(struct net_device *dev)
-{
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	struct ieee80211_key_conf key;
-	int i;
-	u8 addr[ETH_ALEN];
-	struct ieee80211_key_conf *keyconf;
-	struct ieee80211_sub_if_data *sdata;
-	struct sta_info *sta;
-
-	memset(addr, 0xff, ETH_ALEN);
-	read_lock(&local->sub_if_lock);
-	list_for_each_entry(sdata, &local->sub_if_list, list) {
-		for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-			keyconf = NULL;
-			if (sdata->keys[i] &&
-			    !sdata->keys[i]->force_sw_encrypt &&
-			    local->ops->set_key &&
-			    (keyconf = ieee80211_key_data2conf(local,
-							       sdata->keys[i])))
-				local->ops->set_key(local_to_hw(local),
-						   DISABLE_KEY, addr,
-						   keyconf, 0);
-			kfree(keyconf);
-			ieee80211_key_free(sdata->keys[i]);
-			sdata->keys[i] = NULL;
-		}
-		sdata->default_key = NULL;
-	}
-	read_unlock(&local->sub_if_lock);
-
-	spin_lock_bh(&local->sta_lock);
-	list_for_each_entry(sta, &local->sta_list, list) {
-		keyconf = NULL;
-		if (sta->key && !sta->key->force_sw_encrypt &&
-		    local->ops->set_key &&
-		    (keyconf = ieee80211_key_data2conf(local, sta->key)))
-			local->ops->set_key(local_to_hw(local), DISABLE_KEY,
-					   sta->addr, keyconf, sta->aid);
-		kfree(keyconf);
-		ieee80211_key_free(sta->key);
-		sta->key = NULL;
-	}
-	spin_unlock_bh(&local->sta_lock);
-
-	memset(&key, 0, sizeof(key));
-	if (local->ops->set_key &&
-		    local->ops->set_key(local_to_hw(local), REMOVE_ALL_KEYS,
-				       NULL, &key, 0))
-		printk(KERN_DEBUG "%s: failed to remove hwaccel keys\n",
-		       dev->name);
-
-	return 0;
-}
-
-
-static int
-ieee80211_ioctl_force_unicast_rate(struct net_device *dev,
-				   struct ieee80211_sub_if_data *sdata,
-				   int rate)
-{
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	struct ieee80211_hw_mode *mode;
-	int i;
-
-	if (sdata->type != IEEE80211_IF_TYPE_AP)
-		return -ENOENT;
-
-	if (rate == 0) {
-		sdata->u.ap.force_unicast_rateidx = -1;
-		return 0;
-	}
-
-	mode = local->oper_hw_mode;
-	for (i = 0; i < mode->num_rates; i++) {
-		if (mode->rates[i].rate == rate) {
-			sdata->u.ap.force_unicast_rateidx = i;
-			return 0;
-		}
-	}
-	return -EINVAL;
-}
-
-
-static int
-ieee80211_ioctl_max_ratectrl_rate(struct net_device *dev,
-				  struct ieee80211_sub_if_data *sdata,
-				  int rate)
-{
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	struct ieee80211_hw_mode *mode;
-	int i;
-
-	if (sdata->type != IEEE80211_IF_TYPE_AP)
-		return -ENOENT;
-
-	if (rate == 0) {
-		sdata->u.ap.max_ratectrl_rateidx = -1;
-		return 0;
-	}
-
-	mode = local->oper_hw_mode;
-	for (i = 0; i < mode->num_rates; i++) {
-		if (mode->rates[i].rate == rate) {
-			sdata->u.ap.max_ratectrl_rateidx = i;
-			return 0;
-		}
-	}
-	return -EINVAL;
-}
-
-
 static void ieee80211_key_enable_hwaccel(struct ieee80211_local *local,
 					 struct ieee80211_key *key)
 {
@@ -1228,24 +1179,11 @@ static int ieee80211_ioctl_prism2_param(struct net_device *dev,
 			sdata->ieee802_1x = value;
 		break;
 
-	case PRISM2_PARAM_ANTSEL_TX:
-		local->hw.conf.antenna_sel_tx = value;
-		if (ieee80211_hw_config(local))
-			ret = -EINVAL;
-		break;
-
-	case PRISM2_PARAM_ANTSEL_RX:
-		local->hw.conf.antenna_sel_rx = value;
-		if (ieee80211_hw_config(local))
-			ret = -EINVAL;
-		break;
-
 	case PRISM2_PARAM_CTS_PROTECT_ERP_FRAMES:
-		local->cts_protect_erp_frames = value;
-		break;
-
-	case PRISM2_PARAM_DROP_UNENCRYPTED:
-		sdata->drop_unencrypted = value;
+		if (sdata->type != IEEE80211_IF_TYPE_AP)
+			ret = -ENOENT;
+		else
+			sdata->use_protection = value;
 		break;
 
 	case PRISM2_PARAM_PREAMBLE:
@@ -1274,10 +1212,6 @@ static int ieee80211_ioctl_prism2_param(struct net_device *dev,
 		local->next_mode = value;
 		break;
 
-	case PRISM2_PARAM_CLEAR_KEYS:
-		ret = ieee80211_ioctl_clear_keys(dev);
-		break;
-
 	case PRISM2_PARAM_RADIO_ENABLED:
 		ret = ieee80211_ioctl_set_radio_enabled(dev, value);
 		break;
@@ -1292,22 +1226,6 @@ static int ieee80211_ioctl_prism2_param(struct net_device *dev,
 		local->sta_antenna_sel = value;
 		break;
 
-	case PRISM2_PARAM_FORCE_UNICAST_RATE:
-		ret = ieee80211_ioctl_force_unicast_rate(dev, sdata, value);
-		break;
-
-	case PRISM2_PARAM_MAX_RATECTRL_RATE:
-		ret = ieee80211_ioctl_max_ratectrl_rate(dev, sdata, value);
-		break;
-
-	case PRISM2_PARAM_RATE_CTRL_NUM_UP:
-		local->rate_ctrl_num_up = value;
-		break;
-
-	case PRISM2_PARAM_RATE_CTRL_NUM_DOWN:
-		local->rate_ctrl_num_down = value;
-		break;
-
 	case PRISM2_PARAM_TX_POWER_REDUCTION:
 		if (value < 0)
 			ret = -EINVAL;
@@ -1387,20 +1305,8 @@ static int ieee80211_ioctl_get_prism2_param(struct net_device *dev,
 		*param = sdata->ieee802_1x;
 		break;
 
-	case PRISM2_PARAM_ANTSEL_TX:
-		*param = local->hw.conf.antenna_sel_tx;
-		break;
-
-	case PRISM2_PARAM_ANTSEL_RX:
-		*param = local->hw.conf.antenna_sel_rx;
-		break;
-
 	case PRISM2_PARAM_CTS_PROTECT_ERP_FRAMES:
-		*param = local->cts_protect_erp_frames;
-		break;
-
-	case PRISM2_PARAM_DROP_UNENCRYPTED:
-		*param = sdata->drop_unencrypted;
+		*param = sdata->use_protection;
 		break;
 
 	case PRISM2_PARAM_PREAMBLE:
@@ -1426,14 +1332,6 @@ static int ieee80211_ioctl_get_prism2_param(struct net_device *dev,
 		*param = local->sta_antenna_sel;
 		break;
 
-	case PRISM2_PARAM_RATE_CTRL_NUM_UP:
-		*param = local->rate_ctrl_num_up;
-		break;
-
-	case PRISM2_PARAM_RATE_CTRL_NUM_DOWN:
-		*param = local->rate_ctrl_num_down;
-		break;
-
 	case PRISM2_PARAM_TX_POWER_REDUCTION:
 		*param = local->hw.conf.tx_power_reduction;
 		break;
@@ -1801,7 +1699,7 @@ static const iw_handler ieee80211_handler[] =
 	(iw_handler) NULL,				/* SIOCGIWNICKN */
 	(iw_handler) NULL,				/* -- hole -- */
 	(iw_handler) NULL,				/* -- hole -- */
-	(iw_handler) NULL,				/* SIOCSIWRATE */
+	(iw_handler) ieee80211_ioctl_siwrate,		/* SIOCSIWRATE */
 	(iw_handler) ieee80211_ioctl_giwrate,		/* SIOCGIWRATE */
 	(iw_handler) ieee80211_ioctl_siwrts,		/* SIOCSIWRTS */
 	(iw_handler) ieee80211_ioctl_giwrts,		/* SIOCGIWRTS */
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 91b545c..ba2bf8f 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -76,33 +76,36 @@ static int ieee80211_sta_config_auth(struct net_device *dev,
 
 /* Parsed Information Elements */
 struct ieee802_11_elems {
+	/* pointers to IEs */
 	u8 *ssid;
-	u8 ssid_len;
 	u8 *supp_rates;
-	u8 supp_rates_len;
 	u8 *fh_params;
-	u8 fh_params_len;
 	u8 *ds_params;
-	u8 ds_params_len;
 	u8 *cf_params;
-	u8 cf_params_len;
 	u8 *tim;
-	u8 tim_len;
 	u8 *ibss_params;
-	u8 ibss_params_len;
 	u8 *challenge;
-	u8 challenge_len;
 	u8 *wpa;
-	u8 wpa_len;
 	u8 *rsn;
-	u8 rsn_len;
 	u8 *erp_info;
-	u8 erp_info_len;
 	u8 *ext_supp_rates;
-	u8 ext_supp_rates_len;
 	u8 *wmm_info;
-	u8 wmm_info_len;
 	u8 *wmm_param;
+
+	/* length of them, respectively */
+	u8 ssid_len;
+	u8 supp_rates_len;
+	u8 fh_params_len;
+	u8 ds_params_len;
+	u8 cf_params_len;
+	u8 tim_len;
+	u8 ibss_params_len;
+	u8 challenge_len;
+	u8 wpa_len;
+	u8 rsn_len;
+	u8 erp_info_len;
+	u8 ext_supp_rates_len;
+	u8 wmm_info_len;
 	u8 wmm_param_len;
 };
 
@@ -311,6 +314,25 @@ static void ieee80211_sta_wmm_params(struct net_device *dev,
 }
 
 
+static void ieee80211_handle_erp_ie(struct net_device *dev, u8 erp_value)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+	int use_protection = (erp_value & WLAN_ERP_USE_PROTECTION) != 0;
+
+	if (use_protection != sdata->use_protection) {
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "%s: CTS protection %s (BSSID="
+			       MAC_FMT ")\n",
+			       dev->name,
+			       use_protection ? "enabled" : "disabled",
+			       MAC_ARG(ifsta->bssid));
+		}
+		sdata->use_protection = use_protection;
+	}
+}
+
+
 static void ieee80211_sta_send_associnfo(struct net_device *dev,
 					 struct ieee80211_if_sta *ifsta)
 {
@@ -366,6 +388,7 @@ static void ieee80211_set_associated(struct net_device *dev,
 				     struct ieee80211_if_sta *ifsta, int assoc)
 {
 	union iwreq_data wrqu;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	if (ifsta->associated == assoc)
 		return;
@@ -374,9 +397,18 @@ static void ieee80211_set_associated(struct net_device *dev,
 
 	if (assoc) {
 		struct ieee80211_sub_if_data *sdata;
+		struct ieee80211_sta_bss *bss;
 		sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 		if (sdata->type != IEEE80211_IF_TYPE_STA)
 			return;
+
+		bss = ieee80211_rx_bss_get(dev, ifsta->bssid);
+		if (bss) {
+			if (bss->has_erp_value)
+				ieee80211_handle_erp_ie(dev, bss->erp_value);
+			ieee80211_rx_bss_put(dev, bss);
+		}
+
 		netif_carrier_on(dev);
 		ifsta->prev_bssid_set = 1;
 		memcpy(ifsta->prev_bssid, sdata->u.sta.bssid, ETH_ALEN);
@@ -384,6 +416,7 @@ static void ieee80211_set_associated(struct net_device *dev,
 		ieee80211_sta_send_associnfo(dev, ifsta);
 	} else {
 		netif_carrier_off(dev);
+		sdata->use_protection = 0;
 		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
 	}
 	wrqu.ap_addr.sa_family = ARPHRD_ETHER;
@@ -1174,6 +1207,18 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 		return;
 	}
 
+	/* it probably doesn't, but if the frame includes an ERP value then
+	 * update our stored copy */
+	if (elems.erp_info && elems.erp_info_len >= 1) {
+		struct ieee80211_sta_bss *bss
+			= ieee80211_rx_bss_get(dev, ifsta->bssid);
+		if (bss) {
+			bss->erp_value = elems.erp_info[0];
+			bss->has_erp_value = 1;
+			ieee80211_rx_bss_put(dev, bss);
+		}
+	}
+
 	printk(KERN_DEBUG "%s: associated\n", dev->name);
 	ifsta->aid = aid;
 	ifsta->ap_capab = capab_info;
@@ -1496,6 +1541,12 @@ static void ieee80211_rx_bss_info(struct net_device *dev,
 		return;
 	}
 
+	/* save the ERP value so that it is available at association time */
+	if (elems.erp_info && elems.erp_info_len >= 1) {
+		bss->erp_value = elems.erp_info[0];
+		bss->has_erp_value = 1;
+	}
+
 	bss->beacon_int = le16_to_cpu(mgmt->u.beacon.beacon_int);
 	bss->capability = le16_to_cpu(mgmt->u.beacon.capab_info);
 	if (elems.ssid && elems.ssid_len <= IEEE80211_MAX_SSID_LEN) {
@@ -1611,10 +1662,8 @@ static void ieee80211_rx_mgmt_beacon(struct net_device *dev,
 				     size_t len,
 				     struct ieee80211_rx_status *rx_status)
 {
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_if_sta *ifsta;
-	int use_protection;
 	size_t baselen;
 	struct ieee802_11_elems elems;
 
@@ -1638,23 +1687,8 @@ static void ieee80211_rx_mgmt_beacon(struct net_device *dev,
 				   &elems) == ParseFailed)
 		return;
 
-	use_protection = 0;
-	if (elems.erp_info && elems.erp_info_len >= 1) {
-		use_protection =
-			(elems.erp_info[0] & ERP_INFO_USE_PROTECTION) != 0;
-	}
-
-	if (use_protection != !!ifsta->use_protection) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: CTS protection %s (BSSID="
-			       MAC_FMT ")\n",
-			       dev->name,
-			       use_protection ? "enabled" : "disabled",
-			       MAC_ARG(ifsta->bssid));
-		}
-		ifsta->use_protection = use_protection ? 1 : 0;
-		local->cts_protect_erp_frames = use_protection;
-	}
+	if (elems.erp_info && elems.erp_info_len >= 1)
+		ieee80211_handle_erp_ie(dev, elems.erp_info[0]);
 
 	if (elems.wmm_param && ifsta->wmm_enabled) {
 		ieee80211_sta_wmm_params(dev, ifsta, elems.wmm_param,
diff --git a/net/mac80211/rc80211_simple.c b/net/mac80211/rc80211_simple.c
index 5ae7fc4..f6780d6 100644
--- a/net/mac80211/rc80211_simple.c
+++ b/net/mac80211/rc80211_simple.c
@@ -187,9 +187,13 @@ static void rate_control_simple_tx_status(void *priv, struct net_device *dev,
 		}
 #endif
 
-		if (per_failed > local->rate_ctrl_num_down) {
+		/*
+		 * XXX: Make these configurable once we have an
+		 * interface to the rate control algorithms
+		 */
+		if (per_failed > RATE_CONTROL_NUM_DOWN) {
 			rate_control_rate_dec(local, sta);
-		} else if (per_failed < local->rate_ctrl_num_up) {
+		} else if (per_failed < RATE_CONTROL_NUM_UP) {
 			rate_control_rate_inc(local, sta);
 		}
 		srctrl->tx_avg_rate_sum += status->control.rate->rate;
diff --git a/net/wireless/Makefile b/net/wireless/Makefile
index 3a96ae6..092116e 100644
--- a/net/wireless/Makefile
+++ b/net/wireless/Makefile
@@ -1,4 +1,4 @@
 obj-$(CONFIG_WIRELESS_EXT) += wext.o
 obj-$(CONFIG_CFG80211) += cfg80211.o
 
-cfg80211-y += core.o sysfs.o
+cfg80211-y += core.o sysfs.o radiotap.o
diff --git a/net/wireless/radiotap.c b/net/wireless/radiotap.c
new file mode 100644
index 0000000..68c11d0
--- /dev/null
+++ b/net/wireless/radiotap.c
@@ -0,0 +1,257 @@
+/*
+ * Radiotap parser
+ *
+ * Copyright 2007		Andy Green <andy-/Zus8d0mwwtBDgjK7y7TUQ@public.gmane.org>
+ */
+
+#include <net/cfg80211.h>
+#include <net/ieee80211_radiotap.h>
+#include <asm/unaligned.h>
+
+/* function prototypes and related defs are in include/net/cfg80211.h */
+
+/**
+ * ieee80211_radiotap_iterator_init - radiotap parser iterator initialization
+ * @iterator: radiotap_iterator to initialize
+ * @radiotap_header: radiotap header to parse
+ * @max_length: total length we can parse into (eg, whole packet length)
+ *
+ * Returns: 0 or a negative error code if there is a problem.
+ *
+ * This function initializes an opaque iterator struct which can then
+ * be passed to ieee80211_radiotap_iterator_next() to visit every radiotap
+ * argument which is present in the header.  It knows about extended
+ * present headers and handles them.
+ *
+ * How to use:
+ * call __ieee80211_radiotap_iterator_init() to init a semi-opaque iterator
+ * struct ieee80211_radiotap_iterator (no need to init the struct beforehand)
+ * checking for a good 0 return code.  Then loop calling
+ * __ieee80211_radiotap_iterator_next()... it returns either 0,
+ * -ENOENT if there are no more args to parse, or -EINVAL if there is a problem.
+ * The iterator's @this_arg member points to the start of the argument
+ * associated with the current argument index that is present, which can be
+ * found in the iterator's @this_arg_index member.  This arg index corresponds
+ * to the IEEE80211_RADIOTAP_... defines.
+ *
+ * Radiotap header length:
+ * You can find the CPU-endian total radiotap header length in
+ * iterator->max_length after executing ieee80211_radiotap_iterator_init()
+ * successfully.
+ *
+ * Alignment Gotcha:
+ * You must take care when dereferencing iterator.this_arg
+ * for multibyte types... the pointer is not aligned.  Use
+ * get_unaligned((type *)iterator.this_arg) to dereference
+ * iterator.this_arg for type "type" safely on all arches.
+ *
+ * Example code:
+ * See Documentation/networking/radiotap-headers.txt
+ */
+
+int ieee80211_radiotap_iterator_init(
+    struct ieee80211_radiotap_iterator *iterator,
+    struct ieee80211_radiotap_header *radiotap_header,
+    int max_length)
+{
+	/* Linux only supports version 0 radiotap format */
+	if (radiotap_header->it_version)
+		return -EINVAL;
+
+	/* sanity check for allowed length and radiotap length field */
+	if (max_length < le16_to_cpu(get_unaligned(&radiotap_header->it_len)))
+		return -EINVAL;
+
+	iterator->rtheader = radiotap_header;
+	iterator->max_length = le16_to_cpu(get_unaligned(
+						&radiotap_header->it_len));
+	iterator->arg_index = 0;
+	iterator->bitmap_shifter = le32_to_cpu(get_unaligned(
+						&radiotap_header->it_present));
+	iterator->arg = (u8 *)radiotap_header + sizeof(*radiotap_header);
+	iterator->this_arg = NULL;
+
+	/* find payload start allowing for extended bitmap(s) */
+
+	if (unlikely(iterator->bitmap_shifter & (1<<IEEE80211_RADIOTAP_EXT))) {
+		while (le32_to_cpu(get_unaligned((__le32 *)iterator->arg)) &
+				   (1<<IEEE80211_RADIOTAP_EXT)) {
+			iterator->arg += sizeof(u32);
+
+			/*
+			 * check for insanity where the present bitmaps
+			 * keep claiming to extend up to or even beyond the
+			 * stated radiotap header length
+			 */
+
+			if (((ulong)iterator->arg -
+			     (ulong)iterator->rtheader) > iterator->max_length)
+				return -EINVAL;
+		}
+
+		iterator->arg += sizeof(u32);
+
+		/*
+		 * no need to check again for blowing past stated radiotap
+		 * header length, because ieee80211_radiotap_iterator_next
+		 * checks it before it is dereferenced
+		 */
+	}
+
+	/* we are all initialized happily */
+
+	return 0;
+}
+EXPORT_SYMBOL(ieee80211_radiotap_iterator_init);
+
+
+/**
+ * ieee80211_radiotap_iterator_next - return next radiotap parser iterator arg
+ * @iterator: radiotap_iterator to move to next arg (if any)
+ *
+ * Returns: 0 if there is an argument to handle,
+ * -ENOENT if there are no more args or -EINVAL
+ * if there is something else wrong.
+ *
+ * This function provides the next radiotap arg index (IEEE80211_RADIOTAP_*)
+ * in @this_arg_index and sets @this_arg to point to the
+ * payload for the field.  It takes care of alignment handling and extended
+ * present fields.  @this_arg can be changed by the caller (eg,
+ * incremented to move inside a compound argument like
+ * IEEE80211_RADIOTAP_CHANNEL).  The args pointed to are in
+ * little-endian format whatever the endianess of your CPU.
+ *
+ * Alignment Gotcha:
+ * You must take care when dereferencing iterator.this_arg
+ * for multibyte types... the pointer is not aligned.  Use
+ * get_unaligned((type *)iterator.this_arg) to dereference
+ * iterator.this_arg for type "type" safely on all arches.
+ */
+
+int ieee80211_radiotap_iterator_next(
+    struct ieee80211_radiotap_iterator *iterator)
+{
+
+	/*
+	 * small length lookup table for all radiotap types we heard of
+	 * starting from b0 in the bitmap, so we can walk the payload
+	 * area of the radiotap header
+	 *
+	 * There is a requirement to pad args, so that args
+	 * of a given length must begin at a boundary of that length
+	 * -- but note that compound args are allowed (eg, 2 x u16
+	 * for IEEE80211_RADIOTAP_CHANNEL) so total arg length is not
+	 * a reliable indicator of alignment requirement.
+	 *
+	 * upper nybble: content alignment for arg
+	 * lower nybble: content length for arg
+	 */
+
+	static const u8 rt_sizes[] = {
+		[IEEE80211_RADIOTAP_TSFT] = 0x88,
+		[IEEE80211_RADIOTAP_FLAGS] = 0x11,
+		[IEEE80211_RADIOTAP_RATE] = 0x11,
+		[IEEE80211_RADIOTAP_CHANNEL] = 0x24,
+		[IEEE80211_RADIOTAP_FHSS] = 0x22,
+		[IEEE80211_RADIOTAP_DBM_ANTSIGNAL] = 0x11,
+		[IEEE80211_RADIOTAP_DBM_ANTNOISE] = 0x11,
+		[IEEE80211_RADIOTAP_LOCK_QUALITY] = 0x22,
+		[IEEE80211_RADIOTAP_TX_ATTENUATION] = 0x22,
+		[IEEE80211_RADIOTAP_DB_TX_ATTENUATION] = 0x22,
+		[IEEE80211_RADIOTAP_DBM_TX_POWER] = 0x11,
+		[IEEE80211_RADIOTAP_ANTENNA] = 0x11,
+		[IEEE80211_RADIOTAP_DB_ANTSIGNAL] = 0x11,
+		[IEEE80211_RADIOTAP_DB_ANTNOISE] = 0x11
+		/*
+		 * add more here as they are defined in
+		 * include/net/ieee80211_radiotap.h
+		 */
+	};
+
+	/*
+	 * for every radiotap entry we can at
+	 * least skip (by knowing the length)...
+	 */
+
+	while (iterator->arg_index < sizeof(rt_sizes)) {
+		int hit = 0;
+		int pad;
+
+		if (!(iterator->bitmap_shifter & 1))
+			goto next_entry; /* arg not present */
+
+		/*
+		 * arg is present, account for alignment padding
+		 *  8-bit args can be at any alignment
+		 * 16-bit args must start on 16-bit boundary
+		 * 32-bit args must start on 32-bit boundary
+		 * 64-bit args must start on 64-bit boundary
+		 *
+		 * note that total arg size can differ from alignment of
+		 * elements inside arg, so we use upper nybble of length
+		 * table to base alignment on
+		 *
+		 * also note: these alignments are ** relative to the
+		 * start of the radiotap header **.  There is no guarantee
+		 * that the radiotap header itself is aligned on any
+		 * kind of boundary.
+		 *
+		 * the above is why get_unaligned() is used to dereference
+		 * multibyte elements from the radiotap area
+		 */
+
+		pad = (((ulong)iterator->arg) -
+			((ulong)iterator->rtheader)) &
+			((rt_sizes[iterator->arg_index] >> 4) - 1);
+
+		if (pad)
+			iterator->arg +=
+				(rt_sizes[iterator->arg_index] >> 4) - pad;
+
+		/*
+		 * this is what we will return to user, but we need to
+		 * move on first so next call has something fresh to test
+		 */
+		iterator->this_arg_index = iterator->arg_index;
+		iterator->this_arg = iterator->arg;
+		hit = 1;
+
+		/* internally move on the size of this arg */
+		iterator->arg += rt_sizes[iterator->arg_index] & 0x0f;
+
+		/*
+		 * check for insanity where we are given a bitmap that
+		 * claims to have more arg content than the length of the
+		 * radiotap section.  We will normally end up equalling this
+		 * max_length on the last arg, never exceeding it.
+		 */
+
+		if (((ulong)iterator->arg - (ulong)iterator->rtheader) >
+		    iterator->max_length)
+			return -EINVAL;
+
+	next_entry:
+		iterator->arg_index++;
+		if (unlikely((iterator->arg_index & 31) == 0)) {
+			/* completed current u32 bitmap */
+			if (iterator->bitmap_shifter & 1) {
+				/* b31 was set, there is more */
+				/* move to next u32 bitmap */
+				iterator->bitmap_shifter = le32_to_cpu(
+					get_unaligned(iterator->next_bitmap));
+				iterator->next_bitmap++;
+			} else
+				/* no more bitmaps: end */
+				iterator->arg_index = sizeof(rt_sizes);
+		} else /* just try the next bit */
+			iterator->bitmap_shifter >>= 1;
+
+		/* if we found a valid arg earlier, return it now */
+		if (hit)
+			return 0;
+	}
+
+	/* we don't know how to handle any more args, we're done */
+	return -ENOENT;
+}
+EXPORT_SYMBOL(ieee80211_radiotap_iterator_next);
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
