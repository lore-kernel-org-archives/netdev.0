From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 30 Oct 2017 10:43:07 -0700
Message-ID: <20171030104307.0857ee38@cakuba.netronome.com>
References: <20171030170224.badokg3dsgjb4hvg@sirena.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Mark Brown <broonie@kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20171030170224.badokg3dsgjb4hvg@sirena.co.uk>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Oct 2017 17:02:24 +0000, Mark Brown wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in:
> 
>   drivers/net/ethernet/netronome/nfp/flower/action.c
> 
> between commit:
> 
>   d309ae5c6a0064 ("nfp: refuse offloading filters that redirects to upper devices")
> 
> from Linus' tree and commit:
> 
>   62d3f60b4d065c ("nfp: use struct fields for 8 bit-wide access")

Actually the conflict is with a much older commit b27d6a95a70d ("nfp:
compile flower vxlan tunnel set actions").

> from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

Unfortunately, this is not a correct resolution.  Please see below.

> diff --cc drivers/net/ethernet/netronome/nfp/flower/action.c
> index 8ea9320014ee,0a5fc9f8545f..000000000000
> --- a/drivers/net/ethernet/netronome/nfp/flower/action.c
> +++ b/drivers/net/ethernet/netronome/nfp/flower/action.c
> @@@ -105,19 -104,326 +104,329 @@@ nfp_fl_output(struct nfp_fl_output *out
>   	if (!out_dev)
>   		return -EOPNOTSUPP;
>   
> - 	/* Only offload egress ports are on the same device as the ingress
> - 	 * port.
> + 	tmp_flags = last ? NFP_FL_OUT_FLAGS_LAST : 0;
> + 
> + 	if (tun_type) {
> + 		/* Verify the egress netdev matches the tunnel type. */
> + 		if (!nfp_fl_netdev_is_tunnel_type(out_dev, tun_type))
> + 			return -EOPNOTSUPP;
> + 
> + 		if (*tun_out_cnt)
> + 			return -EOPNOTSUPP;
> + 		(*tun_out_cnt)++;
> + 
> + 		output->flags = cpu_to_be16(tmp_flags |
> + 					    NFP_FL_OUT_FLAGS_USE_TUN);
> + 		output->port = cpu_to_be32(NFP_FL_PORT_TYPE_TUN | tun_type);
> + 	} else {
> + 		/* Set action output parameters. */
> + 		output->flags = cpu_to_be16(tmp_flags);
> + 
> + 		/* Only offload if egress ports are on the same device as the
> + 		 * ingress port.
> + 		 */
> + 		if (!switchdev_port_same_parent_id(in_dev, out_dev))
> + 			return -EOPNOTSUPP;

The code from net should be inserted here.  Note that net-next only
indented this area, the code is unchanged.

	if (!nfp_netdev_is_nfp_repr(out_dev))
		return -EOPNOTSUPP;

should immediately follow switchdev_port_same_parent_id() check.

> + 		output->port = cpu_to_be32(nfp_repr_get_port_id(out_dev));
> + 		if (!output->port)
> + 			return -EOPNOTSUPP;
> + 	}
> + 	nfp_flow->meta.shortcut = output->port;
> + 
> + 	return 0;
> + }
> + 
> + static bool nfp_fl_supported_tun_port(const struct tc_action *action)
> + {
> + 	struct ip_tunnel_info *tun = tcf_tunnel_info(action);
> + 
> + 	return tun->key.tp_dst == htons(NFP_FL_VXLAN_PORT);
> + }
> + 
> + static struct nfp_fl_pre_tunnel *nfp_fl_pre_tunnel(char *act_data, int act_len)
> + {
> + 	size_t act_size = sizeof(struct nfp_fl_pre_tunnel);
> + 	struct nfp_fl_pre_tunnel *pre_tun_act;
> + 
> + 	/* Pre_tunnel action must be first on action list.
> + 	 * If other actions already exist they need pushed forward.
>   	 */
> - 	if (!switchdev_port_same_parent_id(in_dev, out_dev))
> + 	if (act_len)
> + 		memmove(act_data + act_size, act_data, act_len);
> + 
> + 	pre_tun_act = (struct nfp_fl_pre_tunnel *)act_data;
> + 
> + 	memset(pre_tun_act, 0, act_size);
> + 
> + 	pre_tun_act->head.jump_id = NFP_FL_ACTION_OPCODE_PRE_TUNNEL;
> + 	pre_tun_act->head.len_lw = act_size >> NFP_FL_LW_SIZ;
> + 
> + 	return pre_tun_act;
> + }
> + 
> + static int
> + nfp_fl_set_vxlan(struct nfp_fl_set_vxlan *set_vxlan,
> + 		 const struct tc_action *action,
> + 		 struct nfp_fl_pre_tunnel *pre_tun)
> + {
> + 	struct ip_tunnel_info *vxlan = tcf_tunnel_info(action);
> + 	size_t act_size = sizeof(struct nfp_fl_set_vxlan);
> + 	u32 tmp_set_vxlan_type_index = 0;
> + 	/* Currently support one pre-tunnel so index is always 0. */
> + 	int pretun_idx = 0;
> + 
> + 	if (vxlan->options_len) {
> + 		/* Do not support options e.g. vxlan gpe. */
>   		return -EOPNOTSUPP;
> + 	}
> + 
>  +	if (!nfp_netdev_is_nfp_repr(out_dev))
>  +		return -EOPNOTSUPP;
>  +
> - 	output->port = cpu_to_be32(nfp_repr_get_port_id(out_dev));
> - 	if (!output->port)
> + 	set_vxlan->head.jump_id = NFP_FL_ACTION_OPCODE_SET_IPV4_TUNNEL;
> + 	set_vxlan->head.len_lw = act_size >> NFP_FL_LW_SIZ;
> + 
> + 	/* Set tunnel type and pre-tunnel index. */
> + 	tmp_set_vxlan_type_index |=
> + 		FIELD_PREP(NFP_FL_IPV4_TUNNEL_TYPE, NFP_FL_TUNNEL_VXLAN) |
> + 		FIELD_PREP(NFP_FL_IPV4_PRE_TUN_INDEX, pretun_idx);
