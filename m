From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netpoll: Don't call driver methods from interrupt context.
Date: Fri, 07 Mar 2014 21:13:48 -0800
Message-ID: <87lhwltgqb.fsf@xmission.com>
References: <87d2i17bq8.fsf@xmission.com>
	<20140304.192616.918758436987378525.davem@davemloft.net>
	<87ha7cwiry.fsf@xmission.com>
	<20140307.143059.2030830185766849286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45715 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbaCHFNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 00:13:55 -0500
In-Reply-To: <20140307.143059.2030830185766849286.davem@davemloft.net> (David
	Miller's message of "Fri, 07 Mar 2014 14:30:59 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Wed, 05 Mar 2014 11:24:33 -0800
>
>> Now that I have looked closer the printk generating a printk problem
>> seems to be something that is best solved at the printk level.
>
> I'm not so sure that disallowing printk recursion is necessary.
>
> If you consider an error printk emitted from a device driver's
> transmit function during netconsole output, netpoll handles this
> transparently already.
>
> Basically, what happens right now in this situation is that netpoll
> queues it up when recursion is detected, and delayed work is scheduled
> to process such pending packets.

Except that printk does not recurse into netpoll again, printk adds the
message to printk's ring buffer, and then the next the next time through
the loop in console_unlock writes that message out with console_unlock.

I have had warnings from printk kill a couple of machines, which is
largely why I am anxious to fix netpoll.  Further I have experimentally
verified that I can still kill a machine that way in the 3.14-rcX.

> The only issue at hand is the IRQ context bit.

That is the only issue that is a networking stack issue, and I am happy to
focus there.  If we don't get printk's generating warnings the machine
won't lock up.

I am slowly working my way through reading the code and verifying I
really understand what is going on so I can reasonably say the routines
in the appropriate drivers should be safe in hard irq context.

Hopefully I will have patches in the next couple of days.

Eric
