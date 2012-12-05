From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/3] virtio_net: multiqueue support
Date: Wed, 05 Dec 2012 14:33:15 +0800
Message-ID: <50BEEAAB.6050806@redhat.com>
References: <1354619278-35702-1-git-send-email-jasowang@redhat.com>
	<1354619278-35702-3-git-send-email-jasowang@redhat.com>
	<20121204132422.GD7499@redhat.com>
	<7748384.YyJVzCCbsc@jason-thinkpad-t430s>
	<20121204151108.GI7499@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, shiyer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121204151108.GI7499@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 12/04/2012 11:11 PM, Michael S. Tsirkin wrote:
> On Tue, Dec 04, 2012 at 10:45:33PM +0800, Jason Wang wrote:
>> On Tuesday, December 04, 2012 03:24:22 PM Michael S. Tsirkin wrote:
>>> I found some bugs, see below.
>>> Also some style nitpicking, this is not mandatory to address.
>> Thanks for the reviewing.
>>> On Tue, Dec 04, 2012 at 07:07:57PM +0800, Jason Wang wrote:
>>>
[...]
>>>> +		set = false;
>>> This will overwrite affinity if it was set by userspace.
>>> Just
>>> 	if (set)
>>> 		return;
>>> will not have this problem.
>> But we need handle the situtaiton when switch back to sq from mq mode. 
>> Otherwise we may still get the affinity hint used in mq.
>>  This kind of overwrite 
>> is unavoidable or is there some method to detect whether userspac write 
>> something new?
> If we didn't set the affinity originally we should not overwrite it.
> I think this means we need a flag that tells us that
> virtio set the affinity.

Ok.

[...]
>>>> +
>>>> +	/* Parameters for control virtqueue, if any */
>>>> +	if (vi->has_cvq) {
>>>> +		callbacks[total_vqs - 1] = NULL;
>>>> +		names[total_vqs - 1] = kasprintf(GFP_KERNEL, "control");
>>>> +	}
>>>>
>>>> +	/* Allocate/initialize parameters for send/receive virtqueues */
>>>> +	for (i = 0; i < vi->max_queue_pairs; i++) {
>>>> +		callbacks[rxq2vq(i)] = skb_recv_done;
>>>> +		callbacks[txq2vq(i)] = skb_xmit_done;
>>>> +		names[rxq2vq(i)] = kasprintf(GFP_KERNEL, "input.%d", i);
>>>> +		names[txq2vq(i)] = kasprintf(GFP_KERNEL, "output.%d", i);
>>>> +	}
>>> We would need to check kasprintf return value.
>> Looks like a better method is to make the name as a memeber of receive_queue 
>> and send_queue, and use sprintf here.
>>> Also if you allocate names from slab we'll need to free them
>>> later.
>> Then it could be freed when the send_queue and receive_queue is freed.
>>> It's probably easier to just use fixed names for now -
>>> it's not like the index is really useful.
>> Looks useful for debugging e.g. check whether the irq distribution is as 
>> expected.
> Well it doesn't really matter which one goes where, right?
> As long as interrupts are distributed well.

Yes, anyway, we decide to store the name in the send/receive queue, so I
will keep the index.
>
>>>> +
>>>> +	ret = vi->vdev->config->find_vqs(vi->vdev, total_vqs, vqs, callbacks,
>>>> +					 (const char **)names);
>>> Please avoid casts, use a proper type for names.
>> I'm consider we need a minor change in this api, we need allocate the names 
>> dynamically which could not be a const char **.
> I don't see why. Any use that allocates on the fly as
> you did would leak memory. Any use like you suggest
> e.g. allocating as part of send/receive structure
> would be fine.

True
>>>> +	if (ret)
>>>> +		goto err_names;
>>>> +
>>>> +	if (vi->has_cvq) {
>>>> +		vi->cvq = vqs[total_vqs - 1];
>>>>
>>>>  		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
>>>>  		
>>>>  			vi->dev->features |= NETIF_F_HW_VLAN_FILTER;
>>>>  	
>>>>  	}
>>>>
>>>> +
>>>> +	for (i = 0; i < vi->max_queue_pairs; i++) {
>>>> +		vi->rq[i].vq = vqs[rxq2vq(i)];
>>>> +		vi->sq[i].vq = vqs[txq2vq(i)];
>>>> +	}
>>>> +
>>>> +	kfree(callbacks);
>>>> +	kfree(vqs);
>>> Who frees names if there's no error?
>>>
>> The virtio core does not copy the name, so it need this and only used for 
>> debugging if I'm reading the code correctly.
> No, virtio core does not free either individual vq name or the names
> array passed in. So this leaks memory.

Yes, so when we use the names in receive/send queue, it can be freed
during queue destroying.

[...]
> @@ -1276,24 +1531,29 @@ static int virtnet_freeze(struct virtio_device
> *vdev)> 
>  static int virtnet_restore(struct virtio_device *vdev)
>  {
>  
>  	struct virtnet_info *vi = vdev->priv;
>
> -	int err;
> +	int err, i;
>
>  	err = init_vqs(vi);
>  	if (err)
>  	
>  		return err;
>  	
>  	if (netif_running(vi->dev))
>
> -		virtnet_napi_enable(&vi->rq);
> +		for (i = 0; i < vi->max_queue_pairs; i++)
> +			virtnet_napi_enable(&vi->rq[i]);
>
>  	netif_device_attach(vi->dev);
>
> -	if (!try_fill_recv(&vi->rq, GFP_KERNEL))
> -		schedule_delayed_work(&vi->refill, 0);
> +	for (i = 0; i < vi->max_queue_pairs; i++)
> +		if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
> +			schedule_delayed_work(&vi->refill, 0);
>
>  	mutex_lock(&vi->config_lock);
>  	vi->config_enable = true;
>  	mutex_unlock(&vi->config_lock);
>
> +	if (vi->has_cvq && virtio_has_feature(vi->vdev, VIRTIO_NET_F_RFS))
> +		virtnet_set_queues(vi);
> +
>>> I think it's easier to test
>>> if (curr_queue_pairs == max_queue_pairs)
>>> within virtnet_set_queues and make it
>>> a NOP if so.
>> Still need to send the command during restore since we reset the device during 
>> freezing.
>
> Then maybe check vi->has_cvq && virtio_has_feature(vi->vdev,
> VIRTIO_NET_F_RFS) in there?

Right.
>
>>>>  
[...]
