From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [PATCH v3 net-next] MPLS: Use mpls_features to
	activate	software MPLS GSO segmentation
Date: Mon,  2 Jun 2014 12:51:53 +0900 (JST)
Message-ID: <20140602035153.E5721710BF@kuma.localdomain>
References: <1401669515-24142-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: Your message of "Mon,  2 Jun 2014 09:38:35 +0900"
 <1401669515-24142-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

> If an MPLS packet requires segmentation then use mpls_features
> to determine if the software implementation should be used.
> 
> As no driver advertises MPLS GSO segmentation this will always be
> the case.
> 
> I had not noticed that this was necessary before as software MPLS GSO
> segmentation was already being used in my test environment. I believe that
> the reason for that is the skbs in question always had fragments and the
> driver I used does not advertise NETIF_F_FRAGLIST (which seems to be the
> case for most drivers). Thus software segmentation was activated by
> skb_gso_ok().
> 
> Thanks to Jesse Gross for prompting me to investigate this.
> 
> Acked-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> 
> ---
> v3
> * As requested by David Miller
>   - Do not mark net_mpls_features as inline
>   - Correct alignment of parameters
> 
> v2
> * Added Ack from Jesse Gross
> * Removed duplicate 'Thus' from changelog
> ---
>  net/core/dev.c | 38 ++++++++++++++++++++++++++++++++++++++
>  1 file changed, 38 insertions(+)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0355ca5..1aa7004 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2540,6 +2540,42 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
>  }
>  EXPORT_SYMBOL(netif_skb_features);
>  
> +/* If MPLS offload request, verify we are testing hardware MPLS features
> + * instead of standard features for the netdev.
> + */
> +#ifdef CONFIG_NET_MPLS_GSO
> +static netdev_features_t net_mpls_features(struct sk_buff *skb,
> +					   struct net_device *dev,
> +					   netdev_features_t features)
> +{
> +	/* There is no support for MPLS LRO. So the only way that
> +	 * an MPLS skb could require GSO segmentation is if it
> +	 * was received as a non-MPLS skb and then became an MPLS skb.
> +	 * This may be effected by Open vSwitch in which case the
> +	 * mac_len will non-zero and not equal to skb_network_offset
> +	 * as the former indicates the end of L2 the latter indicates

s/L2/& and/

> +	 * the beginning of L3 and there is a gap between them occupied
> +	 * by the MPLS label stack.
> +	 *
> +	 * Thus it is possible to avoid traversing any VLAN tags that are
> +	 * present to determine if the ethtype is MPLS. Instead the
> +	 * inequality of mac_llen and skb_network_offset are used to

s/mac_llen/mac_len/

Acked-by: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

YAMAMOTO Takashi

> +	 * determine if a packet is MPLS for the purpose of determining
> +	 * offload features.
> +	 */
> +	if (skb->mac_len && skb->mac_len != skb_network_offset(skb))
> +		features &= dev->mpls_features;
> +	return features;
> +}
> +#else
> +static netdev_features_t net_mpls_features(struct sk_buff *skb,
> +					   struct net_device *dev,
> +					   netdev_features_t features)
> +{
> +	return features;
> +}
> +#endif
> +
>  int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  			struct netdev_queue *txq)
>  {
> @@ -2576,6 +2612,8 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  		if (skb->encapsulation)
>  			features &= dev->hw_enc_features;
>  
> +		features = net_mpls_features(skb, dev, features);
> +
>  		if (netif_needs_gso(skb, features)) {
>  			if (unlikely(dev_gso_segment(skb, features)))
>  				goto out_kfree_skb;
> -- 
> 1.8.5.2
> 
> _______________________________________________
> dev mailing list
> dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> http://openvswitch.org/mailman/listinfo/dev
