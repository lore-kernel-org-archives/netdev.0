From: Jason Wang <jasowang@redhat.com>
Subject: Re: [V2 PATCH 9/9] vhost: zerocopy: poll vq in zerocopy callback
Date: Wed, 16 May 2012 10:58:16 +0800
Message-ID: <4FB317C8.90002@redhat.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>  <20120502034254.11782.27314.stgit@amd-6168-8-1.englab.nay.redhat.com> <1337100630.8220.4.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35433 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753062Ab2EPC61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 22:58:27 -0400
In-Reply-To: <1337100630.8220.4.camel@oc3660625478.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2012 12:50 AM, Shirley Ma wrote:
> On Wed, 2012-05-02 at 11:42 +0800, Jason Wang wrote:
>> We add used and signal guest in worker thread but did not poll the
>> virtqueue
>> during the zero copy callback. This may lead the missing of adding and
>> signalling during zerocopy. Solve this by polling the virtqueue and
>> let it
>> wakeup the worker during callback.
>>
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>> ---
>>   drivers/vhost/vhost.c |    1 +
>>   1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index 947f00d..7b75fdf 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -1604,6 +1604,7 @@ void vhost_zerocopy_callback(void *arg)
>>          struct vhost_ubuf_ref *ubufs = ubuf->arg;
>>          struct vhost_virtqueue *vq = ubufs->vq;
>>
>> +       vhost_poll_queue(&vq->poll);
>>          /* set len = 1 to mark this desc buffers done DMA */
>>          vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
>>          kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
> Doing so, we might have redundant vhost_poll_queue(). Do you know in
> which scenario there might be missing of adding and signaling during
> zerocopy?

Yes, as we only do signaling and adding during tx work, if there's no tx 
work when the skb were sent, we may lose the opportunity to let guest 
know about the completion. It's easy to be reproduced with netperf test.

Thanks
> Thanks
> Shirley
>
