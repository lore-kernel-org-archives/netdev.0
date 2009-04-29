From: "Matthew Lear" <matt@bubblegen.co.uk>
Subject: Re: fec driver question
Date: Wed, 29 Apr 2009 12:11:49 +0100 (BST)
Message-ID: <12670.83.100.215.137.1241003509.squirrel@webmail.plus.net>
References: <6078.83.100.215.137.1240989343.squirrel@webmail.plus.net>
    <20090429080002.GA10438@frolo.macqel>
    <12372.83.100.215.137.1240994917.squirrel@webmail.plus.net>
    <20090429100123.GA23541@frolo.macqel>
Reply-To: matt@bubblegen.co.uk
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, uclinux-dev@uclinux.org
To: "Philippe De Muyter" <phdm@macqel.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.pcl-ipout02.plus.net ([212.159.7.100]:22734 "EHLO
	relay.pcl-ipout02.plus.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758483AbZD2LWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 07:22:14 -0400
In-Reply-To: <20090429100123.GA23541@frolo.macqel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Matthew,
>
> [CCing uclinux-dev@uclinux.org and netdev@vger.kernel.org]
>
> On Wed, Apr 29, 2009 at 09:48:37AM +0100, Matthew Lear wrote:
>> Hi Phillippe - Thanks very much for your reply. some comments below:
>>
>> > Hi Matthew,
>> > On Wed, Apr 29, 2009 at 08:15:43AM +0100, Matthew Lear wrote:
>> >> Hello Philippe,
>> >>
>> >> I hope you don't mind me emailing you. Basically I have a dev board
>> from
>> >> freescale for doing some coldfire development on the mfc54455 device.
>> >> I'm
>> >> using the fec driver in the kernel. Kernel version is 2.6.23. I'm
>> havng
>> >> some problems and I was hoping you might be able to help me.
>> >>
>> >> It seems that running some quite heavy network throughput tests on
>> the
>> >> platform result in the driver dropping packets and the userspace app
>> >> running on the dev board to run consume ~ 85% cpu. I'm using netcat
>> as
>> >> the
>> >> app running on host and the target to do the tests.
>> >>
>> >> I can appreciate that this question  is somewhat 'open' in that there
>> >> could be several causes but I'm fairly certain that a) it's not
>> ksoftirq
>> >> related and b) that it's not driver related (because it's mature and
>> has
>> >> been used in all sorts of different application/platforms).
>> >>
>> >> Can you think of any possible causes for this? The fact that the
>> driver
>> >> is
>> >> dropping packets is surely indicative of there not being enough
>> buffers
>> >> to
>> >> place the incoming data and/or there are issues with the consumption
>> >> (and
>> >> subsequent freeing of these buffers) by something else.
>> >
>> > 1. You could make the same test after increasing the number of receive
>> > buffers
>> > in the driver.
>> >
>> > 2. Actually, each incoming packet generates one interrupt so it needs
>> some
>> > processing time in the interrupt service routine.  Hence if your
>> receive
>> > app itself consumes 85% CPU that's probably normal that at times all
>> > buffers
>> > are used and that the chip has to drop frames.  Check if you have idle
>> > time
>> > remaining.
>> >
>> > 3. It can also be a hardware bug/limitation in the chip itself.  I
>> used
>> > mainly the FEC driver with mcf5272 chips at 10 Mbps, because 100 Mbps
>> > was not really supported in hardware, although it was possible to ask
>> for
>> > it.
>> > There is an offical errata for that :)
>>
>> I did try to increase the number of buffers and I was surprised at the
>> result because it seemed that the cpu utilisation of the user space app
>> increases. There are some comments at the top of fec.c regarding keeping
>> numbers associated to the buffers as powers of 2. I increased the number
>> of buffers to 32 but bizarrely it seemed to make things worse (netcat
>> consumed ~ 95% cpu). Not sure what's going on there!
>
> For me, it means that you loose/drop less packets.  I surmise that your
> CPU is mmu-less, so packets must be copied from kernel to userspace for
> each received packet.  That time passed by the kernel in copying the
> packet for the app is counted as app time, I presume.
> You could measure memcpy's speed and compute how much time is needed
> with your expected throughput.

Apologies Philippe. I should have been more clear. The cpu has an mmu. I'm
running Freescale not uClinux.

>>
>> When you say "check idle time remaining", do you mean in the driver
>> itself
>> or use a profiling tool?
>
> I only meant looking for %id in 'top' header.
>
>>
>> I have seen the scenario of the cpu at ~85% and no packets dropped but
>> typically there are overruns and in this case /proc/net/dev indicates
>> that
>> there are fifo issues within the driver somehow.
>>
>> Yes. One interrupt per packet is what I expected but I also have an SH4
>> dev board (though it uses a different ethernet driver). Running the same
>> kernel version and exactly the same test with netcat on that platform
>> shows seriously contrasting results in that cpu utilisation of netcat on
>> the sh4 target is minimal (as it should be).
>
> Could that be that sh4 has a mmu, and that its ethernet driver implement
> zero-copy mode ?  I'm not an expert in that area though.
>
>>
>> I'm suspecting that it may be a mm or dma issue with how the buffers are
>> relayed to the upper layers. The driver is mature isn't it so I would
>> have
>
> I'm not sure at all that dma is used here, but I could be wrong.
>
>> expected that any problem such as this would have been spotted long
>> before
>> now? In this regard, I am of the opinion that it could possible be an
>> issue with the device as you say.
>
> It depends on what other people do with the ethernet device on their
> board.  Here it is only used for some lightweight communication.
> And, when I used it, the driver was already mature, but I still discovered
> real bugs in initialisation sequences and error recovery, e.g. when
> testing
> link connection/disconnection.

It would be interesting to hear from anybody specifically using the fec
driver on a coldfire based platform in relation to performance under heavy
network traffic conditions.

>>
>> The coldfire part I have is specified as supporting 10 and 100 Mbps so I
>> assume that there are no issues with it. Interesting though that you
>> mention the errata...
>>
>> I think it's just a case of trying to find where the cpu is spending its
>> time. It is quite frustrating though... :-(
>
> Yes, that's part of our job :)

Indeed :)

> Best regards
>
> Philippe
>


