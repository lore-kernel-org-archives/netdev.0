From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [E1000-devel] [next:akpm 16/587] drivers/net/ethernet/intel/igb/igb_main.c:6231:2:
 error: call to '__compiletime_assert_6235' declared with attribute error:
 BUILD_BUG_ON failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) < (NET_SKB_PAD + NET_IP_ALIGN
 + IGB_TS_HDR_LEN + ETH...
Date: Wed, 20 Feb 2013 14:47:19 -0800
Message-ID: <51255277.2020005@intel.com>
References: <5122101a.nBjTqFyZXZ+WuzPr%fengguang.wu@intel.com>   <20130219142708.b454d98a.akpm@linux-foundation.org>   <804857E1F29AAC47BF68C404FC60A1844D0099DF@ORSMSX102.amr.corp.intel.com>   <CAL4WiirCCfN_Xi423sEJB5v=5hCR_3d8M26JmmG3VJ=fbH4-1g@mail.gmail.com>   <51251303.9030803@intel.com> <1361388156.19353.216.camel@edumazet-glaptop>  <51253ED2.3050605@intel.com> <1361396560.19353.226.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Daniel Santos <daniel.santos@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Wu, Fengguang" <fengguang.wu@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32564 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750895Ab3BTWrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2013 17:47:22 -0500
In-Reply-To: <1361396560.19353.226.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2013 01:42 PM, Eric Dumazet wrote:
> On Wed, 2013-02-20 at 13:23 -0800, Alexander Duyck wrote:
>
>> NET_SKB_PAD is defined for the s390.  It is already 32.  If you look it
>> up we only have 2 definitions for NET_SKB_PAD, one specific to the s390
>> architecture and the other one in skbuff.h.
>>
> Andrew traces disagree, as they were :
>
>>>> s390 allmodconfig:
>>>>
>>>> bool __cond = !(!(((2048) - (((sizeof(struct skb_shared_info)) + (256 - 1)) &
>>>> ~(256 - 1))) < (32 + 2 + 16 + 1514 + 4)));
>>>>
> So it might be only a cross-compile environment issue, I dont know.

Huh?  I'm not seeing what you are saying.  The NET_SKB_PAD is the value
that is in the last set of parenthesis since it was:
(NET_SKB_PAD + NET_IP_ALIGN + IGB_TS_HDR_LEN + ETH_FRAME_LEN + ETH_FCS_LEN)
    that is the bit that became:
(32 + 2 + 16 + 1514 + 4)

The problem is the skb_shared_info bit rounds up to 512 reducing the
available space to 1536.  If you add up all of the other bits ignoring
the NET_SKB_PAD value you end up with exactly 1536 meaning the only
value for NET_SKB_PAD that would work is 0.

>> From what I can tell we would have to drop the NET_SKB_PAD to 0 in order
>> to not trigger this error with igb since we still have to add 22 bytes
>> for igb's per packet timestamp header, IP alignment, and CRC.
>>
>> The simple fix is for us just to drop the BUILD_BUG_ON check for igb
>> since we already had a check for size check in igb_set_rx_buffer_len. 
>> It just means that build_skb won't be available for standard MTU sizes
>> on s390.
> Yeah, probably nobody will notice ;)

Yeah, it is only a few percentage points difference and only really
impacts small packets anyway.  :-)

Thanks,

Alex
