From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.26] datapath: Add basic MPLS support to kernel
Date: Tue, 23 Apr 2013 10:51:49 +0900
Message-ID: <20130423015149.GI12017@verge.net.au>
References: <1366596740-18246-1-git-send-email-horms@verge.net.au>
 <EA113734-1070-43F9-B932-C8AD83CAAFA2@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "<dev@openvswitch.org>" <dev@openvswitch.org>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
To: "Rajahalme, Jarno (NSN - FI/Espoo)" <jarno.rajahalme@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:40086 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075Ab3DWBvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 21:51:55 -0400
Content-Disposition: inline
In-Reply-To: <EA113734-1070-43F9-B932-C8AD83CAAFA2@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 01:55:43PM +0000, Rajahalme, Jarno (NSN - FI/Espoo) wrote:
> On Apr 22, 2013, at 5:12 , ext Simon Horman wrote:
> 
> > diff --git a/datapath/actions.c b/datapath/actions.c
> ...
> > +static int push_mpls(struct sk_buff *skb,
> > +		     const struct ovs_action_push_mpls *mpls,
> > +		     unsigned *mpls_stack_depth)
> > +{
> > +	__be32 *new_mpls_lse;
> > +	int err;
> > +
> > +	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> > +	if (unlikely(err))
> > +		return err;
> > +
> > +	skb_push(skb, MPLS_HLEN);
> > +	memmove(skb_mac_header(skb) - MPLS_HLEN, skb_mac_header(skb),
> > +		skb->mac_len);
> > +	skb_reset_mac_header(skb);
> > +	skb_set_network_header(skb, skb->mac_len);
> > +
> > +	new_mpls_lse = (__be32 *)skb_network_header(skb);
> > +	*new_mpls_lse = mpls->mpls_lse;
> > +
> 
> Note: Now the skb_network_header points to the MPLS header. But see below...

The reason for this is that pop_mpls(), push_mpls() and set_ethertype()
each rely on this to locate the end of the L2 headers and/or the top
of the MPLS stack.

> > +	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> > +		skb->csum = csum_add(skb->csum, csum_partial(new_mpls_lse,
> > +							     MPLS_HLEN, 0));
> > +
> > +	set_ethertype(skb, mpls->mpls_ethertype);
> > +	if (!eth_p_mpls(skb->protocol))
> > +		(*mpls_stack_depth)++;
> 
> Here mpls_stack_depth is increased only conditionally. What would be the case where mpls_stack_depth would remain unchanged here? And how does that relate to what follows below...

It would be unchanged if the packet was originally MPLS.
See below...

> 
> > +	return 0;
> > +}
> > +
> > +static int pop_mpls(struct sk_buff *skb, const __be16 *ethertype,
> > +		    unsigned *mpls_stack_depth)
> > +{
> > +	int err;
> > +
> > +	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> > +	if (unlikely(err))
> > +		return err;
> > +
> > +	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> > +		skb->csum = csum_sub(skb->csum,
> > +				     csum_partial(skb_network_header(skb),
> > +						  MPLS_HLEN, 0));
> > +
> > +	memmove(skb_mac_header(skb) + MPLS_HLEN, skb_mac_header(skb),
> > +		skb->mac_len);
> > +
> > +	skb_pull(skb, MPLS_HLEN);
> > +	skb_reset_mac_header(skb);
> > +	skb_set_network_header(skb, skb->mac_len);
> > +
> > +	set_ethertype(skb, *ethertype);
> > +	if (!eth_p_mpls(skb->protocol))
> > +		(*mpls_stack_depth)--;
> 
> Ditto?
> 
> > +	return 0;
> > +}
> > +
> > +static int set_mpls(struct sk_buff *skb, const __be32 *mpls_lse)
> > +{
> > +	__be32 *stack = (__be32 *)skb_network_header(skb);
> > +	int err;
> > +
> > +	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> > +	if (unlikely(err))
> > +		return err;
> > +
> > +	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE) {
> > +		__be32 diff[] = { ~(*stack), *mpls_lse };
> > +		skb->csum = ~csum_partial((char *)diff, sizeof(diff),
> > +					  ~skb->csum);
> > +	}
> > +
> > +	*stack = *mpls_lse;
> > +
> > +	return 0;
> > +}
> > +
> > /* remove VLAN header from packet and update csum accordingly. */
> > static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
> > {
> > @@ -115,6 +210,9 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
> > 		if (!__vlan_put_tag(skb, current_tag))
> > 			return -ENOMEM;
> > 
> > +		/* update mac_len for MPLS functions */
> > +		skb_reset_mac_len(skb);
> > +
> > 		if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> > 			skb->csum = csum_add(skb->csum, csum_partial(skb->data
> > 					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
> > @@ -352,13 +450,31 @@ static int set_tcp(struct sk_buff *skb, const struct ovs_key_tcp *tcp_port_key)
> > 	return 0;
> > }
> > 
> > -static int do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
> > +static int do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
> > +		     unsigned mpls_stack_depth)
> > {
> > 	struct vport *vport;
> > 
> > 	if (unlikely(!skb))
> > 		return -ENOMEM;
> > 
> > +	/* During action execution the network_header, and mac_len,
> > +	 * correspondingly, have tracked the end of the L2 frame (including
> > +	 * any VLAN headers), but proper skb output processing of GSO skbs
> > +	 * requires the network_header (and mac_len) to track the start of
> > +	 * the L3 header instead. These differ in the presence of MPLS
> > +	 * headers.
> > +	 *
> > +	 * mpls_stack_depth is only non-zero if a non-MPLS skb is turned
> > +	 * into an MPLS skb via an MPLS push action. This is the only case
> > +	 * where an MPLS skb may be a GSO skb.
> > +	 */
> > +	if (mpls_stack_depth) {
> > +		skb->mac_len += MPLS_HLEN * mpls_stack_depth;
> > +		skb_set_network_header(skb, skb->mac_len);
> > +		skb_set_encapsulation_features(skb);
> > +	}
> > +
> 
> Here the skb_network_header is changed to point to the L3 header. Is it
> significant that in some cases (?) mpls_stack_depth may remain at zero,
> even when a MPLS header was in fact added? (See above).

With the current code I believe there are the following cases:

Input: non-MPLS skb: Output: network header and mac_len correspond to the
                     beginning of the L3 headers
Input: MPLS:         Output: network header and mac_len correspond to the
                     end of the L2 headers.

In the case of MPLS output the end of the L2 headers and the beginning
of the L3 headers will differ.


As far as I know the network header and mac_len only need to correspond to
the beginning of the L3 header if GSO segmentation will occur (actually,
some proposed changes to the network stack are required, see "[PATCH 0/2]
Small Modifications to GSO to allow segmentation of MPLS").  That only
occurs if the skb is GSO. Which in turn can only occur if the recieved
packet is non-MPLS. This is because the linux kernel doesn't support
MPLS offloads on receive (or anywhere else for that matter).

In the case that we have a non-MPLS skb the stack depth starts at zero and
is tracked. This is used to update the network header and mac_len.
Otherwise the stack depth is unknown and the network header and mac_len are
left as-is, corresponding to the end of the L2 headers.

Actually, it is possible to tighten up the if clause to be the following,
as it is only necessary to update the network header and mac_len for GSO skbs.

	if (mpls_stack_depth && skb_is_gso(skb)) {
		...
	}

It is possible for us to find and track the MPLS stack depth for all cases
and to update the network header and mac_len. However I don't think that
there is any run-time benefit and it seems expensive to find out what the
original stack depth was - I believe it would require parsing the MPLS
entire stack for each packet.
