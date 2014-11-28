From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH rfc] packet: zerocopy packet_snd
Date: Fri, 28 Nov 2014 06:29:19 +0008
Message-ID: <1417155679.3268.0@smtp.corp.redhat.com>
References: <1416602694-7540-1-git-send-email-willemb@google.com>
	<20141126182445.GA15744@redhat.com>
	<CA+FuTSdYB4rDMH3gAAMwaRdbqN58f_SxLz=C3fcCACw_KosGXw@mail.gmail.com>
	<20141126211748.GA11904@redhat.com>
	<1417079412.18179.3@smtp.corp.redhat.com>
	<20141127104445.GA8961@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: Willem de Bruijn <willemb@google.com>,
	Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58478 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902AbaK1GVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2014 01:21:34 -0500
In-Reply-To: <20141127104445.GA8961@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, Nov 27, 2014 at 6:44 PM, Michael S. Tsirkin <mst@redhat.com> 
wrote:
> On Thu, Nov 27, 2014 at 09:18:12AM +0008, Jason Wang wrote:
>>  
>>  
>>  On Thu, Nov 27, 2014 at 5:17 AM, Michael S. Tsirkin 
>> <mst@redhat.com> wrote:
>>  >On Wed, Nov 26, 2014 at 02:59:34PM -0500, Willem de Bruijn wrote:
>>  >> > The main problem with zero copy ATM is with queueing 
>> disciplines
>>  >> > which might keep the socket around essentially forever.
>>  >> > The case was described here:
>>  >> > https://lkml.org/lkml/2014/1/17/105
>>  >> > and of course this will make it more serious now that
>>  >> > more applications will be able to do this, so
>>  >> > chances that an administrator enables this
>>  >> > are higher.
>>  >> The denial of service issue raised there, that a single queue can
>>  >> block an entire virtio-net device, is less problematic in the 
>> case of
>>  >> packet sockets. A socket can run out of sk_wmem_alloc, but a 
>> prudent
>>  >> application can increase the limit or use separate sockets for
>>  >> separate flows.
>>  >
>>  >Socket per flow? Maybe just use TCP then?  increasing the limit
>>  >sounds like a wrong solution, it hurts security.
>>  >
>>  >> > One possible solution is some kind of timer orphaning frags
>>  >> > for skbs that have been around for too long.
>>  >>   Perhaps this can be approximated without an explicit timer by 
>> calling
>>  >> skb_copy_ubufs on enqueue whenever qlen exceeds a threshold 
>> value?
>>  >
>>  >Hard to say. Will have to see that patch to judge how robust this 
>> is.
>>  
>>  This could not work, consider if the threshold is greater than 
>> vring size
>>  or vhost_net pending limit, transmission may still be blocked.
> 
> Well, application can e.g. just switch to non zero copy after
> reaching a specific number of requests.

Yes but only works if user are ok for out of order completion.
> 
> I think the real problem isn't reaching the queue full
> condition, it's the fact a specific buffer might never
> get freed. This API isn't half as useful as it could be
> if applications had a way to force the memory
> to be reclaimed.
> 

Agree. 
> 
> And actually, I see a way for applications to reclaim the memory:
> application could invoke something like MADV_SOFT_OFFLINE on the 
> memory
> submitted for zero copy transmit, to invalidate PTEs, and make next
> access fault new pages in.
> If dedicated memory is used for packets, you could even use
> MADV_DONTNEED - but this doesn't work in many cases, certainly
> not for virtualization type workloads.
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

Doing such in hypervisor seems better. It could reduce the possible
guest triggered behavior. 

But this just can fix the transmission stuck in guest, host socket
still need to wait for the packet to be sent by host?
> 
> 
> With this idea, if application merely reads memory, we incur a lot of
> overhead with pagefaults. So maybe a new call to enable COW for a 
> range
> of pages would be a good idea.
> 

Not very clear, doesn't COW still depends on pagefault to work?
> 
> We'd have to make sure whatever's used for reclaim works for
> a wide range of memory types: mmap-ed file, hugetlbfs, anonymous 
> memory.
> 
> 
> Thoughts?
> 
> -- 
> MST
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
