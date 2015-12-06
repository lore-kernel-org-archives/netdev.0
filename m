From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next] net: cdc_ncm: add "ndp_to_end" sysfs attribute
Date: Sun,  6 Dec 2015 22:47:15 +0100
Message-ID: <1449438435-10823-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Enrico Mioso <mrkiko.rs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38066 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753014AbbLFVra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 16:47:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a writable sysfs attribute for the "NDP to end"
quirk flag.

This makes it easier for end users to test new devices for
this firmware bug.  We've been lucky so far, but we should
not depend on reporters capable of rebuilding the driver.

Cc: Enrico Mioso <mrkiko.rs@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 Documentation/ABI/testing/sysfs-class-net-cdc_ncm | 19 ++++++++++
 drivers/net/usb/cdc_ncm.c                         | 43 +++++++++++++++=
++++++++
 2 files changed, 62 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-class-net-cdc_ncm b/Docume=
ntation/ABI/testing/sysfs-class-net-cdc_ncm
index 5cedf72df358..f7be0e88b139 100644
--- a/Documentation/ABI/testing/sysfs-class-net-cdc_ncm
+++ b/Documentation/ABI/testing/sysfs-class-net-cdc_ncm
@@ -19,6 +19,25 @@ Description:
 		Set to 0 to pad all frames. Set greater than tx_max to
 		disable all padding.
=20
+What:		/sys/class/net/<iface>/cdc_ncm/ndp_to_end
+Date:		Dec 2015
+KernelVersion:	4.5
+Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
+Description:
+		Boolean attribute showing the status of the "NDP to
+		end" quirk.  Defaults to 'N', except for devices
+		already known to need it enabled.
+
+		The "NDP to end" quirk makes the driver place the NDP
+		(the packet index table) after the payload.  The NCM
+		specification does not mandate this, but some devices
+		are known to be more restrictive. Write 'Y' to this
+		attribute for temporary testing of a suspect device
+		failing to work with the default driver settings.
+
+		A device entry should be added to the driver if this
+		quirk is found to be required.
+
 What:		/sys/class/net/<iface>/cdc_ncm/rx_max
 Date:		May 2014
 KernelVersion:	3.16
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 3b1ba8237768..b45e5cae2a6b 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -283,6 +283,48 @@ static DEVICE_ATTR(rx_max, S_IRUGO | S_IWUSR, cdc_=
ncm_show_rx_max, cdc_ncm_store
 static DEVICE_ATTR(tx_max, S_IRUGO | S_IWUSR, cdc_ncm_show_tx_max, cdc=
_ncm_store_tx_max);
 static DEVICE_ATTR(tx_timer_usecs, S_IRUGO | S_IWUSR, cdc_ncm_show_tx_=
timer_usecs, cdc_ncm_store_tx_timer_usecs);
=20
+static ssize_t ndp_to_end_show(struct device *d, struct device_attribu=
te *attr, char *buf)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+
+	return sprintf(buf, "%c\n", ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END ?=
 'Y' : 'N');
+}
+
+static ssize_t ndp_to_end_store(struct device *d,  struct device_attri=
bute *attr, const char *buf, size_t len)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	bool enable;
+
+	if (strtobool(buf, &enable))
+		return -EINVAL;
+
+	/* no change? */
+	if (enable =3D=3D (ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END))
+		return len;
+
+	if (enable && !ctx->delayed_ndp16) {
+		ctx->delayed_ndp16 =3D kzalloc(ctx->max_ndp_size, GFP_KERNEL);
+		if (!ctx->delayed_ndp16)
+			return -ENOMEM;
+	}
+
+	/* flush pending data before changing flag */
+	netif_tx_lock_bh(dev->net);
+	usbnet_start_xmit(NULL, dev->net);
+	spin_lock_bh(&ctx->mtx);
+	if (enable)
+		ctx->drvflags |=3D CDC_NCM_FLAG_NDP_TO_END;
+	else
+		ctx->drvflags &=3D ~CDC_NCM_FLAG_NDP_TO_END;
+	spin_unlock_bh(&ctx->mtx);
+	netif_tx_unlock_bh(dev->net);
+
+	return len;
+}
+static DEVICE_ATTR_RW(ndp_to_end);
+
 #define NCM_PARM_ATTR(name, format, tocpu)				\
 static ssize_t cdc_ncm_show_##name(struct device *d, struct device_att=
ribute *attr, char *buf) \
 { \
@@ -305,6 +347,7 @@ NCM_PARM_ATTR(wNtbOutMaxDatagrams, "%u", le16_to_cp=
u);
=20
 static struct attribute *cdc_ncm_sysfs_attrs[] =3D {
 	&dev_attr_min_tx_pkt.attr,
+	&dev_attr_ndp_to_end.attr,
 	&dev_attr_rx_max.attr,
 	&dev_attr_tx_max.attr,
 	&dev_attr_tx_timer_usecs.attr,
--=20
2.1.4
