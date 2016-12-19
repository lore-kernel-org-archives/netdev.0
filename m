From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] virtio_net: reject XDP programs using header
 adjustment
Date: Mon, 19 Dec 2016 09:50:57 -0800
Message-ID: <58581E01.7070902@gmail.com>
References: <20161219150500.2600-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        mst@redhat.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36706 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932581AbcLSRvZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 12:51:25 -0500
Received: by mail-pg0-f67.google.com with SMTP id w68so3102116pgw.3
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 09:51:24 -0800 (PST)
In-Reply-To: <20161219150500.2600-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-19 07:05 AM, Jakub Kicinski wrote:
> commit 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
> added a new XDP helper to prepend and remove data from a frame.
> Make virtio_net reject programs making use of this helper until
> proper support is added.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  drivers/net/virtio_net.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 08327e005ccc..db761f37783e 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1677,6 +1677,11 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>  	u16 xdp_qp = 0, curr_qp;
>  	int i, err;
>  
> +	if (prog && prog->xdp_adjust_head) {
> +		netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
> +		return -EOPNOTSUPP;
> +	}
> +
>  	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
>  	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6)) {
>  		netdev_warn(dev, "can't set XDP while host is implementing LRO, disable LRO first\n");
> 

Acked-by: John Fastabend <john.r.fastabend@intel.com>

Thanks patch looks good. Alternatively we could push a "bug fix" to
support the adjust header feature depending on how DaveM and MST feel
about that. I don't have a strong opinion but I have the patch on my
queue it just needs some more testing. The adjust header bits were
merged in between some of the later versions of the patch which is how
this check got missed.

Thanks,
John
