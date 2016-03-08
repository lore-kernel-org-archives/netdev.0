From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 01/11] rxrpc: Add a common object cache
Date: Tue, 08 Mar 2016 11:39:57 +0000
Message-ID: <29908.1457437197@warthog.procyon.org.uk>
References: <20160307.230737.1738396720590983620.davem@davemloft.net> <20160307143759.18567.8234.stgit@warthog.procyon.org.uk> <20160307143806.18567.30020.stgit@warthog.procyon.org.uk> <23389.1457390714@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160307.230737.1738396720590983620.davem@davemloft.net>
Content-ID: <29907.1457437197.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> >> I know you put a lot of time and effort into this, but I want to strongly
> >> recommend against a garbage collected hash table for anything whatsoever.
> >> 
> >> Especially if the given objects are in some way created/destroyed/etc. by
> >> operations triggerable remotely.
> >> 
> >> This can be DoS'd quite trivially, and that's why we have removed the ipv4
> >> routing cache which did the same.
> > 
> > Hmmm...  You have a point.  What would you suggest instead?  At least with
> > the common object cache code I have, I might be able to just change that.
> 
> Objects that are used for correct operation have no easily recyclable
> property, you must hold onto them.  There has to be a set of resources
> held and consumed at both endpoints for it to work properly ("I can't
> DoS you without DoS'ing myself").

So what would you use instead for the connection object?  That is the only one
that really needs to live past its last use; local, peer and call objects can
reasonably be recycled the moment they're no longer in use.  Note that I still
need some fast way to look up the connection object (hence the RCU hash table
approach) as they're the main packet routing device.

I would also prefer to avoid having a separate timer for every connection
object when I can have one for the whole set.  Does it make sense to maintain a
FIFO list of connections (though this would mean potentially taking a spinlock
every time I get a packet)?  That's why I prefer the gc hash table scan
approach - it doesn't require a separate list and only requires one timer.

> Where reclaimable tables work is for stuff that is near zero cost to
> reconstitute.  A good example is the TCP metrics table.  When a TCP
> metrics entry is reclaimed, it's not like we have to renegotiate a
> security context when we try to talk to that end-host again.

Sounds like this would be a way to do the peer object management.

> If the concept of these open-ended objects is a fundamental aspect of
> the protocol.... that's a serious shortcoming of RXRPC.

There is sort of a way to close a connection - you can send a connection-level
abort packet (call ID is set to 0) - but I'm not sure anyone does that.  It's
probably worth suggesting to the other implementors, though.

However, to some extent that is irrelevant: I didn't design the protocol and
can't very easily change it - I'm just trying to implement it.

So yes, it can be considered open-ended, but it is also expected to be cached
and to expire after a period of non-use.  If I set up a connection and let it
lapse, the RxRPC server can set it up again, no problem - it is allowed to send
further challenge/response packets for the same connection ID.  As far as the
server is concerned it would be a new connection.

I would expect the reason it's like this is that it's intended as the transport
for AFS, but AFS, unlike CIFS, doesn't negotiate a security context at mount
time for the life of the mount.  An AFS mount is made, then I do kinit to
negotiate a connection and then access the AFS mount - which uses my own
negotiated security context.  Someone else, who has done their own kinit and
has negotiated a different security context can access the same AFS mount -
which will then use their context at the same time as it is using mine.

The problem that the AFS mount has is that it doesn't know when I'm going to
make my last access of it, short of the mount being unmounted.

So, in that respect, an open-ended connection concept might make a certain
amount of sense.

One could argue, I suppose, that things should've been arranged that the RxRPC
client would manage the lifetime of each connection it sets up, rather than
both ends letting it lapse by mutual loss of interest.  But you *still* have to
have a timeout, lest the client die and not close its connection.

David
