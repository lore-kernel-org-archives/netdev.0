From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2] net-tun: restructure tun_do_read for better sleep/wakeup
 efficiency
Date: Wed, 21 May 2014 12:45:06 +0800
Message-ID: <537C2F52.5090901@redhat.com>
References: <1400278308-25372-1-git-send-email-xii@google.com>			 <5379CE8D.2030405@redhat.com>		 <1400508587.5367.37.camel@edumazet-glaptop2.roam.corp.google.com>		 <537ADD91.4000609@redhat.com>	 <1400562668.5367.96.camel@edumazet-glaptop2.roam.corp.google.com>	 <537AF036.7010005@redhat.com> <1400594349.5367.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Xi Wang <xii@google.com>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbaEUEpU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 00:45:20 -0400
In-Reply-To: <1400594349.5367.114.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2014 09:59 PM, Eric Dumazet wrote:
> On Tue, 2014-05-20 at 14:03 +0800, Jason Wang wrote:
>> On 05/20/2014 01:11 PM, Eric Dumazet wrote:
>>> On Tue, 2014-05-20 at 12:44 +0800, Jason Wang wrote:
>>>> On 05/19/2014 10:09 PM, Eric Dumazet wrote:
>>>>> About the sk_data_ready() and wake_up_all(), you missed the whole part
>>>>> of the patch I think.
>>>>>
>>>>> Check how sock_def_readable() does everything properly and efficiently,
>>>>> including the async part.
>>>> But this changes (sk_data_ready()) has nothing related to switching to
>>>> use __skb_recv_datagram()
>>>>
>>> This is totally related.
>>>
>>> I think you did not yet understood this patch
>> Sorry for being unclear, but I think you misunderstand my meaning.
>>> Compare wake_up_all() and sk_data_ready() speeds, you'll be surprised.
>>>
>>> You should ask to yourself : Why do we use wq_has_sleeper() in
>>> networking stacks ?
>> See my first reply, I don't have objection that uses sk_data_ready() in
>> tun_net_xmit(). My only concern is using sk_data_ready() in
>> tun_detach_all():
>>
>> - It was only called during tun destroying, so I believe we don't care
>> about the performance in this condition.
> Its there for symmetry, and so far our tests just work.
>
> Have you run into any problems ?

Nope, I tested this patch and it works well.
>> - sk_data_ready() was usually called when there's something new to be
>> processed which is not case in tun_detach_all()
> sk_data_ready() will wakeup waiters exactly like wake_up_all()
>
> We do not use wake_up_all() in net/ipv4 & net/ipv6, have you seen any
> bug because of this ?
>
> wake_up_all() is a lazy call, when an author cannot be careful enough to
> use a better way.

I haven't. I thought there should be some reason that the author use
wake_up_all() here. But I'm now convinced that it's safe to do the change.
>
> Your resistance shows that you think the _existing_ code might be racy.
>
> Care to elaborate instead ?

I'm asking since I want to make sure nothing breaks and I think some of
changes are unrelated.
>> - Not sure it was a problem but sock_def_readable() will not wake up
>> uninterruptible task during tun destroying.
> Thats irrelevant. We are supposed to unblock threads that are waiting on
> the tun device, not threads doing uninterruptible stuff somewhere else
> in the kernel.
>
> Eventually they will later reach tun device and will detect device is
> gone/dismantled.

Ok.
>
>> - If we make sock_fasync() works for tun in the future, it may send
>> SIGIO to user process during tun destroying which is not expected.
> SOCK_FASYNC is not set on the tun socket.
>
> sk_wake_async() does nothing in this case. As for 99.9999 % of TCP
> sockets and nobody ever noticed this code path was almost dead.
>
>

I see and thanks for your time. I don't have concern with this patch any
more.
