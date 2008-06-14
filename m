From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [2/3] POHMELFS: Documentation.
Date: Sat, 14 Jun 2008 10:56:17 +0400
Message-ID: <20080614065616.GA32585@2ka.mipt.ru>
References: <20080613163700.GA25860@2ka.mipt.ru> <20080613164110.GB26166@2ka.mipt.ru> <20080614021547.GC32232@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080614021547.GC32232@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 14, 2008 at 03:15:47AM +0100, Jamie Lokier (jamie@shareable.org) wrote:
> > * Fast and scalable multithreaded userspace server. Being in
> >   userspace it works with any underlying filesystem and still is
> >   much faster than async in-kernel NFS one.
> 
> That's interesting :-)

Noreover, that's true :)
I regulary run and post various benchmarks comparing POHMELFS, NFS,
XFS and Ext4, main goal of POHMELFS at this stage is to be
essentially as fast as underlying local filesystem. And it is...
Though there is a single place (random reading, all others reached
FS speed, so it is from 10 to 300% faster than NFS in various loads :),
but I'm working on it, I think it is not server's side though.

> That sounds great, but what do you mean by 'novel'?  Don't other
> modern network filesystems use asynchronous requests and replies in
> some form?  It seems like the obvious thing.

Maybe it was a bit naive though :)
But I checked lots of implementation, all of them use send()/recv()
approach. NFSv4 uses a bit different, but it is a cryptic, and at least
from its names it is not clear:
like nfs_pagein_multi() -> nfs_pageio_complete() -> add_stats. Presumably
we add stats when we have data handy...
CIFS/SMB use synchronous approach.

>From those projects, which are not in kernel, like CRFS and CEPH, the
former uses async receiving thread, while the latter is synchronous,
but can select different servers for reading, more like NFSv4.1 leases.

> > * Transactions support. Full failover for all operations.
> >   Resending transactions to different servers on timeout or error.
> 
> By transactions, do you mean an atomic set of writes/changes?
> Or do you trace read dependencies too?

It covers all operations, including reading, directory listing, lookups,
attribite changes and so on. Its main goal is to allow transaparent
failover, so it has to be done for reading too.

> > Main feature of the POHMELFS is writeback data and metadata cache.
> > [...] Creation and removal of objects, as long as writing, are
> > asynchronous and are sent to the server during system writeback.
> > When server receives some request for given object in the system
> > (like data reading, or file creation or whatever else), it stores
> > appropriate client information in own cache, so when subsequent
> > request comes from different client, all previous could be notified
> > (for example when several clients read data from file, and then new
> > client writes there, appropriate pages on clients will be
> > invalidated, so subsequent write will force them to read page from
> > the server). Because of this feature POHMELFS is extremely fast in
> > metadata intensive workloads, and can fully utilize bandwidth to
> > servers when doing bulk data transafers.
> 
> This is extremely cool, and obviously the right thing to do.  No sane
> network filesystem would be without it, one naively hopes :-)
> 
> How is it different from NFSv4 leases and SMB oplocks?  Or are they
> the same basic idea?
> 
> With all those asynchronous requests, are your writeback caches fully
> coherent?  Example.  Client A reads file X (data: x0), then writes X
> (new data: x1), then reads Y (data: y0), then writes Y (data: y1).
> Client B reads Y then reads X.  Is it guaranteed that client B cannot
> ever get data y1 and x0?  A fully coherent system (meaning behaves
> like a local filesystem) does guarantee that.  If cache requests for
> file X and file Y are independent, this is not guaranteed.

Oplocks and leases are essentially lock on given file, which allows one
client to operate on it. POHMELFS does not have locks now, and they will
be created depending on how distributed server will require them. In the
simplesst case it can just lock file for writing and do not allow its
updates from other clients. Lock aciquite can be done at write_begin
time. Without lock and writeback cache in your case writeback for file Y
can happen before writeback for file X, but if client does not only
write, but also sync after its write, then yes, client will see later
updates after more earlier. POHMELFS does not broadcast its interest in
the file content until real writing happens, i.e. at writeback time.
Although I can add a mode, when the same will be done during
write_begin() time. In that case your example will work without sync.

> -- Jamie

-- 
	Evgeniy Polyakov
