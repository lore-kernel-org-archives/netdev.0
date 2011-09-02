From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] ixgbe: drop zero length frame segments during a packet
 split rx
Date: Fri, 02 Sep 2011 10:54:23 -0700
Message-ID: <4E61184F.3040004@intel.com>
References: <1314972197-31557-1-git-send-email-nhorman@tuxdriver.com> <4E6101A4.4060802@intel.com> <20110902165523.GB27571@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20406 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753588Ab1IBRxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 13:53:10 -0400
In-Reply-To: <20110902165523.GB27571@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2011 09:55 AM, Neil Horman wrote:
> On Fri, Sep 02, 2011 at 09:17:40AM -0700, Alexander Duyck wrote:
>> This kind of fix just opens up a whole can of security related
>> worms.  If you are going to discard a packet you should do it after
>> we have reached the EOP in the series.  My advice would be to
>> determine what traits identify this packet and add those to the
>> check for the IXGBE_RXDADV_ERR_FRAME_ERR_MASK check further down in
>> the code.  Likely what you are seeing is skb_headlen(skb) will be
>> equal to 0.
>>
> Well, the traits of the bogus descriptor are almost exactly as you describe
> them, i.e. rx_buffer_info->dma is zero, which the driver takes to mean packet
> split is enabled, and this is a buffer in the middle of that operation
> (according to the comments in ixgbe_clean_rx_irq), and the upper_len value we
> read from the rx_descriptior rx_dex->wb.upper.length is zero.  This implies we
> have a frame which is in the middle of a packet split receive, and one of the
> page long buffers has a length value of zero, which is non-sensical.  I suppose
> we could wait until the next frame with EOP set to discard the whole thing, but
> I'm not sure how that amounts to anything different than just skipping to the
> next descriptor.
>
>> I'm suspecting this is some sort of read corruption.  It looks like
>> in order to trigger it you have to either be reading
>> rx_buffer_info->dma as 0, or the header length is being read as 0.
> Correct, which drops us into the else clause of the if(rx_buffer_info->dma)
> conditional in ixgbe_clean_rx_irq.
>
>> Do you know if you actually have header split enabled when this is
>> occuring?  Are you running with jumbo frames enabled to see the
> Yes, packet split is enabled. and no, Jumbo frames are not in use.
>
>> issue?  If not then packet split wouldn't be enabled.
>>
>> Is this occurring on net-next or on an older kernel?  I just want to
>> be sure since we added a read memory barrier in 2.6.34 to address
>> the fact that the length and descriptor DD bits were being read in
>> the wrong order resulting in the length being corrupted on PowerPC
>> systems.  The fact that we are now seeing another length error on
>> PowerPC seems very odd.
>>
> According to the bz:
> https://bugzilla.redhat.com/show_bug.cgi?id=683611
> This appears to be happening on RHEL, and on upstream kernels, as well as the
> sourceforge driver.  Don't quote me on the SF driver though, because I never got
> a clear answer on that.  Although, fwiw, the RHEL version of the driver in which
> we were definately seeing this problem has a read memory barrrier at the top of
> the loop in ixgbe_clean_rx_irq, pulled in from commit
> 3c945e5b3719bcc18c6ddd31bbcae8ef94f3d19a, so I think thats handled.
>
>
> Regards
> Neil
I'll review the bugzilla and submit my comments there.

Thanks,

Alex
