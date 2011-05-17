From: David Miller <davem@davemloft.net>
Subject: Re: Frequent spurious tx_timeouts for libertas
Date: Tue, 17 May 2011 13:05:40 -0700 (PDT)
Message-ID: <20110517.130540.193724442.davem@davemloft.net>
References: <1304303082.2833.159.camel@localhost>
	<BANLkTi=FT4v=Jvv5bQpUX15R87kPudKq=Q@mail.gmail.com>
	<1304369259.2833.180.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsd@laptop.org, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56442
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932249Ab1EQUGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 16:06:11 -0400
In-Reply-To: <1304369259.2833.180.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 02 May 2011 21:47:39 +0100

> On Mon, 2011-05-02 at 20:59 +0100, Daniel Drake wrote:
>> On 2 May 2011 03:24, Ben Hutchings <bhutchings@solarflare.com> wrote:
>> >> Also, while looking at this code, I spotted a bug in dev_watchdog():
>> >>                               /*
>> >>                                * old device drivers set dev->trans_start
>> >>                                */
>> >>                               trans_start = txq->trans_start ? : dev->trans_start;
>> >>
>> >> i.e. it is trying to figure out whether to read trans_start from txq
>> >> or dev. In both cases, trans_start is updated based on the value of
>> >> jiffies, which will occasionally be 0 (as it wraps around). Therefore
>> >> this line of code will occasionally make the wrong decision.
>> >
>> > No, I don't think so.
>> >
>> > If only dev->trans_start is being updated then the watchdog reads that.
>> > If both txq->trans_start and dev->trans_start are being updated then it
>> > doesn't matter much which the watchdog reads.
>> > If only txq->trans_start is being updated then dev->trans_start is
>> > always set to 0, so when txq->trans_start is 0 the watchdog still gets
>> > 0.
>> 
>> dev->trans_start is unconditionally initialized by dev_activate() in
>> sch_generic.c:
>> 
>> 	if (need_watchdog) {
>> 		dev->trans_start = jiffies;
>> 		dev_watchdog_up(dev);
>> 	}
>> 
>> so it is (usually) not 0.
> [...]
> 
> You're right.  Seems like we have an incomplete compatibility hack that
> can hurt drivers that are doing the right thing.
> 
> For those few single-queue drivers that need to update the transmit
> time, perhaps we could add a dev_trans_update() as a wrapper for
> txq_trans_update().  Then delete net_device::trans_start and change
> dev_trans_start() to avoid using it.

Even though this unconditional assignment exists, it should not cause
problems.

First, in dev_watchdog(), any non-zero txq->trans_start will be preferred
over dev->trans_start.

Second, in dev_trans_start(), netdev->trans_start is used as a baseline,
and any more recent stamp in txq->trans_start will be preferred.

In fact, this makes the assignment of netdev->trans_start to zero in
transition_one_qdisc() look erroneous.
