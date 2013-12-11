From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 4/4] asix: C1 DUB-E100 double rx_urb_size to 4096
Date: Wed, 11 Dec 2013 07:13:22 -0800
Message-ID: <1386774802.30495.369.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com>
	 <1386759028-3534-5-git-send-email-Dean_Jenkins@mentor.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B747E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dean Jenkins <Dean_Jenkins@mentor.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:55526 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892Ab3LKPNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 10:13:24 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so10134544pbb.37
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 07:13:24 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B747E@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-11 at 11:30 +0000, David Laight wrote:

> I don't think this will help - you've only moved the error.
> If the hardware manages to feed over 4k of ethernet frame data
> into a single usb bulk data frame it will still go wrong.

Yep, I feel this way too.

> 
> The rx code needs to keep the partial ethernet frame until the
> next usb bulk data urb arrives.
> (This only applies if the urb is a multiple of the usb packet size
> and isn't known to have been terminated by a zero length block.)
> 
> This should work provided the urb size is a multiple of the usb
> packet size - I don't know if a 1536 (3*512) skb fits into a 4k page.
> If it doesn't you should probably allocate a 5k skb (8k memory).
> (I don't believe there is any point allocating a size inbetween?)


skb allocated on RX path have skb->head as a fragment from a page.

We try to use high order pages, so using a size in between is totally
worth it.

Check __netdev_alloc_frag() for details.

For example, using 1536 bytes, we can fit 21 frames per 32 KB page.

If we were rounding do 2048 bytes, we would fit 16 frames per 32KB page.

I fear that doubling rx_urb_size is artificially doubling the skb
truesize (or not, and this would be a bug), and this has
an impact on general performance of TCP stack.
