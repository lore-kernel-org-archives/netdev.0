From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 1/2] mpls: multipath route support
Date: Sun, 11 Oct 2015 14:23:25 -0700
Message-ID: <561AD34D.4070005@cumulusnetworks.com>
References: <1444588174-44663-2-git-send-email-roopa@cumulusnetworks.com> <87fv1hrvdp.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, rshearma@brocade.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34541 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbbJKVX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 17:23:27 -0400
Received: by padhy16 with SMTP id hy16so135190665pad.1
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 14:23:27 -0700 (PDT)
In-Reply-To: <87fv1hrvdp.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/15, 1:41 PM, Eric W. Biederman wrote:
> Roopa Prabhu <roopa@cumulusnetworks.com> writes:
>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds support for MPLS multipath routes.
>>
>> Includes following changes to support multipath:
>> - splits struct mpls_route into 'struct mpls_route + struct mpls_nh'
>>
>> - 'struct mpls_nh' represents a mpls nexthop label forwarding entry
>>
>> - moves mpls route and nexthop structures into internal.h
>>
>> - A mpls_route can point to multiple mpls_nh structs
>>
>> - the nexthops are maintained as a array (similar to ipv4 fib)
>>
>> - In the process of restructuring, this patch also consistently changes
>>   all labels to u8
>>
>> - Adds support to parse/fill RTA_MULTIPATH netlink attribute for
>> multipath routes similar to ipv4/v6 fib
>>
>> - In this patch, the multipath route nexthop selection algorithm
>> simply returns the first nexthop. It is replaced by a
>> hash based algorithm from Robert Shearman in the next patch
>>
>> - mpls_route_update cleanup: remove 'dev' handling in mpls_route_update.
>> mpls_route_update though implemented to update based on dev, it was
>> never used that way. And the dev handling gets tricky with multiple nexthops.
>> Cannot match against any single nexthops dev. So, this patch removes the unused
>> 'dev' handling in mpls_route_update.
> Ugh.  Looking at this patch I have found if not a bug a misfeature.
>
> The existing code has a function:
>
>> bool mpls_output_possible(const struct net_device *dev)
>> {
>> 	return dev && (dev->flags & IFF_UP) && netif_carrier_ok(dev);
>> }
> Which makes a lot of sense if you only have a single path to choose
> from.   When multipath comes into play we need to do something to ensure
> we don't select a path that where no output is possible for a prolonged
> period of time.

I was planning to add support for this in incremental patches (they are in my todo). Basically introduce the required
support for RTNH_F_DEAD and RTNH_F_LINKDOWN and skipping dead and link down nexthops.
I will submit this as an incremental patch.
>
>> Example:
>>
>> $ip -f mpls route add 100 nexthop as 200 via inet 10.1.1.2 dev swp1 \
>>                 nexthop as 700 via inet 10.1.1.6 dev swp2 \
>>                 nexthop as 800 via inet 40.1.1.2 dev swp3
>>
>> $ip  -f mpls route show
>> 100
>>         nexthop as to 200 via inet 10.1.1.2  dev swp1
>>         nexthop as to 700 via inet 10.1.1.6  dev swp2
>>         nexthop as to 800 via inet 40.1.1.2  dev swp3
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>  include/net/mpls_iptunnel.h |   2 +-
>>  net/mpls/af_mpls.c          | 500 +++++++++++++++++++++++++++++++-------------
>>  net/mpls/internal.h         |  52 ++++-
>>  3 files changed, 404 insertions(+), 150 deletions(-)
>>
> [...]
>> @@ -196,9 +176,13 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>>  	if (!rt)
>>  		goto drop;
>>  
>> +	nh = mpls_select_multipath(rt);
>> +	if (!nh)
>> +		goto drop;
>> +
>>  	/* Find the output device */
>> -	out_dev = rcu_dereference(rt->rt_dev);
>> -	if (!mpls_output_possible(out_dev))
>> +	out_dev = rcu_dereference(nh->nh_dev);
>> +	if (!out_dev || !mpls_output_possible(out_dev))
>>  		goto drop;
>>
> nit: mpls_output_possible already embeds the !out_dev test, making this
> hunk redundant.
ack,
>
>>  	if (skb_warn_if_lro(skb))
>> @@ -635,9 +763,11 @@ static void mpls_ifdown(struct net_device *dev)
>>  		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
>>  		if (!rt)
>>  			continue;
>> -		if (rtnl_dereference(rt->rt_dev) != dev)
>> -			continue;
>> -		rt->rt_dev = NULL;
>> +		for_nexthops(rt) {
>> +			if (rtnl_dereference(nh->nh_dev) != dev)
>> +				continue;
>> +			nh->nh_dev = NULL;
>> +		} endfor_nexthops(rt);
>>  	}
>>  
>>  	mdev = mpls_dev_get(dev);
>> diff --git a/net/mpls/internal.h b/net/mpls/internal.h
>> index 2681a4b..d7757be3 100644
>> --- a/net/mpls/internal.h
>> +++ b/net/mpls/internal.h
>> @@ -21,6 +21,54 @@ struct mpls_dev {
>>  
>>  struct sk_buff;
>>  
>> +#define LABEL_NOT_SPECIFIED (1 << 20)
>> +#define MAX_NEW_LABELS 2
>> +
>> +/* This maximum ha length copied from the definition of struct neighbour */
>> +#define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
>>
>> +enum mpls_payload_type {
>> +	MPT_UNSPEC, /* IPv4 or IPv6 */
>> +	MPT_IPV4 = 4,
>> +	MPT_IPV6 = 6,
>> +
>> +	/* Other types not implemented:
>> +	 *  - Pseudo-wire with or without control word (RFC4385)
>> +	 *  - GAL (RFC5586)
>> +	 */
>> +};
>> +
>> +struct mpls_nh { /* next hop label forwarding entry */
>> +	struct net_device __rcu *nh_dev;
>> +	u32			nh_label[MAX_NEW_LABELS];
>> +	u8			nh_labels;
>> +	u8			nh_via_alen;
>> +	u8			nh_via_table;
>> +	u8			nh_via[MAX_VIA_ALEN];
>> +};
> I think for this patch this is a good version of mpls_nh.
>
> We do have significant optimization opportunities with the mpls_nh
> structure.
>
> - We waste a byte on each mpls label.
> - We need a full byte on any of the fields (nh_lables, nh_via_alen, nh_via_table).
> - nh_via does not need to be longer than 16bytes.  Only infiniband
>   has addresses longer than 16bytes, and no one has standardized
>   mpls over infinband.
>
> So I think with a little care we could reduce mpls_nh to 32 bytes on
> 64bit without any loss of functionality.
>  
yes, reducing MAX_VIA_ALEN to 16bytes would help here. I can do that in an incremental patch.

thanks for the review.
