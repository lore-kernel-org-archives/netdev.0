From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 6/8] net: cdc_ncm: export NCM Transfer Block (NTB) parameters
Date: Mon, 26 May 2014 12:53:43 +0200
Message-ID: <1401101625-12342-7-git-send-email-bjorn@mork.no>
References: <1401101625-12342-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	Lars Melin <larsm17-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1401101625-12342-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The mandatory GetNtbParameters control request is an important part of
the host <-> device protocol negotiation in CDC NCM (and CDC MBIM). It
gives device limits which the host must obey when configuring the
protocol aggregation variables. The driver will enforce this by
rejecting attempts to set any of the tunable variables to a value
which is not supported by the device.  Exporting the parameter block
helps userspace decide which values are allowed without resorting
to trial and error.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index aaa440d892b8..98c3adb5aea3 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -260,10 +260,40 @@ static DEVICE_ATTR(rx_max, S_IRUGO | S_IWUSR, cdc=
_ncm_show_rx_max, cdc_ncm_store
 static DEVICE_ATTR(tx_max, S_IRUGO | S_IWUSR, cdc_ncm_show_tx_max, cdc=
_ncm_store_tx_max);
 static DEVICE_ATTR(tx_timer_usecs, S_IRUGO | S_IWUSR, cdc_ncm_show_tx_=
timer_usecs, cdc_ncm_store_tx_timer_usecs);
=20
+#define NCM_PARM_ATTR(name, format, tocpu)				\
+static ssize_t cdc_ncm_show_##name(struct device *d, struct device_att=
ribute *attr, char *buf) \
+{ \
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d)); \
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0]; \
+	return sprintf(buf, format "\n", tocpu(ctx->ncm_parm.name));	\
+} \
+static DEVICE_ATTR(name, S_IRUGO, cdc_ncm_show_##name, NULL)
+
+NCM_PARM_ATTR(bmNtbFormatsSupported, "0x%04x", le16_to_cpu);
+NCM_PARM_ATTR(dwNtbInMaxSize, "%u", le32_to_cpu);
+NCM_PARM_ATTR(wNdpInDivisor, "%u", le16_to_cpu);
+NCM_PARM_ATTR(wNdpInPayloadRemainder, "%u", le16_to_cpu);
+NCM_PARM_ATTR(wNdpInAlignment, "%u", le16_to_cpu);
+NCM_PARM_ATTR(dwNtbOutMaxSize, "%u", le32_to_cpu);
+NCM_PARM_ATTR(wNdpOutDivisor, "%u", le16_to_cpu);
+NCM_PARM_ATTR(wNdpOutPayloadRemainder, "%u", le16_to_cpu);
+NCM_PARM_ATTR(wNdpOutAlignment, "%u", le16_to_cpu);
+NCM_PARM_ATTR(wNtbOutMaxDatagrams, "%u", le16_to_cpu);
+
 static struct attribute *cdc_ncm_sysfs_attrs[] =3D {
 	&dev_attr_rx_max.attr,
 	&dev_attr_tx_max.attr,
 	&dev_attr_tx_timer_usecs.attr,
+	&dev_attr_bmNtbFormatsSupported.attr,
+	&dev_attr_dwNtbInMaxSize.attr,
+	&dev_attr_wNdpInDivisor.attr,
+	&dev_attr_wNdpInPayloadRemainder.attr,
+	&dev_attr_wNdpInAlignment.attr,
+	&dev_attr_dwNtbOutMaxSize.attr,
+	&dev_attr_wNdpOutDivisor.attr,
+	&dev_attr_wNdpOutPayloadRemainder.attr,
+	&dev_attr_wNdpOutAlignment.attr,
+	&dev_attr_wNtbOutMaxDatagrams.attr,
 	NULL,
 };
=20
--=20
2.0.0.rc4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
