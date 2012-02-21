From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/2] vhost: allow multiple workers threads
Date: Tue, 21 Feb 2012 12:32:44 +0800
Message-ID: <4F431E6C.9080706@redhat.com>
References: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com>	<1329519726-25763-2-git-send-email-aliguori@us.ibm.com>	<20120219144145.GA16620@redhat.com>	<OFC071CE44.FE2F733D-ON862579AA.0055FCA0-862579AA.0057082B@us.ibm.com> <20120220192708.GA18308@redhat.com> <4F42A2FB.7000501@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Tom Lendacky <toml@us.ibm.com>, netdev@vger.kernel.org,
	Cristian Viana <vianac@br.ibm.com>
To: Anthony Liguori <aliguori@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47592 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752629Ab2BUEcw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 23:32:52 -0500
In-Reply-To: <4F42A2FB.7000501@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/21/2012 03:46 AM, Anthony Liguori wrote:
> On 02/20/2012 01:27 PM, Michael S. Tsirkin wrote:
>> On Mon, Feb 20, 2012 at 09:50:37AM -0600, Tom Lendacky wrote:
>>> "Michael S. Tsirkin"<mst@redhat.com>  wrote on 02/19/2012 08:41:45 AM:
>>>
>>>> From: "Michael S. Tsirkin"<mst@redhat.com>
>>>> To: Anthony Liguori/Austin/IBM@IBMUS
>>>> Cc: netdev@vger.kernel.org, Tom Lendacky/Austin/IBM@IBMUS, Cristian
>>>> Viana<vianac@br.ibm.com>
>>>> Date: 02/19/2012 08:42 AM
>>>> Subject: Re: [PATCH 1/2] vhost: allow multiple workers threads
>>>>
>>>> On Fri, Feb 17, 2012 at 05:02:05PM -0600, Anthony Liguori wrote:
>>>>> This patch allows vhost to have multiple worker threads for devices
>>> such as
>>>>> virtio-net which may have multiple virtqueues.
>>>>>
>>>>> Since virtqueues are a lockless ring queue, in an ideal world data is
>>> being
>>>>> produced by the producer as fast as data is being consumed by the
>>> consumer.
>>>>> These loops will continue to consume data until none is left.
>>>>>
>>>>> vhost currently multiplexes the consumer side of the queue on a
>>>> single thread
>>>>> by attempting to read from the queue until everything is read or it
>>> cannot
>>>>> process anymore.  This means that activity on one queue may stall
>>>> another queue.
>>>>
>>>> There's actually an attempt to address this: look up
>>>> VHOST_NET_WEIGHT in the code. I take it, this isn't effective?
>>>>
>>>>> This is exacerbated when using any form of polling to read from
>>>> the queues (as
>>>>> we'll introduce in the next patch).  By spawning a thread per-
>>>> virtqueue, this
>>>>> is addressed.
>>>>>
>>>>> The only problem with this patch right now is how the wake up of
>>>> the threads is
>>>>> done.  It's essentially a broadcast and we have seen lock 
>>>>> contention as
>>> a
>>>>> result.
>>>>
>>>> On which lock?
>>>
>>> The mutex lock in the vhost_virtqueue struct.  This really shows up 
>>> when
>>> running with patch 2/2 and increasing the spin_threshold. Both 
>>> threads wake
>>> up and try to acquire the mutex.  As the spin_threshold increases 
>>> you end
>>> up
>>> with one of the threads getting blocked for a longer and longer time 
>>> and
>>> unable to do any RX processing that might be needed.
>>>
>>> Tom
>>
>> Weird, I had the impression each thread handles one vq.
>> Isn't this the design?
>
> Not the way the code is structured today.  There is a single 
> consumer/producer work queue and either the vq notification or other 
> actions may get placed on it.
>
> It would be possible to do three threads, one for background tasks and 
> then one for each queue with a more invasive refactoring.
>
> But I assumed that the reason the code was structured this was 
> originally was because you saw some value in having a single 
> producer/consumer queue for everything...
>
> Regards,
>
> Anthony Liguori

Not sure I'm reading the code correctly, looks like with this series, 
two worker threads can try to handle the work of a same virtqueue? Looks 
strange as the notification from other side (guest/net) should be 
disabled even if vhost thread is spinning.
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
