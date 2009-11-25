From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH 00/10] Remove skb_dma_map/unmap calls
Date: Wed, 25 Nov 2009 09:25:33 -0800
Message-ID: <4B0D688D.4020904@intel.com>
References: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com> <20091125113050.GA19837@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "mcarlson@broadcom.com" <mcarlson@broadcom.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"sathyap@serverengines.com" <sathyap@serverengines.com>,
	"subbus@serverengines.com" <subbus@serverengines.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58404 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759284AbZKYRZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2009 12:25:28 -0500
In-Reply-To: <20091125113050.GA19837@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ajit Khaparde wrote:
> On 24/11/09 17:20 -0800, Alexander Duyck wrote:
>> This patch series removes the skb_dma_map and skb_dma_unmap function calls.
>> The reason for this change is because the use of skb_dma_map/unmap can lead
>> to serious issues when HW IOMMU is enabled.  This is because each mapping
>> of the skb with a HW IOMMU enabled results in a new set of DMA mappings.
>> This in turn leads to issues when skbs are cloned for uses such as
>> bridging or pktgen because each transmitting device will update the skb
>> shared info structure resulting in some mappings being overwritten, and others
>> being freed multiple times.
> 
> If this is the case can the members related to the dma mapping stuff
> (skb_shinfo(skb)->dma_maps) be moved out of this shared info structure and
> we retain this "good" abstraction provided by this skb_dma_map/unmap api?

I had submitted a patch on November 5th that tried to move the maps out 
of the shared info structure and into the sk_buff itself.  That was 
rejected and it was suggested to go back to what was there before since 
not enough drivers were using the skb_dma_map/unmap calls to justify 
increasing the size of an sk_buff.

The biggest issue is that you end up needing to retain a copy of the DMA 
mapping output each time it is called and so the easiest place to retain 
the information is within the transmit buffer driver specific data 
structure.

>> I am looking for input specifically on the tg3, be2net, and bnx2 driver
>> patches as I am not very familiar with them and I am not certain if
>> additional changes are required.
> 
>>       be2net: remove use of skb_dma_map/unmap
>>
>>  drivers/net/benet/be_main.c    |   37 ++++++---
> 
> We have pulled the be2net specific patch for testing and review.
> We will send an update once done with it.
> 
> -Ajit

Thanks for taking a look at this.

Alex
