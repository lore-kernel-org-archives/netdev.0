From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 1/3] net: Add function for parsing the header length
 out of linear ethernet frames
Date: Thu, 04 Sep 2014 18:00:20 -0700
Message-ID: <54090B24.4070800@gmail.com>
References: <20140904230958.12376.2845.stgit@ahduyck-bv4.jf.intel.com>	 <20140904231333.12376.9881.stgit@ahduyck-bv4.jf.intel.com> <1409873788.26422.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:43925 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbaIEBAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 21:00:22 -0400
Received: by mail-pd0-f174.google.com with SMTP id v10so1380510pde.19
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 18:00:21 -0700 (PDT)
In-Reply-To: <1409873788.26422.130.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2014 04:36 PM, Eric Dumazet wrote:
> On Thu, 2014-09-04 at 19:13 -0400, Alexander Duyck wrote:
>> This patch updates some of the flow_dissector api so that it can be used to
>> parse the length of ethernet buffers stored in fragments.  Most of the
>> changes needed were to __skb_get_poff as it needed to be updated to support
>> sending a linear buffer instead of a skb.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>  include/linux/etherdevice.h |    1 +
>>  include/linux/skbuff.h      |    2 ++
>>  include/net/flow_keys.h     |    2 ++
>>  net/core/flow_dissector.c   |   41 ++++++++++++++++++++++++++---------------
>>  net/ethernet/eth.c          |   27 +++++++++++++++++++++++++++
>>  5 files changed, 58 insertions(+), 15 deletions(-)
>>
>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> index 12f48ca..f55667e 100644
>> --- a/net/core/flow_dissector.c
>> +++ b/net/core/flow_dissector.c
>> @@ -13,6 +13,7 @@
>>  #include <linux/if_pppox.h>
>>  #include <linux/ppp_defs.h>
>>  #include <net/flow_keys.h>
>> +#include <scsi/fc/fc_fcoe.h>
>>  
>>  /* copy saddr & daddr, possibly using 64bit load/store
>>   * Equivalent to :	flow->src = iph->saddr;
>> @@ -118,7 +119,7 @@ ipv6:
>>  		nhoff += sizeof(struct ipv6hdr);
>>  
>>  		flow_label = ip6_flowlabel(iph);
>> -		if (flow_label) {
>> +		if (flow_label && skb) {
> Hmpff... undocumented bit here....

I'll add a comment.  It is basically just forcing it to continue parsing
for the case where skb is NULL which currently only applies to
eth_get_headlen.

>  
> @@ -369,6 +365,21 @@ u32 __skb_get_poff(const struct sk_buff *skb)
>  	return poff;
>  }
>  
> +/* __skb_get_poff() returns the offset to the payload as far as it could
> + * be dissected. The main user is currently BPF, so that we can dynamically
> + * truncate packets without needing to push actual payload to the user
> + * space and can analyze headers only, instead.
> + */
> +u32 __skb_get_poff(const struct sk_buff *skb)
> +{
> +	struct flow_keys keys;
> +
> +	if (!skb_flow_dissect(skb, &keys))
> +		return 0;
> +
> +	return ___skb_get_poff(skb, skb->data, &keys, skb->len);
> hlen is not skb->len, but skb_headlen(skb)

My bad.  I will fix that for the next one.

>> +}
>> +
>>  static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
>>  {
>>  #ifdef CONFIG_XPS
>> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
>> index 5cebca1..f0299ac 100644
>> --- a/net/ethernet/eth.c
>> +++ b/net/ethernet/eth.c
>> @@ -146,6 +146,33 @@ int eth_rebuild_header(struct sk_buff *skb)
>>  EXPORT_SYMBOL(eth_rebuild_header);
>>  
>>  /**
>> + * eth_get_headlen - determine the the length of header for an ethernet frame
>> + * @data: pointer to start of frame
>> + * @len: total length of frame
>> + *
>> + * Make a best effort attempt to pull the length for all of the headers for
>> + * a given frame in a linear buffer.
>> + */
>> +u32 eth_get_headlen(void *data, unsigned int len)
>> +{
>> +	const struct ethhdr *eth = (const struct ethhdr *)data;
>> +	struct flow_keys keys;
>> +
>> +	/* this should never happen, but better safe than sorry */
>> +	if (len < sizeof(*eth))
>> +		return len;
>> +
>> +	/* parse any remaining L2/L3 headers, check for L4 */
>> +	if (!__skb_flow_dissect(NULL, &keys, data,
>> +				eth->h_proto, sizeof(*eth), len))
>> +		return max_t(u32, keys.thoff, sizeof(*eth));
> Not sure keys.thoff is valid at this point ?
>

It should be 0 if it didn't find any value.  __skb_flow_dissect starts
by doing a memset 0 on the keys.  So I am using the max_t to force it to
at least include the Ethernet header in the length to pull as otherwise
we will trigger errors on eth_type_trans.

Thanks,

Alex
