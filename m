From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 08/11] net: cdc_ncm/cdc_mbim: adding NCM protocol statiscics
Date: Sat, 10 May 2014 17:41:46 +0200
Message-ID: <1399736509-1159-9-git-send-email-bjorn@mork.no>
References: <1399736509-1159-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43753 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751550AbaEJPmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 May 2014 11:42:20 -0400
In-Reply-To: <1399736509-1159-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To have an idea of the effects of the protocol coalescing
it's useful to have some counters showing the different
aspects.

Due to the assymetrical usbnet interface the netdev
rx_bytes counter has been counting real received payload,
while the tx_bytes counter has included the NCM/MBIM
framing overhead. This overhead can be many times the
payload because of the aggressive padding strategy of
this driver, and will vary a lot depending on device
and traffic.

With very few exceptions, users are only interested in
the payload size.  Having an somewhat accurate payload
byte counter is particularily important for modbile
broadband devices, which many NCM devices and of course
all MBIM devices are. Users and userspace applications
will use this counter to monitor account quotas.

Having protocol specific counters for the overhead, we are
now able to correct the tx_bytes netdev counter so that
it shows the real payload

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_mbim.c  |  6 +++
 drivers/net/usb/cdc_ncm.c   | 91 +++++++++++++++++++++++++++++++++++++=
++++++++
 include/linux/usb/cdc_ncm.h | 11 ++++++
 3 files changed, 108 insertions(+)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index c9f3281506af..9008e8946a50 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -295,6 +295,7 @@ static int cdc_mbim_rx_fixup(struct usbnet *dev, st=
ruct sk_buff *skb_in)
 	struct usb_cdc_ncm_dpe16 *dpe16;
 	int ndpoffset;
 	int loopcount =3D 50; /* arbitrary max preventing infinite loop */
+	u32 payload =3D 0;
 	u8 *c;
 	u16 tci;
=20
@@ -354,6 +355,7 @@ next_ndp:
 			if (!skb)
 				goto error;
 			usbnet_skb_return(dev, skb);
+			payload +=3D len;	/* count payload bytes in this NTB */
 		}
 	}
 err_ndp:
@@ -362,6 +364,10 @@ err_ndp:
 	if (ndpoffset && loopcount--)
 		goto next_ndp;
=20
+	/* update stats */
+	ctx->rx_overhead +=3D skb_in->len - payload;
+	ctx->rx_ntbs++;
+
 	return 1;
 error:
 	return 0;
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index e28b530bff3a..a28c964b35a9 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -65,6 +65,68 @@ static void cdc_ncm_tx_timeout_start(struct cdc_ncm_=
ctx *ctx);
 static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_tim=
er);
 static struct usb_driver cdc_ncm_driver;
=20
+struct cdc_ncm_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+#define CDC_NCM_STAT(str, m) { \
+		.stat_string =3D str, \
+		.sizeof_stat =3D sizeof(((struct cdc_ncm_ctx *)0)->m), \
+		.stat_offset =3D offsetof(struct cdc_ncm_ctx, m) }
+#define CDC_NCM_SIMPLE_STAT(m)	CDC_NCM_STAT(__stringify(m), m)
+
+static const struct cdc_ncm_stats cdc_ncm_gstrings_stats[] =3D {
+	CDC_NCM_SIMPLE_STAT(tx_reason_ntb_full),
+	CDC_NCM_SIMPLE_STAT(tx_reason_ndp_full),
+	CDC_NCM_SIMPLE_STAT(tx_reason_timeout),
+	CDC_NCM_SIMPLE_STAT(tx_reason_max_datagram),
+	CDC_NCM_SIMPLE_STAT(tx_overhead),
+	CDC_NCM_SIMPLE_STAT(tx_ntbs),
+	CDC_NCM_SIMPLE_STAT(rx_overhead),
+	CDC_NCM_SIMPLE_STAT(rx_ntbs),
+};
+
+static int cdc_ncm_get_sset_count(struct net_device __always_unused *n=
etdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(cdc_ncm_gstrings_stats);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void cdc_ncm_get_ethtool_stats(struct net_device *netdev,
+				    struct ethtool_stats __always_unused *stats,
+				    u64 *data)
+{
+	struct usbnet *dev =3D netdev_priv(netdev);
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	int i;
+	char *p =3D NULL;
+
+	for (i =3D 0; i < ARRAY_SIZE(cdc_ncm_gstrings_stats); i++) {
+		p =3D (char *)ctx + cdc_ncm_gstrings_stats[i].stat_offset;
+		data[i] =3D (cdc_ncm_gstrings_stats[i].sizeof_stat =3D=3D sizeof(u64=
)) ? *(u64 *)p : *(u32 *)p;
+	}
+}
+
+static void cdc_ncm_get_strings(struct net_device __always_unused *net=
dev, u32 stringset, u8 *data)
+{
+	u8 *p =3D data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i =3D 0; i < ARRAY_SIZE(cdc_ncm_gstrings_stats); i++) {
+			memcpy(p, cdc_ncm_gstrings_stats[i].stat_string, ETH_GSTRING_LEN);
+			p +=3D ETH_GSTRING_LEN;
+		}
+	}
+}
+
 static int cdc_ncm_get_coalesce(struct net_device *netdev,
 				struct ethtool_coalesce *ec)
 {
@@ -117,6 +179,9 @@ static const struct ethtool_ops cdc_ncm_ethtool_ops=
 =3D {
 	.get_msglevel      =3D usbnet_get_msglevel,
 	.set_msglevel      =3D usbnet_set_msglevel,
 	.get_ts_info       =3D ethtool_op_get_ts_info,
+	.get_sset_count    =3D cdc_ncm_get_sset_count,
+	.get_strings       =3D cdc_ncm_get_strings,
+	.get_ethtool_stats =3D cdc_ncm_get_ethtool_stats,
 	.get_coalesce      =3D cdc_ncm_get_coalesce,
 	.set_coalesce      =3D cdc_ncm_set_coalesce,
 };
@@ -851,6 +916,9 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk=
_buff *skb, __le32 sign)
=20
 		/* count total number of frames in this NTB */
 		ctx->tx_curr_frame_num =3D 0;
+
+		/* recent payload counter for this skb_out */
+		ctx->tx_curr_frame_payload =3D 0;
 	}
=20
 	for (n =3D ctx->tx_curr_frame_num; n < ctx->tx_max_datagrams; n++) {
@@ -888,6 +956,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk=
_buff *skb, __le32 sign)
 				ctx->tx_rem_sign =3D sign;
 				skb =3D NULL;
 				ready2send =3D 1;
+				ctx->tx_reason_ntb_full++;	/* count reason for transmitting */
 			}
 			break;
 		}
@@ -901,12 +970,14 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct =
sk_buff *skb, __le32 sign)
 		ndp16->dpe16[index].wDatagramIndex =3D cpu_to_le16(skb_out->len);
 		ndp16->wLength =3D cpu_to_le16(ndplen + sizeof(struct usb_cdc_ncm_dp=
e16));
 		memcpy(skb_put(skb_out, skb->len), skb->data, skb->len);
+		ctx->tx_curr_frame_payload +=3D skb->len;	/* count real tx payload d=
ata */
 		dev_kfree_skb_any(skb);
 		skb =3D NULL;
=20
 		/* send now if this NDP is full */
 		if (index >=3D CDC_NCM_DPT_DATAGRAMS_MAX) {
 			ready2send =3D 1;
+			ctx->tx_reason_ndp_full++;	/* count reason for transmitting */
 			break;
 		}
 	}
@@ -936,6 +1007,8 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct s=
k_buff *skb, __le32 sign)
 		goto exit_no_skb;
=20
 	} else {
+		if (n =3D=3D ctx->tx_max_datagrams)
+			ctx->tx_reason_max_datagram++;	/* count reason for transmitting */
 		/* frame goes out */
 		/* variables will be reset at next call */
 	}
@@ -963,6 +1036,17 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct =
sk_buff *skb, __le32 sign)
 	/* return skb */
 	ctx->tx_curr_skb =3D NULL;
 	dev->net->stats.tx_packets +=3D ctx->tx_curr_frame_num;
+
+	/* keep private stats: framing overhead and number of NTBs */
+	ctx->tx_overhead +=3D skb_out->len - ctx->tx_curr_frame_payload;
+	ctx->tx_ntbs++;
+
+	/* usbnet has already counted all the framing overhead.
+	 * Adjust the stats so that the tx_bytes counter show real
+	 * payload data instead.
+	 */
+	dev->net->stats.tx_bytes -=3D skb_out->len - ctx->tx_curr_frame_paylo=
ad;
+
 	return skb_out;
=20
 exit_no_skb:
@@ -1003,6 +1087,7 @@ static void cdc_ncm_txpath_bh(unsigned long param=
)
 		cdc_ncm_tx_timeout_start(ctx);
 		spin_unlock_bh(&ctx->mtx);
 	} else if (dev->net !=3D NULL) {
+		ctx->tx_reason_timeout++;	/* count reason for transmitting */
 		spin_unlock_bh(&ctx->mtx);
 		netif_tx_lock_bh(dev->net);
 		usbnet_start_xmit(NULL, dev->net);
@@ -1138,6 +1223,7 @@ int cdc_ncm_rx_fixup(struct usbnet *dev, struct s=
k_buff *skb_in)
 	struct usb_cdc_ncm_dpe16 *dpe16;
 	int ndpoffset;
 	int loopcount =3D 50; /* arbitrary max preventing infinite loop */
+	u32 payload =3D 0;
=20
 	ndpoffset =3D cdc_ncm_rx_verify_nth16(ctx, skb_in);
 	if (ndpoffset < 0)
@@ -1190,6 +1276,7 @@ next_ndp:
 			skb->data =3D ((u8 *)skb_in->data) + offset;
 			skb_set_tail_pointer(skb, len);
 			usbnet_skb_return(dev, skb);
+			payload +=3D len;	/* count payload bytes in this NTB */
 		}
 	}
 err_ndp:
@@ -1198,6 +1285,10 @@ err_ndp:
 	if (ndpoffset && loopcount--)
 		goto next_ndp;
=20
+	/* update stats */
+	ctx->rx_overhead +=3D skb_in->len - payload;
+	ctx->rx_ntbs++;
+
 	return 1;
 error:
 	return 0;
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 0aac70ee23b6..4eeaf6db20c8 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -116,6 +116,17 @@ struct cdc_ncm_ctx {
 	u16 rx_seq;
 	u16 connected;
 	u16 min_tx_pkt;
+
+	/* statistics */
+	u32 tx_curr_frame_payload;
+	u32 tx_reason_ntb_full;
+	u32 tx_reason_ndp_full;
+	u32 tx_reason_timeout;
+	u32 tx_reason_max_datagram;
+	u64 tx_overhead;
+	u64 tx_ntbs;
+	u64 rx_overhead;
+	u64 rx_ntbs;
 };
=20
 u8 cdc_ncm_select_altsetting(struct usbnet *dev, struct usb_interface =
*intf);
--=20
2.0.0.rc2
