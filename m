From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and
 el bits)
Date: Thu, 24 May 2007 08:44:06 -0400
Message-ID: <46558896.9070505@roinet.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com> <464DDE3E.9010400@roinet.com> <e3819b7a866b1117fd5a69e6a85e0784@bga.com> <4651DAC1.7050604@intel.com> <53c44b6f03973eb1b28f221859d3002c@bga.com> <465369AF.8080508@roinet.com> <f83441453b1233771c5bda869912aeca@bga.com> <4654B2E4.9010308@roinet.com> <039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>
To: Milton Miller <miltonm@bga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:40235
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756065AbXEXMm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 08:42:59 -0400
In-Reply-To: <039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Milton Miller wrote:
> On May 23, 2007, at 4:32 PM, David Acker wrote:
>> Milton Miller wrote:
>>> My current reading of the manual is that the C bit will not be
>>> set on an RFD that is size 0.  It goes on to processes EL and
>>> S, and decides to stop and interrupt RNR or suspend, or just
>>> go to the next packet.
>> I double checked this with a quick experiment and it appears you are 
>> correct.
>>
>> What about if we always did the following:
>> set the size:
>> sync();
>> clear el-bit
>> sync()
>>
>> Then if the hardware sees just the size set, the packet completes but 
>> with the el-bit and we know we need to restart since it completed.
>> If it sees the size == 0, and the el bit set, it stops and RNR 
>> interrupts.
> 
> I think this is exposed to a hole and a race:  we don't know if the 
> hardware
> read the RFD before we set the size or after, just that it was before 
> the EL
> bit was cleared.  If it read it before the size was set, then it will not
> set the C bit.  If it reads it after the size is set, it will complete it.
Yep...I too got sidetracked!  My test time got lost to two 2 month old 
twins needing to be fed or else! :-)

> 
> For coherent DMA we can always observe the C bit.  But for the 
> incoherent DMA
> case, our store to clear the EL bit may overwrite the dma from the 
> device to
> the beginning of the packet, or the write to EOF, F, and size, and/or the
> write to C, OK, and status bits to tell us its done.  In the worst case, we
> would overwrite the beginning of the data but catch the C bit and even the
> actual size, and therefore would receive corrupted data.
> 
> We can only detect the hardware went RNR when it does so or decide we 
> won the
> race when it receives and completes the next frame.
Yes, I agree.

>> When we find a buffer that is not completed but has the el-bit set, we 
>> read the status byte of the status control block to see if the RU is 
>> in the no resources state.  If it isn't, it means that we found that 
>> buffer  before the hardware did and thus need to wait for it.  We will 
>> either find it on the next poll or enable interrupts and get told 
>> about it by hardware.
>>
>> What do you think?
> 
> I think the second part is good ...
Cool.  That part seemed to work well in my tests.

I will reply to your next mail to discuss your plan so that I get it all 
in one message.
-Ack
