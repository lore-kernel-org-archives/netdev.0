From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/3] tuntap: rx batching
Date: Fri, 11 Nov 2016 10:07:44 +0800
Message-ID: <c6cd619f-b9a6-784d-2c44-6106e64f5664@redhat.com>
References: <1478677113-13126-1-git-send-email-jasowang@redhat.com>
 <20161109183259-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51824 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964913AbcKKCHs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 21:07:48 -0500
In-Reply-To: <20161109183259-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016年11月10日 00:38, Michael S. Tsirkin wrote:
> On Wed, Nov 09, 2016 at 03:38:31PM +0800, Jason Wang wrote:
>> Backlog were used for tuntap rx, but it can only process 1 packet at
>> one time since it was scheduled during sendmsg() synchronously in
>> process context. This lead bad cache utilization so this patch tries
>> to do some batching before call rx NAPI. This is done through:
>>
>> - accept MSG_MORE as a hint from sendmsg() caller, if it was set,
>>    batch the packet temporarily in a linked list and submit them all
>>    once MSG_MORE were cleared.
>> - implement a tuntap specific NAPI handler for processing this kind of
>>    possible batching. (This could be done by extending backlog to
>>    support skb like, but using a tun specific one looks cleaner and
>>    easier for future extension).
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> So why do we need an extra queue?

The idea was borrowed from backlog to allow some kind of bulking and 
avoid spinlock on each dequeuing.

>   This is not what hardware devices do.
> How about adding the packet to queue unconditionally, deferring
> signalling until we get sendmsg without MSG_MORE?

Then you need touch spinlock when dequeuing each packet.

>
>
>> ---
>>   drivers/net/tun.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
>>   1 file changed, 65 insertions(+), 6 deletions(-)
>>

[...]

>>   	rxhash = skb_get_hash(skb);
>> -	netif_rx_ni(skb);
>> +	skb_queue_tail(&tfile->socket.sk->sk_write_queue, skb);
>> +
>> +	if (!more) {
>> +		local_bh_disable();
>> +		napi_schedule(&tfile->napi);
>> +		local_bh_enable();
> Why do we need to disable bh here? I thought napi_schedule can
> be called from any context.

Yes, it's unnecessary. Will remove.

Thanks
