From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [2/3] POHMELFS: Documentation.
Date: Mon, 16 Jun 2008 14:20:50 +0400
Message-ID: <20080616102049.GA13894@2ka.mipt.ru>
References: <20080613163700.GA25860@2ka.mipt.ru> <20080613164110.GB26166@2ka.mipt.ru> <20080614021547.GC32232@shareable.org> <20080614065616.GA32585@2ka.mipt.ru> <Pine.LNX.4.64.0806142102550.3341@cobra.newdream.net> <20080615055722.GA2643@2ka.mipt.ru> <Pine.LNX.4.64.0806150918460.3341@cobra.newdream.net> <20080615175039.GA21838@2ka.mipt.ru> <Pine.LNX.4.64.0806151406330.3341@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Sage Weil <sage@newdream.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806151406330.3341@cobra.newdream.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Sun, Jun 15, 2008 at 08:17:46PM -0700, Sage Weil (sage@newdream.net) wrote:
> > I really do not understand your surprise :)
> 
> Well, I must still be misunderstanding you :(.  It sounded like you were 
> saying other network filesystems take the socket exclusively for the 
> duration of an entire operation (i.e., only a single RPC call oustanding 
> with the server at a time).  And I'm pretty sure that isn't the case...
> 
> Which means I'm still confused as to how POHMELFS's transactions are 
> fundamentally different here from, say, NFS's use of RPC.  In both cases, 
> multiple requests can be in flight, and the server is free to reply to 
> requests in any order.  And in the case of a timeout, RPC requests are 
> resent (to the same server.. let's ignore failover for the moment).  Am I 
> missing something?  Or giving NFS too much credit here?

Well, RPC is quite similar to what transaction is, at least its approach
to completion callbacks and theirs async invokation.
 
> > > So what happens if the user creates a new file, and then does a stat() to 
> > > expose i_ino.  Does that value change later?  It's not just 
> > > open-by-inode/cookie that make ino important.  
> > 
> > Local inode number is returned. Inode number does not change during
> > lifetime of the inode, so while it is alive always the same number will
> > be returned.
> 
> I see.  And if the inode drops out of the client cache, and is later 
> reopened, the st_ino seen by an application may change?  st_ino isn't used 
> for much, but I wonder if that would impact a large cp or rsync's ability 
> to preserve hard links.

There is number of cases when inode number will be preserved, like
parent inode holds its number in own subcache, so when it will lookup
object it will give it the same inode number, but generally if inode was
destroyed and then recreated its number can change.
 
> > You pointed to very interesting behaviour of the path based approach,
> > which bothers me quite for a while:
> > since cache coherency messages have own round-trip time, there is always
> > a window when one client does not know that another one updated object
> > or removed it and created new one with the same name.
> 
> Not if the server waits for the cache invalidation to be acked before 
> applying the update.  That is, treat the client's cached copy as a lease 
> or read lock.  I believe this is how NFSv4 delegations behave, and it's 
> how Ceph metadata leases (dentries, inode contents) and file access 
> capabilities (which control sync vs async file access) behave.  I'm not 
> all that familiar with samba, but my guess is that its leases are broken 
> synchronously as well.

That's why I still did not implement locking in POHMELFS - I do not want
to drop to sync case for essentially all operations, which will end up
broadcasting cache coherency messages. But this may be unavoidable case,
so I will have to implement it that way.

NFS-like delegation is really the simplest and not interesting case,
since it drops parallelism for multiple clients accessing the same data,
but 'creates' it for clients who do access to different datasets.

> > It is trivially possible to extend path cache with storing remote ids,
> > so that attempt to access old object would not harm new one with the
> > same name, but I want to think about it some more.
> 
> That's half of it... ideally, though, the client would have a reference to 
> the real object as well, so that the original foo.txt would be removed.  
> I.e. not only avoid doing the wrong thing, but also do the right thing.
> 
> I have yet to come up with a satisfying solution there.  Doing a d_drop on 
> dentry lease revocation gets me most of the way there (Ceph's path 
> generation could stop when it hits an unhashed dentry and make the request 
> path relative to an inode), but the problem I'm coming up against is that 
> there is no explicit communication of the CWD between the VFS and fs 
> (well, that I know of), so the client doesn't know when it needs a real 
> reference to the directory (and I'm not especially keen on taking 
> references for _all_ cached directory inodes).  And I'm not really sure 
> how .. is supposed to behave in that context.

Well, the same code was in previous POHMELFS releases and I dropped it.
I'm not sure yet what is exact requirements for locking and cache
coherency expected from such kind of distributed filesystem, so there is
no yet locking.

There will always be some kind of tradeoffs between parallel access and
caching, so drawing that line closer or far from what we have in local
filesystem will anyway have some drawbacks.

-- 
	Evgeniy Polyakov
