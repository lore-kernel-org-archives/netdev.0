From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH rfc] packet: zerocopy packet_snd
Date: Thu, 27 Nov 2014 19:39:47 -0500
Message-ID: <CA+FuTSdp7k_vcpZ_0GGM0teg80-UAh0dB0u=6HF90MZ=FCjOCA@mail.gmail.com>
References: <1416602694-7540-1-git-send-email-willemb@google.com>
 <20141126182445.GA15744@redhat.com> <CA+FuTSdYB4rDMH3gAAMwaRdbqN58f_SxLz=C3fcCACw_KosGXw@mail.gmail.com>
 <20141126211748.GA11904@redhat.com> <1417079412.18179.3@smtp.corp.redhat.com> <20141127104445.GA8961@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jason Wang <jasowang@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:41837 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbaK1AkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 19:40:18 -0500
Received: by mail-qc0-f177.google.com with SMTP id x3so4146672qcv.22
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 16:40:17 -0800 (PST)
In-Reply-To: <20141127104445.GA8961@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 27, 2014 at 5:44 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Thu, Nov 27, 2014 at 09:18:12AM +0008, Jason Wang wrote:
>>
>>
>> On Thu, Nov 27, 2014 at 5:17 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>> >On Wed, Nov 26, 2014 at 02:59:34PM -0500, Willem de Bruijn wrote:
>> >> > The main problem with zero copy ATM is with queueing disciplines
>> >> > which might keep the socket around essentially forever.
>> >> > The case was described here:
>> >> > https://lkml.org/lkml/2014/1/17/105
>> >> > and of course this will make it more serious now that
>> >> > more applications will be able to do this, so
>> >> > chances that an administrator enables this
>> >> > are higher.
>> >> The denial of service issue raised there, that a single queue can
>> >> block an entire virtio-net device, is less problematic in the case of
>> >> packet sockets. A socket can run out of sk_wmem_alloc, but a prudent
>> >> application can increase the limit or use separate sockets for
>> >> separate flows.
>> >
>> >Socket per flow? Maybe just use TCP then?  increasing the limit
>> >sounds like a wrong solution, it hurts security.
>> >
>> >> > One possible solution is some kind of timer orphaning frags
>> >> > for skbs that have been around for too long.
>> >>   Perhaps this can be approximated without an explicit timer by calling
>> >> skb_copy_ubufs on enqueue whenever qlen exceeds a threshold value?
>> >
>> >Hard to say. Will have to see that patch to judge how robust this is.
>>
>> This could not work, consider if the threshold is greater than vring size
>> or vhost_net pending limit, transmission may still be blocked.
>
>
> Well, application can e.g. just switch to non zero copy after
> reaching a specific number of requests.
> I think the real problem isn't reaching the queue full
> condition, it's the fact a specific buffer might never
> get freed. This API isn't half as useful as it could be
> if applications had a way to force the memory
> to be reclaimed.
>
>
> And actually, I see a way for applications to reclaim the memory:
> application could invoke something like MADV_SOFT_OFFLINE on the memory
> submitted for zero copy transmit, to invalidate PTEs, and make next
> access fault new pages in.
> If dedicated memory is used for packets, you could even use
> MADV_DONTNEED - but this doesn't work in many cases, certainly
> not for virtualization type workloads.

Why not?

>
>
> Playting with PTEs needs to invalidate the TLB so it is not fast,
> but it does not need to be: we are talking about ability to close the
> socket, which should be rare.
>
> For example, an application/hypervisor can detect a timeout when a
> packet is not transmitted within a predefined time period, and trigger
> such reclaim.
> Making this period shorter than network watchdog timer of the VM
> will ensure that watchdog does not trigger within VM.
> Alternatively, VM network watchdog could trigger this reclaim
> in order to recover packet memory.
>
> With this idea, if application merely reads memory, we incur a lot of
> overhead with pagefaults. So maybe a new call to enable COW for a range
> of pages would be a good idea.
>
>
> We'd have to make sure whatever's used for reclaim works for
> a wide range of memory types: mmap-ed file, hugetlbfs, anonymous memory.
>
>
> Thoughts?

Very nice. When exactly are these madvise hints preferable over munmap?

> --
> MST
