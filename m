From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH 5/5] virtio_net: XDP support for adjust_head
Date: Fri, 13 Jan 2017 11:53:54 -0800
Message-ID: <58793052.1080200@gmail.com>
References: <20170112213919.3039.54165.stgit@john-Precision-Tower-5810>
 <20170112214519.3039.27879.stgit@john-Precision-Tower-5810>
 <20170113191451-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33438 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751072AbdAMTyI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 14:54:08 -0500
Received: by mail-pf0-f196.google.com with SMTP id 127so9603711pfg.0
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 11:54:08 -0800 (PST)
In-Reply-To: <20170113191451-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-13 09:23 AM, Michael S. Tsirkin wrote:
> On Thu, Jan 12, 2017 at 01:45:19PM -0800, John Fastabend wrote:
>> Add support for XDP adjust head by allocating a 256B header region
>> that XDP programs can grow into. This is only enabled when a XDP
>> program is loaded.
>>
>> In order to ensure that we do not have to unwind queue headroom push
>> queue setup below bpf_prog_add. It reads better to do a prog ref
>> unwind vs another queue setup call.
>>
>> At the moment this code must do a full reset to ensure old buffers
>> without headroom on program add or with headroom on program removal
>> are not used incorrectly in the datapath. Ideally we would only
>> have to disable/enable the RX queues being updated but there is no
>> API to do this at the moment in virtio so use the big hammer. In
>> practice it is likely not that big of a problem as this will only
>> happen when XDP is enabled/disabled changing programs does not
>> require the reset. There is some risk that the driver may either
>> have an allocation failure or for some reason fail to correctly
>> negotiate with the underlying backend in this case the driver will
>> be left uninitialized. I have not seen this ever happen on my test
>> systems and for what its worth this same failure case can occur
>> from probe and other contexts in virtio framework.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---


[...]

>>  
>> +#define VIRTIO_XDP_HEADROOM 256
>> +
>> +static int init_vqs(struct virtnet_info *vi);
>> +static void remove_vq_common(struct virtnet_info *vi, bool lock);
>> +
>> +/* Reset virtio device with RTNL held this is very similar to the
>> + * freeze()/restore() logic except we need to ensure locking. It is
>> + * possible that this routine may fail and leave the driver in a
>> + * failed state. However assuming the driver negotiated correctly
>> + * at probe time we _should_ be able to (re)negotiate driver again.
>> + */
>> +static int virtnet_xdp_reset(struct virtnet_info *vi)
>> +{
>> +	struct virtio_device *vdev = vi->vdev;
>> +	unsigned int status;
>> +	int i, ret;
>> +
>> +	/* Disable and unwind rings */
>> +	virtio_config_disable(vdev);
>> +	vdev->failed = vdev->config->get_status(vdev) & VIRTIO_CONFIG_S_FAILED;
>> +
>> +	netif_device_detach(vi->dev);
> 
> After this point, netif_device_present
> will return false, and then we have a bunch of code
> that does
>                 if (!netif_device_present(dev))
>                         return -ENODEV;
> 
> 
> so we need to audit this code to make sure it's
> all called under rtnl, correct?
> 

Correct. In the XDP case it is.

> We don't want it to fail because of timing.
> 
> Maybe add an assert there.
> 

I can add an assert here to ensure it doesn't ever get
refactored out or something.

> 
>> +	cancel_delayed_work_sync(&vi->refill);
>> +	if (netif_running(vi->dev)) {
>> +		for (i = 0; i < vi->max_queue_pairs; i++)
>> +			napi_disable(&vi->rq[i].napi);
>> +	}
>> +
>> +	remove_vq_common(vi, false);
>> +
>> +	/* Do a reset per virtio spec recommendation */
>> +	vdev->config->reset(vdev);
>> +
>> +	/* Acknowledge that we've seen the device. */
>> +	status = vdev->config->get_status(vdev);
>> +	vdev->config->set_status(vdev, status | VIRTIO_CONFIG_S_ACKNOWLEDGE);
>> +
>> +	/* Notify driver is up and finalize features per specification. The
>> +	 * error code from finalize features is checked here but should not
>> +	 * fail because we assume features were previously synced successfully.
>> +	 */
>> +	status = vdev->config->get_status(vdev);
>> +	vdev->config->set_status(vdev, status | VIRTIO_CONFIG_S_DRIVER);
>> +	ret = virtio_finalize_features(vdev);
> 
> I'd rather we put all this in virtio core, maybe call it virtio_reset or
> something.

At first I started to do this but decided it was easier to open code it I
was on the fence though so if we think it would be cleaner then I will
do it.

The trick is needs to be broken down into two pieces, something like the
following,

	virtio_reset() {
		do_generic_down_part  -> pci pieces
		vdev->config->down()  -> do down part of device specifics
		do_generic_up_part
		vdev->config->up()    -> do up part of device specifics
		do_finalize_part
	}

Alternatively we could reuse the freeze/restore device callbacks but those
make assumptions about locking. So we could pass a context through but per
Stephen's comment that gets a bit fragile. And sparse doesn't like it either
apparently. I think making it an explicit down/up reset callback might
make it clean and reusable for any other devices.

Any thoughts? My preference outside of open coding it is the new down_reset
and up_reset callbacks.

> 
>> +	if (ret) {
>> +		netdev_warn(vi->dev, "virtio_finalize_features failed during reset aborting\n");
>> +		goto err;
>> +	}
>> +
>> +	ret = init_vqs(vi);
>> +	if (ret) {
>> +		netdev_warn(vi->dev, "init_vqs failed during reset aborting\n");
>> +		goto err;
>> +	}
>> +	virtio_device_ready(vi->vdev);
>> +
>> +	if (netif_running(vi->dev)) {
>> +		for (i = 0; i < vi->curr_queue_pairs; i++)
>> +			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
>> +				schedule_delayed_work(&vi->refill, 0);
>> +
>> +		for (i = 0; i < vi->max_queue_pairs; i++)
>> +			virtnet_napi_enable(&vi->rq[i]);
>> +	}
>> +	netif_device_attach(vi->dev);
>> +	/* Finally, tell the device we're all set */
>> +	status = vdev->config->get_status(vdev);
>> +	vdev->config->set_status(vdev, status | VIRTIO_CONFIG_S_DRIVER_OK);
>> +	virtio_config_enable(vdev);
>> +
>> +	return 0;
>> +err:
>> +	status = vdev->config->get_status(vdev);
>> +	vdev->config->set_status(vdev, status | VIRTIO_CONFIG_S_FAILED);
> 
> And maybe virtio_fail ?
> 

Sure.

Thanks,
John
