From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH] net: virtio: cap mtu when XDP programs are running
Date: Mon, 9 Jan 2017 19:30:34 -0800
Message-ID: <5874555A.3070307@gmail.com>
References: <586BD5D5.6020100@gmail.com>
 <1caf1ffc-0f46-067e-0f0d-a93b408b4ffd@redhat.com>
 <586D458F.5050705@gmail.com>
 <068f0116-b37e-eb44-8c60-1781a9d5255e@redhat.com>
 <20170110010531-mutt-send-email-mst@kernel.org> <5874190B.9050505@gmail.com>
 <20170110012044-mutt-send-email-mst@kernel.org> <58742187.8050505@gmail.com>
 <20170110015759-mutt-send-email-mst@kernel.org>
 <9102bb4b-223a-d441-7546-8b4144d970fb@redhat.com>
 <20170110044910-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36694 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932463AbdAJDbD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 22:31:03 -0500
Received: by mail-pf0-f195.google.com with SMTP id b22so10189816pfd.3
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 19:31:03 -0800 (PST)
In-Reply-To: <20170110044910-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-09 06:51 PM, Michael S. Tsirkin wrote:
> On Tue, Jan 10, 2017 at 10:29:39AM +0800, Jason Wang wrote:
>>
>>
>> On 2017年01月10日 07:58, Michael S. Tsirkin wrote:
>>> On Mon, Jan 09, 2017 at 03:49:27PM -0800, John Fastabend wrote:
>>>> On 17-01-09 03:24 PM, Michael S. Tsirkin wrote:
>>>>> On Mon, Jan 09, 2017 at 03:13:15PM -0800, John Fastabend wrote:
>>>>>> On 17-01-09 03:05 PM, Michael S. Tsirkin wrote:
>>>>>>> On Thu, Jan 05, 2017 at 11:09:14AM +0800, Jason Wang wrote:
>>>>>>>> On 2017年01月05日 02:57, John Fastabend wrote:
>>>>>>>>> [...]
>>>>>>>>>
>>>>>>>>>> On 2017年01月04日 00:48, John Fastabend wrote:
>>>>>>>>>>> On 17-01-02 10:14 PM, Jason Wang wrote:
>>>>>>>>>>>> On 2017年01月03日 06:30, John Fastabend wrote:
>>>>>>>>>>>>> XDP programs can not consume multiple pages so we cap the MTU to
>>>>>>>>>>>>> avoid this case. Virtio-net however only checks the MTU at XDP
>>>>>>>>>>>>> program load and does not block MTU changes after the program
>>>>>>>>>>>>> has loaded.
>>>>>>>>>>>>>
>>>>>>>>>>>>> This patch sets/clears the max_mtu value at XDP load/unload time.
>>>>>>>>>>>>>
>>>>>>>>>>>>> Signed-off-by: John Fastabend<john.r.fastabend@intel.com>
>>>>>>>>>>>>> ---
>>>>>>>>> [...]
>>>>>>>>>
>>>>>>>>>>> OK so this logic is a bit too simply. When it resets the max_mtu I guess it
>>>>>>>>>>> needs to read the mtu via
>>>>>>>>>>>
>>>>>>>>>>>       virtio_cread16(vdev, ...)
>>>>>>>>>>>
>>>>>>>>>>> or we may break the negotiated mtu.
>>>>>>>>>> Yes, this is a problem (even use ETH_MAX_MTU). We may need a method to notify
>>>>>>>>>> the device about the mtu in this case which is not supported by virtio now.
>>>>>>>>> Note this is not really a XDP specific problem. The guest can change the MTU
>>>>>>>>> after init time even without XDP which I assume should ideally result in a
>>>>>>>>> notification if the MTU is negotiated.
>>>>>>>> Yes, Michael, do you think we need add some mechanism to notify host about
>>>>>>>> MTU change in this case?
>>>>>>>>
>>>>>>>> Thanks
>>>>>>> Why does host care?
>>>>>>>
>>>>>> Well the guest will drop packets after mtu has been reduced.
>>>>> I didn't know. What place in code does this?
>>>>>
>>>> hmm in many of the drivers it is convention to use the mtu to set the rx
>>>> buffer sizes and a receive side max length filter. For example in the Intel
>>>> drivers if a packet with length greater than MTU + some headroom is received we
>>>> drop it. I guess in the networking stack RX path though nothing forces this and
>>>> virtio doesn't have any code to drop packets on rx size.
>>>>
>>>> In virtio I don't see any existing case currently. In the XDP case though we
>>>> need to ensure packets fit in a page for the time being which is why I was
>>>> looking at this code and generated this patch.
>>> I'd say just look at the hardware max mtu. Ignore the configured mtu.
>>>
>>>
>>
>> Does this work for small buffers consider it always allocate skb with size
>> of GOOD_PACKET_LEN?
> 
> Spec says hardware won't send in packets > max mtu in config space.
> 
>> I think in any case, we should limit max_mtu to
>> GOOD_PACKET_LEN for small buffers.
>>
>> Thanks
> 
> XDP seems to have a bunch of weird restrictions, I just
> do not like it that the logic spills out to all drivers.
> What if someone decides to extend it to two pages in the future?
> Recode it all in all drivers ...
> 
> Why can't net core enforce mtu?
> 

OK I agree I'll put most the logic in rtnetlink.c when the program is added
or removed.

But, I'm looking at the non-XDP receive_small path now and wondering how does
multiple buffer receives work (e.g. packet larger than GOOD_PACKET_LEN?) I think
this is what Jason is looking at as well? The mergeable case clearly looks at
num_bufs in the descriptor to construct multi-buffer packets but nothing like
that exists in the small_receive path as best I can tell.

.John
