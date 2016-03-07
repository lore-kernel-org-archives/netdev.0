From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 01/11] rxrpc: Add a common object cache
Date: Mon, 07 Mar 2016 22:45:14 +0000
Message-ID: <23389.1457390714@warthog.procyon.org.uk>
References: <20160307.134233.201526978853409580.davem@davemloft.net> <20160307143759.18567.8234.stgit@warthog.procyon.org.uk> <20160307143806.18567.30020.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160307.134233.201526978853409580.davem@davemloft.net>
Content-ID: <23388.1457390714.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> I know you put a lot of time and effort into this, but I want to strongly
> recommend against a garbage collected hash table for anything whatsoever.
> 
> Especially if the given objects are in some way created/destroyed/etc. by
> operations triggerable remotely.
> 
> This can be DoS'd quite trivially, and that's why we have removed the ipv4
> routing cache which did the same.

Hmmm...  You have a point.  What would you suggest instead?  At least with the
common object cache code I have, I might be able to just change that.

Some thoughts/notes:

 (1) Connection objects must have a time delay before expiry after last use.

     A connection object represents a negotiated security context (involving
     sending CHALLENGE and RESPONSE packets) and stores a certain amount of
     crypto state set up that can be reused (potentially for up to 4 billion
     calls).

     The set up cost of a connection is therefore typically non-trivial (you
     can have a connection without any security, but this can only do
     anonymous operations since the negotiated security represents
     authentication as well as data encryption).

     Once I kill off an incoming connection object, I have to set up the
     connection object anew for the next call on the same connection.  Now,
     granted, it's always possible that there will be a new incoming call the
     moment I kill off a connection - but this is much more likely if the
     connection is killed off immediately.

     Similarly, outgoing connections are meant to be reusable, given the same
     parameters - but if, say, a client program is making a series of calls
     and I kill the connection off immediately a call is dead, then I have to
     set up a new connection for each call the client makes.

     The way AF_RXRPC currently works, userspace clients don't interact
     directly with connection and peer objects - only calls.  I'd rather not
     have to expose the management of those to userspace.

 (2) A connection also retains the final state of the call recently terminated
     on that connection in each call slot (channel) until that slot is reused.
     This allows re-sending of final ACK and ABORT packets.

     If I immediately kill off a connection, I can't do this.

 (3) A local endpoint object is a purely local affair, maximum count 1 per
     open AF_RXRPC socket.  These can be destroyed the moment all pinning
     sockets and connections are gone - but these aren't really a problem.

 (4) A peer object can be disposed of when all the connections using it are
     gone - at the cost of losing the determined MTU data.  That's probably
     fine, provided connections have delay before expiry.

 (5) Call objects can be disposed of immediately that they terminate and have
     communicated their last with userspace (I have to tell userspace that the
     identifier it gave us is released).  A call's last state is transferred
     to the parent connection object until a new call displaces it from the
     channel it was using.

 (6) Call objects have to persist for a while since a call involves the
     exchange of at least three packets (a minimum call is a request DATA
     packet with just an ID, a response DATA packet with no payload and then
     an ACK packet) and some communication with userspace.

     An attacker can just send us a whole bunch of request DATA packets, each
     with a different call/connection combination and attempt to run the
     server out of memory, no matter how the persistence is managed.

 (7) Why can't I have simple counters representing the maxmimum numbers of
     peer, connection and call objects in existence at any one time and return
     a BUSY packet to a remote client or EAGAIN to a local client if the
     counters are maxed out?

     I could probably also drive gc based on counter levels as well as expiry
     time.

 (8) Should I take it that I can't use RCU either as that also has a deferred
     garbage collection mechanism and so subject to being stuffed remotely?

     I really want to get spinlocks out of the incoming packet distribution
     path as that's driven from the data_ready handler of the transport
     socket.

David
