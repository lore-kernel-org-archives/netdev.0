From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Fri, 01 Apr 2016 19:08:31 -0700
Message-ID: <1459562911.6473.299.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, gerlitz@mellanox.com,
	daniel@iogearbox.net, john.fastabend@gmail.com, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:33558 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbcDBCIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 22:08:34 -0400
Received: by mail-yw0-f179.google.com with SMTP id t10so6769935ywa.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 19:08:34 -0700 (PDT)
In-Reply-To: <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 18:21 -0700, Brenden Blanco wrote:
> Add support for the BPF_PROG_TYPE_PHYS_DEV hook in mlx4 driver.  Since
> bpf programs require a skb context to navigate the packet, build a
> percpu fake skb with the minimal fields. This avoids the costly
> allocation for packets that end up being dropped.
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


1) mlx4 can use multiple fragments (priv->num_frags) to hold an Ethernet
frame. 

Still you pass a single fragment but total 'length' here : BPF program
can read past the end of this first fragment and panic the box.

Please take a look at mlx4_en_complete_rx_desc() and you'll see what I
mean.

2) priv->stats.rx_dropped is shared by all the RX queues -> false
sharing.

   This is probably the right time to add a rx_dropped field in struct
mlx4_en_rx_ring since you guys want to drop 14 Mpps, and 50 Mpps on
higher speed links.
