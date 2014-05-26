From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 7/8] net: cdc_ncm: allow tuning min_tx_pkt
Date: Mon, 26 May 2014 12:53:44 +0200
Message-ID: <1401101625-12342-8-git-send-email-bjorn@mork.no>
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
Received: from canardo.mork.no ([148.122.252.1]:43706 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731AbaEZK4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2014 06:56:15 -0400
In-Reply-To: <1401101625-12342-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The min_tx_pkt variable decides the cutoff point where the driver
will stop padding out NTBs to maximum size. The padding is a tradeoff
where we use some USB bus bandwidth to allow the device to receive
fixed size buffers. Different devices will have different optimal
settings, spanning from no padding at all to padding every NTB.
There is no way to automatically figure out which setting is best
for a specific device.

The default value is a reasonable tradeoff, calculated based on the
USB packet size and out NTB max size. This may have to be changed
along with any tx_max changes.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 98c3adb5aea3..80a844e0ae03 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -185,6 +185,14 @@ static u32 cdc_ncm_check_tx_max(struct usbnet *dev=
, u32 new_tx)
 	return val;
 }
=20
+static ssize_t cdc_ncm_show_min_tx_pkt(struct device *d, struct device=
_attribute *attr, char *buf)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+
+	return sprintf(buf, "%u\n", ctx->min_tx_pkt);
+}
+
 static ssize_t cdc_ncm_show_rx_max(struct device *d, struct device_att=
ribute *attr, char *buf)
 {
 	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
@@ -209,6 +217,20 @@ static ssize_t cdc_ncm_show_tx_timer_usecs(struct =
device *d, struct device_attri
 	return sprintf(buf, "%u\n", ctx->timer_interval / (u32)NSEC_PER_USEC)=
;
 }
=20
+static ssize_t cdc_ncm_store_min_tx_pkt(struct device *d,  struct devi=
ce_attribute *attr, const char *buf, size_t len)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	unsigned long val;
+
+	/* no need to restrict values - anything from 0 to infinity is OK */
+	if (kstrtoul(buf, 0, &val))
+		return -EINVAL;
+
+	ctx->min_tx_pkt =3D val;
+	return len;
+}
+
 static ssize_t cdc_ncm_store_rx_max(struct device *d,  struct device_a=
ttribute *attr, const char *buf, size_t len)
 {
 	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
@@ -256,6 +278,7 @@ static ssize_t cdc_ncm_store_tx_timer_usecs(struct =
device *d,  struct device_att
 	return len;
 }
=20
+static DEVICE_ATTR(min_tx_pkt, S_IRUGO | S_IWUSR, cdc_ncm_show_min_tx_=
pkt, cdc_ncm_store_min_tx_pkt);
 static DEVICE_ATTR(rx_max, S_IRUGO | S_IWUSR, cdc_ncm_show_rx_max, cdc=
_ncm_store_rx_max);
 static DEVICE_ATTR(tx_max, S_IRUGO | S_IWUSR, cdc_ncm_show_tx_max, cdc=
_ncm_store_tx_max);
 static DEVICE_ATTR(tx_timer_usecs, S_IRUGO | S_IWUSR, cdc_ncm_show_tx_=
timer_usecs, cdc_ncm_store_tx_timer_usecs);
@@ -281,6 +304,7 @@ NCM_PARM_ATTR(wNdpOutAlignment, "%u", le16_to_cpu);
 NCM_PARM_ATTR(wNtbOutMaxDatagrams, "%u", le16_to_cpu);
=20
 static struct attribute *cdc_ncm_sysfs_attrs[] =3D {
+	&dev_attr_min_tx_pkt.attr,
 	&dev_attr_rx_max.attr,
 	&dev_attr_tx_max.attr,
 	&dev_attr_tx_timer_usecs.attr,
--=20
2.0.0.rc4
