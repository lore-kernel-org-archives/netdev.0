From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 5/6] vhost_net: poll vhost queue after marking DMA is done
Date: Tue, 20 Aug 2013 10:44:40 +0800
Message-ID: <5212D818.4090201@redhat.com>
References: <1376630190-5912-1-git-send-email-jasowang@redhat.com>
	<1376630190-5912-6-git-send-email-jasowang@redhat.com>
	<20130816100055.GC21821@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130816100055.GC21821@redhat.com>
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

On 08/16/2013 06:00 PM, Michael S. Tsirkin wrote:
> On Fri, Aug 16, 2013 at 01:16:29PM +0800, Jason Wang wrote:
>> We used to poll vhost queue before making DMA is done, this is racy if vhost
>> thread were waked up before marking DMA is done which can result the signal to
>> be missed. Fix this by always poll the vhost thread before DMA is done.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> Indeed, but vhost_net_ubuf_put should be the last thing we do:
> it can cause the device to go away and we'll get
> a user after free.

Didn't get this. We didn't use ubuf in vhost_zerocopy_signal_used(),
looks safe here?
>
>> ---
>>  drivers/vhost/net.c |    9 +++++----
>>  1 files changed, 5 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index 70cab75..a035a89 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -308,6 +308,11 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
>>  	struct vhost_virtqueue *vq = ubufs->vq;
>>  	int cnt = atomic_read(&ubufs->kref.refcount);
>>  
>> +	/* set len to mark this desc buffers done DMA */
>> +	vq->heads[ubuf->desc].len = success ?
>> +		VHOST_DMA_DONE_LEN : VHOST_DMA_FAILED_LEN;
>> +	vhost_net_ubuf_put(ubufs);
>> +
>>  	/*
>>  	 * Trigger polling thread if guest stopped submitting new buffers:
>>  	 * in this case, the refcount after decrement will eventually reach 1
>> @@ -318,10 +323,6 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
>>  	 */
>>  	if (cnt <= 2 || !(cnt % 16))
>>  		vhost_poll_queue(&vq->poll);
>> -	/* set len to mark this desc buffers done DMA */
>> -	vq->heads[ubuf->desc].len = success ?
>> -		VHOST_DMA_DONE_LEN : VHOST_DMA_FAILED_LEN;
>> -	vhost_net_ubuf_put(ubufs);
>>  }
>>  
>>  /* Expects to be always run from workqueue - which acts as
>> -- 
>> 1.7.1
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
