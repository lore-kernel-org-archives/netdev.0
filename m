From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Thu, 21 Nov 2013 13:12:46 +0100
Message-ID: <20131121121246.GD31491@secunet.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
 <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Saurabh Mohan <saurabh.mohan@vyatta.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33770 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753177Ab3KUMMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 07:12:49 -0500
Content-Disposition: inline
In-Reply-To: <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 09:05:53AM +0100, Christophe Gouault wrote:
>  
> @@ -133,7 +134,13 @@ static int vti_rcv(struct sk_buff *skb)
>  		 * only match policies with this mark.
>  		 */
>  		skb->mark = be32_to_cpu(tunnel->parms.o_key);
> +		/* The packet is decrypted, but not yet decapsulated.
> +		 * Temporarily make network_header point to the inner header
> +		 * for policy check.
> +		 */
> +		skb_reset_network_header(skb);
>  		ret = xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb);

If we do it like this, we would do an input policy check even for
packets that should be forwarded. I think that's a bit odd.

If we really change to match plaintext traffic, we should do
it like Fan Du proposed. Remove the policy check here and
let the further layers do the policy enforcement. All we
have to do is to set the skb mark, then the lookup should
match the vti policy.

It is already clear that this packet was IPsec transformed
when it enters vti_rcv, so deferring the policy check should
be ok.

>  
>  	if (skb->protocol != htons(ETH_P_IP))
> @@ -173,17 +182,35 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	tos = old_iph->tos;
>  
> +	/* SPD lookup: we must provide a dst_entry to xfrm_lookup, normally the
> +	 * route to the final destination. However this route is a route via
> +	 * the vti interface. Now vti interfaces typically have the NOXFRM
> +	 * flag, hence xfrm_lookup would bypass IPsec.
> +	 *
> +	 * Therefore, we feed xfrm_lookup with a route to the vti tunnel remote
> +	 * endpoint instead.
> +	 */
>  	memset(&fl4, 0, sizeof(fl4));
>  	flowi4_init_output(&fl4, tunnel->parms.link,
>  			   be32_to_cpu(tunnel->parms.o_key), RT_TOS(tos),
>  			   RT_SCOPE_UNIVERSE,
>  			   IPPROTO_IPIP, 0,
>  			   dst, tiph->saddr, 0, 0);
> -	rt = ip_route_output_key(dev_net(dev), &fl4);
> +	rt = __ip_route_output_key(tunnel->net, &fl4);
>  	if (IS_ERR(rt)) {
>  		dev->stats.tx_carrier_errors++;
>  		goto tx_error_icmp;
>  	}
> +
> +	memset(&fl, 0, sizeof(fl));
> +	/* Temporarily mark the skb with the tunnel o_key, to look up
> +	 * for a policy with this mark, matching the plaintext traffic.
> +	 */
> +	skb->mark = be32_to_cpu(tunnel->parms.o_key);
> +	__xfrm_decode_session(skb, &fl, AF_INET, 0);
> +	skb->mark = oldmark;
> +	rt = (struct rtable *)xfrm_lookup(tunnel->net, &rt->dst, &fl, NULL, 0);
> +

I think we should not do such a workarround for the NOXFRM case.
In particular because this is not really typical, it is not the
default and it is not documented that it should be like that.
