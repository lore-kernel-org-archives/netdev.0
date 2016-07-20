From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v10 05/12] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Wed, 20 Jul 2016 11:07:57 +0200
Message-ID: <578F3F6D.5000903@iogearbox.net>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com> <1468955817-10604-6-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49414 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752902AbcGTJIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 05:08:02 -0400
In-Reply-To: <1468955817-10604-6-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2016 09:16 PM, Brenden Blanco wrote:
> Add support for the BPF_PROG_TYPE_XDP hook in mlx4 driver.
>
> In tc/socket bpf programs, helpers linearize skb fragments as needed
> when the program touches the packet data. However, in the pursuit of
> speed, XDP programs will not be allowed to use these slower functions,
> especially if it involves allocating an skb.
>
> Therefore, disallow MTU settings that would produce a multi-fragment
> packet that XDP programs would fail to access. Future enhancements could
> be done to increase the allowable MTU.
>
> The xdp program is present as a per-ring data structure, but as of yet
> it is not possible to set at that granularity through any ndo.
>
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
[...]
>   struct mlx4_en_bond {
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index c1b3a9c..6729545 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -32,6 +32,7 @@
>    */
>
>   #include <net/busy_poll.h>
> +#include <linux/bpf.h>
>   #include <linux/mlx4/cq.h>
>   #include <linux/slab.h>
>   #include <linux/mlx4/qp.h>
> @@ -509,6 +510,8 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
>   	struct mlx4_en_dev *mdev = priv->mdev;
>   	struct mlx4_en_rx_ring *ring = *pring;
>
> +	if (ring->xdp_prog)
> +		bpf_prog_put(ring->xdp_prog);

Would be good if you also make this a READ_ONCE() here. I believe this is the
only other spot in your set that has this 'direct' access (besides xchg() and
READ_ONCE() from mlx4_en_process_rx_cq()). It would be mostly for consistency
and to indicate that there's a more complex synchronization behind it. I'm mostly
worried that if it's not consistently used, people might copy this and not use
the READ_ONCE() also in other spots where it matters, and thus add hard to find
bugs.

>   	mlx4_free_hwq_res(mdev->dev, &ring->wqres, size * stride + TXBB_SIZE);
>   	vfree(ring->rx_info);
>   	ring->rx_info = NULL;
> @@ -743,6 +746,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>   	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
>   	struct mlx4_en_rx_alloc *frags;
>   	struct mlx4_en_rx_desc *rx_desc;
> +	struct bpf_prog *xdp_prog;
>   	struct sk_buff *skb;
>   	int index;
>   	int nr;
> @@ -759,6 +763,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>   	if (budget <= 0)
>   		return polled;
