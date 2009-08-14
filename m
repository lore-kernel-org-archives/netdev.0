From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] WAN: bit and/or confusion
Date: Fri, 14 Aug 2009 16:58:52 -0700
Message-ID: <20090814165852.7338461e.akpm@linux-foundation.org>
References: <4A855DE2.2000907@gmail.com>
	<20090814163644.0cc8974f.akpm@linux-foundation.org>
	<20090814.164123.36875657.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49997 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753611AbZHNX66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 19:58:58 -0400
In-Reply-To: <20090814.164123.36875657.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Aug 2009 16:41:23 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Fri, 14 Aug 2009 16:36:44 -0700
> 
> > On Fri, 14 Aug 2009 14:51:46 +0200
> > Roel Kluin <roel.kluin@gmail.com> wrote:
> > 
> >> @@ -663,9 +663,9 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
> >>  	} else {
> >>  		if (skb->data[pkt_len] & FrameRdo)
> >>  			dev->stats.rx_fifo_errors++;
> >> -		else if (!(skb->data[pkt_len] | ~FrameCrc))
> >> +		else if (!(skb->data[pkt_len] & ~FrameCrc))
> >>  			dev->stats.rx_crc_errors++;
> > 
> > that's
> > 
> > 	if (!(x & 0xffffffdf))
> > 
> > which seems peculiar.  Should it have been
> > 
> > 	else if (skb->data[pkt_len] & FrameCrc)
> > 
> > or
> > 
> > 	else if (!(skb->data[pkt_len] & FrameCrc))
> 
> Indeed, I can't tell which variant would be correct.
> 
> I'm reverting until someone with a datasheet for this chip speaks up
> :-)

http://www.datasheet.in/download.php?id=39415

Page 383 and 384 say that bit 5 (CRC) is zero if the rx frame contained
errors.


So we need

	else if (!(skb->data[pkt_len] & FrameCrc))

> -		else if (!(skb->data[pkt_len] | ~(FrameVfr | FrameRab)))
> +		else if (!(skb->data[pkt_len] & ~(FrameVfr | FrameRab)))


vfr is "valid frame".  0 is invalid.

rab is "receive message aborted".  The data sheet doesn't actually say
if the bit is active-high or active-low (grr).  

