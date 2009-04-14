From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Kernel sends multicast groups to sockets that did not
	subscribe to the MC group
Date: Tue, 14 Apr 2009 16:01:40 -0400
Message-ID: <20090414200139.GA17196@hmsreliant.think-freely.org>
References: <alpine.DEB.1.10.0904131704120.3517@qirst.com> <20090414132551.GC14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904140946130.5712@qirst.com> <20090414182731.GD14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141424440.30596@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45994 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbZDNUBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 16:01:50 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904141424440.30596@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2009 at 02:33:53PM -0400, Christoph Lameter wrote:
> On Tue, 14 Apr 2009, Neil Horman wrote:
> 
> > The only reason that happens is because the apps themselves are broken.  The
> > only way an application would get messages from unexpected Multicast addresses
> > is if it joined a group, and then bound the socket to INADDR_ANY, rather than to
> > the multicast group and port that it joined to.  And if it does that, it has to
> > be written to detect and cope with malformed data from unexpected hosts, lest it
> > be vulnurable to any number of bugs.
> 
> This occurs here if two applications on a machine bind to the
> different MC groups but the same port. Applications need to bind to the
> same port since MC traffic has a port number included. Do I need to bind
> to the IP address of the NIC? What does INADDR_ANY have to do with it?
> 
Lets be clear here, when you say, bind, are you referring to the bind call
specifically?  or the setsockopt(IP_ADD_MEMBERSHIP, ... ) call?  I'm referring
to the former.  From your initial description, you're referring to the latter.
If you check inet_bind, you'll note that the sockets rcv_saddr is set to the
bound address, which is then later used in udp_v4_mcast_next to filter on which
sockets should receive which frames, so by binding (via the bind syscall), you
can make a socket filter which mcast address it receives.  I'm fairly certain in
your test, you're referring to membership management, via IP_ADD_MEMBERSHIP,
which is different from bind.

INADDRY_ANY comes into play here because application writers tend to be lazy
(and who can blame them :) ).  Nominally when you use unicast udp, you bind a
socket to an interface to tell it that you want to receive frames from that
interface (using the interfaces source ip address).  If they application wants
to receive frames on all interfaces, it just binds to INADDR_ANY.  When an app
developer uses multicast, they likely say something to themselves along the
lines of "I'd like to receive multicast on all interfaces, so I'll just bind to
INADDRY_ANY".  The problem is that they haven't really taken into consideration
what bind does.  The high level behavior is that it attaches a socket to an
interface, restricting packet reception to only that interface (and the man page
for ip doesn't do much to correct that).  The actuall behavior however is that
bind places a filter on a socket, allowing reception only from the specified
address on that socket.  This is made intuitive by the fact that unicast ip
addresses typically are bound to an interface (I'll ignore the system
ownership/interface ownership discussion here), so bind works like you expect.
But with multicast, there is no interface that the address is bound to, so the
behavior is less intuitive, but still perfectly functional, if you properly
understand how bind filters received packets.

> > It works exactly the same way with unicast UDP.  If an application receives on a
> > socket that is bound to INADDR_ANY, it needs to be especially careful in parsing
> > the data that it receives, since there is no transport layer validation of the
> > sending clients status (the way there is with tcp or sctp).  If host A has a
> > socket on an application bound to INADDR_ANY and is receiving data from host B,
> > nothing is stopping host C from starting to send whatever garbage it wants to
> > host A as well, and its up to the application to sort that out.  Its exactly the
> > same with multicast.  Its just that people assume it works in a certain way
> > (like I did), and it doesn't.
> 
> Again what does this have to do with INADDR_ANY? You are talking about UDP
> sockets? In that case the sorting out usually happens based on the source
> address anyways.
> 
See above.  It has everything to do with how bind works.  If you bind to
INADDR_ANY (which by the way is the default binding if you don't call bind on a
socket from your application), you are implicitly bound to receive frames from
all destination addresses in the system, which is why you get the behavior you
are seeing.  If you want to restrict which multicast addresses you recieve, bind
to them.

> > Yes, we can change the code, and its not hard, the question is: why?  It would
> > make the use of multicast a bit more intuitive, yes, but I would be concerned
> > about applications which expect this behavior.  They would all break with this
> > change.  I can certainly envision an application listening on multiple multicast
> > groups, and as a matter of simplification, binding to INADDR_ANY, and validating
> > any received data to toss messages from groups they don't want in user space.  I
> > suppose theres some advantage in doing the filtering in kernel space to avoid
> > the extraneous copy_to_user, but I'm not sure thats always feasible, As an
> > application might not know at any given moment what multicast groups it needs to
> > receive on.
> 
> Please read the initial message that started this thread.
> 
> If an application listens on multiple multicast groups then it needs to
> perform join operations otherwise the switch will not forward the
> multicast groups to the host.
> (Just ignoring the INADDR_ANY bits since I do not know what this would
> have to do with the issue at hand)
> 
If you don't yet understand what bind has to do with how this works, please read
above.

> > Possible, but I'd still be worried about the above.  Using a switch like this is
> > global (or at least per net namespace), and prevents a mix of apps written to
> > the 'new model' and the current model.  A prctl option or an additional socket
> > option might be more palatable.  I think if you could find some standard,
> > specification or common practice documenting that multicast works the way
> > you 'expect' on other systems, thsi might get more traction.  I've not found
> > anything to that effect though (although I've not looked very hard).
> 
> I cannot envision that there would be many applications having made any
> use of the current situation where all mc traffic to a port is forwarded
> to the multiple applications that may have subscribed to disjunct sets of
> multicast groups.
> 
This has been the behavior of multicast udp in the Linux network stack from its
creation, from what I can see.  I wouldn't be so quick to assume that changing
it won't bring people out of the woodwork.  Setting that asside however, not
breaking anybody isn't in my mind a sufficient reason to change this.  Despite
your inability to see how bind fits into this mechanism, trust for the moment
that bind provides the ability for a socket to filter which multicast group
messages are delivered to it.  Bearing that in mind, what additionl value does
the mechanism that you are proposing provide?

> One could envison having two processes that open the same socket/port and
> coordinate: The first joins the multicast groups and then continues in a
> monitoring role whereas the second actually processes the data. But then
> the data is forwarded to both processes and one of them is not processing
> it. So its fundamentally bad behavior. I would even suggest to make the
> socket based filtering the default (as in other OSes).
> 
Thats a poorly written application.  I refer you again to the implementation of
bind (see inet_bind and udp_v4_mcast_next for details of its inner workings)

Neil

> 
