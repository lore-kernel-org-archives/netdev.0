From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 2/4] virtio_net: Add a virtqueue for outbound control
 commands
Date: Wed, 14 Jan 2009 10:15:10 +0000
Message-ID: <1231928110.4944.290.camel@localhost.localdomain>
References: <1231881797.9095.187.camel@bling>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53591 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755838AbZANKPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 05:15:20 -0500
In-Reply-To: <1231881797.9095.187.camel@bling>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-13 at 14:23 -0700, Alex Williamson wrote:
> This will be used for RX mode, MAC filter table, VLAN filtering, etc...

Looks very reasonable. I'm a bit wary of send_command() being
synchronous, but it probably makes sense.

Could do with some details in the commit log as to why this approach was
chosen over increasing virtio_net_config.

> Signed-off-by: Alex Williamson <alex.williamson@hp.com>
> ---
> 
>  drivers/net/virtio_net.c   |   55 +++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/virtio_net.h |    3 ++
>  2 files changed, 57 insertions(+), 1 deletions(-)
> 
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index e7700de..de348de 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -39,7 +39,7 @@ module_param(gso, bool, 0444);
>  struct virtnet_info
>  {
>  	struct virtio_device *vdev;
> -	struct virtqueue *rvq, *svq;
> +	struct virtqueue *rvq, *svq, *cvq;
>  	struct net_device *dev;
>  	struct napi_struct napi;
>  
> @@ -603,6 +603,47 @@ static int virtnet_open(struct net_device *dev)
>  	return 0;
>  }
>  
> +static int virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
> +				void *data, unsigned int len)
> +{
> +	struct scatterlist sg[3];
> +	struct {
> +		u8 class;
> +		u8 cmd;
> +	} ctrl_cmd;

I'd like to see this defined in virtio_net_hdr.

Why the need for class/cmd? Why not just a single 16 bit command field?

> +	u8 ctrl_status;
> +	unsigned int tmp;
> +	int i = 0;
> +
> +	if (!vi->cvq)
> +		return -EFAULT;

BUG_ON() probably makes more sense here.

> +
> +	sg_init_table(sg, len ? 3 : 2);
> +
> +	sg_set_buf(&sg[i++], &ctrl_cmd, sizeof(ctrl_cmd));
> +	if (len)
> +		sg_set_buf(&sg[i++], data, len);
> +	sg_set_buf(&sg[i], &ctrl_status, sizeof(ctrl_status));
> +
> +	ctrl_cmd.class = class;
> +	ctrl_cmd.cmd = cmd;
> +
> +	ctrl_status = ~0;
> +
> +	if (vi->cvq->vq_ops->add_buf(vi->cvq, sg, i, 1, vi) != 0)
> +		BUG();
> +
> +	vi->cvq->vq_ops->kick(vi->cvq);
> +
> +	while (!vi->cvq->vq_ops->get_buf(vi->cvq, &tmp))
> +		cpu_relax();
> +
> +	if (ctrl_status == VIRTIO_NET_OK)
> +		return 0;
> +	else
> +		return -EFAULT;

Could be all on one line:

        return ctrl_status ? -EFAULT : 0;

Cheers,
Mark.

