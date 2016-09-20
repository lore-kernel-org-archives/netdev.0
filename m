From: Jesper Dangaard Brouer <netdev@brouer.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 10:29:43 +0200
Message-ID: <20160920102943.24732097@brouer.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
        <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36630 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbcITI3q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 04:29:46 -0400
Received: by mail-lf0-f66.google.com with SMTP id s29so507593lfg.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 01:29:46 -0700 (PDT)
In-Reply-To: <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 19 Sep 2016 16:58:58 +0300 Tariq Toukan <tariqt@mellanox.com> wrote:

> +	act = bpf_prog_run_xdp(prog, &xdp);
> +	switch (act) {
> +	case XDP_PASS:
> +		return false;
> +	case XDP_TX:
> +		consumed = mlx5e_xmit_xdp_frame(&rq->channel->xdp_sq, di,
> +						MLX5_RX_HEADROOM,
> +						len);
> +		rq->stats.xdp_tx += consumed;
> +		return consumed;
> +	default:
> +		bpf_warn_invalid_xdp_action(act);
> +		return false;

This looks wrong.  According to the specification[1] and comment in the
code /include/uapi/linux/bpf.h: "Unknown return codes will result in
packet drop"

> +	case XDP_ABORTED:

It is not clearly defined, but I believe XDP_ABORTED should also result
in a warning (calling bpf_warn_invalid_xdp_action(act)).


> +	case XDP_DROP:
> +		rq->stats.xdp_drop++;
> +		mlx5e_page_release(rq, di, true);
> +		return true;
> +	}


I've started documenting XDP[2], as this patch clearly shows there is a
need to have a specification, given already the second driver
supporting XDP gets these details wrong.

[1] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/implementation/xdp_actions.html#xdp-aborted

[2] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/index.html

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
