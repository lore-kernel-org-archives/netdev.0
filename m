From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [E1000-devel] [next:akpm 16/587] drivers/net/ethernet/intel/igb/igb_main.c:6231:2:
 error: call to '__compiletime_assert_6235' declared with attribute error:
 BUILD_BUG_ON failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) < (NET_SKB_PAD + NET_IP_ALIGN
 + IGB_TS_HDR_LEN + ETH...
Date: Wed, 20 Feb 2013 13:23:30 -0800
Message-ID: <51253ED2.3050605@intel.com>
References: <5122101a.nBjTqFyZXZ+WuzPr%fengguang.wu@intel.com>  <20130219142708.b454d98a.akpm@linux-foundation.org>  <804857E1F29AAC47BF68C404FC60A1844D0099DF@ORSMSX102.amr.corp.intel.com>  <CAL4WiirCCfN_Xi423sEJB5v=5hCR_3d8M26JmmG3VJ=fbH4-1g@mail.gmail.com>  <51251303.9030803@intel.com> <1361388156.19353.216.camel@edumazet-glaptop>
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
Received: from mga14.intel.com ([143.182.124.37]:36632 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935081Ab3BTVXw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2013 16:23:52 -0500
In-Reply-To: <1361388156.19353.216.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2013 11:22 AM, Eric Dumazet wrote:
> On Wed, 2013-02-20 at 10:16 -0800, Alexander Duyck wrote:
>
>> The problem is the 256 byte alignment for L1_CACHE_BYTES is increasing
>> the size of the data and shared info significantly pushing us past the
>> 2K limit.
>>
>> I'll look into this since it likely affects ixgbe as well.
> Thats what I said.
>
> Using 256 bytes of headroom is silly.
>
> We should limit NET_SKB_PAD to the 32-64 range
>
>

NET_SKB_PAD is defined for the s390.  It is already 32.  If you look it
up we only have 2 definitions for NET_SKB_PAD, one specific to the s390
architecture and the other one in skbuff.h.

>From what I can tell we would have to drop the NET_SKB_PAD to 0 in order
to not trigger this error with igb since we still have to add 22 bytes
for igb's per packet timestamp header, IP alignment, and CRC.

The simple fix is for us just to drop the BUILD_BUG_ON check for igb
since we already had a check for size check in igb_set_rx_buffer_len. 
It just means that build_skb won't be available for standard MTU sizes
on s390.

For ixgbe we can do something similar as well to avoid the BUILD_BUG_ON
message.

Thanks,

Alex
