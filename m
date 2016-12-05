From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] udp: some improvements on RX path.
Date: Mon, 05 Dec 2016 07:54:05 -0800
Message-ID: <1480953245.18162.541.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161205163711.44b01c3a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paolo Abeni <pabeni@redhat.com>, netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35770 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbcLEQMp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 11:12:45 -0500
Received: by mail-pf0-f193.google.com with SMTP id i88so7902743pfk.2
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 08:12:45 -0800 (PST)
In-Reply-To: <20161205163711.44b01c3a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-12-05 at 16:37 +0100, Jesper Dangaard Brouer wrote:

> Do you think the splice technique would, have the same performance
> benefit as having a MPMC queue with separate enqueue and dequeue locking?
> (like we have with skb_array/ptr_ring that avoids cache bouncing)?

I believe ring buffers make sense for critical points in the kernel,
but for an arbitrary number of TCP/UDP sockets in a host, they are a big
increase of memory, and a practical problem when SO_RCVBUF is changed,
since dynamic resize of the ring buffer would be needed.

If you think about it, most sockets have few outstanding packets, like
0, 1 , 2. But they also might have ~100 packets, sometimes...

For most of TCP/UDP sockets, a linked list is simply good enough.
( We only very recently converted the out of order receive queue to an
RB tree )

Now, if _two_ linked list are also good in the very rare case of floods,
I would use two linked lists, if they can offer us a 50 % increase at
small memory cost.

Then for very special cases, we have af_packet which should be optimized
for all the fancy stuff.

If an application really receives more than 1.5 Mpps per UDP socket,
then the author should seriously consider SO_REUSEPORT, and have more
than 1 vcpu on its VM. I think we have cheap cloud offers available from
many providers.

The ring buffer queue might make sense in net/core/dev.c, since
we currently have 2 queues per cpu.

So you might want to experiment with that, because it looks like we
might go to a model where a single cpu is (busypoll) processing all low
level RX processing from a single queue per NUMA node, then dispatch to
other cpus the IP/{TCP|UDP} processing.
