From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [v2 PATCH 1/2] NETFILTER module xt_hmark new target
	for HASH based fw
Date: Tue, 8 Nov 2011 00:29:53 +0100 (CET)
Message-ID: <0hivdsb.f18682ec9367f08c76301d993553f1b8@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "Hans Schillstrom" <hans.schillstrom@ericsson.com>,
	kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Pablo Neira Ayuso" <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Pablo
>
>Hi Hans,
>
>On Mon, Oct 03, 2011 at 07:46:42PM +0200, Hans Schillstrom wrote:
>> diff --git a/include/linux/netfilter/xt_hmark.h b/include/linux/netfilter/xt_hmark.h
>> new file mode 100644
>> index 0000000..6c1436a
>> --- /dev/null
>> +++ b/include/linux/netfilter/xt_hmark.h
[snip]
>>  
>> +config NETFILTER_XT_TARGET_HMARK
>
>New config option has to go in alphabetic order (this one should go
>after NETFILTER_XT_TARGET_HL).

Oops, I'll fix that

[snip]
>> +/*
>> + * ICMP, get inner header so calc can be made on the source message
>> + *       not the icmp header, i.e. same hash mark must be produced
>> + *       on an icmp error message.
>> + */
>> +static int get_inner_hdr(struct sk_buff *skb, int iphsz, int nhoff)
>
>This looks very similar to icmp_error in nf_conntrack_proto_icmp.c.
>Yours lacks of checksumming validation btw.

Thanks I'll add that.

>
>I'm trying to find some place where we can put this function to make
>it available for both nf_conntrack_ipv4 and your module (to avoid code
>redundancy), but I didn't find any so far.
>
>It would be nice to find some way to avoid duplicating code with
>similar functionality.
>

I do agree, I've also been searching for some icmp "lib" to use...

[snip] 
>
>extra space not required.

OK
>
>> +	/* Error message? */
>> +	if (icmph->type != ICMP_DEST_UNREACH &&
>> +	    icmph->type != ICMP_SOURCE_QUENCH &&
>> +	    icmph->type != ICMP_TIME_EXCEEDED &&
>> +	    icmph->type != ICMP_PARAMETERPROB &&
>> +	    icmph->type != ICMP_REDIRECT)
>> +		goto out;
>> +	/* Checkin full IP header plus 8 bytes of protocol to
>> +	 * avoid additional coding at protocol handlers.
>> +	 */
>> +	if (!pskb_may_pull(skb, nhoff + iphsz + sizeof(_ih) + 8))
>> +		goto out;
>
>We prefer skb_header_pointer instead. If conntrack is enabled, we can
>benefit from defragmention. 

In  our case conntrack will not be there

>Please, replace all pskb_may_pull by skb_header_pointer in this code.
>
>We can assume that the IP header is linear (not fragmented).

I ran in to this issue in IPv6 testing so I got a little bit "paranoid".
Are you sure that the embedded IP and L4 header in the ICMP msg also is unfragmented.  
Is this true for both IPv6 & IPv4 ?

>From what I remember  when I was testing IPv6  icmp and digged into the original header (on a 2.6.32 kernel)  
pskb_may_pull was needed.

[snip]

>> +/*
>> + * Calc hash value, special casre is taken on icmp and fragmented messages
>> + * i.e. fragmented messages don't use ports.
>> + */
>> +static __u32 get_hash(struct sk_buff *skb, struct xt_hmark_info *info)
>
>This function seems to big to me, please, split it into smaller
>chunks, like get_hash_ipv4, get_hash_ipv6 and get_hash_ports.
>

Good catch I'll do that,

>> +{
>> +	int nhoff, hash = 0, poff, proto, frag = 0;
>> +	struct iphdr *ip;
>> +	u8 ip_proto;
>> +	u32 addr1, addr2, ihl;
>> +	u16 snatport = 0, dnatport = 0;
>> +	union {
>> +		u32 v32;
>> +		u16 v16[2];
>> +	} ports;
>> +
>> +	nhoff = skb_network_offset(skb);
>> +	proto = skb->protocol;
>> +
>> +	if (!proto && skb->sk) {
>> +		if (skb->sk->sk_family == AF_INET)
>> +			proto = __constant_htons(ETH_P_IP);
>> +		else if (skb->sk->sk_family == AF_INET6)
>> +			proto = __constant_htons(ETH_P_IPV6);
>
>You already have the layer3 protocol number in xt_action_param. No
>need to use the socket information then.

When splitting get_hash()  above  will  be removed,  xt_action_param ->family will be used for selection.

[snip]
>> +
>> +		if (!ct || !nf_ct_is_confirmed(ct))
>
>You seem to (ab)use nf_ct_is_confirmed to make sure you're not in the
>original direction. Better use the direction that you get by means of
>nf_ct_get.
>
I'm not sure I follow you here ?

>> +			break;
>> +		otuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
>> +		/* On the "return flow", to get the original address
>> +		 * i,e, replace the source address.
>> +		 */
>> +		if (ct->status & IPS_DST_NAT &&
>> +		    info->flags & XT_HMARK_USE_DNAT) {
>> +			rtuple = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
>> +			addr1 = (__force u32) otuple->dst.u3.in.s_addr;
>> +			dnatport = otuple->dst.u.udp.port;
>> +		}
>> +		/* On the "return flow", to get the original address
>> +		 * i,e, replace the destination address.
>> +		 */
>> +		if (ct->status & IPS_SRC_NAT &&
>> +		    info->flags & XT_HMARK_USE_SNAT) {
>> +			rtuple = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
>> +			addr2 = (__force u32) otuple->src.u3.in.s_addr;
>> +			snatport = otuple->src.u.udp.port;
>> +		}
>> +		break;
>> +	}

[snip]

>> +			case NEXTHDR_NONE:
>> +				nhoff += hdrlen;
>> +				goto hdr_rdy;
>> +			default:
>> +				goto done;
>
>This goto doesn't make too much sense to me, better return 0.

hmmm 
kind of left overs,  Actually all "goto done" can be replaced by return 0
  
[snip]

>> +done:
>> +	return 0;
>> +}
>
>I'll try to find more time to look into this. Specifically, I want to
>review the IPv6 bits more carefully.

The IPv6 header recursion is not obvious, and it's hard to test all cases :-)

I really appreciate you review

Thanks
Hans


