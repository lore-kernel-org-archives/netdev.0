From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5] netfilter: xtables: inclusion of xt_TEE
Date: Thu, 01 Apr 2010 12:34:00 +0200
Message-ID: <4BB47698.6070102@trash.net>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de> <1270031934-15940-4-git-send-email-jengelh@medozas.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1270031934-15940-4-git-send-email-jengelh@medozas.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> +static bool
> +tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info)
> +{
> +	const struct iphdr *iph = ip_hdr(skb);
> +	struct rtable *rt;
> +	struct flowi fl;
> +	int err;
> +
> +	memset(&fl, 0, sizeof(fl));
> +	fl.iif  = skb->skb_iif;

I'm not sure you really should set iif here. We usually (tunnels, REJECT
etc) packets generated locally as new packets.

> +	fl.mark = skb->mark;

The same applies to mark.

> +	fl.nl_u.ip4_u.daddr = info->gw.ip;
> +	fl.nl_u.ip4_u.tos   = RT_TOS(iph->tos);
> +	fl.nl_u.ip4_u.scope = RT_SCOPE_UNIVERSE;
> +
> +	/* Trying to route the packet using the standard routing table. */
> +	err = ip_route_output_key(dev_net(skb->dev), &rt, &fl);
> +	if (err != 0)
> +		return false;
> +
> +	dst_release(skb_dst(skb));
> +	skb_dst_set(skb, &rt->u.dst);
> +	skb->dev      = rt->u.dst.dev;
> +	skb->protocol = htons(ETH_P_IP);
> +	IPCB(skb)->flags |= IPSKB_REROUTED;
> +	return true;
> +}
> +
> +/*
> + * To detect and deter routed packet loopback when using the --tee option, we
> + * take a page out of the raw.patch book: on the copied skb, we set up a fake
> + * ->nfct entry, pointing to the local &route_tee_track. We skip routing
> + * packets when we see they already have that ->nfct.

So without conntrack, people may create loops? If that's the case,
I'd suggest to simply forbid TEE'ing packets to loopback. That
doesn't seem to be very useful anyways.

> + */
> +static unsigned int
> +tee_tg4(struct sk_buff *skb, const struct xt_target_param *par)
> +{
> +	const struct xt_tee_tginfo *info = par->targinfo;
> +	struct iphdr *iph;
> +
> +#ifdef WITH_CONNTRACK
> +	if (skb->nfct == &tee_track.ct_general)
> +		/*
> +		 * Loopback - a packet we already routed, is to be
> +		 * routed another time. Avoid that, now.
> +		 */
> +		return NF_DROP;
> +#endif
> +	/*
> +	 * Copy the skb, and route the copy. Will later return %XT_CONTINUE for
> +	 * the original skb, which should continue on its way as if nothing has
> +	 * happened. The copy should be independently delivered to the TEE
> +	 * --gateway.
> +	 */
> +	skb = skb_copy(skb, GFP_ATOMIC);
> +	if (skb == NULL)
> +		return XT_CONTINUE;
> +	/*
> +	 * If we are in PREROUTING/INPUT, the checksum must be recalculated
> +	 * since the length could have changed as a result of defragmentation.
> +	 *
> +	 * We also decrease the TTL to mitigate potential TEE loops
> +	 * between two hosts.
> +	 *
> +	 * Set %IP_DF so that the original source is notified of a potentially
> +	 * decreased MTU on the clone route. IPv6 does this too.
> +	 */
> +	iph = ip_hdr(skb);
> +	iph->frag_off |= htons(IP_DF);
> +	if (par->hooknum == NF_INET_PRE_ROUTING ||
> +	    par->hooknum == NF_INET_LOCAL_IN)
> +		--iph->ttl;
> +	ip_send_check(iph);

Shouldn't this only be done in PRE_ROUTING/INPUT as stated above?

> +
> +#ifdef WITH_CONNTRACK
> +	nf_conntrack_put(skb->nfct);
> +	skb->nfct     = &tee_track.ct_general;
> +	skb->nfctinfo = IP_CT_NEW;
> +	nf_conntrack_get(skb->nfct);
> +#endif
> +	/*
> +	 * Xtables is not reentrant currently, so a choice has to be made:
> +	 * 1. return absolute verdict for the original and let the cloned
> +	 *    packet travel through the chains
> +	 * 2. let the original continue travelling and not pass the clone
> +	 *    to Xtables.
> +	 * #2 is chosen. Normally, we would use ip_local_out for the clone.
> +	 * Because iph->check is already correct and we don't pass it to
> +	 * Xtables anyway, a shortcut to dst_output [forwards to ip_output] can
> +	 * be taken. %IPSKB_REROUTED needs to be set so that ip_output does not
> +	 * invoke POSTROUTING on the cloned packet.
> +	 */
> +	IPCB(skb)->flags |= IPSKB_REROUTED;
> +	if (tee_tg_route4(skb, info))
> +		ip_output(skb);
> +
> +	return XT_CONTINUE;
> +}
> +
