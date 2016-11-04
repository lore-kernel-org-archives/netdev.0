From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Fri, 4 Nov 2016 16:05:51 -0700
Message-ID: <581D144F.8080007@gmail.com>
References: <20161028171812.48073f1f@jkicinski-Precision-T1700>
 <20161028182223.GA53930@ast-mbp.thefacebook.com>
 <ec23c734c23d81884349484927140741@mail.gmail.com>
 <20161029112514.GC1810@pox.localdomain> <20161102152708.5cb40a0c@redhat.com>
 <b09333565b4ead1f90719cfb3643f6af@mail.gmail.com>
 <20161103041145.arylaxxssbdylfwn@redhat.com> <581ADCD1.3040404@gmail.com>
 <20161104002503-mutt-send-email-mst@kernel.org> <581BC852.7010304@gmail.com>
 <20161104022927-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Shrijeet Mukherjee <shm@cumulusnetworks.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Thomas Graf <tgraf@suug.ch>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jakub Kicinski <kubakici@wp.pl>,
        David Miller <davem@davemloft.net>, alexander.duyck@gmail.com,
        shrijeet@gmail.com, tom@herbertland.com, netdev@vger.kernel.org,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        aconole@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35799 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752068AbcKDXGS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 19:06:18 -0400
Received: by mail-pf0-f196.google.com with SMTP id i88so9100554pfk.2
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 16:06:18 -0700 (PDT)
In-Reply-To: <20161104022927-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-03 05:34 PM, Michael S. Tsirkin wrote:
> On Thu, Nov 03, 2016 at 04:29:22PM -0700, John Fastabend wrote:
>> [...]
>>
>>>>> - when XDP is attached disable all LRO using VIRTIO_NET_CTRL_GUEST_OFFLOADS_SET
>>>>>   (not used by driver so far, designed to allow dynamic LRO control with
>>>>>    ethtool)
>>>>
>>>> I see there is a UAPI bit for this but I guess we also need to add
>>>> support to vhost as well? Seems otherwise we may just drop a bunch
>>>> of packets on the floor out of handle_rx() when recvmsg returns larger
>>>> than a page size. Or did I read this wrong...
>>>
>>> It's already supported host side. However you might
>>> get some packets that were in flight when you attached.
>>>
>>
>> Really I must have missed it I don't see any *GUEST_FEATURES* flag in
>> ./drivers/vhost/?
> 
> It's all done by QEMU catching these commands and calling
> ioctls on the tun/macvtap/packet socket.
> 

Well at least for the tap vhost backend in linux that I found here,

 ./qemu/net/tap-linux.c

there is no LRO feature flag but that is OK I can get it working next
week looks fairly straight forward.

[...]

>> And if I try to merge the last email I sent out here. In mergeable and
>> big_packets modes if LRO is off and MTU < PAGE_SIZE it seems we should
>> always get physically contiguous data on a single page correct?
> 
> Unfortunately not in the mergeable buffer case according to spec, even though
> linux hosts will do that, so it's fine to optimize for that
> but need to somehow work in other cases e.g. by doing a data copy.
> 

ah OK this makes sense I was looking at vhost implementation in Linux.

> 
>> It
>> may be at some offset in a page however. But the offset should not
>> matter to XDP. If I read this right we wouldn't need to add a new
>> XDP mode and could just use the existing merge or big modes. This would
>> seem cleaner to me than adding a new mode and requiring a qemu option.
>>
>> Thanks for all the pointers by the way its very helpful.
> 
> So for mergeable we spend cycles trying to make buffers as small
> as possible and I have a patch to avoid copies for that too,
> I'll post it next week hopefully.
> 

Good to know. I'll get the XDP stuff wrapped up next week or see
if Srijeet wants to do it.

Thanks,
John
