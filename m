From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 10:53:25 -0800
Message-ID: <56D493A5.403@hurleysoftware.com>
References: <56D1E8B6.6090003@hurleysoftware.com>
 <1456638957.3676.12.camel@gmail.com>
 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
 <1456721889.3488.67.camel@gmail.com> <56D45DAF.5070709@hurleysoftware.com>
 <1456759153.648.61.camel@edumazet-ThinkPad-T530>
 <56D469B2.2070707@hurleysoftware.com>
 <1456762914.648.76.camel@edumazet-ThinkPad-T530>
 <56D48869.1000106@hurleysoftware.com>
 <1456770279.648.85.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36647 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbcB2Sx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 13:53:29 -0500
Received: by mail-pf0-f178.google.com with SMTP id t66so30866028pfb.3
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 10:53:28 -0800 (PST)
In-Reply-To: <1456770279.648.85.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/29/2016 10:24 AM, Eric Dumazet wrote:
> On lun., 2016-02-29 at 10:05 -0800, Peter Hurley wrote:
> 
>> While I appreciate the attempt, that's not the problem.
>>
>> Just to be clear
>>
>> 		if (time_before(jiffies, end) && !need_resched() &&
>> 		    --max_restart)
>> 			goto restart;
>>
>> aborts softirq *even if 0ns have elapsed*, if NET_RX has woken a process.
> 
> 
> Sure, now remove the 1st and 2nd condition.

Well just removing the 2nd condition has everything working fine,
because that fixes the priority inversion.


> You would still 'abort' (ie wakeup ksoftirqd really) when --max_restart
> becomes 0

Sure. Which would mean there's contended heavy i/o load so the driver
has to fallback to non-DMA. That's an acceptable outcome.


> So, instead of some subtle load dependent bug, you know have a reliable
> trigger.

There's no "subtle load dependent bug" here.

The driver has a fallback mode of operation that it relies on without
DMA. Of course, as I already wrote, this has consequences.

If system resources are _actually contended_, then naturally, fighting
for cpu and i/o time is fine, and I'm happy to do that in ksoftirqd.

However, when system resources are _not_ contended, it makes no
sense to be forced to revert to ksoftirqd resolution, which is strictly
intended as fallback.

Or flipping your argument on its head, why not just _always_ execute
softirq in ksoftirqd?
