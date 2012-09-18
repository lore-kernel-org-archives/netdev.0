From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net] e1000: Small packets may get corrupted during padding by
 HW
Date: Mon, 17 Sep 2012 20:01:06 -0700
Message-ID: <5057E3F2.5090504@gmail.com>
References: <1347740217-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>  <CAHXqBFJZnGUSUutN=L-_LpCN7dXLPFY0ndJnQJ10NCcbzPVLww@mail.gmail.com>  <061C8A8601E8EE4CA8D8FD6990CEA89130DC20AA@ORSMSX102.amr.corp.intel.com>  <50552FF1.5030708@intel.com>  <061C8A8601E8EE4CA8D8FD6990CEA89130DC3631@ORSMSX102.amr.corp.intel.com>  <1347868702.26523.79.camel@edumazet-glaptop>  <50578DE4.7080806@intel.com> <1347915723.26523.179.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Michal Miroslaw <mirqus@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:38120 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121Ab2IRDBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 23:01:16 -0400
Received: by obbuo13 with SMTP id uo13so9875745obb.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 20:01:15 -0700 (PDT)
In-Reply-To: <1347915723.26523.179.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/17/2012 2:02 PM, Eric Dumazet wrote:
> On Mon, 2012-09-17 at 13:53 -0700, Alexander Duyck wrote:
>> On 09/17/2012 12:58 AM, Eric Dumazet wrote:
>>> On Mon, 2012-09-17 at 07:33 +0000, Dave, Tushar N wrote:
>>>>> -----Original Message-----
>>>>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>>>>> On Behalf Of John Fastabend
>>>>> Also wouldn't you want an unlikely() in your patch?
>>>> No because it is quite normal to have packet < ETH_ZLEN. e.g. ARP packets.
>>> ARP packets ? Hardly a performance problem.
>>>
>>> Or make sure all these packets have enough tailroom, or else you are
>>> going to hit the cost of reallocating packets.
>>>
>>> I would better point TCP pure ACK packets, since their size can be 54
>>> bytes.
>>>
>>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>>> index cfe6ffe..aefc681 100644
>>> --- a/net/ipv4/tcp_output.c
>>> +++ b/net/ipv4/tcp_output.c
>>> @@ -3083,8 +3083,9 @@ void tcp_send_ack(struct sock *sk)
>>>   	/* We are not putting this on the write queue, so
>>>   	 * tcp_transmit_skb() will set the ownership to this
>>>   	 * sock.
>>> +	 * Add 64 bytes of tailroom so that some drivers can use skb_pad()
>>>   	 */
>>> -	buff = alloc_skb(MAX_TCP_HEADER, sk_gfp_atomic(sk, GFP_ATOMIC));
>>> +	buff = alloc_skb(MAX_TCP_HEADER + 64, sk_gfp_atomic(sk, GFP_ATOMIC));
>>>   	if (buff == NULL) {
>>>   		inet_csk_schedule_ack(sk);
>>>   		inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
>> For most systems that extra padding should already be added since
>> alloc_skb will cache line align the buffer anyway.
>>
> Please define 'most systems' ?

Sorry I misspoke.  What I meant to say is that the allocation will be 
aligned to a slab size.  If you take a look at alloc_skb it looks like 
it is still using __alloc_skb so it is going to add skb_shared_info to 
the size so at least in the case of most 64 bit systems the total 
allocation size is going to be larger than 512 and as a result skb->head 
will be allocated from a 1K slab cache leaving plenty of room for 
padding to be added later.  On 32 bit systems the total size will likely 
be a little over 256 and get rounded up to 512.

The only real thing that bugged me about this is that you were adding 64 
when the most you should ever need is 10.  That was the only real reason 
I felt like commenting on it.

>> A more general fix might be to make it so that alloc_skb cannot allocate
>> less than 60 byte buffers on systems with a cache line size smaller than
>> 64 bytes.
> Nope, because we do a skb_reserve(skb, MAX_TCP_HEADER)
>
> So we might have no bytes available at all after this MAX_TCP_HEADER
> area.
>
> Relying on extra padding in alloc_skb() is hacky anyway, as it
> depends on external factors (external to TCP stack)

That is true, but the fact is there is probably a fair amount of that 
going on without people even realizing it.  As I recall the smallest skb 
head you can allocate  on a 64 bit system currently is something like 
128 bytes which comes from the 512 byte slab, the next step up after 
that is a 640 byte head.  Since MAX_TCP_HEADER starts at 160 the 
likelihood of it not getting at least 16 bytes of padding is pretty low.

Thanks,

Alex
