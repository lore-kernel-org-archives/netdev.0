From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/3] tuntap: rx batching
Date: Tue, 15 Nov 2016 16:08:52 +0800
Message-ID: <4eb99b34-29a5-fb67-a484-c345e9a2513d@redhat.com>
References: <1478677113-13126-1-git-send-email-jasowang@redhat.com>
 <20161109183259-mutt-send-email-mst@kernel.org>
 <c6cd619f-b9a6-784d-2c44-6106e64f5664@redhat.com>
 <20161111053048-mutt-send-email-mst@kernel.org> <58254654.4000501@gmail.com>
 <2b357b06-f749-5897-f882-aa3121e49e89@redhat.com>
 <20161111181754-mutt-send-email-mst@kernel.org>
 <39c36d36-9029-5d1f-496f-6ff404c3b77a@redhat.com>
 <20161115053435-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115053435-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016年11月15日 11:41, Michael S. Tsirkin wrote:
> On Tue, Nov 15, 2016 at 11:14:48AM +0800, Jason Wang wrote:
>> >
>> >
>> >On 2016年11月12日 00:20, Michael S. Tsirkin wrote:
>>> > >On Fri, Nov 11, 2016 at 12:28:38PM +0800, Jason Wang wrote:
>>>> > > >
>>>> > > >On 2016年11月11日 12:17, John Fastabend wrote:
>>>>> > > > >On 16-11-10 07:31 PM, Michael S. Tsirkin wrote:
>>>>>>> > > > > > >On Fri, Nov 11, 2016 at 10:07:44AM +0800, Jason Wang wrote:
>>>>>>>>> > > > > > > > >
>>>>>>>>> > > > > > > > >On 2016年11月10日 00:38, Michael S. Tsirkin wrote:
>>>>>>>>>>> > > > > > > > > > >On Wed, Nov 09, 2016 at 03:38:31PM +0800, Jason Wang wrote:
>>>>>>>>>>>>> > > > > > > > > > > > >Backlog were used for tuntap rx, but it can only process 1 packet at
>>>>>>>>>>>>> > > > > > > > > > > > >one time since it was scheduled during sendmsg() synchronously in
>>>>>>>>>>>>> > > > > > > > > > > > >process context. This lead bad cache utilization so this patch tries
>>>>>>>>>>>>> > > > > > > > > > > > >to do some batching before call rx NAPI. This is done through:
>>>>>>>>>>>>> > > > > > > > > > > > >
>>>>>>>>>>>>> > > > > > > > > > > > >- accept MSG_MORE as a hint from sendmsg() caller, if it was set,
>>>>>>>>>>>>> > > > > > > > > > > > >     batch the packet temporarily in a linked list and submit them all
>>>>>>>>>>>>> > > > > > > > > > > > >     once MSG_MORE were cleared.
>>>>>>>>>>>>> > > > > > > > > > > > >- implement a tuntap specific NAPI handler for processing this kind of
>>>>>>>>>>>>> > > > > > > > > > > > >     possible batching. (This could be done by extending backlog to
>>>>>>>>>>>>> > > > > > > > > > > > >     support skb like, but using a tun specific one looks cleaner and
>>>>>>>>>>>>> > > > > > > > > > > > >     easier for future extension).
>>>>>>>>>>>>> > > > > > > > > > > > >
>>>>>>>>>>>>> > > > > > > > > > > > >Signed-off-by: Jason Wang<jasowang@redhat.com>
>>>>>>>>>>> > > > > > > > > > >So why do we need an extra queue?
>>>>>>>>> > > > > > > > >The idea was borrowed from backlog to allow some kind of bulking and avoid
>>>>>>>>> > > > > > > > >spinlock on each dequeuing.
>>>>>>>>> > > > > > > > >
>>>>>>>>>>> > > > > > > > > > >    This is not what hardware devices do.
>>>>>>>>>>> > > > > > > > > > >How about adding the packet to queue unconditionally, deferring
>>>>>>>>>>> > > > > > > > > > >signalling until we get sendmsg without MSG_MORE?
>>>>>>>>> > > > > > > > >Then you need touch spinlock when dequeuing each packet.
>>>>> > > > >Random thought, I have a cmpxchg ring I am using for the qdisc work that
>>>>> > > > >could possibly replace the spinlock implementation. I haven't figured
>>>>> > > > >out the resizing API yet because I did not need it but I assume it could
>>>>> > > > >help here and let you dequeue multiple skbs in one operation.
>>>>> > > > >
>>>>> > > > >I can post the latest version if useful or an older version is
>>>>> > > > >somewhere on patchworks as well.
>>>>> > > > >
>>>>> > > > >.John
>>>>> > > > >
>>>>> > > > >
>>>> > > >Look useful here, and I can compare the performance if you post.
>>>> > > >
>>>> > > >A question is can we extend the skb_array to support that?
>>>> > > >
>>>> > > >Thanks
>>> > >I'd like to start with simple patch adding napi with one queue, then add
>>> > >optimization patches on top.
>> >
>> >The point is tun is using backlog who uses two queues (process_queue and
>> >input_pkt_queue).
>> >
>> >How about something like:
>> >
>> >1) NAPI support with skb_array
> I would start with just write queue linked list. It all runs on a single
> CPU normally,

True for virt but I'm not sure the others. If we have multiple senders 
at the same time, current code scales very well.

>   so the nice reductions of cache line bounces due to skb
> array should never materialize.
>
> While we are at it, limiting the size of the queue might
> be a good idea. Kind of like TUNSETSNDBUF but 1. actually
> working where instead of tracking packets within net stack
> we make sndbuf track the internal buffer

Get your point, will start from simple skb list.

Thanks
