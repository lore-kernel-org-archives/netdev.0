From: "Rajahalme, Jarno (NSN - FI/Espoo)" <jarno.rajahalme@nsn.com>
Subject: Re: [PATCH] datapath: Add basic MPLS support to kernel
Date: Thu, 25 Apr 2013 10:02:49 +0000
Message-ID: <A52D2BF3-6A9D-42B5-B52F-0F9FC7A50D61@nsn.com>
References: <1366876738-29688-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "<dev@openvswitch.org>" <dev@openvswitch.org>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
To: ext Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:14329 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757243Ab3DYKDO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 06:03:14 -0400
In-Reply-To: <1366876738-29688-1-git-send-email-horms@verge.net.au>
Content-Language: en-US
Content-ID: <65E388ABD4C9CC4FA20DB315E98CD11E@internal.nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 25, 2013, at 10:58 , ext Simon Horman wrote:

> @@ -648,6 +650,7 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
> 		return -ENOMEM;
> 
> 	skb_reset_network_header(skb);
> +	skb_reset_mac_len(skb);
> 	__skb_push(skb, skb->data - skb_mac_header(skb));
> 
> 	/* Network layer. */
> @@ -730,6 +733,30 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
> 			memcpy(key->ipv4.arp.tha, arp->ar_tha, ETH_ALEN);
> 			key_len = SW_FLOW_KEY_OFFSET(ipv4.arp);
> 		}
> +	} else if (eth_p_mpls(key->eth.type)) {
> +		size_t stack_len = MPLS_HLEN;
> +
> +		while (1) {
> +			__be32 lse;
> +
> +			error = check_header(skb, stack_len);

skb->data has been pushed to the mac_header prior to this, so this would not test availability of the MPLS data. 
Maybe the following would work:

			error = check_header(skb, skb->mac_len + stack_len);

> +			if (unlikely(error))
> +				goto out;
> +
> +			memcpy(&lse, skb_network_header(skb), MPLS_HLEN);
> +
> +			if (stack_len == MPLS_HLEN) {
> +				key_len = SW_FLOW_KEY_OFFSET(mpls.top_lse);
> +				memcpy(&key->mpls.top_lse, &lse, MPLS_HLEN);
> +			}
> +
> +			/* Advance network_header to bottom of MPLS label
> +			 * stack. mac_len corresponds to the top of the stack.
> +			 */
> +			skb_set_network_header(skb, skb->mac_len + stack_len);
> +			if (lse & htonl(MPLS_BOS_MASK))
> +				break;
> +		}

I don't see anything advancing the stack_len, so the loop would not end for deeper stacks?

  Jarno
