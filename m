From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net-next] virtio-net: Set needed_headroom for virtio-net when VIRTIO_F_ANY_LAYOUT is true
Date: Wed, 30 Apr 2014 11:14:10 +0930
Message-ID: <87iopr4mmt.fsf@rustcorp.com.au>
References: <535F824A.5060804@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, linville@tuxdriver.com,
	jeffrey.t.kirsher@intel.com, mst@redhat.com, jasowang@redhat.com,
	qinchuanyu@huawei.com, liuyongan@huawei.com, zhangjie14@huawei.com,
	zhaoshenglong@huawei.com
To: "Zhangjie \(HZ\)" <zhangjie14@huawei.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:47966 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754273AbaD3HLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2014 03:11:22 -0400
In-Reply-To: <535F824A.5060804@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Zhangjie (HZ)" <zhangjie14@huawei.com> writes:
> This is a small supplement for commit e7428e95a06fb516fac1308bd0e176e27c0b9287
> ("virtio-net: put virtio-net header inline with data"). TCP packages have
> enough room to put virtio-net header in, but UDP packages do not. By
> setting dev->needed_headroom for virtio-net device, UDP packages could have
> enough room.
>
> For UDP packages, sk_buff is alloced in fun __ip_append_data. The size is
> "alloclen + hh_len + 15", and "hh_len = LL_RESERVED_SPACE(rt-dst.dev);".
> The Macro is defined as follows:
> #define LL_RESERVED_SPACE(dev) \
>      ((((dev)->hard_header_len+(dev)->needed_headroom)\
>      &~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
> By default, for UDP packages, after skb is allocated, only 16 bytes
> reserved. And 2 bytes remained after mac header is set. That is not enough
> to put virtio-net header in. If we set dev->needed_headroom to 12 or 10
> (according to mergeable_rx_bufs is on or off ), more room can be reserved.
> Then there is enough room for UDP packages to put the header in.

Seems like a no-brainer.  Good find!

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks,
Rusty.



>
> test result list as below:
> guest and host: suse11sp3, netperf, intel 2.4GHz
> +-------+---------+---------+---------+---------+
> |       |   old             |   new             |
> +-------+---------+---------+---------+---------+
> | UDP   |  Gbit/s | pps     |  Gbit/s | pps     |
> | 64    |  0.57   | 692232  |  0.61   | 742420  |
> | 256   |  1.60   | 686860  |  1.71   | 733331  |
> | 512   |  2.92   | 674576  |  3.07   | 710446  |
> | 1024  |  4.99   | 598977  |  5.17   | 620821  |
> | 1460  |  5.68   | 483757  |  7.16   | 610519  |
> | 4096  |  6.98   | 637468  |  7.21   | 658471  |
> +-------+---------+---------+---------+---------+
>
> Signed-off-by: Zhang Jie <zhangjie14@huawei.com>
> ---
>  drivers/net/virtio_net.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 8a852b5..b852bb3 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1724,6 +1724,13 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
>  		vi->has_cvq = true;
>
> +	if (vi->any_header_sg) {
> +		if (vi->mergeable_rx_bufs)
> +			dev->needed_headroom = sizeof(struct virtio_net_hdr_mrg_rxbuf);
> +		else
> +			dev->needed_headroom = sizeof(struct virtio_net_hdr);
> +	}
> +
>  	/* Use single tx/rx queue pair as default */
>  	vi->curr_queue_pairs = 1;
>  	vi->max_queue_pairs = max_queue_pairs;
> -- 
> 1.9.0.msysgit.0
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
