From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net] gso: Update tunnel segmentation to support Tx checksum
 offload
Date: Wed, 10 Jul 2013 14:50:25 -0700
Message-ID: <51DDD721.3010901@intel.com>
References: <20130710203439.14927.20911.stgit@ahduyck-hc1.jf.intel.com> <1373491306.4600.17.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	pshelar@nicira.com, joseph.gasparakis@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5615 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755215Ab3GJVu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jul 2013 17:50:26 -0400
In-Reply-To: <1373491306.4600.17.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2013 02:21 PM, Eric Dumazet wrote:
> On Wed, 2013-07-10 at 13:43 -0700, Alexander Duyck wrote:
>> This change makes it so that the GRE and VXLAN tunnels can make use of Tx
>> checksum offload support provided by some drivers via the hw_enc_features.
>> This resolves a performance regression seen when using TSO versus just
>> using the Tx checksum offload.
>>
>> To achieve this it was necessary to address two items.  First
>> netif_skb_features needed to be updated so that it would correctly handle
>> the Trans Ether Bridging protocol.  To that end the reference to
>> skb->protocol was replaced with a call to skb_network_protocol.
>>
>> Second it was necessary to update the GRE and UDP tunnel segmentation
>> offloads so that they would reset the encapsulation bit and inner header
>> offsets after the offload was complete.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>
>> I am submitting this as a fix for 3.11 and stable, however the fix for
>> stable would likely need some modification since it seems that gre.c was
>> renamed to gre_offload.c at some point between 3.10 and 3.11.  If needed
>> I can submit a separate patch for stable.
>>
>>  net/core/dev.c         |    2 +-
>>  net/ipv4/gre_offload.c |    3 +++
>>  net/ipv4/udp.c         |    4 +++-
>>  3 files changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 560dafd..0419961 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2495,7 +2495,7 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
>>  
>>  netdev_features_t netif_skb_features(struct sk_buff *skb)
>>  {
>> -	__be16 protocol = skb->protocol;
>> +	__be16 protocol = skb_network_protocol(skb);
>>  	netdev_features_t features = skb->dev->features;
>>  
> If we call skb_network_protocol() here, do we still need following tests
> in netif_skb_features() ?
>
> if (protocol == htons(ETH_P_8021Q) || protocol == htons(ETH_P_8021AD)) {
>  ...
> } else if (!vlan_tx_tag_present(skb)) {
> }

I believe the vlan_tx_tag present check is still needed, although I am
not sure about all of the other protocol checks.  I think we could
probably simplify the function quite a bit more now that I look at it.

I'll update things to address the fact that protocol will not be either
of those values and submit a v2 later today.

Thanks,

Alex
