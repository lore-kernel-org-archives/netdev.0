From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [2/3] POHMELFS: Documentation.
Date: Sun, 15 Jun 2008 09:57:22 +0400
Message-ID: <20080615055722.GA2643@2ka.mipt.ru>
References: <20080613163700.GA25860@2ka.mipt.ru> <20080613164110.GB26166@2ka.mipt.ru> <20080614021547.GC32232@shareable.org> <20080614065616.GA32585@2ka.mipt.ru> <Pine.LNX.4.64.0806142102550.3341@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Sage Weil <sage@newdream.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755958AbYFOF5a@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806142102550.3341@cobra.newdream.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sage.

On Sat, Jun 14, 2008 at 09:27:55PM -0700, Sage Weil (sage@newdream.net) wrote:
> By synchronous/asynchronous, are you talking about whether writepages() 
> blocks until the write is acked by the server?  (Really, any FS that does 
> writeback is writing asynchronously...)

Yes, not only writepage, but any request - if it sends sequest and then
receives reply (i.e. doing send/recv sequence without ability to do
something else in between or allow other users to do sends or receives
into the same socket), then it is synchronous. If it only sends, and
someone else receives, it is possible to send multiple requests from
different users who do reads or writes or lookups or whatever and
asynchronously in different thread receive replies not in particular
order, so this approach I call asynchronous.

> Well... Ceph writes synchronously (i.e. waits for ack in write()) only 
> when write-sharing on a single file between multiple clients, when it is 
> needed to preserve proper write ordering semantics.  The rest of the time, 
> it generates nice big writes via writepages().  The main performance issue 
> is with small files... the fact that writepages() waits for an ack and is 
> usually called from only a handful of threads limits overall throughput.  
> If the writeback path was asynchronous as well that would definitely help 
> (provided writeback is still appropriately throttled).  Is that what 
> you're doing in POHMELFS?

Yes, POHMELFS does writing that way.

> > > > * Transactions support. Full failover for all operations.
> > > >   Resending transactions to different servers on timeout or error.
> > > 
> > > By transactions, do you mean an atomic set of writes/changes?
> > > Or do you trace read dependencies too?
> > 
> > It covers all operations, including reading, directory listing, lookups,
> > attribite changes and so on. Its main goal is to allow transaparent
> > failover, so it has to be done for reading too.
> 
> Your meaning of "transaction" confused me as well.  It sounds like you 
> just mean that the read/write operation is retried (asynchronously), and 
> may be redirected at another server if need be.  And that writes can be 
> directed at multiple servers, waiting for an ack from both.  Is that 
> right?

Not exactly. Transaction in a nutshell is a wrapper on top of command
(or multiple commands if needed like in writing), which contains all
information needed to perform appropriate action. When user calls read()
or 'ls' or write() or whatever, POHMELFS creates transaction for that
operation and tries to perform it (if operation is not cached, in that
case nothing actually happens). When transaction is submitted, it
becomes part of the failover state machine which will check if data has
to be read from different server or written to new one or dropped.
original caller may not even know from which server its data will be
received. If request sending failed in the middle, the whole transaction
will be redirected to new one. It is also possible to redo transaction
against different server, if server sent us error (like I'm busy), but
this functionality was dropped in previous release iirc, this can be
resurrected though. Having generic transaction tree callers do not
bother about how to store theirs requests, how to wait for results and
how to complete them - transactions do it for them. It is not rocket
science, but extrmely effective and simple way to help rule out
asynchronous machinery.

> I my view the writeback metadata cache is definitely the most exciting 
> part about this project.  Is there a document that describes where the 
> design ended up?  I seem to remember a string of posts describing your 
> experiements with client-side inode number assignment and how that is 
> reconciled with the server.  Keeping things consistent between clients is 
> definitely the tricky part, although I suspect that even something with 
> very coarse granularity (e.g., directory/subtree-based locking/leasing) 
> will capture most of the performance benefits for most workloads.

That was somewhat old approach, currently inode numbers and things like
open-by-inode or NFS style open-by-cookie are not used. I tried to
describe caching bits in docuementation I ent, although its a bit rough
and likely incomplete :) Feel free to ask if there are some white areas
there.

-- 
	Evgeniy Polyakov
