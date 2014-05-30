From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH v2 net-next 2/8] net: cdc_ncm: always reallocate tx_curr_skb when tx_max increases
Date: Fri, 30 May 2014 09:31:04 +0200
Message-ID: <1401435070-26721-3-git-send-email-bjorn@mork.no>
References: <1401435070-26721-1-git-send-email-bjorn@mork.no>
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
In-Reply-To: <1401435070-26721-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We are calling usbnet_start_xmit() to flush any remaining data,
depending on the side effect that tx_curr_skb is set to NULL,
ensuring a new allocation using the updated tx_max.  But this
side effect will only happen if there were any cached data ready
to transmit. If not, then an empty tx_curr_skb is still allocated
using the old tx_max size. Free it to avoid a buffer overrun.

=46ixes: 68864abf08f0 ("net: cdc_ncm: support rx_max/tx_max updates whe=
n running")
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 2bbbd65591c7..ff5b3a854898 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -268,6 +268,11 @@ static void cdc_ncm_update_rxtx_max(struct usbnet =
*dev, u32 new_rx, u32 new_tx)
 	if (netif_running(dev->net) && val > ctx->tx_max) {
 		netif_tx_lock_bh(dev->net);
 		usbnet_start_xmit(NULL, dev->net);
+		/* make sure tx_curr_skb is reallocated if it was empty */
+		if (ctx->tx_curr_skb) {
+			dev_kfree_skb_any(ctx->tx_curr_skb);
+			ctx->tx_curr_skb =3D NULL;
+		}
 		ctx->tx_max =3D val;
 		netif_tx_unlock_bh(dev->net);
 	} else {
--=20
2.0.0.rc4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
