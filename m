From: Timo Teras <timo.teras@iki.fi>
Subject: Re: r8169 rx_missed increasing in bursts (regression)
Date: Wed, 9 Jan 2013 19:14:56 +0200
Message-ID: <20130109191456.0888ac75@vostro>
References: <20130108102814.7abe8c08@vostro>
	<20130108225833.GA4193@electric-eye.fr.zoreil.com>
	<20130109115850.055b7a7e@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61695 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932218Ab3AIRPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 12:15:00 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so959803eek.33
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2013 09:14:59 -0800 (PST)
In-Reply-To: <20130109115850.055b7a7e@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Jan 2013 11:58:50 +0200 Timo Teras <timo.teras@iki.fi> wrote:

> On Tue, 8 Jan 2013 23:58:33 +0100 Francois Romieu
> <romieu@fr.zoreil.com> wrote:
> 
> > Timo Teras <timo.teras@iki.fi> :
> > [...]
> > > My current hypothesis is that due to high softirq and recent(ish)
> > > commit da78dbf "r8169: remove work from irq handler" moving more
> > > work to softirq makes the receive path now suffer from latency
> > > from getting irq to reading packets from the NIC on these boxes.
> > > And that at times the rx fifo can get full causing a missed
> > > packet or so.
> > 
> > This hypothesis won't explain the regression in 3.3.8 since 3.3.x
> > does not include commit da78dbf.
> > 
> > Do you notice any netdev watchdog message in dmesg ?
> 
> In production boxes. No.
> 
> The lab environment where we tried to reproduce this, we received:
> NOHZ: local_softirq_pending 08
> 
> Which is likely related, but separate issue. And fixed by commit
> da78dbf. So seems that just got upgraded to "regression fix".
> 
> > 'perf top' may exhibit something unusual too.
> 
> Will try this.
> 
> I did notice that:
> /proc/net/softnet_stat's 3rd field aka. softnet_data.time_squeeze
> keeps incrementing when ever rx_missed increases. Sometiems
> time_squeeze increments on it own. But rx_missed never increases
> without time_squeeze bumping up seriously too.

Did more general observing.

It seems that the rx_missed is not directly related to traffic amount.
At times the box is handling easily 10000+ pps, while packet loss can
happen at other times on 4000-8000pps levels.

Generally time_squeeze does not happen, and the box is at 20-30%
softirq. Some times time_squeeze bumps up with one (within a one second
interval) or two and packet loss does not happen.

When rx_missed is getting bumped, time_squeeze goes up with 1-3, and
rx_missed goes up with 50-1000 packets. Usually around 200 packets. (1
second sampling period)

I did find a strong correlation that rx_misses happen usually when the
box has dropped a packet due to iptables DROP/REJECT rule, or some
other reason (e.g. I'm seeing once in a while dmesg contain:
"nf_ct_sip: dropping packet").

Any ideas why a netfilter packet drop might cause netdevice rx to stall
long enough to saturate the hardware receive queue?

- Timo
