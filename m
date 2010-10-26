From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Tue, 26 Oct 2010 10:40:35 +0530
Message-ID: <OF5C53E9CF.FFDF2CE7-ON652577C8.00191D14-652577C8.001C2154@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com> <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com> <20101025161718.GA19559@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:52836 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867Ab0JZFHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 01:07:24 -0400
In-Reply-To: <20101025161718.GA19559@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 10/25/2010 09:47:18 PM:

> > Any feedback, comments, objections, issues or bugs about the
> > patches? Please let me know if something needs to be done.
>
> I am trying to wrap my head around kernel/user interface here.
> E.g., will we need another incompatible change when we add multiple RX
> queues?

Though I added a 'mq' option to qemu, there shouldn't be
any incompatibility between old and new qemu's wrt vhost
and virtio-net drivers. So the old qemu will run new host
and new guest without issues, and new qemu can also run
old host and old guest. Multiple RXQ will also not add
any incompatibility.

With MQ RX, I will be able to remove the hueristic (idea
from David Stevens).  The idea is: Guest sends out packets
on, say TXQ#2, vhost#2 processes the packets but packets
going out from host to guest might be sent out on a
different RXQ, say RXQ#4.  Guest receives the packet on
RXQ#4, and all future responses on that connection are sent
on TXQ#4.  Now vhost#4 processes both RX and TX packets for
this connection.  Without needing to hash on the connection,
guest can make sure that the same vhost thread will handle
a single connection.

> Also need to think about how robust our single stream heuristic is,
> e.g. what are the chances it will misdetect a bidirectional
> UDP stream as a single TCP?

I think it should not happen. The hueristic code gets
called for handling just the transmit packets, packets
that vhost sends out to the guest skip this path.

I tested unidirectional and bidirectional UDP to confirm:

8 iterations of iperf tests, each iteration of 15 secs,
result is the sum of all 8 iterations in Gbits/sec
__________________________________________
Uni-directional          Bi-directional
  Org      New             Org      New
__________________________________________
  71.78    71.77           71.74   72.07
__________________________________________

Thanks,

- KK

