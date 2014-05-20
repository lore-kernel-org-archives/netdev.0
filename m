From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next v2 00/12] cdc_ncm: add buffer tuning and stats using ethtool
Date: Tue, 20 May 2014 09:36:57 +0200
Message-ID: <87tx8k295y.fsf@nemi.mork.no>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
	<20140516.224032.2301577488192248796.davem@davemloft.net>
	<87d2fcoqay.fsf@nemi.mork.no> <20140518011917.11270.qmail@stuge.se>
	<alpine.LNX.2.03.1405181155310.7743@gmail.com>
	<87vbt3m98p.fsf@nemi.mork.no> <5378E985.1040206@gmail.com>
	<87egzqmd8h.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: Peter Stuge <peter@stuge.se>, Enrico Mioso <mrkiko.rs@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, alexey.orishko@gmail.com,
	oliver@neukum.org, David.Laight@aculab.com,
	Greg Suarez <gsuarez@smithmicro.com>
To: Lars Melin <larsm17@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57844 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbaETHiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 03:38:06 -0400
In-Reply-To: <87egzqmd8h.fsf@nemi.mork.no> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Mon, 19
	May 2014 09:36:30 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

[adding Greg Suarez to the Cc list after noticing that he was missing
 from this thread.  Sorry Greg, that was not my intention.  This
 discussion is just as relevant to cdc_mbim as to cdc_ncm, defining a
 new common userspace API for all the cdc_ncm based drivers]

Bj=C3=B8rn Mork <bjorn@mork.no> writes:
> Lars Melin <larsm17@gmail.com> writes:
>
>> Your target audience is embedded systems with limited cpu power and
>> buffer memory, right?
>> If so, then you can't expect them to have ethtool included and their
>> developers are not likely to be happy over having to "waste" another
>> 100KB in order to tune a 20KB driver.
>> My vote goes for sysfs.
>
> That's of course a very good point.
>
> I will argue that you often need ethtool anyway for basic stuff like
> forcing duplex/speed, enabling debug messages, turning on/off pause
> frames etc.  But I don't doubt you know what you are talking about here
> :-)  So I guess many small embedded devices don't include an ethtool
> binary by default.  I do wonder how much we should adapt to that though?
> I understand that you don't see it this way, but others might actually
> see it as an advantage if we're forcing ethtool onto these devices...
>
> Anyway, I'll start looking at an alternative sysfs implementation so we
> can discuss this in terms of actual code.

As this is just a very informal RFC, I'm just attaching the patch to
this mail.  Please test and/or comment.

The patch works for me.  It doesn't remove the ethtool coalescing
support, but I will do that in the final submission if we decide to go
for this sysfs interface instead.

Example output:

 bjorn@nemi:~$ grep . /sys/class/net/wwan0/cdc_ncm/*
 /sys/class/net/wwan0/cdc_ncm/rx_max:16384
 /sys/class/net/wwan0/cdc_ncm/tx_max:4096
 /sys/class/net/wwan0/cdc_ncm/tx_timer_usecs:400

I should probably also add a bit more sanity checking of the input for
the final submission. Maybe even make sure the buffers match the
alignment?  Or should that be up to the user?

But we could add information about the device alignment requirements so
that the end user (or userspace application) can make informed decisions.
The whole NTB parameter struct is vital information which is currently only
available for userspace in a debug log message.  Exporting it as a set
of sysfs read only attributes would be nice.  Maybe?  Or am I just
overdoing things now?

It's also tempting to add the 'timer restart count' to this API.  I left
it out of the ethtool based version because I couldn't make it fit
anywhere.  But it is part of the driver's frame aggregation algorithm.


Bj=C3=B8rn



--=-=-=
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: inline;
 filename=0001-net-cdc_ncm-add-sysfs-support-for-buffer-tuning.patch
Content-Transfer-Encoding: quoted-printable

>From 017c9fc8702132ed76b9c28a196203b1788ef4c8 Mon Sep 17 00:00:00 2001
From: =3D?UTF-8?q?Bj=3DC3=3DB8rn=3D20Mork?=3D <bjorn@mork.no>
Date: Mon, 19 May 2014 16:08:49 +0200
Subject: [RFC] net: cdc_ncm: add sysfs support for buffer tuning
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

Adding a sysfs group to the network device, allowing tuning of
buffers and tx timer.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 143 ++++++++++++++++++++++++++++++++++++++++--=
----
 1 file changed, 124 insertions(+), 19 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index ad2a386a6e92..30b943200ca3 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -191,11 +191,9 @@ static const struct ethtool_ops cdc_ncm_ethtool_ops =
=3D {
 	.set_coalesce      =3D cdc_ncm_set_coalesce,
 };
=20
-/* handle rx_max and tx_max changes */
-static void cdc_ncm_update_rxtx_max(struct usbnet *dev, u32 new_rx, u32 ne=
w_tx)
+static u32 cdc_ncm_check_rx_max(struct usbnet *dev, u32 new_rx)
 {
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
-	u8 iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber;
 	u32 val, max, min;
=20
 	/* clamp new_rx to sane values */
@@ -210,10 +208,125 @@ static void cdc_ncm_update_rxtx_max(struct usbnet *d=
ev, u32 new_rx, u32 new_tx)
 	}
=20
 	val =3D clamp_t(u32, new_rx, min, max);
-	if (val !=3D new_rx) {
-		dev_dbg(&dev->intf->dev, "rx_max must be in the [%u, %u] range. Using %u=
\n",
-			min, max, val);
-	}
+	if (val !=3D new_rx)
+		dev_dbg(&dev->intf->dev, "rx_max must be in the [%u, %u] range\n", min, =
max);
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
+	min =3D ctx->max_datagram_size + ctx->max_ndp_size + sizeof(struct usb_cd=
c_ncm_nth16);
+	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_TX, le32_to_cpu(ctx->ncm_parm.dwN=
tbOutMaxSize));
+
+	/* some devices set dwNtbOutMaxSize too low for the above default */
+	min =3D min(min, max);
+
+	val =3D clamp_t(u32, new_tx, min, max);
+	if (val !=3D new_tx)
+		dev_dbg(&dev->intf->dev, "tx_max must be in the [%u, %u] range\n", min, =
max);
+
+	return val;
+}
+
+/* sysfs attributes */
+static ssize_t cdc_ncm_show_rx_max(struct device *d, struct device_attribu=
te *attr, char *buf)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+
+	return sprintf(buf, "%u\n", ctx->rx_max);
+}
+static ssize_t cdc_ncm_show_tx_max(struct device *d, struct device_attribu=
te *attr, char *buf)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+
+	return sprintf(buf, "%u\n", ctx->tx_max);
+}
+static ssize_t cdc_ncm_show_tx_timer_usecs(struct device *d, struct device=
_attribute *attr, char *buf)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+
+	return sprintf(buf, "%u\n", ctx->timer_interval / (u32)NSEC_PER_USEC);
+}
+
+static ssize_t cdc_ncm_store_rx_max(struct device *d,  struct device_attri=
bute *attr, const char *buf, size_t len)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	unsigned long val;
+
+	if (kstrtoul(buf, 0, &val) || cdc_ncm_check_rx_max(dev, val) !=3D val)
+		return -EINVAL;
+
+	cdc_ncm_update_rxtx_max(dev, val, ctx->tx_max);
+	return len;
+}
+
+static ssize_t cdc_ncm_store_tx_max(struct device *d,  struct device_attri=
bute *attr, const char *buf, size_t len)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	unsigned long val;
+
+	if (kstrtoul(buf, 0, &val) || cdc_ncm_check_tx_max(dev, val) !=3D val)
+		return -EINVAL;
+
+	cdc_ncm_update_rxtx_max(dev, ctx->rx_max, val);
+	return len;
+}
+
+static ssize_t cdc_ncm_store_tx_timer_usecs(struct device *d,  struct devi=
ce_attribute *attr, const char *buf, size_t len)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	ssize_t ret;
+	unsigned long val;
+
+	ret =3D kstrtoul(buf, 0, &val);
+	if (ret)
+		return ret;
+	if (val && (val < CDC_NCM_TIMER_INTERVAL_MIN || val > CDC_NCM_TIMER_INTER=
VAL_MAX))
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
+static DEVICE_ATTR(rx_max, S_IRUGO | S_IWUSR, cdc_ncm_show_rx_max, cdc_ncm=
_store_rx_max);
+static DEVICE_ATTR(tx_max, S_IRUGO | S_IWUSR, cdc_ncm_show_tx_max, cdc_ncm=
_store_tx_max);
+static DEVICE_ATTR(tx_timer_usecs, S_IRUGO | S_IWUSR, cdc_ncm_show_tx_time=
r_usecs, cdc_ncm_store_tx_timer_usecs);
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
+static void cdc_ncm_update_rxtx_max(struct usbnet *dev, u32 new_rx, u32 ne=
w_tx)
+{
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	u8 iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber;
+	u32 val;
+
+	val =3D cdc_ncm_check_rx_max(dev, new_rx);
=20
 	/* usbnet use these values for sizing rx queues */
 	dev->rx_urb_size =3D val;
@@ -238,18 +351,7 @@ static void cdc_ncm_update_rxtx_max(struct usbnet *dev=
, u32 new_rx, u32 new_tx)
 			ctx->rx_max =3D val;
 	}
=20
-	/* clamp new_tx to sane values */
-	min =3D ctx->max_datagram_size + ctx->max_ndp_size + sizeof(struct usb_cd=
c_ncm_nth16);
-	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_TX, le32_to_cpu(ctx->ncm_parm.dwN=
tbOutMaxSize));
-
-	/* some devices set dwNtbOutMaxSize too low for the above default */
-	min =3D min(min, max);
-
-	val =3D clamp_t(u32, new_tx, min, max);
-	if (val !=3D new_tx) {
-		dev_dbg(&dev->intf->dev, "tx_max must be in the [%u, %u] range. Using %u=
\n",
-			min, max, val);
-	}
+	val =3D cdc_ncm_check_tx_max(dev, new_tx);
 	if (val !=3D ctx->tx_max)
 		dev_info(&dev->intf->dev, "setting tx_max =3D %u\n", val);
=20
@@ -743,6 +845,9 @@ advance:
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
2.0.0.rc2


--=-=-=--
