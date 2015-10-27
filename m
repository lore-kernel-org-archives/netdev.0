From: Ravi Kerur <rkerur@gmail.com>
Subject: Re: [PATCH v1 1/3] virtio-net: Using single MSIX IRQ for TX/RX Q
 pair
Date: Tue, 27 Oct 2015 15:17:22 -0700
Message-ID: <562FF7F2.3050205@gmail.com>
References: <1445881969-24663-1-git-send-email-rkerur@gmail.com> <20151027083848.GA22688@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33558 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694AbbJ0WRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 18:17:24 -0400
Received: by pabla5 with SMTP id la5so41603691pab.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 15:17:24 -0700 (PDT)
In-Reply-To: <20151027083848.GA22688@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/27/2015 1:38 AM, Michael S. Tsirkin wrote:
> On Mon, Oct 26, 2015 at 10:52:47AM -0700, Ravi Kerur wrote:
>> Ported earlier patch from Jason Wang (dated 12/26/2014).
>>
>> This patch tries to reduce the number of MSIX irqs required for
>> virtio-net by sharing a MSIX irq for each TX/RX queue pair through
>> channels. If transport support channel, about half of the MSIX irqs
>> were reduced.
>>
>> Signed-off-by: Ravi Kerur <rkerur@gmail.com>
> 
> Why bother BTW? Looks like this is adding a bunch of overhead
> on data path - to what end?
> 
> Maybe you have a huge number of these devices ... but in that case, how
> about sharing the config interrupt instead?
> That's only possible if host supports VIRTIO_1
> (so we can detect config interrupt by reading the ISR).

For my clarification, are you suggesting this as an additional changes for config interrupts or rework existing patch?
> 
> 
> 
>> ---
>>  drivers/net/virtio_net.c | 29 ++++++++++++++++++++++++++++-
>>  1 file changed, 28 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index d8838ded..d705cce 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -72,6 +72,9 @@ struct send_queue {
>>  
>>  	/* Name of the send queue: output.$index */
>>  	char name[40];
>> +
>> +	/* Name of the channel, shared with irq. */
>> +	char channel_name[40];
>>  };
>>  
>>  /* Internal representation of a receive virtqueue */
>> @@ -1529,6 +1532,8 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
>>  	int ret = -ENOMEM;
>>  	int i, total_vqs;
>>  	const char **names;
>> +	const char **channel_names;
>> +	unsigned *channels;
>>  
>>  	/* We expect 1 RX virtqueue followed by 1 TX virtqueue, followed by
>>  	 * possible N-1 RX/TX queue pairs used in multiqueue mode, followed by
>> @@ -1548,6 +1553,17 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
>>  	if (!names)
>>  		goto err_names;
>>  
>> +	channel_names = kmalloc_array(vi->max_queue_pairs,
>> +				      sizeof(*channel_names),
>> +				      GFP_KERNEL);
>> +	if (!channel_names)
>> +		goto err_channel_names;
>> +
>> +	channels = kmalloc_array(total_vqs, sizeof(*channels),
>> +				 GFP_KERNEL);
>> +	if (!channels)
>> +		goto err_channels;
>> +
>>  	/* Parameters for control virtqueue, if any */
>>  	if (vi->has_cvq) {
>>  		callbacks[total_vqs - 1] = NULL;
>> @@ -1562,10 +1578,15 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
>>  		sprintf(vi->sq[i].name, "output.%d", i);
>>  		names[rxq2vq(i)] = vi->rq[i].name;
>>  		names[txq2vq(i)] = vi->sq[i].name;
>> +		sprintf(vi->sq[i].channel_name, "txrx.%d", i);
>> +		channel_names[i] = vi->sq[i].channel_name;
>> +		channels[rxq2vq(i)] = i;
>> +		channels[txq2vq(i)] = i;
>>  	}
>>  
>>  	ret = vi->vdev->config->find_vqs(vi->vdev, total_vqs, vqs, callbacks,
>> -					 names);
>> +					 names, channels, channel_names,
>> +					 vi->max_queue_pairs);
>>  	if (ret)
>>  		goto err_find;
>>  
>> @@ -1580,6 +1601,8 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
>>  		vi->sq[i].vq = vqs[txq2vq(i)];
>>  	}
>>  
>> +	kfree(channels);
>> +	kfree(channel_names);
>>  	kfree(names);
>>  	kfree(callbacks);
>>  	kfree(vqs);
>> @@ -1587,6 +1610,10 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
>>  	return 0;
>>  
>>  err_find:
>> +	kfree(channels);
>> +err_channels:
>> +	kfree(channel_names);
>> +err_channel_names:
>>  	kfree(names);
>>  err_names:
>>  	kfree(callbacks);
>> -- 
>> 1.9.1
