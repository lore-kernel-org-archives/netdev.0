From: "Chung-Chi Lo" <linolo@gmail.com>
Subject: Re: [PATCH net-2.6.25 4/7][ATM]: [br2864] routed support
Date: Tue, 29 Jan 2008 15:42:51 +0800
Message-ID: <3f696b20801282342q43537963ueb8fb9cf3389ac03@mail.gmail.com>
References: <3f696b20801152016r52048016g7c293dbfdc6c9f29@mail.gmail.com>
	 <200801261220.m0QCKJ15023510@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:30017 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbYA2Hmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 02:42:53 -0500
Received: by py-out-1112.google.com with SMTP id u52so2879875pyb.10
        for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 23:42:52 -0800 (PST)
In-Reply-To: <200801261220.m0QCKJ15023510@cmf.nrl.navy.mil>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 26, 2008 8:20 PM, chas williams - CONTRACTOR
<chas@cmf.nrl.navy.mil> wrote:
> In message <3f696b20801152016r52048016g7c293dbfdc6c9f29@mail.gmail.com>,"Chung-
> Chi Lo" writes:
> >By the way, this routed mode patch doesn't include encaps=VCMUX and
> >RFC2684 routed
> >protocol decapsulation?
>
> yep.  eric believes the following should fix both problems:
>
> commit 43e4b025ffe130cd6a292fa9ff909e39a88f849c
> Author: Chas Williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
> Date:   Sat Jan 26 07:18:26 2008 -0500
>
>     [ATM]: [br2864] fix vcmux support
>
>     From: Eric Kinzie <ekinzie@cmf.nrl.navy.mil>
>     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
>
> diff --git a/net/atm/br2684.c b/net/atm/br2684.c
> index 31347cb..97b422c 100644
> --- a/net/atm/br2684.c
> +++ b/net/atm/br2684.c
> @@ -400,15 +400,20 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
>                         return;
>                 }
>
> -       } else {
> -               /* first 2 chars should be 0 */
> -               if (*((u16 *) (skb->data)) != 0) {
> -                       brdev->stats.rx_errors++;
> -                       dev_kfree_skb(skb);
> -                       return;
> +       } else { /* vc-mux */
> +               if (brdev->payload == p_routed) {

add line

			skb->protocol = __constant_htons(ETH_P_IP);

here just like LLC did?

> +                       skb_reset_network_header(skb);
> +                       skb->pkt_type = PACKET_HOST;
> +               } else { /* p_bridged */
> +                       /* first 2 chars should be 0 */
> +                       if (*((u16 *) (skb->data)) != 0) {
> +                               brdev->stats.rx_errors++;
> +                               dev_kfree_skb(skb);
> +                               return;
> +                       }
> +                       skb_pull(skb, BR2684_PAD_LEN);
> +                       skb->protocol = eth_type_trans(skb, net_dev);
>                 }
> -               skb_pull(skb, BR2684_PAD_LEN + ETH_HLEN);       /* pad, dstmac, srcmac, ethtype */
> -               skb->protocol = eth_type_trans(skb, net_dev);
>         }
>

Also have a problem when encapsulation is VCMUX and routed mode, in

 /*
@@ -136,6 +156,7 @@ static int br2684_xmit_vcc(struct sk_buff *skb,
struct br2684_dev *brdev,
 {
..
..
+       if (brvcc->encaps == e_llc) {
..
+       } else {
+               skb_push(skb, 2);
+               if (brdev->payload == p_bridged)
+                       memset(skb->data, 0, 2);
+       }

Here should be

	} else {
		if (brdev->payload == p_bridged) {
			skb_push(skb, 2);
			memset(skb->data, 0, 2);
		}
	}

Because VCMUX and routed mode doesn't need two bytes in header.

-- 
Lino, Chung-Chi Lo
