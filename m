From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: subtle change in behavior with tun driver
Date: Fri, 23 Jan 2015 09:38:29 +0200
Message-ID: <20150123073829.GA26711@redhat.com>
References: <CAOxq_8NJdFV6fbVh-uns3bpaKNjtcGEOEDb4U3_rX3d+w85SWQ@mail.gmail.com>
 <20150122095349.GC26178@redhat.com>
 <CAOxq_8PCJXw+yoXj0MtLO7nTvWWdR3N4XvKUZ00SX6y-A9EziQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fruggeri <fruggeri@arista.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337AbbAWHie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jan 2015 02:38:34 -0500
Content-Disposition: inline
In-Reply-To: <CAOxq_8PCJXw+yoXj0MtLO7nTvWWdR3N4XvKUZ00SX6y-A9EziQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2015 at 04:28:09PM -0800, Ani Sinha wrote:
> On Thu, Jan 22, 2015 at 1:53 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Wed, Jan 21, 2015 at 02:36:17PM -0800, Ani Sinha wrote:
> >> Hi guys :
> >>
> >> Commit 5d097109257c03 ("tun: only queue packets on device") seems to
> >> have introduced a subtle change in behavior in the tun driver in the
> >> default (non IFF_ONE_QUEUE) case. Previously when the queues got full
> >> and eventually sk_wmem_alloc of the socket exceeded sk_sndbuf value,
> >> the user would be given a feedback by returning EAGAIN from sendto()
> >> etc. That way, the user could retry sending the packet again.
> >
> > This behaviour is common, but by no means guaranteed.
> > For example, if socket buffer size is large enough,
> > packets are small enough, or there are multiple sockets
> > transmitting through tun, packets would previously
> > accumulate in qdisc, followed by packet drops
> > without EAGAIN.
> 
> Ah I see. pfifo_fast_enqueue() also starts dropping packets when it's
> length exceeds a threshold. So I supposed we do not have a strong
> argument for bringing back the old semantics because it wasn't
> guranteed in every scenario in the first place.
> 
> >
> >> Unfortunately, with this new  default single queue mode, the driver
> >> silently drops the packet when the device queue is full without giving
> >> userland any feedback. This makes it appear to userland as though the
> >> packet was transmitted successfully. It seems there is a semantic
> >> change in the driver with this commit.
> >>
> >> If the receiving process gets stuck for a short interval and is unable
> >> to drain packets and then restarts again, one might see strange packet
> >> drops in the kernel without getting any error back on the sender's
> >> side. It kind of feels wrong.
> >>
> >> Any thoughts?
> >>
> >> Ani
> >
> > Unfortunately - since it's pretty common for unpriveledged userspace to
> > drive the tun device - blocking the queue indefinitely as was done
> > previously leads to deadlocks for some apps, this was deemed worse than
> > some performance degradation.
> 
> agreed. However applications which needs protection from deadlock can
> exclusively set IFF_ONE_QUEUE mode and live with the fact that they
> might see dropped packets.

This doesn't work because applications are just using the
linux networking stack. Packets end up in tun.
It's up to tun not to break the stack, we can't
change all applications out there.

> >
> > As a simple work-around, if you want packets to accumulate in the qdisc,
> > it's easy to implement by using a non work conserving qdisc.
> > Set the limits to match the speed at which your application
> > is able to consume the packets.
> >
> > I've been thinking about using some kind of watchdog to
> > make it safe to put the old non IFF_ONE_QUEUE semantics back,
> > unfortunately due to application being able to consume packets at the
> > same time it's not trivial to do in a non-racy way.
> 
> I do not have an answer to this issue either. I agree that this is a
> hard issue to solve.
