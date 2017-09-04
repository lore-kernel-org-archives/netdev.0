From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] vhost_net: correctly check tx avail during rx busy
 polling
Date: Mon, 4 Sep 2017 10:51:46 +0800
Message-ID: <7086b3c9-f81f-1c06-b484-abe0888f7fd5@redhat.com>
References: <1504256570-3488-1-git-send-email-jasowang@redhat.com>
 <20170901184531-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901184531-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月01日 23:51, Michael S. Tsirkin wrote:
> On Fri, Sep 01, 2017 at 05:02:50PM +0800, Jason Wang wrote:
>> We check tx avail through vhost_enable_notify() in the past which is
>> wrong since it only checks whether or not guest has filled more
>> available buffer since last avail idx synchronization which was just
>> done by vhost_vq_avail_empty() before. What we really want is checking
>> pending buffers in the avail ring.
> These are rx buffers, right? I'm not even sure why do we need to poll
> for them. Running out of rx buffers is a slow path.

Actually it polls for tx buffer here. I admit the code (or probably the 
variable name) is confusing here.

>
>> Fix this by calling
>> vhost_vq_avail_empty() instead.
>>
>> This issue could be noticed by doing netperf TCP_RR benchmark as
>> client from guest (but not host). With this fix, TCP_RR from guest to
>> localhost restores from 1375.91 trans per sec to 55235.28 trans per
>> sec on my laptop (Intel(R) Core(TM) i7-5600U CPU @ 2.60GHz).
>>
>> Fixes: 030881372460 ("vhost_net: basic polling support")
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>> - The patch is needed for -stable
>> ---
>>   drivers/vhost/net.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index 06d0448..1b68253 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -634,7 +634,7 @@ static int vhost_net_rx_peek_head_len(struct vhost_net *net, struct sock *sk)
> In fact why does it poll the ring at all? I thought this function's
> job is to poll the socket, isn't it?

Tx notification is disabled to try to avoid vmexits, so we poll tx avail 
buffers too.

>
>
>>   
>>   		preempt_enable();
>>   
>> -		if (vhost_enable_notify(&net->dev, vq))
>> +		if (!vhost_vq_avail_empty(&net->dev, vq))
>>   			vhost_poll_queue(&vq->poll);
>>   		mutex_unlock(&vq->mutex);
>
> Adding more contex:
>
>                  mutex_lock(&vq->mutex);
>                  vhost_disable_notify(&net->dev, vq);
>
>                  preempt_disable();
>                  endtime = busy_clock() + vq->busyloop_timeout;
>
>                  while (vhost_can_busy_poll(&net->dev, endtime) &&
>                         !sk_has_rx_data(sk) &&
>                         vhost_vq_avail_empty(&net->dev, vq))
>                          cpu_relax();
>                  
>                  preempt_enable();
>          
>                  if (vhost_enable_notify(&net->dev, vq))
>                          vhost_poll_queue(&vq->poll);
>                  mutex_unlock(&vq->mutex);
>
>                  len = peek_head_len(rvq, sk);
>
>
> If you drop this we'll exit the function with notifications
> disabled. Seems wrong to me.

Yes, will fix this in V2.

Thanks

>
>>   
>> -- 
>> 2.7.4
