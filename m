From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] tulip: Support for byte queue limits
Date: Tue, 16 Jul 2013 15:37:45 +0100
Message-ID: <1373985465.2120.1.camel@bwh-desktop.uk.level5networks.com>
References: <20130712180116.21176.qmail@science.horizon.com>
	 <1373932689.3745.30.camel@bwh-desktop.uk.level5networks.com>
	 <CAP6odjjyXqhMBAY3L1p7w9UPU2VH04MsyaWG6wb1YB_Pe43Dyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: George Spelvin <linux@horizon.com>, <eric.dumazet@gmail.com>,
	"Grant Grundler" <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>
To: Grant Grundler <grantgrundler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63858 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932455Ab3GPOhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 10:37:50 -0400
In-Reply-To: <CAP6odjjyXqhMBAY3L1p7w9UPU2VH04MsyaWG6wb1YB_Pe43Dyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-15 at 18:17 -0700, Grant Grundler wrote:
> On Mon, Jul 15, 2013 at 4:58 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Fri, 2013-07-12 at 14:01 -0400, George Spelvin wrote:
> >> > Hi George,
> >> > While you are right that functionally it doesn't matter, my preference
> >> > would be to have nothing between the wmb() and iowrite() that kicks
> >> > off the TX. This marginally helps kick off the TX process consistently
> >> > slightly sooner. On modern HW, probably irrelevant, but not on the HW
> >> > these chips are used on.
> >>
> >> I'll revise it.  It just made sense to me to put it next to the other
> >> bookkeeping line of tp->cur_tx++.  Should I move them both below the
> >> iowrite()?  As in:
> >>
> >> --- a/drivers/net/ethernet/dec/tulip/tulip_core.c
> >> +++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
> >> @@ -702,11 +702,11 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >>       tp->tx_ring[entry].status = cpu_to_le32(DescOwned);
> >>       wmb();
> >>
> >> -     tp->cur_tx++;
> >> -
> >>       /* Trigger an immediate transmit demand. */
> >>       iowrite32(0, tp->base_addr + CSR1);
> >>
> >> +     tp->cur_tx++;
> >> +     netdev_sent_queue(dev, skb->len);
> >
> > This is not good practice, because once you start DMA you have
> > effectively passed ownership of the skb to the TX completion handler.
> 
> Is the problem the reference to skb->len?
> By passing ownership,  are you suggesting the device can change this value?

No, the device can complete the descriptor and then the TX completion
handler will free the skb.

[...]
> > But one day someone may want to get rid of this lock,
> > so this is a trap waiting to spring.
> 
> Even for tulip driver?  Sorry, I just can't imagine anyone taking
> enough interest in tulip driver to implement that.  I'm not even sure
> it would be possible.

You're taking interest in it, aren't you?  But I accept this is a minor
issue.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
