From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-02-06
Date: Wed, 6 Feb 2013 14:34:23 -0500
Message-ID: <20130206193423.GI2148@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="J/dobhs11T7y2rNN"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57203 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932087Ab3BFTp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 14:45:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please consider this pull request for the 3.8 stream...

Included is a bluetooth pull.  Gustavo says:

"Two simple fixes for 3.8. One of the patches fixes a situation
where the connection wasn't terminated if a timeout ocurrs for LE
an SCO connections.  The other fixes prevent NULL dereference in the
SMP code, it is a security fix as well."

Along with those...

Hauke Mehrtens provides a couple of ssb and bcma bus fixes that
prevent oopses when unloading those modules.

Larry Finger provides and rtlwifi fix to avoid a "scheduling while
atomic" bug.

Last but certainly not least, Arend van Spriel bring a brcmsmac fix that
reworks the mac80211 .flush() callback in order to avoid the dreaded
brcms_c_wait_for_tx_completion warnings.  This one looks a little
large, but I think it is safe and isolated to brcmsmac in any case.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit bf414b369f158bb527f9f29174ada815f961b44c:

  net: usbnet: fix tx_dropped statistics (2013-02-04 13:07:31 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to b3b66ae4c8aff0636521034d824b8953dc617335:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-02-06 13:55:44 -0500)

----------------------------------------------------------------

Andre Guedes (1):
      Bluetooth: Fix hci_conn timeout routine

Arend van Spriel (1):
      brcmsmac: rework of mac80211 .flush() callback operation

Hauke Mehrtens (2):
      bcma: unregister gpios before unloading bcma
      ssb: unregister gpios before unloading ssb

Johan Hedberg (1):
      Bluetooth: Fix handling of unexpected SMP PDUs

John W. Linville (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      rtlwifi: Fix scheduling while atomic bug

 drivers/bcma/bcma_private.h                        |  5 ++++
 drivers/bcma/driver_gpio.c                         |  5 ++++
 drivers/bcma/main.c                                |  7 +++++
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  | 35 +++++++++++++-----=
----
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.h  |  3 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     | 15 ++--------
 drivers/net/wireless/brcm80211/brcmsmac/pub.h      |  3 +-
 drivers/net/wireless/rtlwifi/base.c                |  7 +++--
 drivers/ssb/driver_gpio.c                          | 12 ++++++++
 drivers/ssb/main.c                                 |  9 ++++++
 drivers/ssb/ssb_private.h                          |  5 ++++
 net/bluetooth/hci_conn.c                           |  6 ++--
 net/bluetooth/smp.c                                | 13 ++++++++
 13 files changed, 90 insertions(+), 35 deletions(-)

diff --git a/drivers/bcma/bcma_private.h b/drivers/bcma/bcma_private.h
index 19e3fbf..cb0c454 100644
--- a/drivers/bcma/bcma_private.h
+++ b/drivers/bcma/bcma_private.h
@@ -94,11 +94,16 @@ void bcma_core_pci_hostmode_init(struct bcma_drv_pci *p=
c);
 #ifdef CONFIG_BCMA_DRIVER_GPIO
 /* driver_gpio.c */
 int bcma_gpio_init(struct bcma_drv_cc *cc);
+int bcma_gpio_unregister(struct bcma_drv_cc *cc);
 #else
 static inline int bcma_gpio_init(struct bcma_drv_cc *cc)
 {
 	return -ENOTSUPP;
 }
+static inline int bcma_gpio_unregister(struct bcma_drv_cc *cc)
+{
+	return 0;
+}
 #endif /* CONFIG_BCMA_DRIVER_GPIO */
=20
 #endif
diff --git a/drivers/bcma/driver_gpio.c b/drivers/bcma/driver_gpio.c
index 9a6f585..71f755c 100644
--- a/drivers/bcma/driver_gpio.c
+++ b/drivers/bcma/driver_gpio.c
@@ -96,3 +96,8 @@ int bcma_gpio_init(struct bcma_drv_cc *cc)
=20
 	return gpiochip_add(chip);
 }
+
+int bcma_gpio_unregister(struct bcma_drv_cc *cc)
+{
+	return gpiochip_remove(&cc->gpio);
+}
diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index 4a92f64..324f9de 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -268,6 +268,13 @@ int bcma_bus_register(struct bcma_bus *bus)
 void bcma_bus_unregister(struct bcma_bus *bus)
 {
 	struct bcma_device *cores[3];
+	int err;
+
+	err =3D bcma_gpio_unregister(&bus->drv_cc);
+	if (err =3D=3D -EBUSY)
+		bcma_err(bus, "Some GPIOs are still in use.\n");
+	else if (err)
+		bcma_err(bus, "Can not unregister GPIO driver: %i\n", err);
=20
 	cores[0] =3D bcma_find_core(bus, BCMA_CORE_MIPS_74K);
 	cores[1] =3D bcma_find_core(bus, BCMA_CORE_PCIE);
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/driver=
s/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index 0f71d1d..e5fd209 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -36,6 +36,7 @@
 #include "debug.h"
=20
 #define N_TX_QUEUES	4 /* #tx queues on mac80211<->driver interface */
+#define BRCMS_FLUSH_TIMEOUT	500 /* msec */
=20
 /* Flags we support */
 #define MAC_FILTERS (FIF_PROMISC_IN_BSS | \
@@ -708,16 +709,29 @@ static void brcms_ops_rfkill_poll(struct ieee80211_hw=
 *hw)
 	wiphy_rfkill_set_hw_state(wl->pub->ieee_hw->wiphy, blocked);
 }
=20
+static bool brcms_tx_flush_completed(struct brcms_info *wl)
+{
+	bool result;
+
+	spin_lock_bh(&wl->lock);
+	result =3D brcms_c_tx_flush_completed(wl->wlc);
+	spin_unlock_bh(&wl->lock);
+	return result;
+}
+
 static void brcms_ops_flush(struct ieee80211_hw *hw, bool drop)
 {
 	struct brcms_info *wl =3D hw->priv;
+	int ret;
=20
 	no_printk("%s: drop =3D %s\n", __func__, drop ? "true" : "false");
=20
-	/* wait for packet queue and dma fifos to run empty */
-	spin_lock_bh(&wl->lock);
-	brcms_c_wait_for_tx_completion(wl->wlc, drop);
-	spin_unlock_bh(&wl->lock);
+	ret =3D wait_event_timeout(wl->tx_flush_wq,
+				 brcms_tx_flush_completed(wl),
+				 msecs_to_jiffies(BRCMS_FLUSH_TIMEOUT));
+
+	brcms_dbg_mac80211(wl->wlc->hw->d11core,
+			   "ret=3D%d\n", jiffies_to_msecs(ret));
 }
=20
 static const struct ieee80211_ops brcms_ops =3D {
@@ -772,6 +786,7 @@ void brcms_dpc(unsigned long data)
=20
  done:
 	spin_unlock_bh(&wl->lock);
+	wake_up(&wl->tx_flush_wq);
 }
=20
 /*
@@ -1020,6 +1035,8 @@ static struct brcms_info *brcms_attach(struct bcma_de=
vice *pdev)
=20
 	atomic_set(&wl->callbacks, 0);
=20
+	init_waitqueue_head(&wl->tx_flush_wq);
+
 	/* setup the bottom half handler */
 	tasklet_init(&wl->tasklet, brcms_dpc, (unsigned long) wl);
=20
@@ -1609,13 +1626,3 @@ bool brcms_rfkill_set_hw_state(struct brcms_info *wl)
 	spin_lock_bh(&wl->lock);
 	return blocked;
 }
-
-/*
- * precondition: perimeter lock has been acquired
- */
-void brcms_msleep(struct brcms_info *wl, uint ms)
-{
-	spin_unlock_bh(&wl->lock);
-	msleep(ms);
-	spin_lock_bh(&wl->lock);
-}
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h b/driver=
s/net/wireless/brcm80211/brcmsmac/mac80211_if.h
index 9358bd5..947ccac 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h
@@ -68,6 +68,8 @@ struct brcms_info {
 	spinlock_t lock;	/* per-device perimeter lock */
 	spinlock_t isr_lock;	/* per-device ISR synchronization lock */
=20
+	/* tx flush */
+	wait_queue_head_t tx_flush_wq;
=20
 	/* timer related fields */
 	atomic_t callbacks;	/* # outstanding callback functions */
@@ -100,7 +102,6 @@ extern struct brcms_timer *brcms_init_timer(struct brcm=
s_info *wl,
 extern void brcms_free_timer(struct brcms_timer *timer);
 extern void brcms_add_timer(struct brcms_timer *timer, uint ms, int period=
ic);
 extern bool brcms_del_timer(struct brcms_timer *timer);
-extern void brcms_msleep(struct brcms_info *wl, uint ms);
 extern void brcms_dpc(unsigned long data);
 extern void brcms_timer(struct brcms_timer *t);
 extern void brcms_fatal_error(struct brcms_info *wl);
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/w=
ireless/brcm80211/brcmsmac/main.c
index 9f3d7e9..8b58390 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -7511,25 +7511,16 @@ int brcms_c_get_curband(struct brcms_c_info *wlc)
 	return wlc->band->bandunit;
 }
=20
-void brcms_c_wait_for_tx_completion(struct brcms_c_info *wlc, bool drop)
+bool brcms_c_tx_flush_completed(struct brcms_c_info *wlc)
 {
-	int timeout =3D 20;
 	int i;
=20
 	/* Kick DMA to send any pending AMPDU */
 	for (i =3D 0; i < ARRAY_SIZE(wlc->hw->di); i++)
 		if (wlc->hw->di[i])
-			dma_txflush(wlc->hw->di[i]);
+			dma_kick_tx(wlc->hw->di[i]);
=20
-	/* wait for queue and DMA fifos to run dry */
-	while (brcms_txpktpendtot(wlc) > 0) {
-		brcms_msleep(wlc->wl, 1);
-
-		if (--timeout =3D=3D 0)
-			break;
-	}
-
-	WARN_ON_ONCE(timeout =3D=3D 0);
+	return !brcms_txpktpendtot(wlc);
 }
=20
 void brcms_c_set_beacon_listen_interval(struct brcms_c_info *wlc, u8 inter=
val)
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/pub.h b/drivers/net/wi=
reless/brcm80211/brcmsmac/pub.h
index 4fb2834..b0f14b7 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/pub.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/pub.h
@@ -314,8 +314,6 @@ extern void brcms_c_associate_upd(struct brcms_c_info *=
wlc, bool state);
 extern void brcms_c_scan_start(struct brcms_c_info *wlc);
 extern void brcms_c_scan_stop(struct brcms_c_info *wlc);
 extern int brcms_c_get_curband(struct brcms_c_info *wlc);
-extern void brcms_c_wait_for_tx_completion(struct brcms_c_info *wlc,
-					   bool drop);
 extern int brcms_c_set_channel(struct brcms_c_info *wlc, u16 channel);
 extern int brcms_c_set_rate_limit(struct brcms_c_info *wlc, u16 srl, u16 l=
rl);
 extern void brcms_c_get_current_rateset(struct brcms_c_info *wlc,
@@ -332,5 +330,6 @@ extern int brcms_c_set_tx_power(struct brcms_c_info *wl=
c, int txpwr);
 extern int brcms_c_get_tx_power(struct brcms_c_info *wlc);
 extern bool brcms_c_check_radio_disabled(struct brcms_c_info *wlc);
 extern void brcms_c_mute(struct brcms_c_info *wlc, bool on);
+extern bool brcms_c_tx_flush_completed(struct brcms_c_info *wlc);
=20
 #endif				/* _BRCM_PUB_H_ */
diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtl=
wifi/base.c
index 4494d13..0f8b051 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -1004,7 +1004,8 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struc=
t sk_buff *skb, u8 is_tx)
 					 is_tx ? "Tx" : "Rx");
=20
 				if (is_tx) {
-					rtl_lps_leave(hw);
+					schedule_work(&rtlpriv->
+						      works.lps_leave_work);
 					ppsc->last_delaylps_stamp_jiffies =3D
 					    jiffies;
 				}
@@ -1014,7 +1015,7 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struc=
t sk_buff *skb, u8 is_tx)
 		}
 	} else if (ETH_P_ARP =3D=3D ether_type) {
 		if (is_tx) {
-			rtl_lps_leave(hw);
+			schedule_work(&rtlpriv->works.lps_leave_work);
 			ppsc->last_delaylps_stamp_jiffies =3D jiffies;
 		}
=20
@@ -1024,7 +1025,7 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struc=
t sk_buff *skb, u8 is_tx)
 			 "802.1X %s EAPOL pkt!!\n", is_tx ? "Tx" : "Rx");
=20
 		if (is_tx) {
-			rtl_lps_leave(hw);
+			schedule_work(&rtlpriv->works.lps_leave_work);
 			ppsc->last_delaylps_stamp_jiffies =3D jiffies;
 		}
=20
diff --git a/drivers/ssb/driver_gpio.c b/drivers/ssb/driver_gpio.c
index 97ac0a3..eb27530 100644
--- a/drivers/ssb/driver_gpio.c
+++ b/drivers/ssb/driver_gpio.c
@@ -174,3 +174,15 @@ int ssb_gpio_init(struct ssb_bus *bus)
=20
 	return -1;
 }
+
+int ssb_gpio_unregister(struct ssb_bus *bus)
+{
+	if (ssb_chipco_available(&bus->chipco) ||
+	    ssb_extif_available(&bus->extif)) {
+		return gpiochip_remove(&bus->gpio);
+	} else {
+		SSB_WARN_ON(1);
+	}
+
+	return -1;
+}
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 772ad9b..24dc331 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -443,6 +443,15 @@ static void ssb_devices_unregister(struct ssb_bus *bus)
=20
 void ssb_bus_unregister(struct ssb_bus *bus)
 {
+	int err;
+
+	err =3D ssb_gpio_unregister(bus);
+	if (err =3D=3D -EBUSY)
+		ssb_dprintk(KERN_ERR PFX "Some GPIOs are still in use.\n");
+	else if (err)
+		ssb_dprintk(KERN_ERR PFX
+			    "Can not unregister GPIO driver: %i\n", err);
+
 	ssb_buses_lock();
 	ssb_devices_unregister(bus);
 	list_del(&bus->list);
diff --git a/drivers/ssb/ssb_private.h b/drivers/ssb/ssb_private.h
index 6c10b66..da38305 100644
--- a/drivers/ssb/ssb_private.h
+++ b/drivers/ssb/ssb_private.h
@@ -252,11 +252,16 @@ static inline void ssb_extif_init(struct ssb_extif *e=
xtif)
=20
 #ifdef CONFIG_SSB_DRIVER_GPIO
 extern int ssb_gpio_init(struct ssb_bus *bus);
+extern int ssb_gpio_unregister(struct ssb_bus *bus);
 #else /* CONFIG_SSB_DRIVER_GPIO */
 static inline int ssb_gpio_init(struct ssb_bus *bus)
 {
 	return -ENOTSUPP;
 }
+static inline int ssb_gpio_unregister(struct ssb_bus *bus)
+{
+	return 0;
+}
 #endif /* CONFIG_SSB_DRIVER_GPIO */
=20
 #endif /* LINUX_SSB_PRIVATE_H_ */
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index 25bfce0..4925a02 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -249,12 +249,12 @@ static void hci_conn_disconnect(struct hci_conn *conn)
 	__u8 reason =3D hci_proto_disconn_ind(conn);
=20
 	switch (conn->type) {
-	case ACL_LINK:
-		hci_acl_disconn(conn, reason);
-		break;
 	case AMP_LINK:
 		hci_amp_disconn(conn, reason);
 		break;
+	default:
+		hci_acl_disconn(conn, reason);
+		break;
 	}
 }
=20
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 68a9587..5abefb1 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -859,6 +859,19 @@ int smp_sig_channel(struct l2cap_conn *conn, struct sk=
_buff *skb)
=20
 	skb_pull(skb, sizeof(code));
=20
+	/*
+	 * The SMP context must be initialized for all other PDUs except
+	 * pairing and security requests. If we get any other PDU when
+	 * not initialized simply disconnect (done if this function
+	 * returns an error).
+	 */
+	if (code !=3D SMP_CMD_PAIRING_REQ && code !=3D SMP_CMD_SECURITY_REQ &&
+	    !conn->smp_chan) {
+		BT_ERR("Unexpected SMP command 0x%02x. Disconnecting.", code);
+		kfree_skb(skb);
+		return -ENOTSUPP;
+	}
+
 	switch (code) {
 	case SMP_CMD_PAIRING_REQ:
 		reason =3D smp_cmd_pairing_req(conn, skb);
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--J/dobhs11T7y2rNN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRErA/AAoJEJctW/TcYTgGcrsP/11W/ntiBjWdrsB1NcOv9xjR
EkShzsJKclRIJcpqhZZL0Y9NS7fwECfp+qydgCu9+lXJcms2KkpB74ynIuFUANUy
bDcW+bWZ1oq+jUV6o3lldGFViT3AuDZu6YGgSRieangJE4CrmDo1Xg2eLg3QYu3O
0B+3KU+MsGHvSsb49HkmdmmAqPgIn7skG+Ah8nTXAUg9QT+Fxq0jaBBKO6GdYC31
ji2W5k0B0WprI4OoZI5xP4QUloyI3e3Tjj7g9cXxSiPyBupRvawcj7TKJVK0VlX3
orjhyl4dXJMG5YbYuMBTSAjl1RLhnT+Nu/kMDh+OphJeXq+QLrhy3ojQe7Rl7qtd
KXDmcd5+h03I2zRMDyqGkDm+xzVTr/PRNbM9z0giQRBXM1GN1Rc6DdPtSAyhlEAt
LQDaaQwzkiPF1fDpU6xsT/680dgUfcLN8J258jM+gC9zR+yVbfuhMsq3mNJvrIcu
ye2nAk45ERJ4jinJHE0l8XINzOpsW54N7YvCCFlSPfTVZcJYdnwXE0/TPfQOzf1Z
V/DiW99/S8ZK5vlSH57jPHaBvGZnroVyUEvhVUaQDSmbn/jsOgfR5RcdnPG2rF/v
z+sGQy4OeISDWrs+RS58IPUBd3wpnRSVH8ghExWF0Aaz+pD4VAr3GzSby2KmZV+M
jDX7iPY079YpMB9lip/7
=FdSR
-----END PGP SIGNATURE-----

--J/dobhs11T7y2rNN--
