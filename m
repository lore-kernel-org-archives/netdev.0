From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] cdc_ncm: Fix TCP Window Size issue by CDC NCM
 driver
Date: Fri, 10 Jun 2011 16:10:36 +0200
Message-ID: <1307715036.4044.11.camel@edumazet-laptop>
References: <1307713174-533-1-git-send-email-elof.vrigborn@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.name>, netdev@vger.kernel.org
To: Elof Vrigborn <elof.vrigborn@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64809 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755512Ab1FJOLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 10:11:01 -0400
Received: by wya21 with SMTP id 21so1887335wya.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 07:11:00 -0700 (PDT)
In-Reply-To: <1307713174-533-1-git-send-email-elof.vrigborn@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 juin 2011 =C3=A0 15:39 +0200, Elof Vrigborn a =C3=A9crit=
 :
> CDC NCM driver clones SKBs for received data and update SKB
> members of the clones according to received frames.
>=20
> If SKB clone len member is updated but truesize member is not, it
> could cause check #2 of the tcp_grow_window function to increase
> the TCP window by the __tcp_grow_window function instead of the
> expected increment by 2*advmss. This could to a great extent
> limit the rcv_ssthres and by that the advertised TCP Window Size,
> and in the end the data rate of a TCP connection, as according to
> the TCP Sliding Window concept.
>=20
> With this patch the truesize member of the SKB clones is updated
> in similarity to the len member and by this the expected incremental
> of the advertised TCP Window Size is seen and the TCP connection
> data rate will not be unnecessarily limited.
>=20
> Signed-off-by: Elof Vrigborn <elof.vrigborn@ericsson.com>
> ---
>  drivers/net/usb/cdc_ncm.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index f33ca6a..09923cd 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -1083,6 +1083,7 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev,=
 struct sk_buff *skb_in)
>  			if (!skb)
>  				goto error;
>  			skb->len =3D temp;
> +			skb->truesize =3D temp + sizeof(struct sk_buff);
>  			skb->data =3D ((u8 *)skb_in->data) + offset;
>  			skb_set_tail_pointer(skb, temp);
>  			usbnet_skb_return(dev, skb);

I find this patch dubious.

skb truesize is not meant to be skb->len + sizeof(struct sk_buff);

truesize is really accounting for the truesize of memory blocks, not th=
e
used one.

Many drivers allocate a full 2Kbyte block, even if only 100 bytes are
used in it. If we want to reduce "truesize", then we perform a
"copybreak", to allocate a right sized skb. Some NICS do that for small
frames.

If you have TCP performance problems, this might be because of another
high level problem. This truesize underestimation is only hiding the
problem, but makes the whole machine more subject to OOM bugs.

Could you provide more information ?


