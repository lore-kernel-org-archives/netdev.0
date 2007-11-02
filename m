From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Fix e100 on systems that have cache incoherent DMA
Date: Fri, 02 Nov 2007 12:11:32 -0400
Message-ID: <472B4C34.5010909@pobox.com>
References: <20071102132703.1652446C128@localhost> <472B4AD0.4020504@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Acker <dacker@roinet.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Milton Miller <miltonm@bga.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Scott Feldman <sfeldma@pobox.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53425 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756276AbXKBQLx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2007 12:11:53 -0400
In-Reply-To: <472B4AD0.4020504@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> David Acker wrote:
>> On the systems that have cache incoherent DMA, including ARM, there is a
>> race condition between software allocating a new receive buffer and hardware
>> writing into a buffer.  The two race on touching the last Receive Frame
>> Descriptor (RFD).  It has its el-bit set and its next link equal to 0.
>> When hardware encounters this buffer it attempts to write data to it and
>> then update Status Word bits and Actual Count in the RFD.  At the same time
>> software may try to clear the el-bit and set the link address to a new buffer.
>>
>> Since the entire RFD is once cache-line, the two write operations can collide.
>> This can lead to the receive unit stalling or interpreting random memory as
>> its receive area.
>>
>> The fix is to set the el-bit on and the size to 0 on the next to last buffer
>> in the chain.  When the hardware encounters this buffer it stops and does not
>> write to it at all.  The hardware issues an RNR interrupt with the receive
>> unit in the No Resources state.  Software can write to the tail of the list
>> because it knows hardware will stop on the previous descriptor that was
>> marked as the end of list.
>>
>> Once it has a new next to last buffer prepared, it can clear the el-bit and
>> set the size on the previous one.  The race on this buffer is safe since
>> the link already points to a valid next buffer and the software can handle
>> the race setting the size (assuming aligned 16 bit writes are atomic with
>> respect to the DMA read). If the hardware sees the el-bit cleared without
>> the size set, it will move on to the next buffer and skip this one.  If it
>> sees the size set but the el-bit still set, it will complete that buffer
>> and then RNR interrupt and wait.
>>
>>
>> This is a patch for 2.6.24-rc1.
>>
>> Signed-off-by: David Acker <dacker@roinet.com>
>>
>> ---
>>
>> This version is based on the simpler patch I did in May.  The algorithm I tried
>> after that never worked correctly under load.  It would hang the RU and the
>> transmit unit sometimes and if the card was restarted it would often crash the
>> system with memory corruption.  This patch was tested on my embedded system
>> using pktgen.  I had it sending while a PC sent at it.  I also ran it as
>> wireless access point with a 12-hour bidirectional 20 mbps UDP going between an
>> ethernet host on the e100 and a wireless client.
> 
> looks much simpler to me too, which I like.
> 
> It's good to see something coming from you! I'm going to make sure this gets on
> the test bench today and will keep you posted on the progress. We'll take a few
> days to make sure that this doesn't break early.
> 
> Thanks!!!

Agreed, I _really_ appreciate this effort being kept alive.

	Jeff



