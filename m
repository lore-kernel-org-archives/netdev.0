From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 2/3] tipc: byte-based overload control on socket
 receive queue
Date: Tue, 19 Feb 2013 16:44:39 -0500
Message-ID: <20130219214439.GC31871@hmsreliant.think-freely.org>
References: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com>
 <1360969067-29956-3-git-send-email-paul.gortmaker@windriver.com>
 <20130218144757.GA26199@hmsreliant.think-freely.org>
 <512332DA.5040508@ericsson.com>
 <20130219142629.GA31871@hmsreliant.think-freely.org>
 <5123BC46.40909@ericsson.com>
 <20130219191833.GB31871@hmsreliant.think-freely.org>
 <5123DDA8.5090202@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34941 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933545Ab3BSVpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 16:45:08 -0500
Content-Disposition: inline
In-Reply-To: <5123DDA8.5090202@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 19, 2013 at 09:16:40PM +0100, Jon Maloy wrote:
> On 02/19/2013 08:18 PM, Neil Horman wrote:
> > On Tue, Feb 19, 2013 at 06:54:14PM +0100, Jon Maloy wrote:
> >> On 02/19/2013 03:26 PM, Neil Horman wrote:
> >>> On Tue, Feb 19, 2013 at 09:07:54AM +0100, Jon Maloy wrote:
> >>>> On 02/18/2013 09:47 AM, Neil Horman wrote:
> >>>>> On Fri, Feb 15, 2013 at 05:57:46PM -0500, Paul Gortmaker wrote:
> >>>>>> From: Ying Xue <ying.xue@windriver.com>
><snip>

> >> 	
> >> There are two reasons for this. 
> >> The first one due to the message oriented nature of the flow control for 
> >> connections. Max message size is 65k, and max number of unacked messages 
> >> (at socket level, that is) before the sending process will take a break 
> >> is 1024. 
> >> So, simple maths gives that we must allow for 64MB + sk_overhead to guarantee 
> >> that a connection never is broken because of receiver overload. Contrary to TCP,
> > Note, this is false, due to the fact that, it presumes that the sender will
> > honor the congestion window.  Granted, that would be a sender violation, but its
> > still possible for packets to get lost due to receiver overrun.  
> 
> The reason for this high limit is exactly to guard against crazy or malevolent 
> senders. If they respect their send window they will never hit this limit on
> connections.
> 
Nope, You don't get to have it both ways - If a sender is malevolent or crazy,
what makes you think it will respect its send window?

> The fact that
> > you ack packets before accepting them to the receive queue is the problem that
> > needs fixing in this case, but that looks like it can be easily accomplished
> > (see below).
> > 
> >> we don't have the luxury to just drop packets and expect them to be retransmitted,
> >> because in TIPC they have already passed through the retransmission and 
> >> defragmentation layers, and are committed for delivery when they reach the 
> >> receiving socket.
> > The problem isn't that you don't have the luxury of droping packets, the problem
> > is that you've decided to ack an incomming packet before you've determined if
> > you have the space to accept it (I sympathise with you here, I had to go through
> > this same exercise with SCTP a few years ago).  Just trying to balance your
> > rcvbuf space so that you don't have to worry about it causes more problems than
> > it solves in the end.
> 
> I think you are missing an important point here. There is no one-to-one relation
> between a link and a socket. The link serves *all* socket on a node, with one shared
> send/retransmission queue and one shared packet number sequence.  So dropping 
> packets on arrival as you suggest will not only hurt the process sending too many 
> messages, but everybody else sending anything between the two nodes.
No, I get that, but the fact that TIPC has a shared retransmit queue between all
sockets on the link isn't an excuse to violate the limits set on an individual
socket.

> Granted, the retransmission will take care of the dropped packet, but in the 
> meantime no other packets can be delivered through from that link, to any 
> socket. Basically, all TIPC communication between the two involved
> nodes in the given direction would grind to a halt until the slow or overwhelmed 
> receiver process has decided to work off his receive queue, something that may 
> never happen if it is faulty.
Sounds like a bug.  That should be fixed.

> You may see this as a flaw, but it is a consequence of that TIPC is a radically 
> different design than IP based protocols, designed for completely different needs.
> The shared link concept is a fundamental feature that has a lot of other advantages 
> which I won't elaborate on here.
> 
Very well.  While I'm thinking of it though, you also seem to be making a large
leap in reasoning - you seem to be repeatedly equating my request to have you
honor the limits of sk_rcvbuf, with a desire to have that limit be smaller than
what you currently have it set to.  Thats absolutely untrue.  I don't care if
you set your limit to UINT_MAX/2 on a socket, I just want what you set to be
honored.  If you set your sk_rcvbuf high enough (using setsockopt or the proc
tunables I mentioned below), checking to make sure you're complying with those values
should do nothing from a rx path standpoint (i.e. if you set your rcvbuf high
enough, you will never hit the limit anyway, unless of course you have a
malevolent sender, in which case all bets are off anyway).

> > 
> > The thing to do is just move your rcvbuf check lower in the stack, in this case
> > to tipc_recv_msg.  You have a tipc_msg struct there, from which you can
> > determine if the message is data, get the desination port, and convert that to a
> > tipc_port pointer, which contains a usr_handle pointer.  From my read, the
> > usr_handle pointer is only ever set to a socket structure, 
> 
> Unfortunately not. There are still remnants of the "native" interface present, 
> which is not socket based at all. We are working on that.
> 
Ugh, you're right.  Well, thats still just two possible types in usr_handle, you
could easily add a boolean flag to mark those ports which had sockets assigned
to them, at least until you cleaned out the native interface

> so if you have a non
> > NULL usr_handle, cast it to a struct sock, and read is sk_rcvbuf.  If its over
> > capacity, drop the packet before you ack it.
> 
> In theory this is possible, but extremely awkward with the current locking
> structure (We are working on that too). Anyway, I hope I have convinced
> you with the above that dropping packets at the link level is not a viable
> option.
> 
The only locking that I see you doing to check the sk_rcvbuf value in
its current location is the tipc_port_lock, and you do that with all the same
locks held farther up the call stack (tipc_net_lock, tipc_node_lock).  The fact
of the matter is, moving that check lower down into tipc_recv_msg doesn't
require any nesting changes to your locking at all.

> > 
> >> You may question the wisdom of having a message oriented flow control algorithm, 
> >> but this the way it is now. We do actually have a working prototype where we 
> >> introduce purely byte-based flow control, but it is not ready for delivery yet, 
> >> and compatibility constraints will require that we still keep this high limit 
> >> in some cases.
> >>
> > I do believe that a byte oriented algorithm is better, but for now a message
> > based mechanism is fine by me.  My only concern is that you honor the limits
> > placed on the socket.  I'm not sure what compatibilty requirement enjoin you
> > from having a lower rcvbuf limit, but it would seem to me, just not acking a
> > message until you are sure you can accept it would fix those problems.  Even if
> > that isn't the case, honor the limits, tie them to the tunables in /proc (or
> > create your own), and document what the required limits are.
> > 
> >> The second reason is that TIPC provides SOCK_RDM instead of SOCK_DGRAM as its
> >> basic datagram service. (It is the only transport service doing this afaik.)
> >> So, the risk of having datagram messages rejected (not dropped), for any reason, 
> >> must be extremely low. ("Rejected" here means that we notify the sender when a
> >> message cannot be delivered, we don't just silently drop it.)
> > Thats fine, I'm not talking about rejecting messages, I'm specifically referring
> > to dropping them - i.e. behaving as if they never arrived at the host at all
> > (save for maybe increasing a stats counter, so the admin knows whats going on).
> > One way or another the sender has to be prepared to handle an unacked frame.  If
> > you can't, then the protocol is broken.
> > 
> >> Given that we also often have seen designs with many clients sending towards
> >> one server we have empirical experience that we must have a high threshold here.
> >> One can discuss whether 2MB or 5MB is the adequate limit for the lowest level, 
> >> we don't really now since this a new design, but we have every reason to believe
> >> that the upper limit permitted by setsockopt(SOL_SOCK) (425,984 bytes according
> >> to a quick test I made) is not enough for us.
> > I'm not trying to force you to a lower sk_rcvbuf value, I'm fine with whatever
> > you want to set it to, my only request here is that you honor the limits set on
> > your socket at least semi accurately.  If you need to set that limit higher by
> > default, do so (theres sysctl values for that already:
> > sysctl_rmem_[min|default|max], or you can build your own, though I would
> > recommend you use the former).
> 
> Ok, I wasn't aware of that. Now, if we could set these parameters from inside 
> the module, when a socket is created, we I think we have what we need. We 
> don't want to force every socket creator to set these limits explicitly, unless
> he has some very particular needs and knows what he is doing.
> 
I've tried to explain this several times now.  You don't have to have set this value to
what you want programatically, nor do you need to force the value from within
the module code itself, you can do it administratively.  If you set:

/proc/sys/net/core/rmem_default

to the value that you want all your sockets to have, any socket that gets
initalized with sock_init_data will inherit that value.  Note that, when doing
so, you may also have to set:

/proc/sys/net/core/rmem_max

As you can't adminstratively set your default socket rcvbuf value to something
larger than the maximum allowed value without raising the maximum allowed value
first.

Then all you have to do is make sure those values are set during boot up, and for
users, it will appear as though nothing has changed.

Neil

> 
