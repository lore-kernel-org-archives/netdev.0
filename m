From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: removing the timer from cdc-ncm
Date: Thu, 11 Oct 2012 14:15:51 +0200
Message-ID: <87k3uxgq6g.fsf@nemi.mork.no>
References: <6020948.EvS2esPpc0@linux-lqwf.site>
	<2AC7D4AD8BA1C640B4C60C61C8E520154A8BED59B5@EXDCVYMBSTM006.EQ1STM.local>
	<9022066.PsM0uBqIB8@linux-lqwf.site> <87zk3te2j9.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb\@vger.kernel.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87zk3te2j9.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Thu, 11
	Oct 2012 12:17:14 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> writes:

> [48880.048494] BUG: unable to handle kernel NULL pointer dereference =
at 0000000000000068
> [48880.048573] IP: [<ffffffffa06ba879>] cdc_ncm_tx_bundle+0x168/0x43b=
 [cdc_ncm]

This one is because you removed the "if (skb =3D=3D NULL)" from the for
loop, but left the "skb =3D NULL;" at the end:


@@ -719,28 +707,15 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, st=
ruct sk_buff *skb)
                /* compute maximum buffer size */
                rem =3D ctx->tx_max - offset;
=20
-               if (skb =3D=3D NULL) {
-                       skb =3D ctx->tx_rem_skb;
-                       ctx->tx_rem_skb =3D NULL;
-
-                       /* check for end of skb */
-                       if (skb =3D=3D NULL)
-                               break;
-               }
-
                if (skb->len > rem) {
                        if (n =3D=3D 0) {
                                /* won't fit, MTU problem? */
                                dev_kfree_skb_any(skb);
                                skb =3D NULL;
                                ctx->netdev->stats.tx_dropped++;
+                               error =3D 1;
                        } else {
-                               /* no room for skb - store for later */
-                               if (ctx->tx_rem_skb !=3D NULL) {
-                                       dev_kfree_skb_any(ctx->tx_rem_s=
kb);
-                                       ctx->netdev->stats.tx_dropped++=
;
-                               }
-                               ctx->tx_rem_skb =3D skb;
+
                                skb =3D NULL;
                                ready2send =3D 1;
                        }
@@ -768,13 +743,6 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, str=
uct sk_buff *skb)
                skb =3D NULL;
        }


If I understand your intentions with this code, then the for loop shoul=
d
probably just go away completely?

Anyway, after avoiding that one, I ended up with

[  857.112692] cdc_ncm_fill_tx_frame: skb_out=3Dffff880218624cc0, lengt=
h=3D2048
[  857.112696] cdc_ncm_tx_fixup: returning           (null)
[  857.112731] BUG: unable to handle kernel NULL pointer dereference at=
 0000000000000068
[  857.112807] IP: [<ffffffffa030e68b>] usbnet_start_xmit+0x128/0x4e9 [=
usbnet]

No need for the reset of the trace here. Removing the "goto not_drop"
makes usbnet_start_xmit continue after tx_fixup returns NULL:


-       if (info->tx_fixup) {
+       if (transmit_now && info->tx_fixup) {
                skb =3D info->tx_fixup (dev, skb, GFP_ATOMIC);
                if (!skb) {
                        if (netif_msg_tx_err(dev)) {
                                netif_dbg(dev, tx_err, dev->net, "can't=
 tx_fixup skb\n");
                                goto drop;
-                       } else {
-                               /* cdc_ncm collected packet; waits for =
more */
-                               goto not_drop;
                        }
                }
        }


	// some devices want funky USB-level framing, for
	// win32 driver (usually) and/or hardware quirks
	if (transmit_now && info->tx_fixup) {
		skb =3D info->tx_fixup (dev, skb, GFP_ATOMIC);
		if (!skb) {
			if (netif_msg_tx_err(dev)) {
				netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
				goto drop;
			}
		}
	}
	length =3D skb->len;



I stopped there.  I am not exactly sure where you were going with this
anymore.  tx_fixup will return the tx_curr_skb being currently built
every time it is called, without anything resetting it at that point.
Then when finally cdc_ncm_fill_tx_frame has been called enough times to
fill it completely, you end up just dropping it on the floor.  The
result is that nothing is ever transmitted even after fixing the above
errors because the tx_curr_skb has an incomplete header every time
tx_fixup returns it.

I do like your idea, but if you don't mind I think we'll go ahead and
base the upcoming cdc_mbim driver on the current cdc_ncm *with* the
timer.  The plan is to reuse as much of cdc_ncm as possible, so in
theory it should be easy to update both drivers when the timer goes awa=
y
(there is no need for cdc_mbim be aware of the timer at all).  But
unfortunately it seems that cdc_ncm_fill_tx_frame must be changed a lot
to support the concept of multiple NDPs in a single NTB.  This means
that the timer removal patches will conflict heavily with the
preparations for MBIM support.  With some luck and acceptance from all
contributors, I hope to be able to post the first version of that as th=
e
merge window closes.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
