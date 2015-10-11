From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 2/2] mpls: flow-based multipath selection
Date: Sun, 11 Oct 2015 14:33:09 -0700
Message-ID: <561AD595.8050109@cumulusnetworks.com>
References: <1444588174-44663-3-git-send-email-roopa@cumulusnetworks.com> <877fmtw5rk.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, rshearma@brocade.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36507 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbbJKVdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 17:33:11 -0400
Received: by pablk4 with SMTP id lk4so135781784pab.3
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 14:33:10 -0700 (PDT)
In-Reply-To: <877fmtw5rk.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/15, 12:43 PM, Eric W. Biederman wrote:
> Roopa Prabhu <roopa@cumulusnetworks.com> writes:
>
>> From: Robert Shearman <rshearma@brocade.com>
>>
>> Change the selection of a multipath route to use a flow-based
>> hash. This more suitable for traffic sensitive to reordering within a
>> flow (e.g. TCP, L2VPN) and whilst still allowing a good distribution
>> of traffic given enough flows.
>>
>> Selection of the path for a multipath route is done using a hash of:
>> 1. Label stack up to MAX_MP_SELECT_LABELS labels or up to and
>>    including entropy label, whichever is first.
>> 2. 3-tuple of (L3 src, L3 dst, proto) from IPv4/IPv6 header in MPLS
>>    payload, if present.
>>
>> Naturally, a 5-tuple hash using L4 information in addition would be
>> possible and be better in some scenarios, but there is a tradeoff
>> between looking deeper into the packet to achieve good distribution,
>> and packet forwarding performance, and I have erred on the side of the
>> latter as the default.
> Not a fault with this patch, but this patches use of entropy labels
> does highlight that we don't handle creating entropy labels on ingress
> nor dealing with entropy labels on egress.
>
>> Signed-off-by: Robert Shearman <rshearma@brocade.com>
>> ---
>>  net/mpls/af_mpls.c | 88 ++++++++++++++++++++++++++++++++++++++++++++++++++----
>>  1 file changed, 83 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>> index 4d819df..15dd2eb 100644
>> --- a/net/mpls/af_mpls.c
>> +++ b/net/mpls/af_mpls.c
>> @@ -22,6 +22,11 @@
>>  #include <net/nexthop.h>
>>  #include "internal.h"
>>  
>> +/* Maximum number of labels to look ahead at when selecting a path of
>> + * a multipath route
>> + */
>> +#define MAX_MP_SELECT_LABELS 4
> This number seems a little small.  Especially given that an entopy label
> and the entropy label indicator consume two of these.  Although I
> suspect 4 is enough for most cases in practice.
yes, we have seen 4 to be enough in practice as well. We can increase it in future if need be.
>
>> +
>>  static int zero = 0;
>>  static int label_limit = (1 << 20) - 1;
>>  
>> @@ -77,10 +82,78 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
>>  }
>>  EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
>>  
>> -static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt)
>> +static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
>> +					     struct sk_buff *skb, bool bos)
>>  {
>> -	/* assume single nexthop for now */
>> -	return &rt->rt_nh[0];
>> +	struct mpls_entry_decoded dec;
>> +	struct mpls_shim_hdr *hdr;
>> +	bool eli_seen = false;
>> +	int label_index;
>> +	int nh_index = 0;
>> +	u32 hash = 0;
>> +
>> +	/* No need to look further into packet if there's only
>> +	 * one path
>> +	 */
>> +	if (rt->rt_nhn == 1)
>> +		goto out;
>> +
>> +	for (label_index = 0; label_index < MAX_MP_SELECT_LABELS && !bos;
>> +	     label_index++) {
>> +		if (!pskb_may_pull(skb, sizeof(*hdr) * label_index))
>> +			break;
>> +
>> +		/* Read and decode the current label */
>> +		hdr = mpls_hdr(skb) + label_index;
>> +		dec = mpls_entry_decode(hdr);
>> +
>> +		/* RFC6790 - reserved labels MUST NOT be used as keys
>> +		 * for the load-balancing function
>> +		 */
>> +		if (dec.label == MPLS_LABEL_ENTROPY) {
>> +			eli_seen = true;
>> +		} else if (dec.label >= MPLS_LABEL_FIRST_UNRESERVED) {
> We should probably test this first and mark this branch as likely.

ok
>
>> +			hash = jhash_1word(dec.label, hash);
>> +
>> +			/* The entropy label follows the entropy label
>> +			 * indicator, so this means that the entropy
>> +			 * label was just added to the hash - no need to
>> +			 * go any deeper either in the label stack or in the
>> +			 * payload
>> +			 */
>> +			if (eli_seen)
>> +				break;
>> +		}
>> +
>> +		bos = dec.bos;
>> +		if (bos && pskb_may_pull(skb, sizeof(*hdr) * label_index +
>> +					 sizeof(struct iphdr))) {
>> +			const struct iphdr *v4hdr;
>> +
>> +			v4hdr = (const struct iphdr *)(mpls_hdr(skb) +
>> +						       label_index);
>> +			if (v4hdr->version == 4) {
>> +				hash = jhash_3words(ntohl(v4hdr->saddr),
>> +						    ntohl(v4hdr->daddr),
>> +						    v4hdr->protocol, hash);
>> +			} else if (v4hdr->version == 6 &&
>> +				pskb_may_pull(skb, sizeof(*hdr) * label_index +
>> +					      sizeof(struct ipv6hdr))) {
>> +				const struct ipv6hdr *v6hdr;
>> +
>> +				v6hdr = (const struct ipv6hdr *)(mpls_hdr(skb) +
>> +								label_index);
>> +
>> +				hash = __ipv6_addr_jhash(&v6hdr->saddr, hash);
>> +				hash = __ipv6_addr_jhash(&v6hdr->daddr, hash);
>> +				hash = jhash_1word(v6hdr->nexthdr, hash);
>       If we are looking into the ipv6 packet we should look at the ipv6
>       flow label here.  The ipv6 flow label is roughly the equivalent
>       of the mpls entpropy label and removes any need to look deeper in
>       the packet to achieve good flow hashing.

ok, will look.
>
>> +			}
>> +		}
>> +	}
>> +
>> +	nh_index = hash % rt->rt_nhn;
>> +out:
>> +	return &rt->rt_nh[nh_index];
>>  }
>>  
>>  static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
>> @@ -145,7 +218,6 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>>  	unsigned int new_header_size;
>>  	unsigned int mtu;
>>  	int err;
>> -	int nhidx;
>>  
>>  	/* Careful this entire function runs inside of an rcu critical section */
>>  
>> @@ -176,7 +248,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>>  	if (!rt)
>>  		goto drop;
>>  
>> -	nh = mpls_select_multipath(rt);
>> +	nh = mpls_select_multipath(rt, skb, dec.bos);
>>  	if (!nh)
>>  		goto drop;
>>  
>> @@ -545,6 +617,12 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
>>  		if (!rtnh_ok(rtnh, remaining))
>>  			goto errout;
>>  
>> +		/* neither weighted multipath nor any flags
>> +		 * are supported
>> +		 */
>> +		if (rtnh->rtnh_hops || rtnh->rtnh_flags)
>> +			goto errout;
>> +
>>  		attrlen = rtnh_attrlen(rtnh);
>>  		if (attrlen > 0) {
>>  			struct nlattr *attrs = rtnh_attrs(rtnh);
