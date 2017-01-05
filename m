From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH 1/2] virtio_net: cap mtu when XDP programs are running
Date: Wed, 4 Jan 2017 19:14:01 -0800
Message-ID: <586DB9F9.9090701@gmail.com>
References: <20170105031118.2636.82374.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35120 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751946AbdAEDOQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 22:14:16 -0500
Received: by mail-pf0-f195.google.com with SMTP id i88so27718973pfk.2
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 19:14:16 -0800 (PST)
In-Reply-To: <20170105031118.2636.82374.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-04 07:11 PM, John Fastabend wrote:
> XDP programs can not consume multiple pages so we cap the MTU to
> avoid this case. Virtio-net however only checks the MTU at XDP
> program load and does not block MTU changes after the program
> has loaded.
> 
> This patch sets/clears the max_mtu value at XDP load/unload time.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/virtio_net.c |   26 ++++++++++++++++++++++----
>  1 file changed, 22 insertions(+), 4 deletions(-)


[...]

>  static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>  {
> -	unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	struct bpf_prog *old_prog;
> +	unsigned long int max_sz;
>  	u16 xdp_qp = 0, curr_qp;
>  	int i, err;
>  
> @@ -1720,6 +1737,7 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>  		return -EINVAL;
>  	}
>  
> +	max_sz = virtnet_xdp_mtu(prog, vi);
>  	if (dev->mtu > max_sz) {
>  		netdev_warn(dev, "XDP requires MTU less than %lu\n", max_sz);
>  		return -EINVAL;
> @@ -1748,6 +1766,9 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>  			virtnet_set_queues(vi, curr_qp);
>  			return PTR_ERR(prog);
>  		}
> +		dev->max_mtu = max_sz;
> +	} else {
> +		dev->max_mtu = ETH_MAX_MTU;
>  	}

oops v2 needed. The else branch is not required anymore. :/
