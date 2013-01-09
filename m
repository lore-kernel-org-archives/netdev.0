From: Timo Teras <timo.teras@iki.fi>
Subject: Re: r8169 rx_missed increasing in bursts (regression)
Date: Wed, 9 Jan 2013 11:58:50 +0200
Message-ID: <20130109115850.055b7a7e@vostro>
References: <20130108102814.7abe8c08@vostro>
	<20130108225833.GA4193@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:64065 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757422Ab3AIJ6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 04:58:55 -0500
Received: by mail-la0-f45.google.com with SMTP id ep20so1640018lab.18
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2013 01:58:54 -0800 (PST)
In-Reply-To: <20130108225833.GA4193@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Jan 2013 23:58:33 +0100 Francois Romieu
<romieu@fr.zoreil.com> wrote:

> Timo Teras <timo.teras@iki.fi> :
> [...]
> > My current hypothesis is that due to high softirq and recent(ish)
> > commit da78dbf "r8169: remove work from irq handler" moving more
> > work to softirq makes the receive path now suffer from latency from
> > getting irq to reading packets from the NIC on these boxes. And
> > that at times the rx fifo can get full causing a missed packet or
> > so.
> 
> This hypothesis won't explain the regression in 3.3.8 since 3.3.x does
> not include commit da78dbf.
> 
> Do you notice any netdev watchdog message in dmesg ?

In production boxes. No.

The lab environment where we tried to reproduce this, we received:
NOHZ: local_softirq_pending 08

Which is likely related, but separate issue. And fixed by commit
da78dbf. So seems that just got upgraded to "regression fix".

> 'perf top' may exhibit something unusual too.

Will try this.

I did notice that:
/proc/net/softnet_stat's 3rd field aka. softnet_data.time_squeeze keeps
incrementing when ever rx_missed increases. Sometiems time_squeeze
increments on it own. But rx_missed never increases without time_squeeze
bumping up seriously too.

> > This might be further escalated by the bug fixed in commit 7dbb491
> > "r8169: avoid NAPI scheduling delay" (which is not present in
> > -stable trees).
> 
> Right, it would had been worth adding to -stable.
> 
> However it only 1) is a problem for 3.4.x (fixed in 3.5) and 2)
> triggers when returning from the slow work thread - which should not
> be used much.

Ok. Didn't realize 3.3.x did not include it. So something else is broke
too.

The slow thread handles the RxOverflow, and in rx_missed case is taken
relatively often. Maybe add a printk there.

> [...]
> > So would it be sensible to do something like:
> > -#define NUM_RX_DESC    256     /* Number of Rx descriptor
> > registers */ +#define NUM_RX_DESC    512     /* Number of Rx
> > descriptor registers */
> 
> You can try it but it may actually increase the amount of heavy work
> done in softirq.

Ok. Will try this and some other things along with added debug logging.
