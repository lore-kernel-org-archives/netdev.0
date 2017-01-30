From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 1/2] af_packet: direct dma for packet ineterface
Date: Mon, 30 Jan 2017 13:51:55 -0800
Message-ID: <588FB57B.1060507@gmail.com>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
 <20170127213344.14162.59976.stgit@john-Precision-Tower-5810>
 <20170130191607.14d964e4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bjorn.topel@gmail.com, jasowang@redhat.com, ast@fb.com,
        alexander.duyck@gmail.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33812 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752998AbdA3VwP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 16:52:15 -0500
Received: by mail-pf0-f193.google.com with SMTP id y143so24315771pfb.1
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 13:52:15 -0800 (PST)
In-Reply-To: <20170130191607.14d964e4@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-30 10:16 AM, Jesper Dangaard Brouer wrote:
> On Fri, 27 Jan 2017 13:33:44 -0800 John Fastabend <john.fastabend@gmail.com> wrote:
> 
>> This adds ndo ops for upper layer objects to request direct DMA from
>> the network interface into memory "slots". The slots must be DMA'able
>> memory given by a page/offset/size vector in a packet_ring_buffer
>> structure.
>>
>> The PF_PACKET socket interface can use these ndo_ops to do zerocopy
>> RX from the network device into memory mapped userspace memory. For
>> this to work drivers encode the correct descriptor blocks and headers
>> so that existing PF_PACKET applications work without any modification.
>> This only supports the V2 header formats for now. And works by mapping
>> a ring of the network device to these slots. Originally I used V2
>> header formats but this does complicate the driver a bit.
>>
>> V3 header formats added bulk polling via socket calls and timers
>> used in the polling interface to return every n milliseconds. Currently,
>> I don't see any way to support this in hardware because we can't
>> know if the hardware is in the middle of a DMA operation or not
>> on a slot. So when a timer fires I don't know how to advance the
>> descriptor ring leaving empty descriptors similar to how the software
>> ring works. The easiest (best?) route is to simply not support this.
> 
> From a performance pov bulking is essential. Systems like netmap that
> also depend on transferring control between kernel and userspace,
> report[1] that they need at least bulking size 8, to amortize the overhead.
> 

Bulking in general is not a problem it can be done on top of V2 implementation
without issue. Its the poll timer that seemed a bit clumsy to implement.
Looking at it again though I think we could do something if we cared to.
I'm not convinced we would gain much though.

Also v2 uses static buffer sizes so that every buffer is 2k or whatever
size the user configures. V3 allows the buffer size to be updated at
runtime which could be done in the drivers I suppose but would require
some ixgbe restructuring.

> [1] Figure 7, page 10, http://info.iet.unipi.it/~luigi/papers/20120503-netmap-atc12.pdf
> 
> 
>> It might be worth creating a new v4 header that is simple for drivers
>> to support direct DMA ops with. I can imagine using the xdp_buff
>> structure as a header for example. Thoughts?
> 
> Likely, but I would like that we do a measurement based approach.  Lets
> benchmark with this V2 header format, and see how far we are from
> target, and see what lights-up in perf report and if it is something we
> can address.

Yep I'm hoping to get to this sometime this week.

> 
> 
>> The ndo operations and new socket option PACKET_RX_DIRECT work by
>> giving a queue_index to run the direct dma operations over. Once
>> setsockopt returns successfully the indicated queue is mapped
>> directly to the requesting application and can not be used for
>> other purposes. Also any kernel layers such as tc will be bypassed
>> and need to be implemented in the hardware via some other mechanism
>> such as tc offload or other offload interfaces.
> 
> Will this also need to bypass XDP too?

There is nothing stopping this from working with XDP but why would
you want to run XDP here?

Dropping a packet for example is not really useful because its
already in memory user space can read. Modifying the packet seems
pointless user space can modify it. Maybe pushing a copy of the packet
to kernel stack is useful in some case? But I can't see where I would
want this.

> 
> E.g. how will you support XDP_TX?  AFAIK you cannot remove/detach a
> packet with this solution (and place it on a TX queue and wait for DMA
> TX completion).
> 

This is something worth exploring. tpacket_v2 uses a fixed ring with
slots so all the pages are allocated and assigned to the ring at init
time. To xmit a packet in this case the user space application would
be required to leave the packet descriptor on the rx side pinned
until the tx side DMA has completed. Then it can unpin the rx side
and return it to the driver. This works if the TX/RX processing is
fast enough to keep up. For many things this is good enough.

For some work loads though this may not be sufficient. In which
case a tpacket_v4 would be useful that can push down a new set
of "slots" every n packets. Where n is sufficiently large to keep
the workload running. This is similar in many ways to virtio/vhost
interaction.

> 
>> Users steer traffic to the selected queue using flow director,
>> tc offload infrastructure or via macvlan offload.
>>
>> The new socket option added to PF_PACKET is called PACKET_RX_DIRECT.
>> It takes a single unsigned int value specifying the queue index,
>>
>>      setsockopt(sock, SOL_PACKET, PACKET_RX_DIRECT,
>> 		&queue_index, sizeof(queue_index));
>>
>> Implementing busy_poll support will allow userspace to kick the
>> drivers receive routine if needed. This work is TBD.
>>
>> To test this I hacked a hardcoded test into  the tool psock_tpacket
>> in the selftests kernel directory here:
>>
>>      ./tools/testing/selftests/net/psock_tpacket.c
>>
>> Running this tool opens a socket and listens for packets over
>> the PACKET_RX_DIRECT enabled socket. Obviously it needs to be
>> reworked to enable all the older tests and not hardcode my
>> interface before it actually gets released.
>>
>> In general this is a rough patch to explore the interface and
>> put something concrete up for debate. The patch does not handle
>> all the error cases correctly and needs to be cleaned up.
>>
>> Known Limitations (TBD):
>>
>>      (1) Users are required to match the number of rx ring
>>          slots with ethtool to the number requested by the
>>          setsockopt PF_PACKET layout. In the future we could
>>          possibly do this automatically.
>>
>>      (2) Users need to configure Flow director or setup_tc
>>          to steer traffic to the correct queues. I don't believe
>>          this needs to be changed it seems to be a good mechanism
>>          for driving directed dma.
>>
>>      (3) Not supporting timestamps or priv space yet, pushing
>> 	 a v4 packet header would resolve this nicely.
>>
>>      (5) Only RX supported so far. TX already supports direct DMA
>>          interface but uses skbs which is really not needed. In
>>          the TX_RING case we can optimize this path as well.
>>
>> To support TX case we can do a similar "slots" mechanism and
>> kick operation. The kick could be a busy_poll like operation
>> but on the TX side. The flow would be user space loads up
>> n number of slots with packets, kicks tx busy poll bit, the
>> driver sends packets, and finally when xmit is complete
>> clears header bits to give slots back. When we have qdisc
>> bypass set today we already bypass the entire stack so no
>> paticular reason to use skb's in this case. Using xdp_buff
>> as a v4 packet header would also allow us to consolidate
>> driver code.
>>
>> To be done:
>>
>>      (1) More testing and performance analysis
>>      (2) Busy polling sockets
>>      (3) Implement v4 xdp_buff headers for analysis
>>      (4) performance testing :/ hopefully it looks good.
> 
> Guess, I don't understand the details of the af_packet versions well
> enough, but can you explain to me, how userspace knows what slots it
> can read/fetch, and how it marks when it is complete/finished so the
> kernel knows it can reuse this slot?
> 

At init time user space allocates a ring of buffers. Each buffer has
space to hold the packet descriptor + packet payload. The API gives this
to the driver to initialize DMA engine and assign addresses. At init
time all buffers are "owned" by the driver which is indicated by a status bit
in the descriptor header.

Userspace can spin on the status bit to know when the driver has handed
it to userspace. The driver will check the status bit before returning
the buffer to the hardware. Then a series of kicks are used to wake up
userspace (if its not spinning) and to wake up the driver if it is overrun
and needs to return buffers into its pool (not implemented yet). The
kick to wake up the driver could in a future v4 be used to push new
buffers to the driver if needed.

It seems to work reasonably well but the perf numbers will let us know
more.

.John
