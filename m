From: "Rajahalme, Jarno (NSN - FI/Espoo)" <jarno.rajahalme-OYasijW0DpE@public.gmane.org>
Subject: Re: [PATCH v2.26] datapath: Add basic MPLS support to
	kernel
Date: Mon, 22 Apr 2013 13:55:43 +0000
Message-ID: <EA113734-1070-43F9-B932-C8AD83CAAFA2@nsn.com>
References: <1366596740-18246-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "<dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: ext Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1366596740-18246-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Content-Language: en-US
Content-ID: <2E4313722239B44B934177889999EFEB-z7JfP6tgrtWhxUC7wdWhuQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Apr 22, 2013, at 5:12 , ext Simon Horman wrote:

> diff --git a/datapath/actions.c b/datapath/actions.c
...
> +static int push_mpls(struct sk_buff *skb,
> +		     const struct ovs_action_push_mpls *mpls,
> +		     unsigned *mpls_stack_depth)
> +{
> +	__be32 *new_mpls_lse;
> +	int err;
> +
> +	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> +	if (unlikely(err))
> +		return err;
> +
> +	skb_push(skb, MPLS_HLEN);
> +	memmove(skb_mac_header(skb) - MPLS_HLEN, skb_mac_header(skb),
> +		skb->mac_len);
> +	skb_reset_mac_header(skb);
> +	skb_set_network_header(skb, skb->mac_len);
> +
> +	new_mpls_lse = (__be32 *)skb_network_header(skb);
> +	*new_mpls_lse = mpls->mpls_lse;
> +

Note: Now the skb_network_header points to the MPLS header. But see below...

> +	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> +		skb->csum = csum_add(skb->csum, csum_partial(new_mpls_lse,
> +							     MPLS_HLEN, 0));
> +
> +	set_ethertype(skb, mpls->mpls_ethertype);
> +	if (!eth_p_mpls(skb->protocol))
> +		(*mpls_stack_depth)++;

Here mpls_stack_depth is increased only conditionally. What would be the case where mpls_stack_depth would remain unchanged here? And how does that relate to what follows below...

> +	return 0;
> +}
> +
> +static int pop_mpls(struct sk_buff *skb, const __be16 *ethertype,
> +		    unsigned *mpls_stack_depth)
> +{
> +	int err;
> +
> +	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> +	if (unlikely(err))
> +		return err;
> +
> +	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> +		skb->csum = csum_sub(skb->csum,
> +				     csum_partial(skb_network_header(skb),
> +						  MPLS_HLEN, 0));
> +
> +	memmove(skb_mac_header(skb) + MPLS_HLEN, skb_mac_header(skb),
> +		skb->mac_len);
> +
> +	skb_pull(skb, MPLS_HLEN);
> +	skb_reset_mac_header(skb);
> +	skb_set_network_header(skb, skb->mac_len);
> +
> +	set_ethertype(skb, *ethertype);
> +	if (!eth_p_mpls(skb->protocol))
> +		(*mpls_stack_depth)--;

Ditto?

> +	return 0;
> +}
> +
> +static int set_mpls(struct sk_buff *skb, const __be32 *mpls_lse)
> +{
> +	__be32 *stack = (__be32 *)skb_network_header(skb);
> +	int err;
> +
> +	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> +	if (unlikely(err))
> +		return err;
> +
> +	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE) {
> +		__be32 diff[] = { ~(*stack), *mpls_lse };
> +		skb->csum = ~csum_partial((char *)diff, sizeof(diff),
> +					  ~skb->csum);
> +	}
> +
> +	*stack = *mpls_lse;
> +
> +	return 0;
> +}
> +
> /* remove VLAN header from packet and update csum accordingly. */
> static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
> {
> @@ -115,6 +210,9 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
> 		if (!__vlan_put_tag(skb, current_tag))
> 			return -ENOMEM;
> 
> +		/* update mac_len for MPLS functions */
> +		skb_reset_mac_len(skb);
> +
> 		if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> 			skb->csum = csum_add(skb->csum, csum_partial(skb->data
> 					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
> @@ -352,13 +450,31 @@ static int set_tcp(struct sk_buff *skb, const struct ovs_key_tcp *tcp_port_key)
> 	return 0;
> }
> 
> -static int do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
> +static int do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
> +		     unsigned mpls_stack_depth)
> {
> 	struct vport *vport;
> 
> 	if (unlikely(!skb))
> 		return -ENOMEM;
> 
> +	/* During action execution the network_header, and mac_len,
> +	 * correspondingly, have tracked the end of the L2 frame (including
> +	 * any VLAN headers), but proper skb output processing of GSO skbs
> +	 * requires the network_header (and mac_len) to track the start of
> +	 * the L3 header instead. These differ in the presence of MPLS
> +	 * headers.
> +	 *
> +	 * mpls_stack_depth is only non-zero if a non-MPLS skb is turned
> +	 * into an MPLS skb via an MPLS push action. This is the only case
> +	 * where an MPLS skb may be a GSO skb.
> +	 */
> +	if (mpls_stack_depth) {
> +		skb->mac_len += MPLS_HLEN * mpls_stack_depth;
> +		skb_set_network_header(skb, skb->mac_len);
> +		skb_set_encapsulation_features(skb);
> +	}
> +

Here the skb_network_header is changed to point to the L3 header. Is it significant that in some cases (?) mpls_stack_depth may remain at zero, even when a MPLS header was in fact added? (See above).

> 	vport = ovs_vport_rcu(dp, out_port);
> 	if (unlikely(!vport)) {
> 		kfree_skb(skb);
