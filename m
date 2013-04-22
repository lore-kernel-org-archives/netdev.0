From: Simon Horman <horms@verge.net.au>
Subject: Re: [ovs-dev] [PATCH] datapath: Add basic MPLS support to kernel
Date: Mon, 22 Apr 2013 10:29:49 +0900
Message-ID: <20130422012949.GE15680@verge.net.au>
References: <1366357310-7816-1-git-send-email-horms@verge.net.au>
 <A0E5584A-E05C-4FFF-9CF7-5B78A68FE921@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "<dev@openvswitch.org>" <dev@openvswitch.org>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ravi K <rkerur@gmail.com>
To: "Rajahalme, Jarno (NSN - FI/Espoo)" <jarno.rajahalme@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53429 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932Ab3DVB35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 21:29:57 -0400
Content-Disposition: inline
In-Reply-To: <A0E5584A-E05C-4FFF-9CF7-5B78A68FE921@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 20, 2013 at 06:25:03AM +0000, Rajahalme, Jarno (NSN - FI/Espoo) wrote:
> 
> On Apr 19, 2013, at 10:41 , ext Simon Horman wrote:
> 
> > diff --git a/datapath/actions.c b/datapath/actions.c
> > index 0dac658..2c923be 100644
> > --- a/datapath/actions.c
> > +++ b/datapath/actions.c
> > @@ -38,6 +38,7 @@
> > #include "vport.h"
> > 
> > static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
> > +			      unsigned *mpls_stack_depth,
> > 			      const struct nlattr *attr, int len, bool keep_skb);
> > 
> > static int make_writable(struct sk_buff *skb, int write_len)
> > @@ -48,6 +49,89 @@ static int make_writable(struct sk_buff *skb, int write_len)
> > 	return pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
> > }
> > 
> > +static void set_ethertype(struct sk_buff *skb, const __be16 ethertype)
> > +{
> > +	struct ethhdr *hdr = (struct ethhdr *)skb_mac_header(skb);
> > +	if (hdr->h_proto == ethertype)
> > +		return;
> > +	hdr->h_proto = ethertype;
> 
> Will this work properly if the skb has VLAN headers? I recall there was an earlier version that used the l2_size (now mac_len) to locate the actual "h_proto" to update?

Thanks, I believe you are correct and that the version above is wrong.
I will revert to a version that makes use of mac_len.

> 
> > +	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE) {
> > +		__be16 diff[] = { ~hdr->h_proto, ethertype };
> > +		skb->csum = ~csum_partial((char *)diff, sizeof(diff),
> > +					  ~skb->csum);
> > +	}
> > +}
> > +
> > +static int push_mpls(struct sk_buff *skb, const struct ovs_action_push_mpls *mpls)
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
> > +	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> > +		skb->csum = csum_add(skb->csum, csum_partial(new_mpls_lse,
> > +							     MPLS_HLEN, 0));
> > +
> > +	set_ethertype(skb, mpls->mpls_ethertype);
> > +	return 0;
> > +}
> > +
> > +static int pop_mpls(struct sk_buff *skb, const __be16 *ethertype)
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
> > @@ -115,6 +199,9 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
> > 		if (!__vlan_put_tag(skb, current_tag))
> > 			return -ENOMEM;
> > 
> > +		/* update mac_len for MPLS functions */
> > +		skb_reset_mac_len(skb);
> > +
> > 		if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> > 			skb->csum = csum_add(skb->csum, csum_partial(skb->data
> > 					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
> > @@ -352,13 +439,26 @@ static int set_tcp(struct sk_buff *skb, const struct ovs_key_tcp *tcp_port_key)
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
> > +	/* The mpls_stack_depth is only non zero if a non-MPLS packet is
> > +	 * turned into an MPLS packet via an MPLS push action. In this case
> > +	 * the skb may be GSO so update skb->mac_len and skb's
> > +	 * network_header to correspond to the bottom of the MPLS label
> > +	 * stack rather than the end of the original L2 data which is now
> > +	 * the top of the MPLS label stack.  */
> 
> It is not clear to me that "bottom of the MPLS label stack" necessarily refers to the start of L3 header, "Bottom of stack" having a special meaning with MPLS.
> It might be clearer to state that "during action execution network_header, and mac_len, correspondingly, have tracked the end of the L2 frame (including any VLAN headers), but proper skb output processing (e.g., GSO) requires the network_header (and mac_len) to track the start of the L3 header instead. These differ in the presence of MPLS headers."

Thanks, I will update the wording.

> > +	if (mpls_stack_depth) {
> > +		skb->mac_len += MPLS_HLEN * mpls_stack_depth;
> > +		skb_set_network_header(skb, skb->mac_len);
> > +		skb_set_encapsulation_features(skb);
> > +	}
> > +
> > 	vport = ovs_vport_rcu(dp, out_port);
> > 	if (unlikely(!vport)) {
> > 		kfree_skb(skb);
> > @@ -398,7 +498,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
> > }
> > 
> > static int sample(struct datapath *dp, struct sk_buff *skb,
> > -		  const struct nlattr *attr)
> > +		  unsigned *mpls_stack_depth, const struct nlattr *attr)
> > {
> > 	const struct nlattr *acts_list = NULL;
> > 	const struct nlattr *a;
> > @@ -418,8 +518,9 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
> > 		}
> > 	}
> > 
> > -	return do_execute_actions(dp, skb, nla_data(acts_list),
> > -				  nla_len(acts_list), true);
> > +	return do_execute_actions(dp, skb, mpls_stack_depth,
> > +				  nla_data(acts_list), nla_len(acts_list),
> > +				  true);
> > }
> > 
> > static int execute_set_action(struct sk_buff *skb,
> > @@ -459,13 +560,23 @@ static int execute_set_action(struct sk_buff *skb,
> > 	case OVS_KEY_ATTR_UDP:
> > 		err = set_udp(skb, nla_data(nested_attr));
> > 		break;
> > +
> > +	case OVS_KEY_ATTR_MPLS:
> > +		err = set_mpls(skb, nla_data(nested_attr));
> > +		break;
> > 	}
> > 
> > 	return err;
> > }
> > 
> > -/* Execute a list of actions against 'skb'. */
> > +/* Execute a list of actions against 'skb'.
> > + *
> > + * The stack depth is only tracked in the case of a non-MPLS packet
> > + * that becomes MPLS via an MPLS push action. The stack depth
> > + * is passed to do_output() in order to allow it to prepare the
> > + * skb for possible GSO segmentation. */
> > static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
> > +			unsigned *mpls_stack_depth,
> > 			const struct nlattr *attr, int len, bool keep_skb)
> > {
> > 	/* Every output action needs a separate clone of 'skb', but the common
> > @@ -481,7 +592,8 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
> > 		int err = 0;
> > 
> > 		if (prev_port != -1) {
> > -			do_output(dp, skb_clone(skb, GFP_ATOMIC), prev_port);
> > +			do_output(dp, skb_clone(skb, GFP_ATOMIC),
> > +				  prev_port, *mpls_stack_depth);
> > 			prev_port = -1;
> > 		}
> > 
> > @@ -494,6 +606,18 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
> > 			output_userspace(dp, skb, a);
> > 			break;
> > 
> > +		case OVS_ACTION_ATTR_PUSH_MPLS:
> > +			err = push_mpls(skb, nla_data(a));
> > +			if (!eth_p_mpls(skb->protocol))
> > +				(*mpls_stack_depth)++;
> > +			break;
> > +
> > +		case OVS_ACTION_ATTR_POP_MPLS:
> > +			err = pop_mpls(skb, nla_data(a));
> > +			if (!eth_p_mpls(skb->protocol))
> > +				(*mpls_stack_depth)--;
> > +			break;
> > +
> 
> In both cases the stack is changed whenever err == 0, but it is not immediately clear to me whether the '!eth_p_mpls(skb->protocol)' is true if and only if the label stack has changed.

Thanks, I will change the code to something like this:

	if (!err && !eth_p_mpls(skb->protocol))
		...
