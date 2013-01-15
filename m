From: Timo Teras <timo.teras@iki.fi>
Subject: Re: r8169 rx_missed increasing in bursts (regression)
Date: Tue, 15 Jan 2013 10:11:14 +0200
Message-ID: <20130115101114.0a59a7cb@vostro>
References: <20130108102814.7abe8c08@vostro>
	<20130108225833.GA4193@electric-eye.fr.zoreil.com>
	<20130109115850.055b7a7e@vostro>
	<20130109191456.0888ac75@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:38537 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753565Ab3AOILN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 03:11:13 -0500
Received: by mail-ee0-f41.google.com with SMTP id d41so2453368eek.0
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 00:11:12 -0800 (PST)
In-Reply-To: <20130109191456.0888ac75@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Jan 2013 19:14:56 +0200 Timo Teras <timo.teras@iki.fi> wrote:

> It seems that the rx_missed is not directly related to traffic amount.
> At times the box is handling easily 10000+ pps, while packet loss can
> happen at other times on 4000-8000pps levels.
> 
> Generally time_squeeze does not happen, and the box is at 20-30%
> softirq. Some times time_squeeze bumps up with one (within a one
> second interval) or two and packet loss does not happen.
> 
> When rx_missed is getting bumped, time_squeeze goes up with 1-3, and
> rx_missed goes up with 50-1000 packets. Usually around 200 packets. (1
> second sampling period)
> 
> I did find a strong correlation that rx_misses happen usually when the
> box has dropped a packet due to iptables DROP/REJECT rule, or some
> other reason (e.g. I'm seeing once in a while dmesg contain:
> "nf_ct_sip: dropping packet").
> 
> Any ideas why a netfilter packet drop might cause netdevice rx to
> stall long enough to saturate the hardware receive queue?

Ok, found the main culprit. Embarassingly, there was LOG targets, which
wound up writing to ttyS0. That apparently is synchronous operation, so
the printk's made the napi poller choke whenever packets got dropped.

However, I do still observe minor packet drops on specific loads.
Increasing the rx fifo size helped noticeably, but even at 512 it still
does some drops. Seems that Realtek's r8168 driver has rx fifo size of
1024.

Would it be feasible to make the fifo size a module parameter, or
somehow autotuned according to available system memory?

I also noticed that since recent commits, the dirty_rx is always
identical cur_rx. Basically, dirty_rx can be just removed. Should I
send a patch for this?

 - Timo
