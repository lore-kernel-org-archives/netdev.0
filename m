From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 5/6] vhost_net: poll vhost queue after marking DMA
	is done
Date: Mon, 02 Sep 2013 11:06:54 +0800
Message-ID: <522400CE.3020102@redhat.com>
References: <1377836962-49780-1-git-send-email-jasowang@redhat.com>
	<1377836962-49780-6-git-send-email-jasowang@redhat.com>
	<1377881073.2065.10.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1377881073.2065.10.camel@bwh-desktop.uk.level5networks.com>
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

On 08/31/2013 12:44 AM, Ben Hutchings wrote:
> On Fri, 2013-08-30 at 12:29 +0800, Jason Wang wrote:
>> We used to poll vhost queue before making DMA is done, this is racy if vhost
>> thread were waked up before marking DMA is done which can result the signal to
>> be missed. Fix this by always poll the vhost thread before DMA is done.
> Does this bug only exist in net-next or is it older?  Should the fix go
> to net and stable branches?

This should go for the stable branches too (3.4 above).

Thanks for the checking.
>
> Ben.
>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/vhost/net.c |    9 +++++----
>>  1 files changed, 5 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index ff60c2a..d09c17c 100644
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
