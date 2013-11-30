From: Mark Lord <mlord@pobox.com>
Subject: Re: net/usb/ax88179_178a driver broken in linux-3.12
Date: Fri, 29 Nov 2013 21:58:51 -0500
Message-ID: <5299546B.2020800@pobox.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com> <528A9A36.50903@pobox.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com> <20131119.161313.743887333007019981.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7439@saturn3.aculab.com> <20131120165420.GD9611@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	ming.lei@canonical.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:36237 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab3K3C66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 21:58:58 -0500
In-Reply-To: <20131120165420.GD9611@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-11-19 08:44 AM, Mark Lord wrote:
> On 13-11-19 05:04 AM, David Laight wrote:
>>
>> Which changes did you revert?
> 
> Just the bits that changed how the headroom/tailroom sizes
> were checked and adjusted.  See attachment for the revert patch
> I am using here.  My mailer unfortunately likes to mangle inline patches.
> 
> =========snip===========
> Revert USB 3.0 network driver changes that break the adapter (lockups)
> in 3.12.  This just puts back the original code from previous kernels.
> 
> Signed-off-by: Mark Lord <mlord@pobox.com>
> 
> --- linux/drivers/net/usb/ax88179_178a.c.orig   2013-11-03 18:41:51.000000000 -0500
> +++ linux/drivers/net/usb/ax88179_178a.c        2013-11-17 13:23:39.525734277 -0500
> @@ -1177,18 +1177,31 @@
>         int frame_size = dev->maxpacket;
>         int mss = skb_shinfo(skb)->gso_size;
>         int headroom;
> +       int tailroom;
> 
>         tx_hdr1 = skb->len;
>         tx_hdr2 = mss;
>         if (((skb->len + 8) % frame_size) == 0)
>                 tx_hdr2 |= 0x80008000;  /* Enable padding */
> 
> -       headroom = skb_headroom(skb) - 8;
> +       headroom = skb_headroom(skb);
> +       tailroom = skb_tailroom(skb);
> 
> -       if ((skb_header_cloned(skb) || headroom < 0) &&
> -           pskb_expand_head(skb, headroom < 0 ? 8 : 0, 0, GFP_ATOMIC)) {
> +       if (!skb_header_cloned(skb) &&
> +           !skb_cloned(skb) &&
> +           (headroom + tailroom) >= 8) {
> +               if (headroom < 8) {
> +                       skb->data = memmove(skb->head + 8, skb->data, skb->len);
> +                       skb_set_tail_pointer(skb, skb->len);
> +               }
> +       } else {
> +               struct sk_buff *skb2;
> +
> +               skb2 = skb_copy_expand(skb, 8, 0, flags);
>                 dev_kfree_skb_any(skb);
> -               return NULL;
> +               skb = skb2;
> +               if (!skb)
> +                       return NULL;
>         }
> 
>         skb_push(skb, 4);
> 


Two kernels later, and this regression has still not been fixed.

A simple revert, folks.
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
