From: Sage Weil <sage@newdream.net>
Subject: Re: [2/3] POHMELFS: Documentation.
Date: Sat, 14 Jun 2008 21:27:55 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0806142102550.3341@cobra.newdream.net>
References: <20080613163700.GA25860@2ka.mipt.ru> <20080613164110.GB26166@2ka.mipt.ru>
 <20080614021547.GC32232@shareable.org> <20080614065616.GA32585@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamie Lokier <jamie@shareable.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080614065616.GA32585@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

On Sat, 14 Jun 2008, Evgeniy Polyakov wrote:
> > That sounds great, but what do you mean by 'novel'?  Don't other
> > modern network filesystems use asynchronous requests and replies in
> > some form?  It seems like the obvious thing.
> 
> Maybe it was a bit naive though :)
> But I checked lots of implementation, all of them use send()/recv()
> approach. NFSv4 uses a bit different, but it is a cryptic, and at least
> from its names it is not clear:
> like nfs_pagein_multi() -> nfs_pageio_complete() -> add_stats. Presumably
> we add stats when we have data handy...
> CIFS/SMB use synchronous approach.

By synchronous/asynchronous, are you talking about whether writepages() 
blocks until the write is acked by the server?  (Really, any FS that does 
writeback is writing asynchronously...)

> >From those projects, which are not in kernel, like CRFS and CEPH, the
> former uses async receiving thread, while the latter is synchronous,
> but can select different servers for reading, more like NFSv4.1 leases.

Well... Ceph writes synchronously (i.e. waits for ack in write()) only 
when write-sharing on a single file between multiple clients, when it is 
needed to preserve proper write ordering semantics.  The rest of the time, 
it generates nice big writes via writepages().  The main performance issue 
is with small files... the fact that writepages() waits for an ack and is 
usually called from only a handful of threads limits overall throughput.  
If the writeback path was asynchronous as well that would definitely help 
(provided writeback is still appropriately throttled).  Is that what 
you're doing in POHMELFS?

> > > * Transactions support. Full failover for all operations.
> > >   Resending transactions to different servers on timeout or error.
> > 
> > By transactions, do you mean an atomic set of writes/changes?
> > Or do you trace read dependencies too?
> 
> It covers all operations, including reading, directory listing, lookups,
> attribite changes and so on. Its main goal is to allow transaparent
> failover, so it has to be done for reading too.

Your meaning of "transaction" confused me as well.  It sounds like you 
just mean that the read/write operation is retried (asynchronously), and 
may be redirected at another server if need be.  And that writes can be 
directed at multiple servers, waiting for an ack from both.  Is that 
right?

I my view the writeback metadata cache is definitely the most exciting 
part about this project.  Is there a document that describes where the 
design ended up?  I seem to remember a string of posts describing your 
experiements with client-side inode number assignment and how that is 
reconciled with the server.  Keeping things consistent between clients is 
definitely the tricky part, although I suspect that even something with 
very coarse granularity (e.g., directory/subtree-based locking/leasing) 
will capture most of the performance benefits for most workloads.

Cheers-
sage
