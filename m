From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC] tc: introduce OpenFlow classifier
Date: Fri, 23 Jan 2015 16:38:42 +0100
Message-ID: <20150123153842.GI2065@nanopsycho.orion>
References: <1421933824-17916-1-git-send-email-jiri@resnulli.us>
 <20150123151145.GK25797@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:45541 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128AbbAWPip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 10:38:45 -0500
Received: by mail-we0-f179.google.com with SMTP id q59so8260169wes.10
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 07:38:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150123151145.GK25797@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 23, 2015 at 04:11:45PM CET, tgraf@suug.ch wrote:
>On 01/22/15 at 02:37pm, Jiri Pirko wrote:
>> This patch introduces OpenFlow-based filter. So far, the very essential
>> packet fields are supported (according to OpenFlow v1.4 spec).
>> 
>> Known issues: skb_flow_dissect hashes out ipv6 addresses. That needs
>> to be changed to store them somewhere so they can be used later on.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Since OpenFlow is a wire protocol the description could be somewhat
>confusing as you are not actually implementing OpenFlow. Maybe call
>this "OpenFlow inspired classifier" or something along those lines?

Yep, therefore I do not call it "OpenFlow" but rather
"Openflow-classifier". But sure, I will rename it to make it clearer

>
>> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
>> index 475e35e..9b01fae 100644
>> --- a/net/sched/Kconfig
>> +++ b/net/sched/Kconfig
>> @@ -477,6 +477,17 @@ config NET_CLS_BPF
>>  	  To compile this code as a module, choose M here: the module will
>>  	  be called cls_bpf.
>>  
>> +config NET_CLS_OPENFLOW
>> +	tristate "OpenFlow classifier"
>> +	select NET_CLS
>> +	---help---
>> +	  If you say Y here, you will be able to classify packets based on
>> +	  a configurable combination of packet keys and masks accordint to
>                                                                     ^^^
>
>Typo

Yep, already fixed.

>
>> +struct of_flow_key {
>> +	int	indev_ifindex;
>> +	struct {
>> +		u8	src[ETH_ALEN];
>> +		u8	dst[ETH_ALEN];
>> +		__be16	type;
>> +	} eth;
>> +	struct {
>> +		u8	proto;
>> +	} ip;
>> +	union {
>> +		struct {
>> +			__be32 src;
>> +			__be32 dst;
>> +		} ipv4;
>> +		struct {
>> +			struct in6_addr src;
>> +			struct in6_addr dst;
>> +		} ipv6;
>> +	};
>> +	union {
>> +		struct {
>> +			__be16 src;
>> +			__be16 dst;
>> +		} tp;
>> +	};
>> +} __aligned(BITS_PER_LONG / 8); /* Ensure that we can do comparisons as longs. */
>
>I'm sure you considered this already. Any advantage in sharing the
>flow key definition w/ OVS?


For now, I support much less than ovs here. Therefore I wanted to keep
the key simple. But I count with the eventual code merge with ovs in
this matter.


>
>> +static void of_extract_key(struct sk_buff *skb, struct of_flow_key *skb_key)
>> +{
>> +	struct flow_keys flow_keys;
>> +	struct ethhdr *eth;
>> +
>> +	skb_key->indev_ifindex = skb->skb_iif;
>> +
>> +	eth = eth_hdr(skb);
>> +	ether_addr_copy(skb_key->eth.src, eth->h_source);
>> +	ether_addr_copy(skb_key->eth.dst, eth->h_dest);
>> +
>> +	skb_flow_dissect(skb, &flow_keys);
>> +	skb_key->eth.type = flow_keys.n_proto;
>> +	skb_key->ip.proto = flow_keys.ip_proto;
>> +	skb_key->ipv4.src = flow_keys.src;
>> +	skb_key->ipv4.dst = flow_keys.dst;
>> +	skb_key->tp.src = flow_keys.port16[0];
>> +	skb_key->tp.dst = flow_keys.port16[1];
>> +}
>
>If I understand skb_flow_dissect() correctly then you will always
>fill of_flow_key with the inner most header. How would you for
>example match on the outer UDP header?

Yes, flow dissect is not ideal for this usage, for example also for the
ipv6 addresses hashing. I was thinking about extending it. Eventually,
this code can be merged with ovs as well.


>
>> +static bool of_match(struct of_flow_key *skb_key, struct cls_of_filter *f)
>> +{
>> +	const long *lkey = (const long *) &f->match.key;
>> +	const long *lmask = (const long *) &f->match.mask;
>> +	const long *lskb_key = (const long *) skb_key;
>> +	int i;
>> +
>> +	for (i = 0; i < sizeof(struct of_flow_key); i += sizeof(const long)) {
>> +		if ((*lkey++ & *lmask) != (*lskb_key++ & *lmask))
>> +			return false;
>> +		lmask++;
>> +	}
>> +	return true;
>> +}
>
>Nice. An further possible optimization would be to calculate the
>length of the flow key that must match and cut off the flow key if
>the remaining bits are all wildcarded, e.g. eth header only match.

Yep, I have another optimization ideas. I just focused to getting this
to work first, optimize later on.
