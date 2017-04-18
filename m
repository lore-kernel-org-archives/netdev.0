From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] smsc95xx: Use skb_cow_head to deal with cloned skbs
Date: Tue, 18 Apr 2017 11:58:41 -0700
Message-ID: <1492541921.10587.135.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170418171706.21190-1-james.hughes@raspberrypi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
To: James Hughes <james.hughes@raspberrypi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36542 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754946AbdDRS6n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 14:58:43 -0400
Received: by mail-pf0-f196.google.com with SMTP id i5so244636pfc.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 11:58:42 -0700 (PDT)
In-Reply-To: <20170418171706.21190-1-james.hughes@raspberrypi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-18 at 18:17 +0100, James Hughes wrote:
> The driver was failing to check that the SKB wasn't cloned
> before adding checksum data.
> Replace existing handling to extend/copy the header buffer
> with skb_cow_head.
> 
> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
> ---
> Changes in v2
>  - Changed skb_cow to skb_cow_head as suggested by netdev list
> 
> 
>  drivers/net/usb/smsc95xx.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index df60c98..094f0ee 100644
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
> +	/* Make writable and expand header space by overhead if required */
> +	if (skb_cow_head(skb, overhead)) {

I believe you still need to 
		dev_kfree_skb_any(skb);

> +		return NULL;
>  	}
>  
>  	if (csum) {
