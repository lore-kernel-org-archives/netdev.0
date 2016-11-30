From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v3 net-next 3/3] openvswitch: Fix skb->protocol for vlan
 frames.
Date: Wed, 30 Nov 2016 15:30:41 +0100
Message-ID: <20161130153041.7a9590ef@griffin>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
        <1480462253-114713-3-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org, e@erig.me
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47428 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757842AbcK3Oap (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 09:30:45 -0500
In-Reply-To: <1480462253-114713-3-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Nov 2016 15:30:53 -0800, Jarno Rajahalme wrote:
> Do not always set skb->protocol to be the ethertype of the L3 header.
> For a packet with non-accelerated VLAN tags skb->protocol needs to be
> the ethertype of the outermost non-accelerated VLAN ethertype.

Well, the current handling of skb->protocol matches what used to be the
handling of the kernel net stack before Jiri Pirko cleaned up the vlan
code.

I'm not opposed to changing this but I'm afraid it needs much deeper
review. Because with this in place, no core kernel functions that
depend on skb->protocol may be called from within openvswitch.

> @@ -361,6 +362,11 @@ static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>  	if (res <= 0)
>  		return res;
>  
> +	/* If the outer vlan tag was accelerated, skb->protocol should
> +	 * refelect the inner vlan type. */
> +	if (!eth_type_vlan(skb->protocol))
> +		skb->protocol = key->eth.cvlan.tpid;

This should not depend on the current value in skb->protocol which
could be arbitrary at this point (from the point of view of how this
patch understands the skb->protocol values). It's easy to fix, though -
just add a local bool variable tracking whether the skb->protocol has
been set.

> @@ -531,15 +544,16 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>  		if (unlikely(parse_vlan(skb, key)))
>  			return -ENOMEM;
>  
> -		skb->protocol = parse_ethertype(skb);
> -		if (unlikely(skb->protocol == htons(0)))
> +		key->eth.type = parse_ethertype(skb);
> +		if (unlikely(key->eth.type == htons(0)))
>  			return -ENOMEM;
>  
>  		skb_reset_network_header(skb);
>  		__skb_push(skb, skb->data - skb_mac_header(skb));
>  	}
>  	skb_reset_mac_len(skb);
> -	key->eth.type = skb->protocol;
> +	if (!eth_type_vlan(skb->protocol))
> +		skb->protocol = key->eth.type;

This leaves key->eth.type undefined for key->mac_proto ==
MAC_PROTO_NONE.

Plus the same problem as above with unknown value of skb->protocol. But
this is more complicated here, as skb->protocol may be either
uninitialized at this point or already initialized by parse_vlan.

>  
>  	/* Network layer. */
>  	if (key->eth.type == htons(ETH_P_IP)) {
> @@ -800,29 +814,15 @@ int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
>  	if (err)
>  		return err;
>  
> -	if (ovs_key_mac_proto(key) == MAC_PROTO_NONE) {
> -		/* key_extract assumes that skb->protocol is set-up for
> -		 * layer 3 packets which is the case for other callers,
> -		 * in particular packets recieved from the network stack.
> -		 * Here the correct value can be set from the metadata
> -		 * extracted above.
> -		 */
> -		skb->protocol = key->eth.type;
> -	} else {
> -		struct ethhdr *eth;
> -
> -		skb_reset_mac_header(skb);
> -		eth = eth_hdr(skb);
> -
> -		/* Normally, setting the skb 'protocol' field would be
> -		 * handled by a call to eth_type_trans(), but it assumes
> -		 * there's a sending device, which we may not have.
> -		 */
> -		if (eth_proto_is_802_3(eth->h_proto))
> -			skb->protocol = eth->h_proto;
> -		else
> -			skb->protocol = htons(ETH_P_802_2);
> -	}
> +	/* key_extract assumes that skb->protocol is set-up for
> +	 * layer 3 packets which is the case for other callers,
> +	 * in particular packets recieved from the network stack.
> +	 * Here the correct value can be set from the metadata
> +	 * extracted above.  For layer 2 packets we initialize
> +         * skb->protocol to zero and set it in key_extract() while
> +         * parsing the L2 headers.
> +	 */
> +	skb->protocol = key->eth.type;
>  
>  	return key_extract(skb, key);
>  }

Interesting. This hunk looks safe even without the rest of the patch.
You should fix the comment indentation, though.

 Jiri
