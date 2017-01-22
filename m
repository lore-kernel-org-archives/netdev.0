From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 5/5] bridge: vlan lwt dst_metadata hooks in
 ingress and egress paths
Date: Sun, 22 Jan 2017 13:15:41 +0100
Message-ID: <b0977994-907d-6868-197f-b9fe25a5632b@cumulusnetworks.com>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com>
 <1484977616-1541-6-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35722 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdAVMPo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 07:15:44 -0500
Received: by mail-wm0-f49.google.com with SMTP id r126so96194937wmr.0
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 04:15:44 -0800 (PST)
In-Reply-To: <1484977616-1541-6-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/01/17 06:46, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> - ingress hook:
>     - if port is a lwt tunnel port, use tunnel info in
>       attached dst_metadata to map it to a local vlan
> - egress hook:
>     - if port is a lwt tunnel port, use tunnel info attached to
>       vlan to set dst_metadata on the skb
> 
> CC: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> CC'ing Nikolay for some more eyes as he has been trying to keep the
> bridge driver fast path lite.
> 
>  net/bridge/br_input.c   |    4 ++++
>  net/bridge/br_private.h |    4 ++++
>  net/bridge/br_vlan.c    |   55 +++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 63 insertions(+)
> 
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 83f356f..96602a1 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -262,6 +262,10 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
>  		return RX_HANDLER_CONSUMED;
>  
>  	p = br_port_get_rcu(skb->dev);
> +	if (p->flags & BR_LWT_VLAN) {
> +		if (br_handle_ingress_vlan_tunnel(skb, p, nbp_vlan_group_rcu(p)))
> +			goto drop;
> +	}

Is there any reason to do this so early (perhaps netfilter?) ? If not, you can push it to the vlan __allowed_ingress
(and rename that function to something else, it does a hundred additional things)
and avoid this check for all packets if vlans are disabled, thus people using non-vlan filtering
bridge won't have an additional test in their fast path

>  
>  	if (unlikely(is_link_local_ether_addr(dest))) {
>  		u16 fwd_mask = p->br->group_fwd_mask_required;
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index f68e360..68a23c5 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -804,6 +804,10 @@ int __vlan_tunnel_info_del(struct net_bridge_vlan_group *vg,
>  int nbp_vlan_tunnel_info_add(struct net_bridge_port *port, u16 vid, u32 tun_id);
>  bool vlan_tunnel_id_isrange(struct net_bridge_vlan *v_end,
>  			    struct net_bridge_vlan *v);
> +int br_handle_ingress_vlan_tunnel(struct sk_buff *skb, struct net_bridge_port *p,
> +				  struct net_bridge_vlan_group *vg);
> +int br_handle_egress_vlan_tunnel(struct sk_buff *skb,
> +				 struct net_bridge_vlan *vlan);
>  
>  static inline struct net_bridge_vlan_group *br_vlan_group(
>  					const struct net_bridge *br)
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 2040f08..6cf2344 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -405,6 +405,11 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
>  
>  	if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
>  		skb->vlan_tci = 0;
> +
> +	if (br_handle_egress_vlan_tunnel(skb, v)) {
> +		kfree_skb(skb);
> +		return NULL;
> +	}
>  out:
>  	return skb;
>  }
> @@ -1213,3 +1218,53 @@ int nbp_vlan_tunnel_info_delete(struct net_bridge_port *port, u16 vid)
>  
>  	return 0;
>  }
> +
> +int br_handle_ingress_vlan_tunnel(struct sk_buff *skb,
> +				  struct net_bridge_port *p,
> +				  struct net_bridge_vlan_group *vg)
> +{
> +	struct ip_tunnel_info *tinfo = skb_tunnel_info(skb);
> +	struct net_bridge_vlan *vlan;
> +
> +	if (!vg || !tinfo)
> +		return 0;
> +
> +	/* if already tagged, ignore */
> +	if (skb_vlan_tagged(skb))
> +		return 0;
> +
> +	/* lookup vid, given tunnel id */
> +	vlan = br_vlan_tunnel_lookup(&vg->tunnel_hash, tinfo->key.tun_id);
> +	if (!vlan)
> +		return 0;
> +
> +	skb_dst_drop(skb);
> +
> +	__vlan_hwaccel_put_tag(skb, p->br->vlan_proto, vlan->vid);
> +
> +	return 0;
> +}
> +
> +int br_handle_egress_vlan_tunnel(struct sk_buff *skb,
> +				 struct net_bridge_vlan *vlan)
> +{
> +	__be32 tun_id;
> +	int err;
> +
> +	if (!vlan || !vlan->tinfo.tunnel_id)
> +		return 0;
> +
> +	if (unlikely(!skb_vlan_tag_present(skb)))
> +		return 0;
> +
> +	skb_dst_drop(skb);
> +	tun_id = tunnel_id_to_key32(vlan->tinfo.tunnel_id);
> +
> +	err = skb_vlan_pop(skb);
> +	if (err)
> +		return err;
> +
> +	skb_dst_set(skb, dst_clone(&vlan->tinfo.tunnel_dst->dst));
> +
> +	return 0;
> +}
> 
