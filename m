From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Sat, 3 Dec 2016 11:48:22 -0800
Message-ID: <58432186.20006@gmail.com>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161202182233.7d78459f@redhat.com>
 <CAF=yD-+Wx9Pkt55-dUU6dYM7P==kQoKE4YXKoFSq1yi7rY5rDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34106 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750916AbcLCTse (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 14:48:34 -0500
Received: by mail-pg0-f65.google.com with SMTP id e9so11492300pgc.1
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 11:48:33 -0800 (PST)
In-Reply-To: <CAF=yD-+Wx9Pkt55-dUU6dYM7P==kQoKE4YXKoFSq1yi7rY5rDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-03 08:19 AM, Willem de Bruijn wrote:
> On Fri, Dec 2, 2016 at 12:22 PM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
>>
>> On Thu, 1 Dec 2016 10:11:08 +0100 Florian Westphal <fw@strlen.de> wrote:
>>
>>> In light of DPDKs existence it make a lot more sense to me to provide
>>> a). a faster mmap based interface (possibly AF_PACKET based) that allows
>>> to map nic directly into userspace, detaching tx/rx queue from kernel.
>>>
>>> John Fastabend sent something like this last year as a proof of
>>> concept, iirc it was rejected because register space got exposed directly
>>> to userspace.  I think we should re-consider merging netmap
>>> (or something conceptually close to its design).
>>
>> I'm actually working in this direction, of zero-copy RX mapping packets
>> into userspace.  This work is mostly related to page_pool, and I only
>> plan to use XDP as a filter for selecting packets going to userspace,
>> as this choice need to be taken very early.
>>
>> My design is here:
>>  https://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/design/memory_model_nic.html
>>
>> This is mostly about changing the memory model in the drivers, to allow
>> for safely mapping pages to userspace.  (An efficient queue mechanism is
>> not covered).
> 
> Virtio virtqueues are used in various other locations in the stack.
> With separate memory pools and send + completion descriptor rings,
> signal moderation, careful avoidance of cacheline bouncing, etc. these
> seem like a good opportunity for a TPACKET_V4 format.
> 

FWIW. After we rejected exposing the register space to user space due to
valid security issues we fell back to using VFIO which works nicely for
mapping virtual functions into userspace and VMs. The main  drawback is
user space has to manage the VF but that is mostly a solved problem at
this point. Deployment concerns aside.

There was a TPACKET_V4 version we had a prototype of that passed
buffers down to the hardware to use with the dma engine. This gives
zero-copy but same as VFs requires the hardware to do all the steering
of traffic and any expected policy in front of the application. Due to
requiring user space to kick hardware and vice versa though it was
somewhat slower so I didn't finish it up. The kick was implemented as a
syscall iirc. I can maybe look at it a bit more next week and see if its
worth reviving now in this context.

I don't think any of this requires page pools though. Or rather tpacket
and vhost/virtio already know how to do page pools is perhaps the other
way to look at it.

One idea I've been playing around with is a vhost backend using
tpacketv{3|4} so we don't require socket manipulation.

Thanks,
John
