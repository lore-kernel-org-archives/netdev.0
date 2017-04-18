From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] smsc95xx: Use skb_cow to deal with cloned skbs
Date: Tue, 18 Apr 2017 08:51:51 -0700
Message-ID: <1492530711.10587.125.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170418144857.7810-1-james.hughes@raspberrypi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
To: James Hughes <james.hughes@raspberrypi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33141 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755123AbdDRPvx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 11:51:53 -0400
Received: by mail-pf0-f195.google.com with SMTP id c198so31278570pfc.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 08:51:53 -0700 (PDT)
In-Reply-To: <20170418144857.7810-1-james.hughes@raspberrypi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-18 at 15:48 +0100, James Hughes wrote:
> The driver was failing to check that the SKB wasn't cloned
> before adding checksum data or adding header data.
> Replace existing handling to extend the buffer with
> skb_cow. Don't use skb_cow_head as the sw checksum
> code modifies the data portion.
> 
> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
> ---
>  drivers/net/usb/smsc95xx.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index df60c98..04f6397 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -2067,13 +2067,9 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
>  	/* We do not advertise SG, so skbs should be already linearized */
>  	BUG_ON(skb_shinfo(skb)->nr_frags);
>  
> -	if (skb_headroom(skb) < overhead) {
> -		struct sk_buff *skb2 = skb_copy_expand(skb,
> -			overhead, 0, flags);
> -		dev_kfree_skb_any(skb);
> -		skb = skb2;
> -		if (!skb)
> -			return NULL;
> +	/* Make writable and expand space by overhead if required */
> +	if (skb_cow(skb, overhead)) {
> +		return NULL;
>  	}

Note that this patch will probably force a copy of all locally generated
TCP packets.

For them skb_cloned(skb) is true.

I do believe skb_cow_head() would be better, since TCP stack uses the
__skb_header_release() helper to tell lower stacks they can write the
header part, even on a clone.
