From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next V3 PATCH 3/5] bpf: cpumap xdp_buff to skb conversion
 and allocation
Date: Mon, 2 Oct 2017 18:02:46 -0700
Message-ID: <20171003010245.f3op4t56crbjc4ke@ast-mbp>
References: <150696027949.24152.7507025809123255386.stgit@firesoul>
 <150696032966.24152.3096148163967111058.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:56948 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdJCBCt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 21:02:49 -0400
Received: by mail-pg0-f53.google.com with SMTP id n1so3170450pgt.13
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 18:02:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150696032966.24152.3096148163967111058.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 02, 2017 at 06:05:29PM +0200, Jesper Dangaard Brouer wrote:
> +		while ((xdp_pkt = __ptr_ring_consume(rcpu->queue))) {
> +			struct sk_buff *skb;
> +			int ret;
> +
> +			/* Allow busy polling again */
> +			empty_cnt = 0;
> +
> +			skb = cpu_map_build_skb(rcpu, xdp_pkt);
> +			if (!skb) {
> +				page_frag_free(xdp_pkt);
> +				continue;
> +			}
> +
> +			/* Inject into network stack */
> +			ret = netif_receive_skb(skb);
> +			if (ret == NET_RX_DROP)
> +				drops++;

I thought the whole thing is an alternative to RPS,
but netif_receive_skb_internal() will call into RPS logic.
So the user has to make sure it disabled or they will
conflict in some weird way?
Or you're calling netif_receive_skb() to be able to call
generic XDP on that cpu again ?
But that prog can do cpumap redirect again?
sort-of recursive redirect? Is it really useful?
May be call into __netif_receive_skb_core() directly?
not sure.
I'm asking all these questions to make sure we think through
these implications before it becomes an abi.
