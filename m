From: Jason Wang <jasowang@redhat.com>
Subject: Re: [V2 PATCH 9/9] vhost: zerocopy: poll vq in zerocopy callback
Date: Wed, 23 May 2012 18:31:36 +0800
Message-ID: <4FBCBC88.70707@redhat.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>  <20120502034254.11782.27314.stgit@amd-6168-8-1.englab.nay.redhat.com>  <1337100630.8220.4.camel@oc3660625478.ibm.com> <4FB317C8.90002@redhat.com>  <1337181027.10741.13.camel@oc3660625478.ibm.com>  <20120516151444.GC9934@redhat.com>  <1337189525.10741.24.camel@oc3660625478.ibm.com>  <4FB4677A.8020402@redhat.com>  <1337268862.10741.58.camel@oc3660625478.ibm.com>  <4FB61D57.4030103@redhat.com>  <1337354974.12999.12.camel@oc3660625478.ibm.com>  <4FB9DB24.2040408@redhat.com>  <1337614972.12999.56.camel@oc3660625478.ibm.com>  <4FBB64F7.5090801@redhat.com> <1337702145.11592.3.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747Ab2EWKaO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2012 06:30:14 -0400
In-Reply-To: <1337702145.11592.3.camel@oc3660625478.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2012 11:55 PM, Shirley Ma wrote:
> On Tue, 2012-05-22 at 18:05 +0800, Jason Wang wrote:
>> On 05/21/2012 11:42 PM, Shirley Ma wrote:
>>> On Mon, 2012-05-21 at 14:05 +0800, Jason Wang wrote:
>>>>>> - tx polling depends on skb_orphan() which is often called by
>>>> device
>>>>>> driver when it place the packet into the queue of the devices
>>>> instead
>>>>>> of  when the packets were sent. So it was too early for vhost to
>> be
>>>>>> notified.
>>>>> Then do you think it's better to replace with vhost_poll_queue
>> here
>>>>> instead?
>>>> Just like what does this patch do - calling vhost_poll_queue() in
>>>> vhost_zerocopy_callback().
>>>>>> - it only works when the pending DMAs exceeds VHOST_MAX_PEND,
>> it's
>>>>>> highly possible that guest needs to be notified when the pending
>>>>>> packets
>>>>>> isn't so much.
>>>>> In which situation the guest needs to be notified when there is no
>>>> TX
>>>>> besides buffers run out?
>>>> Consider guest call virtqueue_enable_cb_delayed() which means it
>> only
>>>> need to be notified when 3/4 of pending buffers ( about 178 buffers
>>>> (256-MAX_SKB_FRAGS-2)*3/4 ) were sent by host. So vhost_net would
>>>> notify
>>>> guest when about 60 buffers were pending. Since tx polling is only
>>>> enabled when pending packets exceeds VHOST_MAX_PEND 128, so tx work
>>>> would not be notified to run and guest would never get the
>> interrupt
>>>> it
>>>> expected to re-enable the queue.
>>> So it seems we still need vhost_enable_notify() in handle_tx when
>> there
>>> is no tx in zerocopy case.
>>>
>>> Do you know which one is more expensive: the cost of
>> vhost_poll_queue()
>>> in each zerocopy callback or calling vhost_enable_notify()?
>> Didn't follow here, do you mean vhost_signal() here?
> I meant removing the code in handle_tx for zerocopy as below:
>
> +	if (zcopy) {
>                          /* If more outstanding DMAs, queue the work.
>                           * Handle upend_idx wrap around
>                           */
>                          num_pends = likely(vq->upend_idx>= vq->done_idx) ?
>                                      (vq->upend_idx - vq->done_idx) :
>                                      (vq->upend_idx + UIO_MAXIOV - vq->done_idx);
> +			/* zerocopy vhost_enable_notify is under zerocopy callback
> +			 * since it could be too early to notify here */
> +			break;
> +	}
> -                       if (unlikely(num_pends>  VHOST_MAX_PEND)) {
> -                                tx_poll_start(net, sock);
> -                                set_bit(SOCK_ASYNC_NOSPACE,&sock->flags);
> -                                break;
> -                        }
>                          if (unlikely(vhost_enable_notify(&net->dev, vq))) {
>                                  vhost_disable_notify(&net->dev, vq);
>                                  continue;
>                          }
>                          break;

Didn't think this can work well as the notification from guest were 
disabled forever.

>
> Thanks
> Shirley
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
