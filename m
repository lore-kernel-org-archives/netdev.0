From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: changing usbnet's API to better deal with cdc-ncm
Date: Thu, 06 Sep 2012 10:17:46 +0200
Message-ID: <87ehmf36qd.fsf@nemi.mork.no>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexey.orishko@stericsson.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:46632 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752743Ab2IFIS3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 04:18:29 -0400
In-Reply-To: <2791550.LhGu6po6Xy@linux-lqwf.site> (Oliver Neukum's message of
	"Wed, 05 Sep 2012 22:12:54 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.de> writes:

> looking at cdc-ncm it seeems to me that cdc-ncm is forced to play
> very dirty games because usbnet doesn't have a notion about aggregati=
ng
> packets for a single transfer.
>
> It seems to me that this can be fixed introducing a method for bundli=
ng,
> which tells usbnet how packets have been aggregated. To have performa=
nce
> usbnet strives to always keep at least two transfers in flight.
>
> The code isn't complete and I need to get a device for testing, but t=
o get
> your opinion, I ask you to comment on what I have now.

I haven't tested this on any device either, but it looks like the right
direction to me.  Note that there are several other existing minidriver=
s
which could take advantage of this code. A quick look found that both
sierra_net and rndis_host have some unbundling support in their
rx_fixups, but both ignore tx bundling. rndis_host has the following
explanation in tx_fixup:

        /* fill out the RNDIS header.  we won't bother trying to batch
         * packets; Linux minimizes wasted bandwidth through tx queues.
         */

Although that may be true for the host, I am not sure it will be true
for every device?


> @@ -874,71 +840,37 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, =
struct sk_buff *skb)
>  	/* return skb */
>  	ctx->tx_curr_skb =3D NULL;
>  	ctx->netdev->stats.tx_packets +=3D ctx->tx_curr_frame_num;


Maybe all the statistics could be moved back to usbnet now that it will
see all packets again?


> index f87cf62..bb2f622 100644
> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -33,6 +33,7 @@ struct usbnet {
>  	wait_queue_head_t	*wait;
>  	struct mutex		phy_mutex;
>  	unsigned char		suspend_count;
> +	atomic_t		tx_in_flight;
> =20
>  	/* i/o info: pipes etc */
>  	unsigned		in, out;


So you don't keep any timer here?  The idea is that you always will
transmit immediately unless there are two transmit's in flight?  I
believe that is a change which has to be tested against real devices.
They may be optimized for receiving bundles.


Not really related, but I am still worrying how MBIM is going to fit
into the usbnet model where you have a strict relation between one
netdev and one USB interface.  Do you see any way usbnet could be
extended to manage a list of netdevs?

All the netdev related functions doing

	struct usbnet		*dev =3D netdev_priv(net);

would still work.  But all the USB related functions using dev->net to
get _the_ netdev would fail.  Maybe this will be too difficult to
implement within the usbnet framework at all?


Bj=C3=B8rn
