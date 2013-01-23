From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v2 10/10] ixgbe: Add support for set_channels ethtool
 operation
Date: Wed, 23 Jan 2013 15:48:05 -0800
Message-ID: <510076B5.7070108@intel.com>
References: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>  <20130110185846.29578.94872.stgit@ahduyck-cp1.jf.intel.com>  <1358353157.2923.18.camel@bwh-desktop.uk.solarflarecom.com>  <1358353807.29335.1.camel@ppwaskie-mobl2> <1358976045.2658.18.camel@bwh-desktop.uk.solarflarecom.com> <510064D5.2020905@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>,
	"ycai@google.com" <ycai@google.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55212 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143Ab3AWXsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 18:48:08 -0500
In-Reply-To: <510064D5.2020905@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/2013 2:31 PM, Alexander Duyck wrote:
> On 01/23/2013 01:20 PM, Ben Hutchings wrote:
>> On Wed, 2013-01-16 at 16:30 +0000, Waskiewicz Jr, Peter P wrote:
>>> On Wed, 2013-01-16 at 16:19 +0000, Ben Hutchings wrote:
>>>> On Thu, 2013-01-10 at 10:58 -0800, Alexander Duyck wrote:
>>>>> This change adds support for the ethtool set_channels operation.
>>>>>
>>>>> Since the ixgbe driver has to support DCB as well as the other modes the
>>>>> assumption I made here is that the number of channels in DCB modes refers
>>>>> to the number of queues per traffic class, not the number of queues total.
>>>>>
>>>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>>>> In DCB mode are there separate IRQs for the different classes?
>>> Yes.  The Rx packet buffer is split into multiple packet buffers, one
>>> for each online class.  After that, it's just queues assigned to the
>>> packet buffers, and interrupts assigned however you want them to be.
>> Right, I think we've been through this before.  And I can see how it
>> would be more useful for users to specify number of RX queues per
>> priority level.  But that's not what was specified...
>>
>> I'm afraid the 'channels' ethtool operations have turned into a mess...
>> I can't see how to get to a reasonable generic definition of what they
>> should do.
>>
>> Ben.
>
> Actually it looks like most of the drivers (I looked at bnx, bnx2x, tg3,
> and qlcnic) are using the set_queues call in a similar way.  What they
> end up doing is using the value and plugging it into their TSS/RSS
> fields in their private structures.  From what I can tell in
> bnx2x_setup_tc they may do exactly the same thing we are currently doing
> for DCB since they use the BNX2X_NUM_ETH_QUEUES value that they set in
> their set_channels call to set the number of queues they use per traffic
> class.  I would say the usage is actually pretty consistent between
> bnx2x and ixgbe based on this, even if it isn't exactly correct.
>
> For now I would say all of the drivers are using the set_channels
> operation to specify the number of Tx/Rx queues, or queue pairs per
> traffic class.  So for non-DCB NICs this means it is setting exactly
> that number of queues, and for DCB capable nics it means num_tcs times
> the specified number of queues.
>
> Thanks,
>
> Alex
>

Would it perhaps be cleaner to let set_channels set the absolute
number of tx/rx queue pairs regardless of number of tcs. Then
you could use the mqprio interface to divide those queues into
classes.

struct tc_mqprio_qopt {
         __u8    num_tc;
         __u8    prio_tc_map[TC_QOPT_BITMASK + 1];
         __u8    hw;
         __u16   count[TC_QOPT_MAX_QUEUE];
         __u16   offset[TC_QOPT_MAX_QUEUE];
};

The ndo_setup_tc op could pass the tc_mqprio_qopt structure to the
driver instead of just the number of tcs. This would allow changing
the number of queues per class depending on the traffic type expected
and set_channels then is consistent regardless of number of TCs.

Thanks,
John
