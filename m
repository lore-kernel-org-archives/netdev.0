From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and
 el bits)
Date: Mon, 21 May 2007 10:45:37 -0700
Message-ID: <4651DAC1.7050604@intel.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com> <464DDE3E.9010400@roinet.com> <e3819b7a866b1117fd5a69e6a85e0784@bga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Acker <dacker@roinet.com>, Jeff Garzik <jgarzik@pobox.com>,
	Scott Feldman <sfeldma@pobox.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Milton Miller <miltonm@bga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6745 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755100AbXEURqH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 13:46:07 -0400
In-Reply-To: <e3819b7a866b1117fd5a69e6a85e0784@bga.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Milton Miller wrote:
> On May 18, 2007, at 12:11 PM, David Acker wrote:
> 
>> Kok, Auke wrote:
>>> First impression just came in: It seems RX performance is dropped to 
>>> 10mbit. TX is unaffected and runs at 94mbit/tcp, but RX the new code 
>>> seems to misbehave and  fluctuate, dropping below 10mbit after a few 
>>> netperf runs and staying there...
>>> ideas?
>> I found the problem.  Another casualty of working with two different 
>> kernels at once...arg.
>> The blank rfd needs to have its el-bit clear now.  Here is the new and 
>> improved patch.
>>
>> On the ARM, their is a race condition between software allocating a 
>> new receive
>> buffer and hardware writing into a buffer.  The two race on touching 
>> the last
>> Receive Frame Descriptor (RFD).  It has its el-bit set and its next 
>> link equal
>> to 0.  When hardware encounters this buffer it attempts to write data 
>> to it
>> and then update Status Word bits and Actual Count in the RFD.  At the 
>> same time
>> software may try to clear the el-bit and set the link address to a new 
>> buffer.
>> Since the entire RFD is once cache-line, the two write operations can
>> collide.  This can lead to the receive unit stalling or freed receive 
>> buffers
>> getting written to.
>>
>> The fix is to set the el-bit on and the size to 0 on the next to last 
>> buffer
>> in the chain.  When the hardware encounters this buffer it stops and 
>> does
>> not write to it at all.  The hardware issues an RNR interrupt with the
>> receive unit in the No Resources state.  When software allocates 
>> buffers,
>> it can update the tail of the list because it knows the hardware will 
>> stop
>> at the buffer before it.  Once it has a new next to last buffer 
>> prepared,
>> it can clear the el-bit and set the size on the previous one.  The 
>> race on
>> this buffer is safe since the link already points to a valid next 
>> buffer.
>> If the hardware sees the el-bit cleared without the size set, it will
>> move on to the next buffer and complete that one in error.  If it sees
>> the size set but the el-bit still set, it will complete that buffer
>> and then RNR interrupt and wait.
>>
>>
>> Signed-off-by: David Acker <dacker@roinet.com>
>>
> 
> 
> This patch doesn't apply.  It appears white space damaged somewhere:
> 
> (1) blank lines in diff are empty not <space>
> (2) unchanged lines starting with tab are <space><space><tab>
> 
> After fixing the above I still get:
> 
> patching file drivers/net/e100.c
> Hunk #1 FAILED at 285.
> Hunk #4 FAILED at 1749.
> Hunk #8 FAILED at 1865.
> Hunk #10 succeeded at 1965 with fuzz 1.
> Hunk #11 succeeded at 1982 with fuzz 1.
> 3 out of 14 hunks FAILED -- saving rejects to file 
> drivers/net/e100.c.rej
> 
> although I haven't figured out what is wrong.
> 
> Proceeding with the review:
> 
> Coding style:
> (1) if body on seperate line.
> (2) space after if before (
> (3) The other enums in this driver are not ALL_CAPS
> (4) This driver doesn't do CONSTANT != value but value != enum
>      (see nic->mac for examples)

I sent Milton my copy of this patch which has these style issues corrected and 
applies cleanly to a recent git tree. If anyone else specifically wants a copy 
let me know.

Auke
