From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next v3] xen-netfront: Add support for
 IPv6 offloads
Date: Tue, 07 Jan 2014 09:53:52 -0500
Message-ID: <52CC1500.8050104@oracle.com>
References: <1385484112-12975-1-git-send-email-paul.durrant@citrix.com> <52C31691.9040302@oracle.com> <9AAE0902D5BC7E449B7C8E4E778ABCD01E2C05@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Annie Li <annie.li@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18538 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbaAGOxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 09:53:19 -0500
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD01E2C05@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2014 05:25 AM, Paul Durrant wrote:
>> -----Original Message-----
>> From: Boris Ostrovsky [mailto:boris.ostrovsky@oracle.com]
>> Sent: 31 December 2013 19:10
>> To: Paul Durrant
>> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Konrad Rzeszutek
>> Wilk; David Vrabel; Ian Campbell; Wei Liu; Annie Li
>> Subject: Re: [PATCH net-next v3] xen-netfront: Add support for IPv6 offloads
>>
>> On 11/26/2013 11:41 AM, Paul Durrant wrote:
>>> This patch adds support for IPv6 checksum offload and GSO when those
>>> features are available in the backend.
>> Sorry for late review. Mostly style comments.
>>
> Thanks for the review.
>
> The checksum related code essentially needs to be a duplicate of that in netback and it seems wasteful to have the code in both places. Could this code be moved perhaps to net/core/dev.c? It's not specific to netback/netfront usage.

Will any of these routines be called for anything other than Xen 
networking?

I don't know about net/core/dev.c but given the large amount of 
duplicate code between netfront and netback I think factoring out should 
be done at least for these two. Into xen-netcore.c or some such.

-boris


>
> Opinions?
>
>    Paul
>
>>> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
>>> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
>>> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
>>> Cc: David Vrabel <david.vrabel@citrix.com>
>>> Cc: Ian Campbell <ian.campbell@citrix.com>
>>> Cc: Wei Liu <wei.liu2@citrix.com>
>>> Cc: Annie Li <annie.li@oracle.com>
>>> ---
>>>
>>> v3:
>>>    - Addressed comments raised by Annie Li
>>>
>>> v2:
>>>    - Addressed comments raised by Ian Campbell
>>>
>>>    drivers/net/xen-netfront.c |  239
>> ++++++++++++++++++++++++++++++++++++++++----
>>>    include/linux/ipv6.h       |    2 +
>>>    2 files changed, 224 insertions(+), 17 deletions(-)
>>>
>>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>>> index dd1011e..fe747e4 100644
>>> --- a/drivers/net/xen-netfront.c
>>> +++ b/drivers/net/xen-netfront.c
>>> @@ -616,7 +616,9 @@ static int xennet_start_xmit(struct sk_buff *skb,
>> struct net_device *dev)
>>>    		tx->flags |= XEN_NETTXF_extra_info;
>>>
>>>    		gso->u.gso.size = skb_shinfo(skb)->gso_size;
>>> -		gso->u.gso.type = XEN_NETIF_GSO_TYPE_TCPV4;
>>> +		gso->u.gso.type = (skb_shinfo(skb)->gso_type &
>> SKB_GSO_TCPV6) ?
>>> +			          XEN_NETIF_GSO_TYPE_TCPV6 :
>>> +			          XEN_NETIF_GSO_TYPE_TCPV4;
>>>    		gso->u.gso.pad = 0;
>>>    		gso->u.gso.features = 0;
>>>
>>> @@ -808,15 +810,18 @@ static int xennet_set_skb_gso(struct sk_buff
>> *skb,
>>>    		return -EINVAL;
>>>    	}
>>>
>>> -	/* Currently only TCPv4 S.O. is supported. */
>>> -	if (gso->u.gso.type != XEN_NETIF_GSO_TYPE_TCPV4) {
>>> +	if (gso->u.gso.type != XEN_NETIF_GSO_TYPE_TCPV4 &&
>>> +	    gso->u.gso.type != XEN_NETIF_GSO_TYPE_TCPV6) {
>>>    		if (net_ratelimit())
>>>    			pr_warn("Bad GSO type %d\n", gso->u.gso.type);
>>>    		return -EINVAL;
>>>    	}
>>>
>>>    	skb_shinfo(skb)->gso_size = gso->u.gso.size;
>>> -	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
>>> +	skb_shinfo(skb)->gso_type =
>>> +		(gso->u.gso.type == XEN_NETIF_GSO_TYPE_TCPV4) ?
>>> +		SKB_GSO_TCPV4 :
>>> +		SKB_GSO_TCPV6;
>>>
>>>    	/* Header must be checked, and gso_segs computed. */
>>>    	skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
>>> @@ -856,11 +861,42 @@ static RING_IDX xennet_fill_frags(struct
>> netfront_info *np,
>>>    	return cons;
>>>    }
>>>
>>> -static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
>>> +static inline bool maybe_pull_tail(struct sk_buff *skb, unsigned int min,
>>> +				   unsigned int max)
>> Should this routine return error code instead of a boolean? Otherwise
>> it's not clear what "false" should mean --- whether it is that it failed
>> to pull or that the pull wasn't needed.
>>
>>>    {
>>> -	struct iphdr *iph;
>>> -	int err = -EPROTO;
>>> +	int target;
>>> +
>>> +	BUG_ON(max < min);
>>> +
>>> +	if (!skb_is_nonlinear(skb) || skb_headlen(skb) >= min)
>>> +		return true;
>>> +
>>> +	/* If we need to pullup then pullup to max, so we hopefully
>>> +	 * won't need to do it again.
>>> +	 */
>> Comment style.
>>
>>> +	target = min_t(int, skb->len, max);
>>> +	__pskb_pull_tail(skb, target - skb_headlen(skb));
>>> +
>>> +	if (skb_headlen(skb) < min) {
>> Why not explicitly check whether__pskb_pull_tail() returned NULL ?
>>
>>> +		net_err_ratelimited("Failed to pullup packet header\n");
>>> +		return false;
>>> +	}
>>> +
>>> +	return true;
>>> +}
>>> +
>>> +/* This value should be large enough to cover a tagged ethernet header
>> plus
>>> + * maximally sized IP and TCP or UDP headers.
>>> + */
>> Comment style.
>>
>>> +#define MAX_IP_HEADER 128
>>> +
>>> +static int checksum_setup_ip(struct net_device *dev, struct sk_buff
>> *skb)
>>> +{
>>> +	struct iphdr *iph = (void *)skb->data;
>>> +	unsigned int header_size;
>>> +	unsigned int off;
>>>    	int recalculate_partial_csum = 0;
>>> +	int err = -EPROTO;
>>>
>>>    	/*
>>>    	 * A GSO SKB must be CHECKSUM_PARTIAL. However some buggy
>>> @@ -879,40 +915,158 @@ static int checksum_setup(struct net_device
>> *dev, struct sk_buff *skb)
>>>    	if (skb->ip_summed != CHECKSUM_PARTIAL)
>>>    		return 0;
>>>
>>> -	if (skb->protocol != htons(ETH_P_IP))
>>> +	off = sizeof(struct iphdr);
>>> +
>>> +	header_size = skb->network_header + off;
>>> +	if (!maybe_pull_tail(skb, header_size, MAX_IP_HEADER))
>>>    		goto out;
>>>
>>> -	iph = (void *)skb->data;
>>> +	off = iph->ihl * 4;
>>>
>>>    	switch (iph->protocol) {
>>>    	case IPPROTO_TCP:
>>> -		if (!skb_partial_csum_set(skb, 4 * iph->ihl,
>>> +		if (!skb_partial_csum_set(skb, off,
>>>    					  offsetof(struct tcphdr, check)))
>>>    			goto out;
>>>
>>>    		if (recalculate_partial_csum) {
>>>    			struct tcphdr *tcph = tcp_hdr(skb);
>>> +
>>> +			header_size = skb->network_header +
>>> +				off +
>>> +				sizeof(struct tcphdr);
>> You can put these (off and sizeof) onto the same line.
>>
>>> +			if (!maybe_pull_tail(skb, header_size,
>> MAX_IP_HEADER))
>>> +				goto out;
>>> +
>>>    			tcph->check = ~csum_tcpudp_magic(iph->saddr, iph-
>>> daddr,
>>> -							 skb->len - iph->ihl*4,
>>> +							 skb->len - off,
>>>    							 IPPROTO_TCP, 0);
>>>    		}
>>>    		break;
>>>    	case IPPROTO_UDP:
>>> -		if (!skb_partial_csum_set(skb, 4 * iph->ihl,
>>> +		if (!skb_partial_csum_set(skb, off,
>>>    					  offsetof(struct udphdr, check)))
>>>    			goto out;
>>>
>>>    		if (recalculate_partial_csum) {
>>>    			struct udphdr *udph = udp_hdr(skb);
>>> +
>>> +			header_size = skb->network_header +
>>> +				off +
>>> +				sizeof(struct udphdr);
>>> +			if (!maybe_pull_tail(skb, header_size,
>> MAX_IP_HEADER))
>>> +				goto out;
>>> +
>>>    			udph->check = ~csum_tcpudp_magic(iph->saddr,
>> iph->daddr,
>>> -							 skb->len - iph->ihl*4,
>>> +							 skb->len - off,
>>>    							 IPPROTO_UDP, 0);
>>>    		}
>>>    		break;
>>>    	default:
>>> -		if (net_ratelimit())
>>> -			pr_err("Attempting to checksum a non-TCP/UDP
>> packet, dropping a protocol %d packet\n",
>>> -			       iph->protocol);
>>> +		net_err_ratelimited("Attempting to checksum a non-
>> TCP/UDP packet, dropping a protocol %d packet\n",
>>> +				    iph->protocol);
>>> +		goto out;
>>> +	}
>>> +
>>> +	err = 0;
>>> +
>>> +out:
>>> +	return err;
>>> +}
>>> +
>>> +/* This value should be large enough to cover a tagged ethernet header
>> plus
>>> + * an IPv6 header, all options, and a maximal TCP or UDP header.
>>> + */
>>> +#define MAX_IPV6_HEADER 256
>>> +
>>> +static int checksum_setup_ipv6(struct net_device *dev, struct sk_buff
>> *skb)
>>> +{
>>> +	struct ipv6hdr *ipv6h = (void *)skb->data;
>>> +	u8 nexthdr;
>>> +	unsigned int header_size;
>>> +	unsigned int off;
>>> +	bool fragment;
>>> +	bool done;
>>> +	int err = -EPROTO;
>>> +
>>> +	done = false;
>> This should probably be moved down to the beginning of the while loop.
>> And you also need to initialize fragment to "false" (and possibly rename
>> it to is_fragment?)
>>
>>> +
>>> +	/* A non-CHECKSUM_PARTIAL SKB does not require setup. */
>>> +	if (skb->ip_summed != CHECKSUM_PARTIAL)
>>> +		return 0;
>>> +
>>> +	off = sizeof(struct ipv6hdr);
>>> +
>>> +	header_size = skb->network_header + off;
>>> +	if (!maybe_pull_tail(skb, header_size, MAX_IPV6_HEADER))
>>> +		goto out;
>>> +
>>> +	nexthdr = ipv6h->nexthdr;
>>> +
>>> +	while ((off <= sizeof(struct ipv6hdr) + ntohs(ipv6h->payload_len))
>> &&
>>> +	       !done) {
>>> +		switch (nexthdr) {
>>> +		case IPPROTO_DSTOPTS:
>>> +		case IPPROTO_HOPOPTS:
>>> +		case IPPROTO_ROUTING: {
>>> +			struct ipv6_opt_hdr *hp = (void *)(skb->data + off);
>>> +
>>> +			header_size = skb->network_header +
>>> +				off +
>>> +				sizeof(struct ipv6_opt_hdr);
>> I'd merge the last two lines.
>>
>>> +			if (!maybe_pull_tail(skb, header_size,
>> MAX_IPV6_HEADER))
>>> +				goto out;
>>> +
>>> +			nexthdr = hp->nexthdr;
>>> +			off += ipv6_optlen(hp);
>>> +			break;
>>> +		}
>>> +		case IPPROTO_AH: {
>>> +			struct ip_auth_hdr *hp = (void *)(skb->data + off);
>>> +
>>> +			header_size = skb->network_header +
>>> +				off +
>>> +				sizeof(struct ip_auth_hdr);
>> Here as well.
>>
>>> +			if (!maybe_pull_tail(skb, header_size,
>> MAX_IPV6_HEADER))
>>> +				goto out;
>>> +
>>> +			nexthdr = hp->nexthdr;
>>> +			off += ipv6_ahlen(hp);
>>> +			break;
>>> +		}
>>> +		case IPPROTO_FRAGMENT:
>>> +			fragment = true;
>>> +			/* fall through */
>>> +		default:
>>> +			done = true;
>>> +			break;
>>> +		}
>>> +	}
>>> +
>>> +	if (!done) {
>>> +		net_err_ratelimited("Failed to parse packet header\n");
>>> +		goto out;
>>> +	}
>>> +
>>> +	if (fragment) {
>>> +		net_err_ratelimited("Packet is a fragment!\n");
>>> +		goto out;
>>> +	}
>>> +
>>> +	switch (nexthdr) {
>>> +	case IPPROTO_TCP:
>>> +		if (!skb_partial_csum_set(skb, off,
>>> +					  offsetof(struct tcphdr, check)))
>>> +			goto out;
>>> +		break;
>>> +	case IPPROTO_UDP:
>>> +		if (!skb_partial_csum_set(skb, off,
>>> +					  offsetof(struct udphdr, check)))
>>> +			goto out;
>>> +		break;
>>> +	default:
>>> +		net_err_ratelimited("Attempting to checksum a non-
>> TCP/UDP packet, dropping a protocol %d packet\n",
>>> +				    nexthdr);
>>>    		goto out;
>>>    	}
>>>
>>> @@ -922,6 +1076,25 @@ out:
>>>    	return err;
>>>    }
>>>
>>> +static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
>>> +{
>>> +	int err;
>> Initialize to -EPROTO (just to keep consistent with the rest of the file)
>>
>>> +
>>> +	switch (skb->protocol) {
>>> +	case htons(ETH_P_IP):
>>> +		err = checksum_setup_ip(dev, skb);
>>> +		break;
>>> +	case htons(ETH_P_IPV6):
>>> +		err = checksum_setup_ipv6(dev, skb);
>>> +		break;
>>> +	default:
>>> +		err = -EPROTO;
>>> +		break;
>>> +	}
>>> +
>>> +	return err;
>>> +}
>>> +
>>>    static int handle_incoming_queue(struct net_device *dev,
>>>    				 struct sk_buff_head *rxq)
>>>    {
>>> @@ -1232,6 +1405,15 @@ static netdev_features_t
>> xennet_fix_features(struct net_device *dev,
>>>    			features &= ~NETIF_F_SG;
>>>    	}
>>>
>>> +	if (features & NETIF_F_IPV6_CSUM) {
>>> +		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
>>> +				 "feature-ipv6-csum-offload", "%d", &val) <
>> 0)
>>> +			val = 0;
>>> +
>>> +		if (!val)
>>> +			features &= ~NETIF_F_IPV6_CSUM;
>>> +	}
>>> +
>>>    	if (features & NETIF_F_TSO) {
>>>    		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
>>>    				 "feature-gso-tcpv4", "%d", &val) < 0)
>>> @@ -1241,6 +1423,15 @@ static netdev_features_t
>> xennet_fix_features(struct net_device *dev,
>>>    			features &= ~NETIF_F_TSO;
>>>    	}
>>>
>>> +	if (features & NETIF_F_TSO6) {
>>> +		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
>>> +				 "feature-gso-tcpv6", "%d", &val) < 0)
>>> +			val = 0;
>>> +
>>> +		if (!val)
>>> +			features &= ~NETIF_F_TSO6;
>>> +	}
>>> +
>>>    	return features;
>>>    }
>>>
>>> @@ -1373,7 +1564,9 @@ static struct net_device
>> *xennet_create_dev(struct xenbus_device *dev)
>>>    	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
>>>    	netdev->features        = NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
>>>    				  NETIF_F_GSO_ROBUST;
>>> -	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG |
>> NETIF_F_TSO;
>>> +	netdev->hw_features	= NETIF_F_SG |
>>> +		                  NETIF_F_IPV6_CSUM |
>>> +		                  NETIF_F_TSO | NETIF_F_TSO6;
>> Can you merge these three lines and stay under 80? If not, merge either
>> of the two of them.
>>
>>
>> -boris
>>
>>>    	/*
>>>             * Assume that all hw features are available for now. This set
>>> @@ -1751,6 +1944,18 @@ again:
>>>    		goto abort_transaction;
>>>    	}
>>>
>>> +	err = xenbus_printf(xbt, dev->nodename, "feature-gso-tcpv6",
>> "%d", 1);
>>> +	if (err) {
>>> +		message = "writing feature-gso-tcpv6";
>>> +		goto abort_transaction;
>>> +	}
>>> +
>>> +	err = xenbus_printf(xbt, dev->nodename, "feature-ipv6-csum-
>> offload", "%d", 1);
>>> +	if (err) {
>>> +		message = "writing feature-ipv6-csum-offload";
>>> +		goto abort_transaction;
>>> +	}
>>> +
>>>    	err = xenbus_transaction_end(xbt, 0);
>>>    	if (err) {
>>>    		if (err == -EAGAIN)
>>> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
>>> index 5d89d1b..10f1b03 100644
>>> --- a/include/linux/ipv6.h
>>> +++ b/include/linux/ipv6.h
>>> @@ -4,6 +4,8 @@
>>>    #include <uapi/linux/ipv6.h>
>>>
>>>    #define ipv6_optlen(p)  (((p)->hdrlen+1) << 3)
>>> +#define ipv6_ahlen(p)   (((p)->hdrlen+2) << 2);
>>> +
>>>    /*
>>>     * This structure contains configuration options per IPv6 link.
>>>     */
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
