From: Andi Kleen <ak@muc.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: 30 Mar 2005 17:22:08 +0200
Message-ID: <20050330152208.GB12672@muc.de>
References: <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com> <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave> <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Yusupov <dmitry_yus@yahoo.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Rik van Riel <riel@redhat.com>, mpm@selenic.com, andrea@suse.de,
        michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        ksummit-2005-discuss@thunk.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Date: Wed, 30 Mar 2005 17:22:08 +0200
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112130512.1077.107.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 29, 2005 at 04:08:32PM -0500, jamal wrote:
> Sender is holding onto memory (retransmit queue i assume) waiting
> for ACKs. Said sender is under OOM and therefore drops ACKs coming in
> and as a result cant let go of these precious resource sitting on the
> retransmit queue. 
> And iscsi cant wait long enough for someone else to release memory so
> the ACKs can be delivered. 
> Did i capture this correctly?

Or worse your swap device is on iscsi and you need the ACK to free
memory. 

But that is unrealistic because it could only happen if 100% of
your memory is dirty  pages or filled up by other non VM users.
Which I think is pretty unlikely. Normally the dirty limits in the VM
should prevent it anyways - VM is supposed to block before all
your memory is dirty. The CPU can still dirty pages in user space,
but the cleaner should also clean it and if necessary block
the process.

> 
> If yes, the solution maybe to just drop all non-high-prio packets coming
> in during the denial of service attack (for lack of better term). In
> other words some strict prioritization scheduling (or rate control) at
> the network level either in the NIC or ingress qdisc level.

It does not help. You would need this filtering in all possible
queues of the network (including all routers, the RX queue of the NIC etc.)
Otherwise the queue in front of you can always starve you in theory.

It is even impossible to do this filtering for normal ethernet devices
because they cannot easily distingush different flows and put
them into different queus (and even if they can it is usually useless
because the max number of flows is so small that you would add
an arbitary very small max number limit of your iscsi connections, which
users surely would not like)

And you cannot control the Ethernet in front of it neither.

The only exception would be a network that is designed around
bandwidth allocation, like an ATM network. But definitely not TCP/IP.

So you cannot solve this problem perfectly. All you can do is
to do "good enough" solutions. Have big enough pipes. Keep
big enough free memory around etc. I suspect mempools are not really
needed for that, probably just some statistical early dropping
of packets is enough to give the retransmits a high enough
chance to actually make it.

 
> On a slightly related topic: is SCSI (not iscsi) considered a reliable
> protocol?
> If yes, why would you wanna run a reliable protocol inside another
> reliable protocol (TCP)?

iSCSI runs on top of TCP AFAIK

-Andi
