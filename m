From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2009-03-16
Date: Mon, 16 Mar 2009 19:14:24 -0400
Message-ID: <20090316231423.GA3633@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is a group of patches intended for 2.6.29.  The one from me is
minor, but it cuts-down on log SPAM for ipw2100, ipw2200, and hostap
users.  The two from Jouni fix some panics he observed himself.

The first one from Luis fixes bug 12110 at bugzilla.kernel.org.  I know
he has worked on it for a long time and I've had several desperate user=
s
asking for it, so it must be good. :-)  Unfortunately, it causes some
nasty merge errors with what is in net-next-2.6 and wireless-next-2.6.
I created a merge-test branch in wireless-next-2.6, and the merge commi=
t
log goes into more detail about resolving the issue.  In short, you
probably want to diff drivers/net/ath9k against the merge-test branch..=
=2E

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit ea8dbdd17099a9a5864ebd4c87e01e657b19=
c7ab:
  fran=E7ois romieu (1):
        r8169: revert "r8169: read MAC address from EEPROM on init (2nd=
 attempt)"

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it master

John W. Linville (1):
      lib80211: silence excessive crypto debugging messages

Jouni Malinen (2):
      mac80211: Fix panic on fragmentation with power saving
      zd1211rw: Do not panic on device eject when associated

Luis R. Rodriguez (2):
      ath9k: implement IO serialization
      ath9k: AR9280 PCI devices must serialize IO as well

 drivers/net/wireless/ath9k/ath9k.h     |    4 +-
 drivers/net/wireless/ath9k/core.h      |   33 ++++++++++++++++++++++++=
++++++++
 drivers/net/wireless/ath9k/hw.c        |   22 ++++++++++++++++++++-
 drivers/net/wireless/ath9k/main.c      |    1 +
 drivers/net/wireless/zd1211rw/zd_mac.c |    8 +++++-
 net/mac80211/tx.c                      |    2 +
 net/wireless/Kconfig                   |   10 +++++++++
 net/wireless/lib80211_crypt_ccmp.c     |    2 +
 net/wireless/lib80211_crypt_tkip.c     |    4 +++
 9 files changed, 81 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath9k/ath9k.h b/drivers/net/wireless/=
ath9k/ath9k.h
index d278135..6650f60 100644
--- a/drivers/net/wireless/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath9k/ath9k.h
@@ -587,8 +587,8 @@ struct ath9k_country_entry {
 	u8 iso[3];
 };
=20
-#define REG_WRITE(_ah, _reg, _val) iowrite32(_val, _ah->ah_sh + _reg)
-#define REG_READ(_ah, _reg) ioread32(_ah->ah_sh + _reg)
+#define REG_WRITE(_ah, _reg, _val) ath9k_iowrite32((_ah), (_reg), (_va=
l))
+#define REG_READ(_ah, _reg) ath9k_ioread32((_ah), (_reg))
=20
 #define SM(_v, _f)  (((_v) << _f##_S) & _f)
 #define MS(_v, _f)  (((_v) & _f) >> _f##_S)
diff --git a/drivers/net/wireless/ath9k/core.h b/drivers/net/wireless/a=
th9k/core.h
index 4ca2aed..139566c 100644
--- a/drivers/net/wireless/ath9k/core.h
+++ b/drivers/net/wireless/ath9k/core.h
@@ -701,6 +701,7 @@ struct ath_softc {
 	struct ath_hal *sc_ah;
 	void __iomem *mem;
 	spinlock_t sc_resetlock;
+	spinlock_t sc_serial_rw;
 	struct mutex mutex;
=20
 	u8 sc_curbssid[ETH_ALEN];
@@ -751,4 +752,36 @@ int ath_get_hal_qnum(u16 queue, struct ath_softc *=
sc);
 int ath_get_mac80211_qnum(u32 queue, struct ath_softc *sc);
 int ath_cabq_update(struct ath_softc *);
=20
+/*
+ * Read and write, they both share the same lock. We do this to serial=
ize
+ * reads and writes on Atheros 802.11n PCI devices only. This is requi=
red
+ * as the FIFO on these devices can only accept sanely 2 requests. Aft=
er
+ * that the device goes bananas. Serializing the reads/writes prevents=
 this
+ * from happening.
+ */
+
+static inline void ath9k_iowrite32(struct ath_hal *ah, u32 reg_offset,=
 u32 val)
+{
+	if (ah->ah_config.serialize_regmode =3D=3D SER_REG_MODE_ON) {
+		unsigned long flags;
+		spin_lock_irqsave(&ah->ah_sc->sc_serial_rw, flags);
+		iowrite32(val, ah->ah_sc->mem + reg_offset);
+		spin_unlock_irqrestore(&ah->ah_sc->sc_serial_rw, flags);
+	} else
+		iowrite32(val, ah->ah_sc->mem + reg_offset);
+}
+
+static inline unsigned int ath9k_ioread32(struct ath_hal *ah, u32 reg_=
offset)
+{
+	u32 val;
+	if (ah->ah_config.serialize_regmode =3D=3D SER_REG_MODE_ON) {
+		unsigned long flags;
+		spin_lock_irqsave(&ah->ah_sc->sc_serial_rw, flags);
+		val =3D ioread32(ah->ah_sc->mem + reg_offset);
+		spin_unlock_irqrestore(&ah->ah_sc->sc_serial_rw, flags);
+	} else
+		val =3D ioread32(ah->ah_sc->mem + reg_offset);
+	return val;
+}
+
 #endif /* CORE_H */
diff --git a/drivers/net/wireless/ath9k/hw.c b/drivers/net/wireless/ath=
9k/hw.c
index 34474ed..c38a00b 100644
--- a/drivers/net/wireless/ath9k/hw.c
+++ b/drivers/net/wireless/ath9k/hw.c
@@ -437,6 +437,25 @@ static void ath9k_hw_set_defaults(struct ath_hal *=
ah)
 	}
=20
 	ah->ah_config.intr_mitigation =3D 1;
+
+	/*
+	 * We need this for PCI devices only (Cardbus, PCI, miniPCI)
+	 * _and_ if on non-uniprocessor systems (Multiprocessor/HT).
+	 * This means we use it for all AR5416 devices, and the few
+	 * minor PCI AR9280 devices out there.
+	 *
+	 * Serialization is required because these devices do not handle
+	 * well the case of two concurrent reads/writes due to the latency
+	 * involved. During one read/write another read/write can be issued
+	 * on another CPU while the previous read/write may still be working
+	 * on our hardware, if we hit this case the hardware poops in a loop.
+	 * We prevent this by serializing reads and writes.
+	 *
+	 * This issue is not present on PCI-Express devices or pre-AR5416
+	 * devices (legacy, 802.11abg).
+	 */
+	if (num_possible_cpus() > 1)
+		ah->ah_config.serialize_regmode =3D SER_REG_MODE_AUTO;
 }
=20
 static struct ath_hal_5416 *ath9k_hw_newstate(u16 devid,
@@ -668,7 +687,8 @@ static struct ath_hal *ath9k_hw_do_attach(u16 devid=
, struct ath_softc *sc,
 	}
=20
 	if (ah->ah_config.serialize_regmode =3D=3D SER_REG_MODE_AUTO) {
-		if (ah->ah_macVersion =3D=3D AR_SREV_VERSION_5416_PCI) {
+		if (ah->ah_macVersion =3D=3D AR_SREV_VERSION_5416_PCI ||
+		    (AR_SREV_9280(ah) && !ah->ah_isPciExpress)) {
 			ah->ah_config.serialize_regmode =3D
 				SER_REG_MODE_ON;
 		} else {
diff --git a/drivers/net/wireless/ath9k/main.c b/drivers/net/wireless/a=
th9k/main.c
index 0e80990..3c04044 100644
--- a/drivers/net/wireless/ath9k/main.c
+++ b/drivers/net/wireless/ath9k/main.c
@@ -1336,6 +1336,7 @@ static int ath_init(u16 devid, struct ath_softc *=
sc)
 		printk(KERN_ERR "Unable to create debugfs files\n");
=20
 	spin_lock_init(&sc->sc_resetlock);
+	spin_lock_init(&sc->sc_serial_rw);
 	mutex_init(&sc->mutex);
 	tasklet_init(&sc->intr_tq, ath9k_tasklet, (unsigned long)sc);
 	tasklet_init(&sc->bcon_tasklet, ath9k_beacon_tasklet,
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wirel=
ess/zd1211rw/zd_mac.c
index a611ad8..847057d 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -575,13 +575,17 @@ static int zd_op_tx(struct ieee80211_hw *hw, stru=
ct sk_buff *skb)
=20
 	r =3D fill_ctrlset(mac, skb);
 	if (r)
-		return r;
+		goto fail;
=20
 	info->rate_driver_data[0] =3D hw;
=20
 	r =3D zd_usb_tx(&mac->chip.usb, skb);
 	if (r)
-		return r;
+		goto fail;
+	return 0;
+
+fail:
+	dev_kfree_skb(skb);
 	return 0;
 }
=20
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 94de503..37e3d5e 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -752,6 +752,8 @@ ieee80211_tx_h_fragment(struct ieee80211_tx_data *t=
x)
 		skb_copy_queue_mapping(frag, first);
=20
 		frag->do_not_encrypt =3D first->do_not_encrypt;
+		frag->dev =3D first->dev;
+		frag->iif =3D first->iif;
=20
 		pos +=3D copylen;
 		left -=3D copylen;
diff --git a/net/wireless/Kconfig b/net/wireless/Kconfig
index e28e2b8..092ae6f 100644
--- a/net/wireless/Kconfig
+++ b/net/wireless/Kconfig
@@ -102,3 +102,13 @@ config LIB80211_CRYPT_CCMP
=20
 config LIB80211_CRYPT_TKIP
 	tristate
+
+config LIB80211_DEBUG
+	bool "lib80211 debugging messages"
+	depends on LIB80211
+	default n
+	---help---
+	  You can enable this if you want verbose debugging messages
+	  from lib80211.
+
+	  If unsure, say N.
diff --git a/net/wireless/lib80211_crypt_ccmp.c b/net/wireless/lib80211=
_crypt_ccmp.c
index db42819..2301dc1 100644
--- a/net/wireless/lib80211_crypt_ccmp.c
+++ b/net/wireless/lib80211_crypt_ccmp.c
@@ -337,6 +337,7 @@ static int lib80211_ccmp_decrypt(struct sk_buff *sk=
b, int hdr_len, void *priv)
 	pos +=3D 8;
=20
 	if (ccmp_replay_check(pn, key->rx_pn)) {
+#ifdef CONFIG_LIB80211_DEBUG
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "CCMP: replay detected: STA=3D%pM "
 				 "previous PN %02x%02x%02x%02x%02x%02x "
@@ -346,6 +347,7 @@ static int lib80211_ccmp_decrypt(struct sk_buff *sk=
b, int hdr_len, void *priv)
 				 key->rx_pn[3], key->rx_pn[4], key->rx_pn[5],
 				 pn[0], pn[1], pn[2], pn[3], pn[4], pn[5]);
 		}
+#endif
 		key->dot11RSNAStatsCCMPReplays++;
 		return -4;
 	}
diff --git a/net/wireless/lib80211_crypt_tkip.c b/net/wireless/lib80211=
_crypt_tkip.c
index 7e8e22b..c362873 100644
--- a/net/wireless/lib80211_crypt_tkip.c
+++ b/net/wireless/lib80211_crypt_tkip.c
@@ -465,12 +465,14 @@ static int lib80211_tkip_decrypt(struct sk_buff *=
skb, int hdr_len, void *priv)
 	pos +=3D 8;
=20
 	if (tkip_replay_check(iv32, iv16, tkey->rx_iv32, tkey->rx_iv16)) {
+#ifdef CONFIG_LIB80211_DEBUG
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "TKIP: replay detected: STA=3D%pM"
 			       " previous TSC %08x%04x received TSC "
 			       "%08x%04x\n", hdr->addr2,
 			       tkey->rx_iv32, tkey->rx_iv16, iv32, iv16);
 		}
+#endif
 		tkey->dot11RSNAStatsTKIPReplays++;
 		return -4;
 	}
@@ -505,10 +507,12 @@ static int lib80211_tkip_decrypt(struct sk_buff *=
skb, int hdr_len, void *priv)
 			 * it needs to be recalculated for the next packet. */
 			tkey->rx_phase1_done =3D 0;
 		}
+#ifdef CONFIG_LIB80211_DEBUG
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "TKIP: ICV error detected: STA=3D"
 			       "%pM\n", hdr->addr2);
 		}
+#endif
 		tkey->dot11RSNAStatsTKIPICVErrors++;
 		return -5;
 	}
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
