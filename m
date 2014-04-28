From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: Set dev->needed_headroom for virtio-net
 device when it has the feature VIRTIO_F_ANY_LAYOUT
Date: Mon, 28 Apr 2014 09:48:48 -0400
Message-ID: <535E5C40.9090102@gmail.com>
References: <535E5235.4000903@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, qinchuanyu@huawei.com,
	liuyongan@huawei.com
To: "Zhangjie (HZ)" <zhangjie14@huawei.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:54479 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756153AbaD1Nsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 09:48:51 -0400
Received: by mail-qg0-f41.google.com with SMTP id j107so6263379qga.28
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 06:48:51 -0700 (PDT)
In-Reply-To: <535E5235.4000903@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/28/2014 09:05 AM, Zhangjie (HZ) wrote:
> This is a small supplement for commit
> e7428e95a06fb516fac1308bd0e176e27c0b9287("virtio-net: put virtio-net header
> inline with data"). TCP packages have enough room to put virtio-net header
> in, but UDP packages do not. By setting dev->needed_headroom for virtio-net
> device, UDP packages could have enough room.
> 
> For UDP packages, sk_buff is alloced in fun __ip_append_data. The size
> is "alloclen + hh_len + 15", and "hh_len =
> LL_RESERVED_SPACE(rt->dst.dev);".
> The Macro is defined as follows:
> #define LL_RESERVED_SPACE(dev) \
>      ((((dev)->hard_header_len+(dev)->needed_headroom)\
>      &~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
> By default, for UDP packages, after skb is allocated, only 16 bytes
> reserved. And 2 bytes remained after mac header is set. That is not
> enough to put virtio-net header in. If we set dev->needed_headroom
> to 12 or 10 (according to mergeable_rx_bufs is on or off ), more room
> can be reserved. Then there is enough room for UDP packages to put
> the header in.
> 
> test result list as below:
> guest and host: suse11sp3, netperf, intel 2.4GHz
> +-------+---------+---------+---------+---------+
> |       |   old   |         |   new   |         |
> +-------+---------+---------+---------+---------+
> |  UDP  | Gbit/s  |   PPs   | Gbit/s  |   PPs   |
> |  64   |  0.573  | 692232  |  0.614  | 742420  |
> |  256  |   1.6   | 686860  |  1.71   | 733331  |
> |  512  |  2.92   | 674576  |  3.07   | 710446  |
> | 1024  |  4.99   | 598977  |  5.17   | 620821  |
> | 1460  |  5.68   | 483757  |  7.16   | 610519  |
> +-------+---------+---------+---------+---------+
> 
> 
> Signed-off-by: ZhangJie <zhangjie14@huawei.com>
> ---
>  drivers/net/virtio_net.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 8a852b5..e18acc3 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1724,6 +1724,13 @@ static int virtnet_probe(struct virtio_device *vdev)
>      if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
>          vi->has_cvq = true;
> 
> +        if (vi->any_header_sg) {
> +                if (vi->mergeable_rx_bufs)
> +                        dev->needed_headroom = sizeof(struct
> virtio_net_hdr_mrg_rxbuf);
> +                else
> +                        dev->needed_headroom = sizeof(struct
> virtio_net_hdr);
> +        }
> +

Looks like your mailer corrupted the patch.  You can see what it
looks like here:
  http://patchwork.ozlabs.org/patch/343388/

-vlad

>      /* Use single tx/rx queue pair as default */
>      vi->curr_queue_pairs = 1;
>      vi->max_queue_pairs = max_queue_pairs;
