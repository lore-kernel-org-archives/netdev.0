From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-09-17
Date: Wed, 17 Sep 2014 11:23:01 -0400
Message-ID: <20140917152300.GB13392@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.17 stream...

Arend van Spriel sends a trio of minor brcmfmac fixes, including a
fix for a Kconfig/build issue, a fix for a crash (null reference),
and a regression fix related to event handling on a P2P interface.

Hante Meuleman follows-up with a brcmfmac fix for a memory leak.

Johannes Stezenbach brings an ath9k_htc fix for a regression related
to hardware decryption offload.

Marcel Holtmann delivers a one-liner to properly mark a device ID
table in rfkill-gpio.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit ae0fd6354134e63aa3e62456e2080c430287144d:

  Revert "ath9k: Calculate sleep duration" (2014-09-11 14:17:20 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-09-16

for you to fetch changes up to dda3b191eb6c5a56d443723dcb71ade60d97c04f:

  net: rfkill: gpio: Enable module auto-loading for ACPI based switches (20=
14-09-16 16:09:01 -0400)

----------------------------------------------------------------
Arend van Spriel (3):
      brcmfmac: conditionally compile firmware protocol source code
      brcmfmac: obtain ifp through wdev structure
      brcmfmac: handle IF event for P2P_DEVICE interface

Hante Meuleman (1):
      brcmfmac: Fix memory leak and missing assignment.

Johannes Stezenbach (1):
      ath9k_htc: fix random decryption failure

Marcel Holtmann (1):
      net: rfkill: gpio: Enable module auto-loading for ACPI based switches

 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c         |  2 +-
 drivers/net/wireless/brcm80211/Kconfig                | 10 ++++++++++
 drivers/net/wireless/brcm80211/brcmfmac/Makefile      | 10 ++++++----
 drivers/net/wireless/brcm80211/brcmfmac/bcdc.h        |  7 +++++--
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c        | 12 +++++++++---
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h        |  2 ++
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h      | 11 +++++++++--
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  9 +++++++--
 net/rfkill/rfkill-gpio.c                              |  1 +
 9 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wi=
reless/ath/ath9k/htc_drv_txrx.c
index bb86eb2ffc95..f0484b1b617e 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -978,7 +978,7 @@ static bool ath9k_rx_prepare(struct ath9k_htc_priv *pri=
v,
 	struct ath_hw *ah =3D common->ah;
 	struct ath_htc_rx_status *rxstatus;
 	struct ath_rx_status rx_stats;
-	bool decrypt_error;
+	bool decrypt_error =3D false;
=20
 	if (skb->len < HTC_RX_FRAME_HEADER_SIZE) {
 		ath_err(common, "Corrupted RX frame, dropping (len: %d)\n",
diff --git a/drivers/net/wireless/brcm80211/Kconfig b/drivers/net/wireless/=
brcm80211/Kconfig
index b8e2561ea645..fe3dc126b149 100644
--- a/drivers/net/wireless/brcm80211/Kconfig
+++ b/drivers/net/wireless/brcm80211/Kconfig
@@ -27,10 +27,17 @@ config BRCMFMAC
 	  one of the bus interface support. If you choose to build a module,
 	  it'll be called brcmfmac.ko.
=20
+config BRCMFMAC_PROTO_BCDC
+	bool
+
+config BRCMFMAC_PROTO_MSGBUF
+	bool
+
 config BRCMFMAC_SDIO
 	bool "SDIO bus interface support for FullMAC driver"
 	depends on (MMC =3D y || MMC =3D BRCMFMAC)
 	depends on BRCMFMAC
+	select BRCMFMAC_PROTO_BCDC
 	select FW_LOADER
 	default y
 	---help---
@@ -42,6 +49,7 @@ config BRCMFMAC_USB
 	bool "USB bus interface support for FullMAC driver"
 	depends on (USB =3D y || USB =3D BRCMFMAC)
 	depends on BRCMFMAC
+	select BRCMFMAC_PROTO_BCDC
 	select FW_LOADER
 	---help---
 	  This option enables the USB bus interface support for Broadcom
@@ -52,6 +60,8 @@ config BRCMFMAC_PCIE
 	bool "PCIE bus interface support for FullMAC driver"
 	depends on BRCMFMAC
 	depends on PCI
+	depends on HAS_DMA
+	select BRCMFMAC_PROTO_MSGBUF
 	select FW_LOADER
 	---help---
 	  This option enables the PCIE bus interface support for Broadcom
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/Makefile b/drivers/net=
/wireless/brcm80211/brcmfmac/Makefile
index c35adf4bc70b..90a977fe9a64 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/Makefile
+++ b/drivers/net/wireless/brcm80211/brcmfmac/Makefile
@@ -30,16 +30,18 @@ brcmfmac-objs +=3D \
 		fwsignal.o \
 		p2p.o \
 		proto.o \
-		bcdc.o \
-		commonring.o \
-		flowring.o \
-		msgbuf.o \
 		dhd_common.o \
 		dhd_linux.o \
 		firmware.o \
 		feature.o \
 		btcoex.o \
 		vendor.o
+brcmfmac-$(CONFIG_BRCMFMAC_PROTO_BCDC) +=3D \
+		bcdc.o
+brcmfmac-$(CONFIG_BRCMFMAC_PROTO_MSGBUF) +=3D \
+		commonring.o \
+		flowring.o \
+		msgbuf.o
 brcmfmac-$(CONFIG_BRCMFMAC_SDIO) +=3D \
 		dhd_sdio.o \
 		bcmsdh.o
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcdc.h b/drivers/net/w=
ireless/brcm80211/brcmfmac/bcdc.h
index 17e8c039ff32..6003179c0ceb 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcdc.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcdc.h
@@ -16,9 +16,12 @@
 #ifndef BRCMFMAC_BCDC_H
 #define BRCMFMAC_BCDC_H
=20
-
+#ifdef CONFIG_BRCMFMAC_PROTO_BCDC
 int brcmf_proto_bcdc_attach(struct brcmf_pub *drvr);
 void brcmf_proto_bcdc_detach(struct brcmf_pub *drvr);
-
+#else
+static inline int brcmf_proto_bcdc_attach(struct brcmf_pub *drvr) { return=
 0; }
+static inline void brcmf_proto_bcdc_detach(struct brcmf_pub *drvr) {}
+#endif
=20
 #endif /* BRCMFMAC_BCDC_H */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c b/drivers/net/w=
ireless/brcm80211/brcmfmac/fweh.c
index 4f1daabc551b..44fc85f68f7a 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
@@ -185,7 +185,13 @@ static void brcmf_fweh_handle_if_event(struct brcmf_pu=
b *drvr,
 		  ifevent->action, ifevent->ifidx, ifevent->bssidx,
 		  ifevent->flags, ifevent->role);
=20
-	if (ifevent->flags & BRCMF_E_IF_FLAG_NOIF) {
+	/* The P2P Device interface event must not be ignored
+	 * contrary to what firmware tells us. The only way to
+	 * distinguish the P2P Device is by looking at the ifidx
+	 * and bssidx received.
+	 */
+	if (!(ifevent->ifidx =3D=3D 0 && ifevent->bssidx =3D=3D 1) &&
+	    (ifevent->flags & BRCMF_E_IF_FLAG_NOIF)) {
 		brcmf_dbg(EVENT, "event can be ignored\n");
 		return;
 	}
@@ -210,12 +216,12 @@ static void brcmf_fweh_handle_if_event(struct brcmf_p=
ub *drvr,
 				return;
 	}
=20
-	if (ifevent->action =3D=3D BRCMF_E_IF_CHANGE)
+	if (ifp && ifevent->action =3D=3D BRCMF_E_IF_CHANGE)
 		brcmf_fws_reset_interface(ifp);
=20
 	err =3D brcmf_fweh_call_event_handler(ifp, emsg->event_code, emsg, data);
=20
-	if (ifevent->action =3D=3D BRCMF_E_IF_DEL) {
+	if (ifp && ifevent->action =3D=3D BRCMF_E_IF_DEL) {
 		brcmf_fws_del_interface(ifp);
 		brcmf_del_if(drvr, ifevent->bssidx);
 	}
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fweh.h b/drivers/net/w=
ireless/brcm80211/brcmfmac/fweh.h
index dd20b1862d44..cbf033f59109 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/fweh.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/fweh.h
@@ -172,6 +172,8 @@ enum brcmf_fweh_event_code {
 #define BRCMF_E_IF_ROLE_STA			0
 #define BRCMF_E_IF_ROLE_AP			1
 #define BRCMF_E_IF_ROLE_WDS			2
+#define BRCMF_E_IF_ROLE_P2P_GO			3
+#define BRCMF_E_IF_ROLE_P2P_CLIENT		4
=20
 /**
  * definitions for event packet validation.
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h b/drivers/net=
/wireless/brcm80211/brcmfmac/msgbuf.h
index f901ae52bf2b..77a51b8c1e12 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h
@@ -15,6 +15,7 @@
 #ifndef BRCMFMAC_MSGBUF_H
 #define BRCMFMAC_MSGBUF_H
=20
+#ifdef CONFIG_BRCMFMAC_PROTO_MSGBUF
=20
 #define BRCMF_H2D_MSGRING_CONTROL_SUBMIT_MAX_ITEM	20
 #define BRCMF_H2D_MSGRING_RXPOST_SUBMIT_MAX_ITEM	256
@@ -32,9 +33,15 @@
=20
=20
 int brcmf_proto_msgbuf_rx_trigger(struct device *dev);
+void brcmf_msgbuf_delete_flowring(struct brcmf_pub *drvr, u8 flowid);
 int brcmf_proto_msgbuf_attach(struct brcmf_pub *drvr);
 void brcmf_proto_msgbuf_detach(struct brcmf_pub *drvr);
-void brcmf_msgbuf_delete_flowring(struct brcmf_pub *drvr, u8 flowid);
-
+#else
+static inline int brcmf_proto_msgbuf_attach(struct brcmf_pub *drvr)
+{
+	return 0;
+}
+static inline void brcmf_proto_msgbuf_detach(struct brcmf_pub *drvr) {}
+#endif
=20
 #endif /* BRCMFMAC_MSGBUF_H */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index 02fe706fc9ec..f3a9804988a6 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -497,8 +497,11 @@ brcmf_configure_arp_offload(struct brcmf_if *ifp, bool=
 enable)
 static void
 brcmf_cfg80211_update_proto_addr_mode(struct wireless_dev *wdev)
 {
-	struct net_device *ndev =3D wdev->netdev;
-	struct brcmf_if *ifp =3D netdev_priv(ndev);
+	struct brcmf_cfg80211_vif *vif;
+	struct brcmf_if *ifp;
+
+	vif =3D container_of(wdev, struct brcmf_cfg80211_vif, wdev);
+	ifp =3D vif->ifp;
=20
 	if ((wdev->iftype =3D=3D NL80211_IFTYPE_ADHOC) ||
 	    (wdev->iftype =3D=3D NL80211_IFTYPE_AP) ||
@@ -5143,6 +5146,7 @@ static int brcmf_enable_bw40_2g(struct brcmf_cfg80211=
_info *cfg)
=20
 		ch.band =3D BRCMU_CHAN_BAND_2G;
 		ch.bw =3D BRCMU_CHAN_BW_40;
+		ch.sb =3D BRCMU_CHAN_SB_NONE;
 		ch.chnum =3D 0;
 		cfg->d11inf.encchspec(&ch);
=20
@@ -5176,6 +5180,7 @@ static int brcmf_enable_bw40_2g(struct brcmf_cfg80211=
_info *cfg)
=20
 			brcmf_update_bw40_channel_flag(&band->channels[j], &ch);
 		}
+		kfree(pbuf);
 	}
 	return err;
 }
diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 02a86a27fd84..5fa54dd78e25 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -163,6 +163,7 @@ static const struct acpi_device_id rfkill_acpi_match[] =
=3D {
 	{ "LNV4752", RFKILL_TYPE_GPS },
 	{ },
 };
+MODULE_DEVICE_TABLE(acpi, rfkill_acpi_match);
 #endif
=20
 static struct platform_driver rfkill_gpio_driver =3D {
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUGadUAAoJEJctW/TcYTgGhC0P/35cN5ZvdkU0L5CXLPG04lnJ
wjc8UCt0x31NKae+rYBPm4uqEhzOsU2VMYBdi5y9wa7pbSxuh301Ez6E79b7kWQJ
UssqnGarzIKnyy5EekqNayweEBrMImqQUNF4YZqaL4eaUKA7mbXdVrt6ZAzk0Ar5
IJb1A7BMGx31lVK9ucygl9zP+f4y+2tqMCNE+3Cg/nBcm7NBGYMifOBKVHSgv8G8
4sQPmpe2yTBEEGv2g+Lj1TX8XNqYE/ius0xvJtT25RvLOkeX1kQ6FTolvPzutaEK
yZqZ+93suqlMPgJH7gni6C3xyBdKgW4jqLiEeMNVi8OQJUTlONpNMxoWaNynz+8g
eCwxZfo1yWU7acDF6lnEvO3fvl0jdWrHCHovSR+jey3t2uQh2+WIbL3HV37uE4z0
GoHdRX/ozhoqmGkQy97umGhlPGdyXDvWDLXA61dxpip5GWzVmx5LT8POSrUt1q3t
x8xqx6FFwjKM5SkQ4I1/TM53/85wT5oBx7Bn+acWKzKayP7T++K3XQc4ctc2ilXc
IiZ24NPhxJkEM8Z/daNhF2Dx5LhagGGW2YaEFMxdg5RqSEV83L4bT+DPKryaDejA
0iIEblMyYbYATNpVFv/zbPb2dN/spZ/3nK5RP5jduRMPEXkGxx4keNLDYEjtNCWH
MJWWuWBFos1t71GwR6KX
=afvC
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--
