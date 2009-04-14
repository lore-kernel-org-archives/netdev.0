From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Kernel sends multicast groups to sockets that did not
	subscribe to the MC group
Date: Tue, 14 Apr 2009 14:27:31 -0400
Message-ID: <20090414182731.GD14305@hmsreliant.think-freely.org>
References: <alpine.DEB.1.10.0904131704120.3517@qirst.com> <20090414132551.GC14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904140946130.5712@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46564 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758199AbZDNS1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 14:27:42 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904140946130.5712@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2009 at 09:53:50AM -0400, Christoph Lameter wrote:
> On Tue, 14 Apr 2009, Neil Horman wrote:
> 
> > > If I send a multicast message to 239.0.0.50 then both receive it. Why is
> > > the process listening to 239.0.0.51 receiving the multicast message send
> > > to 239.0.0.50?
> > Its correct behavior.  I had the same misunderstanding a few months back, but
> > Dave stevens set me right:
> > http://kerneltrap.org/index.php?q=mailarchive/linux-netdev/2008/7/11/2430904
> 
> Well its traditional behavior. The join operation occurs on a socket so
> it is surprising that this means I join all multicast groups on an
> interface. The reason given is that all unixes since BSD were as
> braindead. Still crappy behavior since multiple applications that
> subscribe to different groups but listen on the same port will get all
> traffic of the other apps delivered to them.

The only reason that happens is because the apps themselves are broken.  The
only way an application would get messages from unexpected Multicast addresses
is if it joined a group, and then bound the socket to INADDR_ANY, rather than to
the multicast group and port that it joined to.  And if it does that, it has to
be written to detect and cope with malformed data from unexpected hosts, lest it
be vulnurable to any number of bugs.

It works exactly the same way with unicast UDP.  If an application receives on a
socket that is bound to INADDR_ANY, it needs to be especially careful in parsing
the data that it receives, since there is no transport layer validation of the
sending clients status (the way there is with tcp or sctp).  If host A has a
socket on an application bound to INADDR_ANY and is receiving data from host B,
nothing is stopping host C from starting to send whatever garbage it wants to
host A as well, and its up to the application to sort that out.  Its exactly the
same with multicast.  Its just that people assume it works in a certain way
(like I did), and it doesn't.

> Its trivial to fix as your patch shows since we already have per socket mc
> lists required to support IGMPv3.
> 
Yes, we can change the code, and its not hard, the question is: why?  It would
make the use of multicast a bit more intuitive, yes, but I would be concerned
about applications which expect this behavior.  They would all break with this
change.  I can certainly envision an application listening on multiple multicast
groups, and as a matter of simplification, binding to INADDR_ANY, and validating
any received data to toss messages from groups they don't want in user space.  I
suppose theres some advantage in doing the filtering in kernel space to avoid
the extraneous copy_to_user, but I'm not sure thats always feasible, As an
application might not know at any given moment what multicast groups it needs to
receive on.

> Maybe we can get this merged by adding a mc configuration variable
> that switches between interface and socket based multicast subscriptions.
> 
> /proc/sys/net/mc_socket_based_join
> 
Possible, but I'd still be worried about the above.  Using a switch like this is
global (or at least per net namespace), and prevents a mix of apps written to
the 'new model' and the current model.  A prctl option or an additional socket
option might be more palatable.  I think if you could find some standard,
specification or common practice documenting that multicast works the way
you 'expect' on other systems, thsi might get more traction.  I've not found
anything to that effect though (although I've not looked very hard).

Neil

