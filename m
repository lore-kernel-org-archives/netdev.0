From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v10 05/12] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Tue, 19 Jul 2016 14:41:47 -0700
Message-ID: <20160719214146.GB64618@ast-mbp.thefacebook.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-6-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33897 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbcGSVlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 17:41:52 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so2077023pfb.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 14:41:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1468955817-10604-6-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 12:16:50PM -0700, Brenden Blanco wrote:
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
...
> +static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
> +{
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +	struct bpf_prog *old_prog;
> +	int xdp_ring_num;
> +	int i;
> +
> +	xdp_ring_num = prog ? ALIGN(priv->rx_ring_num, MLX4_EN_NUM_UP) : 0;
> +
> +	if (priv->num_frags > 1) {
> +		en_err(priv, "Cannot set XDP if MTU requires multiple frags\n");
> +		return -EOPNOTSUPP;
> +	}
> +
> +	if (prog) {
> +		prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
> +		if (IS_ERR(prog))
> +			return PTR_ERR(prog);
> +	}
> +
> +	priv->xdp_ring_num = xdp_ring_num;
> +
> +	/* This xchg is paired with READ_ONCE in the fast path */
> +	for (i = 0; i < priv->rx_ring_num; i++) {
> +		old_prog = xchg(&priv->rx_ring[i]->xdp_prog, prog);
> +		if (old_prog)
> +			bpf_prog_put(old_prog);
> +	}

priv->xdp_ring_num looks similar priv->rx_ring_num, so on the first glance
it seemed that the per ring refactoring broke detach logic, but no. it's good.
Acked-by: Alexei Starovoitov <ast@kernel.org>
