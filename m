From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH rfc] packet: zerocopy packet_snd
Date: Thu, 27 Nov 2014 09:27:17 +0200
Message-ID: <20141127072717.GA8644@redhat.com>
References: <1416602694-7540-1-git-send-email-willemb@google.com>
 <20141126182445.GA15744@redhat.com>
 <CA+FuTSdYB4rDMH3gAAMwaRdbqN58f_SxLz=C3fcCACw_KosGXw@mail.gmail.com>
 <20141126212038.GA12118@redhat.com>
 <CA+FuTSf_qiO964ZK1gB9skd1iQMj3iodcccscCt=vo6j92MsuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53970 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884AbaK0H1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2014 02:27:23 -0500
Content-Disposition: inline
In-Reply-To: <CA+FuTSf_qiO964ZK1gB9skd1iQMj3iodcccscCt=vo6j92MsuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2014 at 06:05:16PM -0500, Willem de Bruijn wrote:
> On Wed, Nov 26, 2014 at 4:20 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Wed, Nov 26, 2014 at 02:59:34PM -0500, Willem de Bruijn wrote:
> >> > The main problem with zero copy ATM is with queueing disciplines
> >> > which might keep the socket around essentially forever.
> >> > The case was described here:
> >> > https://lkml.org/lkml/2014/1/17/105
> >> > and of course this will make it more serious now that
> >> > more applications will be able to do this, so
> >> > chances that an administrator enables this
> >> > are higher.
> >>
> >> The denial of service issue raised there, that a single queue can
> >> block an entire virtio-net device, is less problematic in the case of
> >> packet sockets. A socket can run out of sk_wmem_alloc, but a prudent
> >> application can increase the limit or use separate sockets for
> >> separate flows.
> >
> > Sounds like this interface is very hard to use correctly.
> 
> Actually, this socket alloc issue is the same for zerocopy and
> non-zerocopy. Packets can be held in deep queues at which point
> the packet socket is blocked. This is accepted behavior.
>
> >From the above thread:
> 
> "It's ok for non-zerocopy packet to be blocked since VM1 thought the
> packets has been sent instead of pending in the virtqueue. So VM1 can
> still send packet to other destination."
> 
> This is very specific to virtio and vhost-net. I don't think that that
> concern applies to a packet interface.

Well, you are obviously building the interface with some use-case in mind.
Let's try to make it work for multiple use-cases.

So at some level, you are right.  The issue is not running out of wmem.
But I think I'm right too - this is hard to use correctly.

I think the difference is that with your patch, application
can't reuse the memory until packet is transmitted, otherwise junk goes
out on the network. Even closing the socket won't help.
Is this true?

I see this as a problem.

I'm trying to figure out how would one use this interface, one obvious
use would be to tunnel out raw packets directly from VM memory.
For this application, a zero copy packet never completing is a problem:
at minimum, you want to be able to remove the device, which
translates to a requirement that closing the socket effectively stops
using userspace memory. In case you want to be able to run e.g. a watchdog,
ability to specify a deadline also seems benefitial.


> Another issue, though, is that the method currently really only helps
> TSO because ll other paths cause a deep copy. There are more use
> cases once it can send up to 64KB MTU over loopback or send out
> GSO datagrams without triggering skb_copy_ubufs. I have not looked
> into how (or if) that can be achieved yet.

I think this was done intentionally at some point,
try to look at git history to find out the reasons.

> >
> >> > One possible solution is some kind of timer orphaning frags
> >> > for skbs that have been around for too long.
> >>
> >> Perhaps this can be approximated without an explicit timer by calling
> >> skb_copy_ubufs on enqueue whenever qlen exceeds a threshold value?
> >
> > Not sure.  I'll have to see that patch to judge.
