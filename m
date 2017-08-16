From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2 1/3] tap: use build_skb() for small packet
Date: Wed, 16 Aug 2017 12:07:25 +0800
Message-ID: <3b24805d-b489-2dfc-f930-0518ba1a6ea0@redhat.com>
References: <1502451678-17358-1-git-send-email-jasowang@redhat.com>
 <1502451678-17358-2-git-send-email-jasowang@redhat.com>
 <1502855120.4936.89.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170816064951-mutt-send-email-mst@kernel.org>
 <5280f66f-85cf-fa4f-1a1c-7acbac2c9ab7@redhat.com>
 <20170816065837-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kubakici@wp.pl
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170816065837-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年08月16日 11:59, Michael S. Tsirkin wrote:
> On Wed, Aug 16, 2017 at 11:57:51AM +0800, Jason Wang wrote:
>>
>> On 2017年08月16日 11:55, Michael S. Tsirkin wrote:
>>> On Tue, Aug 15, 2017 at 08:45:20PM -0700, Eric Dumazet wrote:
>>>> On Fri, 2017-08-11 at 19:41 +0800, Jason Wang wrote:
>>>>> We use tun_alloc_skb() which calls sock_alloc_send_pskb() to allocate
>>>>> skb in the past. This socket based method is not suitable for high
>>>>> speed userspace like virtualization which usually:
>>>>>
>>>>> - ignore sk_sndbuf (INT_MAX) and expect to receive the packet as fast as
>>>>>     possible
>>>>> - don't want to be block at sendmsg()
>>>>>
>>>>> To eliminate the above overheads, this patch tries to use build_skb()
>>>>> for small packet. We will do this only when the following conditions
>>>>> are all met:
>>>>>
>>>>> - TAP instead of TUN
>>>>> - sk_sndbuf is INT_MAX
>>>>> - caller don't want to be blocked
>>>>> - zerocopy is not used
>>>>> - packet size is smaller enough to use build_skb()
>>>>>
>>>>> Pktgen from guest to host shows ~11% improvement for rx pps of tap:
>>>>>
>>>>> Before: ~1.70Mpps
>>>>> After : ~1.88Mpps
>>>>>
>>>>> What's more important, this makes it possible to implement XDP for tap
>>>>> before creating skbs.
>>>> Well well well.
>>>>
>>>> You do realize that tun_build_skb() is not thread safe ?
>>> The issue is alloc frag, isn't it?
>>> I guess for now we can limit this to XDP mode only, and
>>> just allocate full pages in that mode.
>>>
>>>
>> Limit this to XDP mode only does not prevent user from sending packets to
>> same queue in parallel I think?
>>
>> Thanks
> Yes but then you can just drop the page frag allocator since
> XDP is assumed not to care about truesize for most packets.
>

Ok, let me do some test to see the numbers between the two methods first.

Thanks
