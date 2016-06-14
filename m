From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC 3/3] ipv4: kill RTO_ONLINK, RT_CONN_FLAGS and
 RT_CONN_FLAGS_TOS
Date: Tue, 14 Jun 2016 11:03:43 +0200
Message-ID: <0cd2e1a3-2e3f-8414-d720-aed2e13cdb05@stressinduktion.org>
References: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
 <1465850858-8559-4-git-send-email-hannes@stressinduktion.org>
 <alpine.LFD.2.11.1606140905470.2467@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:33104 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751643AbcFNJDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 05:03:46 -0400
In-Reply-To: <alpine.LFD.2.11.1606140905470.2467@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.06.2016 08:29, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 13 Jun 2016, Hannes Frederic Sowa wrote:
> 
>> Unfortunately because of bisectability I cannot split this patch. :(
>>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
>> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
>> index b4d746943bc570..961d7905599150 100644
>> --- a/drivers/net/vrf.c
>> +++ b/drivers/net/vrf.c
>> @@ -37,9 +37,6 @@
>>  #include <net/l3mdev.h>
>>  #include <net/fib_rules.h>
>>  
>> -#define RT_FL_TOS(oldflp4) \
>> -	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
> 
> 	IPTOS_RT_MASK is 3 bits (2..4) while RT_TOS is
> 4 bits (1..4). Should we just redefine RT_TOS to 3 bits?
> Otherwise, flowi4_tos still needs to be masked with IPTOS_RT_MASK
> and as result, it should be present in flowi4_update_output.
> But after removing the RTO_ONLINK flag from flowi4_tos,
> the tos should not be updated by flowi4_update_output,
> even if we mask it with IPTOS_RT_MASK.

Yes, my plan is to start adding either sparse or a new type for tos
fields, so we can have the compiler check all the casts/masking.

I hope those problems will simply vanish then. ;)

My plan is in the end to remove IPTTOS_TOS_MASK, IPTOS_RT_MASK and
RT_TOS and come up with something common for all tos handling.

>> -
>>  #define DRV_NAME	"vrf"
>>  #define DRV_VERSION	"1.0"
>>  
>> @@ -721,7 +718,6 @@ static int vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
>>  	u32 orig_tos = fl4->flowi4_tos;
>>  	u8 flags = fl4->flowi4_flags;
>>  	u8 scope = fl4->flowi4_scope;
>> -	u8 tos = RT_FL_TOS(fl4);
>>  	int rc;
>>  
>>  	if (unlikely(!fl4->daddr))
>> @@ -731,9 +727,6 @@ static int vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
>>  	fl4->flowi4_iif = LOOPBACK_IFINDEX;
>>  	/* make sure oif is set to VRF device for lookup */
>>  	fl4->flowi4_oif = dev->ifindex;
>> -	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
> 
> 	Ops, now output route has the same bug as the
> input route from 3.6: bit 1 reaches the rule matching,
> we left all 4 bits from RT_TOS in flowi4_tos.

Exactly, the next change in RT_TOS will fix this. We shouldn't be able
to store the lower bits in flowi4_tos then.

> 
>> -	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
>> -			     RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
>>  
>>  	rc = fib_lookup(net, fl4, &res, 0);
>>  	if (!rc) {
>> diff --git a/include/net/route.h b/include/net/route.h
>> index 8937e36fc9fd11..c374c217de7d7f 100644
>> --- a/include/net/route.h
>> +++ b/include/net/route.h
>> @@ -133,8 +136,10 @@ static inline struct rtable *ip_route_output_key(struct net *net, struct flowi4
>>  	return ip_route_output_flow(net, flp, NULL);
>>  }
>>  
>> -static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
>> -					     __be32 saddr, u8 tos, int oif)
>> +static inline struct rtable *ip_route_output_scope(struct net *net,
>> +						   __be32 daddr,
>> +						   __be32 saddr, u8 tos,
>> +						   u8 scope, int oif)
> 
> 	scope added but ignored?

Ups, I fixed this locally. Thanks for spotting.

> 
>>  {
>>  	struct flowi4 fl4 = {
>>  		.flowi4_oif = oif,
>> @@ -145,6 +150,18 @@ static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
>>  	return ip_route_output_key(net, &fl4);
>>  }
>>  
>> +static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
>> +					     __be32 saddr, u8 tos, int oif)
>> +{
>> +	return ip_route_output_scope(net, daddr, saddr, tos, RT_SCOPE_UNIVERSE,
>> +				     oif);
>> +}
>> +
>> +static inline struct rtable *ip_route_output_link(struct net *net, __be32 daddr)
>> +{
>> +	return ip_route_output_scope(net, daddr, 0, 0, RT_SCOPE_LINK, 0);
>> +}
>> +
>>  static inline struct rtable *ip_route_output_ports(struct net *net, struct flowi4 *fl4,
>>  						   struct sock *sk,
>>  						   __be32 daddr, __be32 saddr,
> 
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index e8f499d224ec2a..2446727ca6f980 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -2162,7 +2162,6 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
>>  					  int mp_hash)
>>  {
>>  	struct net_device *dev_out = NULL;
>> -	__u8 tos = RT_FL_TOS(fl4);
>>  	unsigned int flags = 0;
>>  	struct fib_result res;
>>  	struct rtable *rth;
>> @@ -2180,9 +2179,6 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
>>  	if (master_idx)
>>  		fl4->flowi4_oif = master_idx;
>>  	fl4->flowi4_iif = LOOPBACK_IFINDEX;
>> -	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
> 
> 	Now bit 1 reaches rule matching if not masked
> with IPTOS_RT_MASK.
> 
>> -	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
>> -			 RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
>>  
>>  	rcu_read_lock();
>>  	if (fl4->saddr) {
> 
> 	Also, do you plan to include a patch that adds the
> missing IPTOS_RT_MASK for input route or it is a material
> for the net tree?

I am not sure if I want to go for net tree. I would much rather focus on
fixing those things up upstream so it is easy to work with in future and
isn't as error-prone as it is now. This RFC was mostly about if the
re-factoring would be accepted upstream.

Bye,
Hannes
