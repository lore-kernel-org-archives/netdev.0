From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 4/5] xps_flows: XPS for packets that don't
 have a socket
Date: Thu, 29 Sep 2016 06:18:00 -0700
Message-ID: <1475155080.28155.159.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160929035428.204355-1-tom@herbertland.com>
         <20160929035428.204355-5-tom@herbertland.com>
         <1475124851.28155.135.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALx6S36FsjSioksB+O7Lp7-7PcC8iMc9LWqWiFr8RzFJ=GkKGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Rick Jones <rick.jones2@hpe.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34200 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752596AbcI2NSd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 09:18:33 -0400
Received: by mail-pf0-f196.google.com with SMTP id 21so3607302pfy.1
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 06:18:04 -0700 (PDT)
In-Reply-To: <CALx6S36FsjSioksB+O7Lp7-7PcC8iMc9LWqWiFr8RzFJ=GkKGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-29 at 08:53 -0400, Tom Herbert wrote:
> On Thu, Sep 29, 2016 at 12:54 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Wed, 2016-09-28 at 20:54 -0700, Tom Herbert wrote:
> >> xps_flows maintains a per device flow table that is indexed by the
> >> skbuff hash. The table is only consulted when there is no queue saved in
> >> a transmit socket for an skbuff.
> >>
> >> Each entry in the flow table contains a queue index and a queue
> >> pointer. The queue pointer is set when a queue is chosen using a
> >> flow table entry. This pointer is set to the head pointer in the
> >> transmit queue (which is maintained by BQL).
> >>
> >> The new function get_xps_flows_index that looks up flows in the
> >> xps_flows table. The entry returned gives the last queue a matching flow
> >> used. The returned queue is compared against the normal XPS queue. If
> >> they are different, then we only switch if the tail pointer in the TX
> >> queue has advanced past the pointer saved in the entry. In this
> >> way OOO should be avoided when XPS wants to use a different queue.
> >
> > There is something I do not understand with this.
> >
> > If this OOO avoidance is tied to BQL, it means that packets sitting in a
> > qdisc wont be part of the detection.
> >
> > So packets of flow X could possibly be queued on multiple qdiscs.
> >
> Hi Eric,
> 
> I'm not sure I understand your concern. If packets for flow X can be
> queued on multiple qdiscs wouldn't that mean that flow will be subject
> to ooo transmission regardless of this patch? In other words here
> we're trying to keep packets for the flow in order as they are emitted
> from the qdiscs which we assume maintains ordering of packets in a
> flow.

Well, then what this patch series is solving ?

You have a producer of packets running on 8 vcpus in a VM.

Packets are exiting the VM and need to be queued on a mq NIC in the
hypervisor.

Flow X can be scheduled on any of these 8 vcpus, so XPS is currently
selecting different TXQ.

Your patch aims to detect this and steer packets to one TXQ, but not
using a static hash() % num_real_queues (as RSS would have done on a NIC
at RX), but trying to please XPS (as : selecting a queue close to the
CPU producing the packet. VM with one vcpu, and cpu bounded, would
really be happy to not spread packets all over the queues)

Your mechanism relies on counters updated at the time packets are given
to the NIC, not at the time packets are given to the txq (and eventually
sit for a while in the qdisc right before BQL layer)

dev_queue_xmit() is not talking to the device directly...


All I am saying is that the producer/consumer counters you added are not
at the right place.

You tried hard to not change the drivers, by adding something to
existing BQL. But packets can sit in a qdisc for a while...

So you added 2 potential cache lines misses per outgoing packet, but
with no guarantee that OOO are really avoided.
