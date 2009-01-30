From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2 1/4] virtio_net: Add a virtqueue for outbound control commands
Date: Fri, 30 Jan 2009 15:38:06 +1030
Message-ID: <200901301538.06975.rusty@rustcorp.com.au>
References: <20090129230502.2672.87669.stgit@debian.lart> <20090129230507.2672.97837.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090129230507.2672.97837.stgit@debian.lart>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 30 January 2009 09:35:07 Alex Williamson wrote:
> +static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
> +				 void *data, unsigned int len)
> +{
> +	struct scatterlist sg[3];
> +	struct virtio_net_ctrl_hdr ctrl;
> +	virtio_net_ctrl_ack status;
> +	unsigned int tmp;
> +	int i = 0;
> +
> +	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
> +		return false;
> +
> +	sg_init_table(sg, len ? 3 : 2);

I'd test data rather than len here.

> +	sg_set_buf(&sg[i++], &ctrl, sizeof(ctrl));
> +	if (len)
> +		sg_set_buf(&sg[i++], data, len);
> +	sg_set_buf(&sg[i], &status, sizeof(status));
> +
> +	ctrl.class = class;
> +	ctrl.cmd = cmd;
> +
> +	status = ~0;
> +
> +	if (vi->cvq->vq_ops->add_buf(vi->cvq, sg, i, 1, vi) != 0)
> +		BUG();

Hmm, I prefer initialize buffer, then set sg to refer to it.  Seems to make
more sense to me.

> +	while (!vi->cvq->vq_ops->get_buf(vi->cvq, &tmp))
> +		cpu_relax();

This probably deserves a comment about why it's OK to spin here.

> +	return status == VIRTIO_NET_OK ? true : false;

Or "return status == VIRTIO_NET_OK;" ?

See what I mean about nit-picking?
Rusty.
