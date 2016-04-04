From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Mon, 4 Apr 2016 10:33:14 +0200
Message-ID: <20160404103314.56286d64@redhat.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	<1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, Or Gerlitz <ogerlitz@mellanox.com>,
	daniel@iogearbox.net, john.fastabend@gmail.com, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52135 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751310AbcDDIdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 04:33:20 -0400
In-Reply-To: <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  1 Apr 2016 18:21:57 -0700
Brenden Blanco <bblanco@plumgrid.com> wrote:

> @@ -840,6 +843,21 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  		l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
>  			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
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
> +				priv->stats.rx_dropped++;
> +				goto next;
> +			}
> +		}
> +

For future API, I can imagine more return codes being needed.

For forwarding I could imagine returning "STOLEN", which should not
increment rx_dropped.

One could also imagine supporting tcpdump/af_packet like facilities at
this packet-page level (e.g. af_packet queue packets into a RX ring
buffer, later processed/read async). It could return "SHARED", bumping
refcnt on page, and indicate page is now read-only. Thus, affecting
drivers processing flow.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
