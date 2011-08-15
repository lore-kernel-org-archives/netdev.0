From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: invalid requirement from ethtool?
Date: Mon, 15 Aug 2011 18:24:00 +0100
Message-ID: <1313429040.2731.17.camel@bwh-desktop>
References: <20110726124222.GA4842@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eli Cohen <eli@dev.mellanox.co.il>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13644 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302Ab1HORYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 13:24:10 -0400
In-Reply-To: <20110726124222.GA4842@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-26 at 15:42 +0300, Eli Cohen wrote:
> Hi,
> I see the following text in include/linux/ethtool.h and wonder what is
> the reasoning for requiring that both params cannot be zero. I could
> not track when and who inserted this text as it dates before git was
> used to track kernel code, but my feeling is that is related to a
> specific hardware limitation.
> 
>         /* How many packets to delay an RX interrupt after
>          * a packet arrives.  If 0, only rx_coalesce_usecs is
>          * used.  It is illegal to set both usecs and max frames
>          * to zero as this would cause RX interrupts to never be
>          * generated.
>          */
>         __u32   rx_max_coalesced_frames;
> 
>         /* How many packets to delay a TX interrupt after
>          * a packet is sent.  If 0, only tx_coalesce_usecs is
>          * used.  It is illegal to set both usecs and max frames
>          * to zero as this would cause TX interrupts to never be
>          * generated.
>          */
>         __u32   tx_max_coalesced_frames;
> 
> I found this in tg3 driver:
>          /* No rx interrupts will be generated if both are zero */
>         if ((ec->rx_coalesce_usecs == 0) &&
>             (ec->rx_max_coalesced_frames == 0))
>                 return -EINVAL;
> 
> However, bnx2 for example allows setting both to zero.
> 
> I think both params zero should be allowed and mean coalescing is not
> operational, thus we can remove these comments from ethtool.h

If coalescing is not operational, the maximum number of completions
before an interrupt is 1.  So logically {rx,tx}_max_coalesced_frames
should be 1, right?  Although the comment does say 'How many packets ...
after ...' which implies that the value of the field must be 1 less than
the wanted maximum, i.e. 0, which is supposedly invalid.

The first implementation of ethtool coalescing control was in tg3, so it
should be a useful reference.

David, I know you maintained tg3 for some time so I assume you have a
hardware reference.  Can you confirm whether a value of 1 in
HOSTCC_{RX,TX}MAX_FRAMES results in an interrupt after 1 completion or
after 2 completions?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

