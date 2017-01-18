From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net PATCH v5 6/6] virtio_net: XDP support for adjust_head
Date: Wed, 18 Jan 2017 11:35:58 +0800
Message-ID: <5a587c8e-851c-9793-7f1f-8857cc00b2d7@redhat.com>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117222259.20280.24625.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53410 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750893AbdARDgF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 22:36:05 -0500
In-Reply-To: <20170117222259.20280.24625.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月18日 06:22, John Fastabend wrote:
>   
> +static int virtnet_reset(struct virtnet_info *vi)
> +{
> +	struct virtio_device *dev = vi->vdev;
> +	int ret;
> +
> +	virtio_config_disable(dev);
> +	dev->failed = dev->config->get_status(dev) & VIRTIO_CONFIG_S_FAILED;
> +	virtnet_freeze_down(dev);
> +	_remove_vq_common(vi);
> +
> +	dev->config->reset(dev);
> +	virtio_add_status(dev, VIRTIO_CONFIG_S_ACKNOWLEDGE);
> +	virtio_add_status(dev, VIRTIO_CONFIG_S_DRIVER);
> +
> +	ret = virtio_finalize_features(dev);
> +	if (ret)
> +		goto err;
> +
> +	ret = virtnet_restore_up(dev);
> +	if (ret)
> +		goto err;
> +	ret = _virtnet_set_queues(vi, vi->curr_queue_pairs);
> +	if (ret)
> +		goto err;
> +
> +	virtio_add_status(dev, VIRTIO_CONFIG_S_DRIVER_OK);
> +	virtio_config_enable(dev);
> +	return 0;
> +err:
> +	virtio_add_status(dev, VIRTIO_CONFIG_S_FAILED);
> +	return ret;
> +}
> +

Hi John:

I still prefer not open code (part of) virtio_device_freeze() and 
virtio_device_restore() here. How about:

1) introduce __virtio_device_freeze/__virtio_device_restore which 
accepts a function pointer of free/restore
2) for virtio_device_freeze/virtio_device_restore just pass 
drv->freeze/drv->restore (locked version)
3) for virtnet_reset(), we can pass unlocked version of freeze and restore

Just my preference, if both Michael and you stick to this, I'm also fine.

Thanks
