From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-09-10
Date: Tue, 10 Sep 2013 15:38:45 -0400
Message-ID: <20130910193845.GD1960@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WIyZ46R2i8wDzkSu"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This is a pull request for a few early fixes for the 3.12 stream.

Alexey Khoroshilov corrects a use-after-free issue on rtl8187 found
by the Linux Driver Verification project.

Arend van Spriel provides a brcmfmac patch to fix a build issue
reported by Randy Dunlap.

Hauke Mehrtens offers a bcma fix to properly account for the storage
width of error code values before checking them.

Solomon Peachy brings a pair of cw1200 fixes to avoid hangs in that
driver with SPI devices.  One avoids transfers in interrupt context,
the other fixes a locking issue.

Stanislaw Gruszka changes the initialization of the rt2800 driver to
avoid a freeze, addressing a bug in the Red Hat bugzilla.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit e7d33bb5ea82922e6ddcfc6b28a630b1a4ced071:

  lockref: add ability to mark lockrefs "dead" (2013-09-07 15:49:18 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2013-09-09

for you to fetch changes up to f4e1a4d3ecbb9e42bdf8e7869ee8a4ebfa27fb20:

  rt2800: change initialization sequence to fix system freeze (2013-09-09 1=
4:44:34 -0400)

----------------------------------------------------------------
Alexey Khoroshilov (1):
      rtl8187: fix use after free on failure path in rtl8187_init_urbs()

Arend van Spriel (1):
      brcmfmac: fix bus interface selection in Kconfig

Hauke Mehrtens (1):
      bcma: fix error code handling on 64 Bit systems

Solomon Peachy (2):
      cw1200: Don't perform SPI transfers in interrupt context
      cw1200: Prevent a lock-related hang in the cw1200_spi driver

Stanislaw Gruszka (1):
      rt2800: change initialization sequence to fix system freeze

 drivers/bcma/scan.c                        | 12 +++++++-----
 drivers/net/wireless/brcm80211/Kconfig     |  4 ++--
 drivers/net/wireless/cw1200/cw1200_spi.c   | 28 +++++++++++++++++++++++++-=
--
 drivers/net/wireless/cw1200/fwio.c         |  2 +-
 drivers/net/wireless/cw1200/hwbus.h        |  1 +
 drivers/net/wireless/cw1200/hwio.c         | 15 +++++++++++++++
 drivers/net/wireless/rt2x00/rt2800lib.c    | 11 ++++++-----
 drivers/net/wireless/rtl818x/rtl8187/dev.c | 15 ++++++++++-----
 8 files changed, 67 insertions(+), 21 deletions(-)

diff --git a/drivers/bcma/scan.c b/drivers/bcma/scan.c
index cd6b20f..3776840 100644
--- a/drivers/bcma/scan.c
+++ b/drivers/bcma/scan.c
@@ -269,6 +269,8 @@ static struct bcma_device *bcma_find_core_reverse(struc=
t bcma_bus *bus, u16 core
 	return NULL;
 }
=20
+#define IS_ERR_VALUE_U32(x) ((x) >=3D (u32)-MAX_ERRNO)
+
 static int bcma_get_next_core(struct bcma_bus *bus, u32 __iomem **eromptr,
 			      struct bcma_device_id *match, int core_num,
 			      struct bcma_device *core)
@@ -351,11 +353,11 @@ static int bcma_get_next_core(struct bcma_bus *bus, u=
32 __iomem **eromptr,
 	 * the main register space for the core
 	 */
 	tmp =3D bcma_erom_get_addr_desc(bus, eromptr, SCAN_ADDR_TYPE_SLAVE, 0);
-	if (tmp =3D=3D 0 || IS_ERR_VALUE(tmp)) {
+	if (tmp =3D=3D 0 || IS_ERR_VALUE_U32(tmp)) {
 		/* Try again to see if it is a bridge */
 		tmp =3D bcma_erom_get_addr_desc(bus, eromptr,
 					      SCAN_ADDR_TYPE_BRIDGE, 0);
-		if (tmp =3D=3D 0 || IS_ERR_VALUE(tmp)) {
+		if (tmp =3D=3D 0 || IS_ERR_VALUE_U32(tmp)) {
 			return -EILSEQ;
 		} else {
 			bcma_info(bus, "Bridge found\n");
@@ -369,7 +371,7 @@ static int bcma_get_next_core(struct bcma_bus *bus, u32=
 __iomem **eromptr,
 		for (j =3D 0; ; j++) {
 			tmp =3D bcma_erom_get_addr_desc(bus, eromptr,
 				SCAN_ADDR_TYPE_SLAVE, i);
-			if (IS_ERR_VALUE(tmp)) {
+			if (IS_ERR_VALUE_U32(tmp)) {
 				/* no more entries for port _i_ */
 				/* pr_debug("erom: slave port %d "
 				 * "has %d descriptors\n", i, j); */
@@ -386,7 +388,7 @@ static int bcma_get_next_core(struct bcma_bus *bus, u32=
 __iomem **eromptr,
 		for (j =3D 0; ; j++) {
 			tmp =3D bcma_erom_get_addr_desc(bus, eromptr,
 				SCAN_ADDR_TYPE_MWRAP, i);
-			if (IS_ERR_VALUE(tmp)) {
+			if (IS_ERR_VALUE_U32(tmp)) {
 				/* no more entries for port _i_ */
 				/* pr_debug("erom: master wrapper %d "
 				 * "has %d descriptors\n", i, j); */
@@ -404,7 +406,7 @@ static int bcma_get_next_core(struct bcma_bus *bus, u32=
 __iomem **eromptr,
 		for (j =3D 0; ; j++) {
 			tmp =3D bcma_erom_get_addr_desc(bus, eromptr,
 				SCAN_ADDR_TYPE_SWRAP, i + hack);
-			if (IS_ERR_VALUE(tmp)) {
+			if (IS_ERR_VALUE_U32(tmp)) {
 				/* no more entries for port _i_ */
 				/* pr_debug("erom: master wrapper %d "
 				 * has %d descriptors\n", i, j); */
diff --git a/drivers/net/wireless/brcm80211/Kconfig b/drivers/net/wireless/=
brcm80211/Kconfig
index fc8a0fa..b00a7e9 100644
--- a/drivers/net/wireless/brcm80211/Kconfig
+++ b/drivers/net/wireless/brcm80211/Kconfig
@@ -28,7 +28,7 @@ config BRCMFMAC
=20
 config BRCMFMAC_SDIO
 	bool "SDIO bus interface support for FullMAC driver"
-	depends on MMC
+	depends on (MMC =3D y || MMC =3D BRCMFMAC)
 	depends on BRCMFMAC
 	select FW_LOADER
 	default y
@@ -39,7 +39,7 @@ config BRCMFMAC_SDIO
=20
 config BRCMFMAC_USB
 	bool "USB bus interface support for FullMAC driver"
-	depends on USB
+	depends on (USB =3D y || USB =3D BRCMFMAC)
 	depends on BRCMFMAC
 	select FW_LOADER
 	---help---
diff --git a/drivers/net/wireless/cw1200/cw1200_spi.c b/drivers/net/wireles=
s/cw1200/cw1200_spi.c
index d063760..f5e6b48 100644
--- a/drivers/net/wireless/cw1200/cw1200_spi.c
+++ b/drivers/net/wireless/cw1200/cw1200_spi.c
@@ -40,7 +40,9 @@ struct hwbus_priv {
 	struct cw1200_common	*core;
 	const struct cw1200_platform_data_spi *pdata;
 	spinlock_t		lock; /* Serialize all bus operations */
+	wait_queue_head_t       wq;
 	int claimed;
+	int irq_disabled;
 };
=20
 #define SDIO_TO_SPI_ADDR(addr) ((addr & 0x1f)>>2)
@@ -197,8 +199,11 @@ static void cw1200_spi_lock(struct hwbus_priv *self)
 {
 	unsigned long flags;
=20
+	DECLARE_WAITQUEUE(wait, current);
+
 	might_sleep();
=20
+	add_wait_queue(&self->wq, &wait);
 	spin_lock_irqsave(&self->lock, flags);
 	while (1) {
 		set_current_state(TASK_UNINTERRUPTIBLE);
@@ -211,6 +216,7 @@ static void cw1200_spi_lock(struct hwbus_priv *self)
 	set_current_state(TASK_RUNNING);
 	self->claimed =3D 1;
 	spin_unlock_irqrestore(&self->lock, flags);
+	remove_wait_queue(&self->wq, &wait);
=20
 	return;
 }
@@ -222,6 +228,8 @@ static void cw1200_spi_unlock(struct hwbus_priv *self)
 	spin_lock_irqsave(&self->lock, flags);
 	self->claimed =3D 0;
 	spin_unlock_irqrestore(&self->lock, flags);
+	wake_up(&self->wq);
+
 	return;
 }
=20
@@ -230,6 +238,8 @@ static irqreturn_t cw1200_spi_irq_handler(int irq, void=
 *dev_id)
 	struct hwbus_priv *self =3D dev_id;
=20
 	if (self->core) {
+		disable_irq_nosync(self->func->irq);
+		self->irq_disabled =3D 1;
 		cw1200_irq_handler(self->core);
 		return IRQ_HANDLED;
 	} else {
@@ -263,13 +273,22 @@ exit:
=20
 static int cw1200_spi_irq_unsubscribe(struct hwbus_priv *self)
 {
-	int ret =3D 0;
-
 	pr_debug("SW IRQ unsubscribe\n");
 	disable_irq_wake(self->func->irq);
 	free_irq(self->func->irq, self);
=20
-	return ret;
+	return 0;
+}
+
+static int cw1200_spi_irq_enable(struct hwbus_priv *self, int enable)
+{
+	/* Disables are handled by the interrupt handler */
+	if (enable && self->irq_disabled) {
+		enable_irq(self->func->irq);
+		self->irq_disabled =3D 0;
+	}
+
+	return 0;
 }
=20
 static int cw1200_spi_off(const struct cw1200_platform_data_spi *pdata)
@@ -349,6 +368,7 @@ static struct hwbus_ops cw1200_spi_hwbus_ops =3D {
 	.unlock			=3D cw1200_spi_unlock,
 	.align_size		=3D cw1200_spi_align_size,
 	.power_mgmt		=3D cw1200_spi_pm,
+	.irq_enable             =3D cw1200_spi_irq_enable,
 };
=20
 /* Probe Function to be called by SPI stack when device is discovered */
@@ -400,6 +420,8 @@ static int cw1200_spi_probe(struct spi_device *func)
=20
 	spi_set_drvdata(func, self);
=20
+	init_waitqueue_head(&self->wq);
+
 	status =3D cw1200_spi_irq_subscribe(self);
=20
 	status =3D cw1200_core_probe(&cw1200_spi_hwbus_ops,
diff --git a/drivers/net/wireless/cw1200/fwio.c b/drivers/net/wireless/cw12=
00/fwio.c
index acdff0f..0b2061b 100644
--- a/drivers/net/wireless/cw1200/fwio.c
+++ b/drivers/net/wireless/cw1200/fwio.c
@@ -485,7 +485,7 @@ int cw1200_load_firmware(struct cw1200_common *priv)
=20
 	/* Enable interrupt signalling */
 	priv->hwbus_ops->lock(priv->hwbus_priv);
-	ret =3D __cw1200_irq_enable(priv, 1);
+	ret =3D __cw1200_irq_enable(priv, 2);
 	priv->hwbus_ops->unlock(priv->hwbus_priv);
 	if (ret < 0)
 		goto unsubscribe;
diff --git a/drivers/net/wireless/cw1200/hwbus.h b/drivers/net/wireless/cw1=
200/hwbus.h
index 8b2fc83..51dfb3a 100644
--- a/drivers/net/wireless/cw1200/hwbus.h
+++ b/drivers/net/wireless/cw1200/hwbus.h
@@ -28,6 +28,7 @@ struct hwbus_ops {
 	void (*unlock)(struct hwbus_priv *self);
 	size_t (*align_size)(struct hwbus_priv *self, size_t size);
 	int (*power_mgmt)(struct hwbus_priv *self, bool suspend);
+	int (*irq_enable)(struct hwbus_priv *self, int enable);
 };
=20
 #endif /* CW1200_HWBUS_H */
diff --git a/drivers/net/wireless/cw1200/hwio.c b/drivers/net/wireless/cw12=
00/hwio.c
index ff230b7..41bd761 100644
--- a/drivers/net/wireless/cw1200/hwio.c
+++ b/drivers/net/wireless/cw1200/hwio.c
@@ -273,6 +273,21 @@ int __cw1200_irq_enable(struct cw1200_common *priv, in=
t enable)
 	u16 val16;
 	int ret;
=20
+	/* We need to do this hack because the SPI layer can sleep on I/O
+	   and the general path involves I/O to the device in interrupt
+	   context.
+
+	   However, the initial enable call needs to go to the hardware.
+
+	   We don't worry about shutdown because we do a full reset which
+	   clears the interrupt enabled bits.
+	*/
+	if (priv->hwbus_ops->irq_enable) {
+		ret =3D priv->hwbus_ops->irq_enable(priv->hwbus_priv, enable);
+		if (ret || enable < 2)
+			return ret;
+	}
+
 	if (HIF_8601_SILICON =3D=3D priv->hw_type) {
 		ret =3D __cw1200_reg_read_32(priv, ST90TDS_CONFIG_REG_ID, &val32);
 		if (ret < 0) {
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless=
/rt2x00/rt2800lib.c
index 95e6e61..88ce656 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -6659,19 +6659,20 @@ int rt2800_enable_radio(struct rt2x00_dev *rt2x00de=
v)
 		     rt2800_init_registers(rt2x00dev)))
 		return -EIO;
=20
+	if (unlikely(rt2800_wait_bbp_rf_ready(rt2x00dev)))
+		return -EIO;
+
 	/*
 	 * Send signal to firmware during boot time.
 	 */
 	rt2800_register_write(rt2x00dev, H2M_BBP_AGENT, 0);
 	rt2800_register_write(rt2x00dev, H2M_MAILBOX_CSR, 0);
-	if (rt2x00_is_usb(rt2x00dev)) {
+	if (rt2x00_is_usb(rt2x00dev))
 		rt2800_register_write(rt2x00dev, H2M_INT_SRC, 0);
-		rt2800_mcu_request(rt2x00dev, MCU_BOOT_SIGNAL, 0, 0, 0);
-	}
+	rt2800_mcu_request(rt2x00dev, MCU_BOOT_SIGNAL, 0, 0, 0);
 	msleep(1);
=20
-	if (unlikely(rt2800_wait_bbp_rf_ready(rt2x00dev) ||
-		     rt2800_wait_bbp_ready(rt2x00dev)))
+	if (unlikely(rt2800_wait_bbp_ready(rt2x00dev)))
 		return -EIO;
=20
 	rt2800_init_bbp(rt2x00dev);
diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/wirel=
ess/rtl818x/rtl8187/dev.c
index 841fb9d..9a6edb0 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
@@ -438,17 +438,16 @@ static int rtl8187_init_urbs(struct ieee80211_hw *dev)
 		skb_queue_tail(&priv->rx_queue, skb);
 		usb_anchor_urb(entry, &priv->anchored);
 		ret =3D usb_submit_urb(entry, GFP_KERNEL);
+		usb_put_urb(entry);
 		if (ret) {
 			skb_unlink(skb, &priv->rx_queue);
 			usb_unanchor_urb(entry);
 			goto err;
 		}
-		usb_free_urb(entry);
 	}
 	return ret;
=20
 err:
-	usb_free_urb(entry);
 	kfree_skb(skb);
 	usb_kill_anchored_urbs(&priv->anchored);
 	return ret;
@@ -956,8 +955,12 @@ static int rtl8187_start(struct ieee80211_hw *dev)
 				  (RETRY_COUNT << 8  /* short retry limit */) |
 				  (RETRY_COUNT << 0  /* long retry limit */) |
 				  (7 << 21 /* MAX TX DMA */));
-		rtl8187_init_urbs(dev);
-		rtl8187b_init_status_urb(dev);
+		ret =3D rtl8187_init_urbs(dev);
+		if (ret)
+			goto rtl8187_start_exit;
+		ret =3D rtl8187b_init_status_urb(dev);
+		if (ret)
+			usb_kill_anchored_urbs(&priv->anchored);
 		goto rtl8187_start_exit;
 	}
=20
@@ -966,7 +969,9 @@ static int rtl8187_start(struct ieee80211_hw *dev)
 	rtl818x_iowrite32(priv, &priv->map->MAR[0], ~0);
 	rtl818x_iowrite32(priv, &priv->map->MAR[1], ~0);
=20
-	rtl8187_init_urbs(dev);
+	ret =3D rtl8187_init_urbs(dev);
+	if (ret)
+		goto rtl8187_start_exit;
=20
 	reg =3D RTL818X_RX_CONF_ONLYERLPKT |
 	      RTL818X_RX_CONF_RX_AUTORESETPHY |
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--WIyZ46R2i8wDzkSu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSL3VFAAoJEJctW/TcYTgGlYcP/i66/45F4+L1/V655zaURbFx
ejN0k/jx4DhHJLHhbk81Epg9SK9+bDCqoCHkIrIXlVDaXcx8R2o9PEsO20h55RRK
ZF3hotTfc2FQrHr+oCQjjOiNb34X4jpKlME97iLIpHKxw+5iIzRVTQc8pzycFdI/
HadJ3WTOavRk1zHj6Kt6ENrI4J/ytE9dIjLSt9ysJ8Io6LaU50xRveeYI4uEgKsV
Ms+xYUmhbCMgaOfXqyRGOfEJj+yRAfBFGlI+q9BUWeGtdYfXqEmQlCH79kHrdwqz
K0lWGK2aDIEsDLjUrC4Io/x8D03W4njQTpTFyV0JVc9qJk7Xvssd2h8fL8QJriDv
D29tzcF30S0t+NG3hH8+PWOMFpJV/3IiK+/9FaKazKrHmjatyCd5FUJzL/PWb9Bn
Mpzn7kaDr/KP6E1u9NQuNyqjbQdUkLyYDyeIpE8AQZvzYpkw9t/f8J2ba0eKnE0e
KBeNQkEoOh0WjSk3kf42fuIPygOrB+2nkhgqShg3RTk+UjZ9g69GwoJc93IfVNsa
ocrknmNsFCC5fYIs9BYQly8aTyJ6Pnj22WFerPZlGgcRJWOZJI9XYgkgCF61/DSz
46/6eEVcc4905U2psR0OByIHsn+AH0CgdV77iwVLb9JP3dfTCIBvD+XcSBrZVROa
RPnF4ZdjNC19C9Qui8mZ
=O/XM
-----END PGP SIGNATURE-----

--WIyZ46R2i8wDzkSu--
