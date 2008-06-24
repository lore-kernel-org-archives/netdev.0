From: Eric Miao <eric.y.miao@gmail.com>
Subject: Re: [PATCH 5/8] smc91x: add SMC91X_IO_SHIFT* macros and make SMC_IO_SHIFT
 a variable
Date: Tue, 24 Jun 2008 11:13:01 +0800
Message-ID: <4860663D.9040606@gmail.com>
References: <485A3E0B.1080505@gmail.com> <alpine.LFD.1.10.0806191223390.2982@xanadu.home> <485B2850.5050004@gmail.com> <alpine.LFD.1.10.0806200754030.23059@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	Magnus Damm <magnus.damm@gmail.com>
To: Nicolas Pitre <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:38933 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665AbYFXDNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 23:13:14 -0400
Received: by yw-out-2324.google.com with SMTP id 9so997514ywe.1
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 20:13:13 -0700 (PDT)
In-Reply-To: <alpine.LFD.1.10.0806200754030.23059@xanadu.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Pitre wrote:
> On Fri, 20 Jun 2008, Eric Miao wrote:
> 
>> Nicolas Pitre wrote:
>>> On Thu, 19 Jun 2008, Eric Miao wrote:
>>>
>>>> SMC_IO_SHIFT is currently hardcoded, which makes some platforms (e.g.
>>>> Lubbock) unable to use the newly introduced platform data. This patch
>>>> introduces SMC91X_IO_SHIFT* macros and make SMC_IO_SHIFT a variable.
>>>>
>>>> Signed-off-by: Eric Miao <eric.miao@marvell.com>
>>> NAK.
>>>
>>> The very point of those macros is actually to optimize the IO accesses 
>>> as much as possible at compile time.  By introducing a variable element 
>>> in the definition of those macros (for when the driver is configured 
>>> with constant params for those macros of course) you add a significant 
>>> overhead to every access to the hardware, including when transferring 
>>> data in and out of the chip.
>>>
>> Contrary to expected, the result shows a slight decrease on zylonite,
>> PXA310@624MHz, result shown as below:
>>
>> (by a simple measurement with "proc/uptime" and tftp)
>>
>> with SMC_IO_SHIFT being a variable
>>
>> trial 1: 2062776 bytes in (179.77 - 177.72 = 2.05) seconds = 1,006,232 Bps
>> trial 2: 2062776 bytes in (183.00 - 180.95 = 2.05) seconds = 1,006,232 Bps
>> trial 3: 2062776 bytes in (261.48 - 259.42 = 2.06) seconds = 1,001,347 Bps
>>
>> with SMC_IO_SHIFT being a constant
>>
>> trial 1: 2062776 bytes in (41.07 - 39.04 = 2.03) seconds = 1,016,145 Bps
>> trial 2: 2062776 bytes in (97.19 - 95.16 = 2.03) seconds = 1,016,145 Bps
>> trial 3: 2062776 bytes in (159.81 - 157.78 = 2.03) seconds = 1,016,145 Bps
>>
>> The statistics were stable during the test, so I generally think it's
>> typical.
>>
>> On lubbock, PXA255@200MHz, however, the result shows a slight increase:
>>
>> with SMC_IO_SHIFT being a variable
>>
>> trial 1: 2062776 bytes in (49.42 - 42.20 = 7.22) seconds = 285,703 Bps
>> trial 2: 2062776 bytes in (60.27 - 53.07 = 7.20) seconds = 286,497 Bps
>> trial 3: 2062776 bytes in (141.04 - 133.84 = 7.20) seconds = 286,497 Bps
>>
>> with SMC_IO_SHIFT being a constant
>>
>> trial 1: 2062776 bytes in (58.93 - 51.62 = 7.31) seconds = 282,185 Bps
>> trial 2: 2062776 bytes in (69.26 - 61.95 = 7.31) seconds = 282,185 Bps
>> trial 3: 2062776 bytes in (151.58 - 144.27 = 7.31) seconds = 282,185 Bps
>>
>> So I'm thinking that the overhead may not be so significant as expected,
>> 1. control register accesses are rare compared to data register
>> 2. data register access is usually fixed at one address and enclosed in
>>    a loop, which the compiler may well optimize
> 
> You must also look at the CPU usage too.  A faster CPU may well mitigate 
> the latency issue and make no significant throughput difference, but at 
> a higher CPU cost.  That means fewer cycles for doing anything else, 
> like drawing those pictures on the screen as they are received over the 
> net for example.
> 

OK, finally got netperf working, and here're the statistics as expected:

with SMC_IO_SHIFT being a constant:

Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    10.01         6.50   23.99    -1.00    302.459  -1.000
 87380  16384  16384    10.02         6.46   25.18    -1.00    319.295  -1.000
 87380  16384  16384    10.04         6.37   24.38    -1.00    313.405  -1.000

with SMC_IO_SHIFT being a variable:

Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    10.04         6.41   36.25    -1.00    463.470  -1.000
 87380  16384  16384    10.04         6.54   36.26    -1.00    454.069  -1.000
 87380  16384  16384    10.03         6.40   39.58    -1.00    506.363  -1.000

So the CPU utilization at the local sending side increases by > 10%, which
will create much overhead on slow CPU indeed.

>>> And this is very important to have the lowest overhead possible with 
>>> this chip that can do 100mbps on platforms with a CPU clock almost as 
>>> slow.
>>>
>> Indeed, the overhead will be magnified on a system with slow CPU clock,
>> maybe I should spend some time to have a test also. However, arguably,
>> the smc91x chips are usually used as a debug ethernet on most (if not
>> all) platforms, I don't think a serious design will deploy such a chip
>> for performance critical application, though.
> 
> That's not acceptable as an argument to introduce what actually is a 
> regression, especially when it should be possible to avoid it.  And the 
> fact is that there are already designs out there using this chip in 
> production, serious or not.
> 

OK, so is it arguable that boards like lubbock/mainstone/zylonite/littleton
can be switched over to use the SMC_IO_SHIFT as a variable and leave other
platforms unchanged due to the fact that these boards are just development
platforms and do not care much about performance?

> 
> Nicolas

