From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Mon, 04 Apr 2016 11:22:39 +0200
Message-ID: <5702325F.6040805@iogearbox.net>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com> <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, gerlitz@mellanox.com,
	john.fastabend@gmail.com, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54236 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbcDDJWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 05:22:46 -0400
In-Reply-To: <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/2016 03:21 AM, Brenden Blanco wrote:
> Add support for the BPF_PROG_TYPE_PHYS_DEV hook in mlx4 driver.  Since
> bpf programs require a skb context to navigate the packet, build a
> percpu fake skb with the minimal fields. This avoids the costly
> allocation for packets that end up being dropped.
>
> Since mlx4 is so far the only user of this pseudo skb, the build
> function is defined locally.
>
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 61 ++++++++++++++++++++++++++
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 18 ++++++++
>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  2 +
>   3 files changed, 81 insertions(+)
>
[...]
>
> +static DEFINE_PER_CPU(struct sk_buff, percpu_pseudo_skb);
> +
> +static void build_pseudo_skb_for_bpf(struct sk_buff *skb, void *data,
> +				     unsigned int length)
> +{
> +	/* data_len is intentionally not set here so that skb_is_nonlinear()
> +	 * returns false
> +	 */
> +
> +	skb->len = length;
> +	skb->head = data;
> +	skb->data = data;
> +}
> +
> +int mlx4_call_bpf(struct bpf_prog *prog, void *data, unsigned int length)
> +{
> +	struct sk_buff *skb = this_cpu_ptr(&percpu_pseudo_skb);
> +	int ret;
> +
> +	build_pseudo_skb_for_bpf(skb, data, length);
> +
> +	rcu_read_lock();
> +	ret = BPF_PROG_RUN(prog, (void *)skb);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}

Couldn't this diff rather live in filter.c? Doesn't seem mlx4 specific. When
placed there, the api would also make the requirements clear for every driver
wanting to implement xdp wrt meta data that needs to be passed, and allows to
easier review code (as driver just call a few core helpers rather than needing
to re-implement the pseudo skb et al).

> +static int mlx4_bpf_set(struct net_device *dev, int fd)
> +{
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +	struct bpf_prog *prog = NULL, *old_prog;
> +
> +	if (fd >= 0) {
> +		prog = bpf_prog_get(fd);
> +		if (IS_ERR(prog))
> +			return PTR_ERR(prog);
> +
> +		if (prog->type != BPF_PROG_TYPE_PHYS_DEV) {
> +			bpf_prog_put(prog);
> +			return -EINVAL;
> +		}

This block could just be a generic helper that mlx4_bpf_set() calls from here.

> +	}
> +
> +	old_prog = xchg(&priv->prog, prog);
> +	if (old_prog) {
> +		synchronize_net();
> +		bpf_prog_put(old_prog);
> +	}
> +
> +	priv->dev->bpf_valid = !!prog;

Could the 'bpf_valid' addition to the net_device be avoided altogether?

The API could probably just be named .ndo_bpf() and depending how you invoke
it, either set/deletes the program or tell (return code) whether a program is
currently attached.

> +	return 0;
> +}
> +
>   static const struct net_device_ops mlx4_netdev_ops = {
>   	.ndo_open		= mlx4_en_open,
>   	.ndo_stop		= mlx4_en_close,
> @@ -2486,6 +2545,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
>   	.ndo_features_check	= mlx4_en_features_check,
>   #endif
>   	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
> +	.ndo_bpf_set		= mlx4_bpf_set,
>   };
>
>   static const struct net_device_ops mlx4_netdev_ops_master = {
> @@ -2524,6 +2584,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
>   	.ndo_features_check	= mlx4_en_features_check,
>   #endif
>   	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
> +	.ndo_bpf_set		= mlx4_bpf_set,
>   };
>
>   struct mlx4_en_bond {
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 86bcfe5..03fe005 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -748,6 +748,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>   	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
>   	struct mlx4_en_rx_alloc *frags;
>   	struct mlx4_en_rx_desc *rx_desc;
> +	struct bpf_prog *prog;
>   	struct sk_buff *skb;
>   	int index;
>   	int nr;
> @@ -764,6 +765,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>   	if (budget <= 0)
>   		return polled;
>
> +	prog = READ_ONCE(priv->prog);
> +
>   	/* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
>   	 * descriptor offset can be deduced from the CQE index instead of
>   	 * reading 'cqe->index' */
> @@ -840,6 +843,21 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>   		l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
>   			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
>
> +		/* A bpf program gets first chance to drop the packet. It may
> +		 * read bytes but not past the end of the frag. A non-zero
> +		 * return indicates packet should be dropped.
> +		 */
> +		if (prog) {
> +			struct ethhdr *ethh;
> +
> +			ethh = (struct ethhdr *)(page_address(frags[0].page) +
> +						 frags[0].page_offset);
> +			if (mlx4_call_bpf(prog, ethh, length)) {

Since such program will be ABI, the return code might get some more additions in
future (e.g. forwarding, etc), so it needs to be thought through that we don't
burn ourselves later.

Maybe reuse tc opcodes, or define own ones?

We currently would have:

  0    - Drop.
  1    - Pass to stack.
  rest - Reserved for future use.

> +				priv->stats.rx_dropped++;
> +				goto next;
> +			}
> +		}
> +
>   		if (likely(dev->features & NETIF_F_RXCSUM)) {
>   			if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_TCP |
>   						      MLX4_CQE_STATUS_UDP)) {
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index d12ab6a..3d0fc89 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -568,6 +568,7 @@ struct mlx4_en_priv {
>   	struct hlist_head mac_hash[MLX4_EN_MAC_HASH_SIZE];
>   	struct hwtstamp_config hwtstamp_config;
>   	u32 counter_index;
> +	struct bpf_prog *prog;
>
>   #ifdef CONFIG_MLX4_EN_DCB
>   	struct ieee_ets ets;
> @@ -682,6 +683,7 @@ int mlx4_en_create_drop_qp(struct mlx4_en_priv *priv);
>   void mlx4_en_destroy_drop_qp(struct mlx4_en_priv *priv);
>   int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring);
>   void mlx4_en_rx_irq(struct mlx4_cq *mcq);
> +int mlx4_call_bpf(struct bpf_prog *prog, void *data, unsigned int length);
>
>   int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
>   int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv);
>
