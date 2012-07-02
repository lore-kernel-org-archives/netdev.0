From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: AF_BUS socket address family
Date: Mon, 2 Jul 2012 17:46:24 +0100
Message-ID: <20120702174624.5c8d2e74@rainbow.cbg.collabora.co.uk>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
	<201206302241.08662.hpj@urpla.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: "Hans-Peter Jansen" <hpj@urpla.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201206302241.08662.hpj@urpla.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sat, 30 Jun 2012 22:41:08 +0200,
"Hans-Peter Jansen" <hpj@urpla.net> wrote :

> Dear Vincent,
> 
> On Friday 29 June 2012, 18:45:39 Vincent Sanders wrote:
> > This series adds the bus address family (AF_BUS) it is against
> > net-next as of yesterday.
> >
> > AF_BUS is a message oriented inter process communication system.
> >
> > The principle features are:
> >
> >  - Reliable datagram based communication (all sockets are of type
> >    SOCK_SEQPACKET)
> >
> >  - Multicast message delivery (one to many, unicast as a subset)
> >
> >  - Strict ordering (messages are delivered to every client in the
> > same order)
> >
> >  - Ability to pass file descriptors
> >
> >  - Ability to pass credentials
> >
> > The basic concept is to provide a virtual bus on which multiple
> > processes can communicate and policy is imposed by a "bus master".
> >
> > Introduction
> > ------------
> >
> > AF_BUS is based upon AF_UNIX but extended for multicast operation and
> > removes stream operation, responding to extensive feedback on
> > previous approaches we have made the implementation as isolated as
> > possible. There are opportunities in the future to integrate the
> > socket garbage collector with that of the unix socket implementation.
> >
> > The impetus for creating this IPC mechanism is to replace the
> > underlying transport for D-Bus. The D-Bus system currently emulates
> > this IPC mechanism using AF_UNIX sockets in userspace and has
> > numerous undesirable behaviours. D-Bus is now widely deployed in many
> > areas and has become a de-facto IPC standard. Using this IPC
> > mechanism as a transport gives a significant (100% or more)
> > improvement to throughput with comparable improvement to latency.
> 
> Your introduction is missing a comprehensive "Discussion" section, where 
> you compare the AF_UNIX based implementation with AF_BUS ones. 
> 
> You should elaborate on each of the above noted undesirable behaviours, 
> why and how AF_BUS is advantageous. Show the workarounds, that are 
> needed by AF_UNIX to operate (properly?!?) and how the new 
> implementation is going to improve this situation.

Hi Hans-Peter,

Thanks for your feedback. I would like to elaborate on the priority
inversion and on the latency.

Priority inversion:
===================

A bus can have users with different priorities. The classical example was
Nokia's N900 phone. A incoming phone call should query the contact 
database, start the correct ringtone, display the correct avatar very
quickly. Other background tasks don't have the same priority. Since all
messages go through dbus-daemon, it is a single bottleneck and the
kernel has no way to schedule the processes with the correct
priorities. Low priority messages are waking up dbus-daemon as much as
high priority messages.

A workaround was to set the nice level of dbus-daemon to -5. It didn't
really address the priority inversion, but it reduces the number of
context switches on multicast messages, and that helped a bit. The
diagram "Experiment #3" on this blog post shows dbus-daemon is no
longer context switched for every recipient of a multicast message:
http://alban-apinc.blogspot.co.uk/2011/12/importance-of-scheduling-priority-in-d.html

With AF_BUS, there is no single process who has to receive all messages
from low priority processes and high priority processes. The kernel can
schedule the high priority processes and they can progress in their
communication without having dbus-daemon involved.

Latency:
========

On AF_UNIX, a message round-trip would go like this:
- the sender sends a message to dbus-daemon
- dbus-daemon receives it and forward it to the correct recipient
- the recipient receives it and reply with a new message sent to
  dbus-daemon
- dbus-daemon receives the reply and forward it to the initial sender
- the sender receives the reply.
There is a total of 4 context switches.

On AF_BUS, the messages are most of the time not routed by dbus-daemon,
this halves the number of context switches. It reduced the latency and
brought the performance improvement mentioned by Vincent.

> This will help to get some progress into the indurated discussion here.
> 
> Please also note, that, while your aims are nice and sound, it's even 
> more important for IPC mechanisms to operate properly - even during 
> persisting error conditions (crashed bus master and clients, 
> misbehaving or even abusing members). It would be cool to create a 
> D-BUS test rig, that not only measures performance numbers, but also 
> checks for dead locks, corner cases and abuse attempts in both IPC 
> implementations.
> 
> It's a juggling act: while AF_UNIX might suffer from downsides, the code 
> is heavily exercised in every aspect. Your implementation will only be 
> exercised by a handful of users (basically one lib), but in order to 
> rectify its existence in kernel space, such extensions need different 
> kinds of users, and the basic concepts need to fit in the whole kernel 
> picture as well, or you need to call it AF_DBUS with even less chance 
> to get it into mainstream.

I am hoping there will be more users with different use-cases and it
should help to improve AF_BUS and fix the unavoidable bugs in a young
code. I would be happy if AF_BUS reduces the cost of maintaining the
out-of-tree multicast messaging protocol family based on AF_UNIX
mentioned by Chris Friesen.

Thank you!
Alban
