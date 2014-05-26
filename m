From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 4/8] net: cdc_ncm: use sysfs for rx/tx aggregation tuning
Date: Mon, 26 May 2014 12:53:41 +0200
Message-ID: <1401101625-12342-5-git-send-email-bjorn@mork.no>
References: <1401101625-12342-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Lars Melin <larsm17@gmail.com>, Peter Stuge <peter@stuge.se>,
	Greg Suarez <gsuarez@smithmicro.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43710 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752095AbaEZK4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2014 06:56:16 -0400
In-Reply-To: <1401101625-12342-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Attach a driver specific sysfs group to the netdev, and use it
for the rx/tx aggregation variables.

The datagram aggregation defined by the CDC NCM specification is
specific to this device class (including CDC MBIM). Using the
ethtool interrupt coalesce API as an interface to the aggregation
parameters redefined that API in a driver specific and confusing
way.  A sysfs group
 - makes it clear that this is a driver specific userspace API, and
 - allows us to export the real values instead of some translated
   version, and
 - lets us include more aggregation variables which were impossible
   to force into the ethtool API.

Additionally, using sysfs allows tuning the driver on space
constrained hosts where userspace tools like ethtool are undesired.

Suggested-by: Peter Stuge <peter@stuge.se>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 144 ++++++++++++++++++++++++++++++++++++++=
++------
 1 file changed, 125 insertions(+), 19 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 5bce86a0d063..631741c8ff22 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -191,11 +191,9 @@ static const struct ethtool_ops cdc_ncm_ethtool_op=
s =3D {
 	.set_coalesce      =3D cdc_ncm_set_coalesce,
 };
=20
-/* handle rx_max and tx_max changes */
-static void cdc_ncm_update_rxtx_max(struct usbnet *dev, u32 new_rx, u3=
2 new_tx)
+static u32 cdc_ncm_check_rx_max(struct usbnet *dev, u32 new_rx)
 {
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
-	u8 iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber;
 	u32 val, max, min;
=20
 	/* clamp new_rx to sane values */
@@ -210,10 +208,126 @@ static void cdc_ncm_update_rxtx_max(struct usbne=
t *dev, u32 new_rx, u32 new_tx)
 	}
=20
 	val =3D clamp_t(u32, new_rx, min, max);
-	if (val !=3D new_rx) {
-		dev_dbg(&dev->intf->dev, "rx_max must be in the [%u, %u] range. Usin=
g %u\n",
-			min, max, val);
-	}
+	if (val !=3D new_rx)
+		dev_dbg(&dev->intf->dev, "rx_max must be in the [%u, %u] range\n", m=
in, max);
+
+	return val;
+}
+
+static u32 cdc_ncm_check_tx_max(struct usbnet *dev, u32 new_tx)
+{
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	u32 val, max, min;
+
+	/* clamp new_tx to sane values */
+	min =3D ctx->max_datagram_size + ctx->max_ndp_size + sizeof(struct us=
b_cdc_ncm_nth16);
+	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_TX, le32_to_cpu(ctx->ncm_parm=
=2EdwNtbOutMaxSize));
+
+	/* some devices set dwNtbOutMaxSize too low for the above default */
+	min =3D min(min, max);
+
+	val =3D clamp_t(u32, new_tx, min, max);
+	if (val !=3D new_tx)
+		dev_dbg(&dev->intf->dev, "tx_max must be in the [%u, %u] range\n", m=
in, max);
+
+	return val;
+}
+
+static ssize_t cdc_ncm_show_rx_max(struct device *d, struct device_att=
ribute *attr, char *buf)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+
+	return sprintf(buf, "%u\n", ctx->rx_max);
+}
+
+static ssize_t cdc_ncm_show_tx_max(struct device *d, struct device_att=
ribute *attr, char *buf)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+
+	return sprintf(buf, "%u\n", ctx->tx_max);
+}
+
+static ssize_t cdc_ncm_show_tx_timer_usecs(struct device *d, struct de=
vice_attribute *attr, char *buf)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+
+	return sprintf(buf, "%u\n", ctx->timer_interval / (u32)NSEC_PER_USEC)=
;
+}
+
+static ssize_t cdc_ncm_store_rx_max(struct device *d,  struct device_a=
ttribute *attr, const char *buf, size_t len)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	unsigned long val;
+
+	if (kstrtoul(buf, 0, &val) || cdc_ncm_check_rx_max(dev, val) !=3D val=
)
+		return -EINVAL;
+
+	cdc_ncm_update_rxtx_max(dev, val, ctx->tx_max);
+	return len;
+}
+
+static ssize_t cdc_ncm_store_tx_max(struct device *d,  struct device_a=
ttribute *attr, const char *buf, size_t len)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	unsigned long val;
+
+	if (kstrtoul(buf, 0, &val) || cdc_ncm_check_tx_max(dev, val) !=3D val=
)
+		return -EINVAL;
+
+	cdc_ncm_update_rxtx_max(dev, ctx->rx_max, val);
+	return len;
+}
+
+static ssize_t cdc_ncm_store_tx_timer_usecs(struct device *d,  struct =
device_attribute *attr, const char *buf, size_t len)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	ssize_t ret;
+	unsigned long val;
+
+	ret =3D kstrtoul(buf, 0, &val);
+	if (ret)
+		return ret;
+	if (val && (val < CDC_NCM_TIMER_INTERVAL_MIN || val > CDC_NCM_TIMER_I=
NTERVAL_MAX))
+		return -EINVAL;
+
+	spin_lock_bh(&ctx->mtx);
+	ctx->timer_interval =3D val * NSEC_PER_USEC;
+	if (!ctx->timer_interval)
+		ctx->tx_timer_pending =3D 0;
+	spin_unlock_bh(&ctx->mtx);
+	return len;
+}
+
+static DEVICE_ATTR(rx_max, S_IRUGO | S_IWUSR, cdc_ncm_show_rx_max, cdc=
_ncm_store_rx_max);
+static DEVICE_ATTR(tx_max, S_IRUGO | S_IWUSR, cdc_ncm_show_tx_max, cdc=
_ncm_store_tx_max);
+static DEVICE_ATTR(tx_timer_usecs, S_IRUGO | S_IWUSR, cdc_ncm_show_tx_=
timer_usecs, cdc_ncm_store_tx_timer_usecs);
+
+static struct attribute *cdc_ncm_sysfs_attrs[] =3D {
+	&dev_attr_rx_max.attr,
+	&dev_attr_tx_max.attr,
+	&dev_attr_tx_timer_usecs.attr,
+	NULL,
+};
+
+static struct attribute_group cdc_ncm_sysfs_attr_group =3D {
+	.name =3D "cdc_ncm",
+	.attrs =3D cdc_ncm_sysfs_attrs,
+};
+
+/* handle rx_max and tx_max changes */
+static void cdc_ncm_update_rxtx_max(struct usbnet *dev, u32 new_rx, u3=
2 new_tx)
+{
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	u8 iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber;
+	u32 val;
+
+	val =3D cdc_ncm_check_rx_max(dev, new_rx);
=20
 	/* inform device about NTB input size changes */
 	if (val !=3D ctx->rx_max) {
@@ -238,18 +352,7 @@ static void cdc_ncm_update_rxtx_max(struct usbnet =
*dev, u32 new_rx, u32 new_tx)
 			usbnet_unlink_rx_urbs(dev);
 	}
=20
-	/* clamp new_tx to sane values */
-	min =3D ctx->max_datagram_size + ctx->max_ndp_size + sizeof(struct us=
b_cdc_ncm_nth16);
-	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_TX, le32_to_cpu(ctx->ncm_parm=
=2EdwNtbOutMaxSize));
-
-	/* some devices set dwNtbOutMaxSize too low for the above default */
-	min =3D min(min, max);
-
-	val =3D clamp_t(u32, new_tx, min, max);
-	if (val !=3D new_tx) {
-		dev_dbg(&dev->intf->dev, "tx_max must be in the [%u, %u] range. Usin=
g %u\n",
-			min, max, val);
-	}
+	val =3D cdc_ncm_check_tx_max(dev, new_tx);
 	if (val !=3D ctx->tx_max)
 		dev_info(&dev->intf->dev, "setting tx_max =3D %u\n", val);
=20
@@ -749,6 +852,9 @@ advance:
 	/* override ethtool_ops */
 	dev->net->ethtool_ops =3D &cdc_ncm_ethtool_ops;
=20
+	/* add our sysfs attrs */
+	dev->net->sysfs_groups[0] =3D &cdc_ncm_sysfs_attr_group;
+
 	return 0;
=20
 error2:
--=20
2.0.0.rc4
