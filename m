From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH RFC 3/3] mlx4: Call skb_csum_offload_check to check
 offloadability
Date: Wed, 7 Oct 2015 18:41:58 +0300
Message-ID: <56153D46.2080606@mellanox.com>
References: <1444088364-2839440-1-git-send-email-tom@herbertland.com>
 <1444088364-2839440-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>, <dwmw2@infradead.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0072.outbound.protection.outlook.com ([157.56.112.72]:13152
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753697AbbJGPmZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 11:42:25 -0400
In-Reply-To: <1444088364-2839440-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/6/2015 2:39 AM, Tom Herbert wrote:
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 494e776..f364ffd 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -702,6 +702,14 @@ static void mlx4_bf_copy(void __iomem *dst, const void *src,
>   	__iowrite64_copy(dst, src, bytecnt / 8);
>   }
>   
> +static const struct skb_csum_offl_spec csum_offl_spec = {
> +	.ipv4_okay = 1,
> +	.ipv6_okay = 1,
> +	.encap_okay = 1,
> +	.tcp_okay = 1,
> +	.udp_okay = 1,
> +};
> +
>   netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>   {
>   	struct skb_shared_info *shinfo = skb_shinfo(skb);
> @@ -727,6 +735,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>   	bool stop_queue;
>   	bool inline_ok;
>   	u32 ring_cons;
> +	struct skb_csum_offl_params offl_params;
>   
>   	if (!priv->port_up)
>   		goto tx_drop;
> @@ -853,8 +862,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>   	/* Prepare ctrl segement apart opcode+ownership, which depends on
>   	 * whether LSO is used */
>   	tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
> -	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
> -		if (!skb->encapsulation)
> +	if (skb_csum_offload_chk(skb, &csum_offl_spec,
> +				 &offl_params, true)) {
> +		if (!offl_params.encapped_csum)
>   			tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
>   								 MLX4_WQE_CTRL_TCP_UDP_CSUM);
>   		else
> @@ -912,9 +922,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>   		build_inline_wqe(tx_desc, skb, shinfo, real_size, &vlan_tag,
>   				 tx_ind, fragptr);
>   
> -	if (skb->encapsulation) {
> -		struct iphdr *ipv4 = (struct iphdr *)skb_inner_network_header(skb);
> -		if (ipv4->protocol == IPPROTO_TCP || ipv4->protocol == IPPROTO_UDP)
> +	if (!offl_params.encapped_csum) {
> +		if (offl_params.ip_proto == IPPROTO_TCP ||
> +		    offl_params.ip_proto == IPPROTO_UDP)
>   			op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP | MLX4_WQE_CTRL_ILP);
>   		else
>   			op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP);
> -- 2.4.6
few quick comments

not all mlx4 devices support offloading checksum for tunneled traffic, 
only ConnectX3-pro -- this translates for the mlx4 EN driver
logic that determines that on startup, e.g only when 
mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN
we set hw_enc_features and friends -- in that respect, I wasn't sure if 
it's okay to blindly set  .encap_oka = 1 here.

Another constraint, is that when the device does support (say) TCP TX 
checksum offload for the inner packet they don't support UDP
checksum offload for the outer packet.
