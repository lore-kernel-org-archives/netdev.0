From: Sage Weil <sage@newdream.net>
Subject: Re: [2/3] POHMELFS: Documentation.
Date: Sun, 15 Jun 2008 20:17:46 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0806151406330.3341@cobra.newdream.net>
References: <20080613163700.GA25860@2ka.mipt.ru> <20080613164110.GB26166@2ka.mipt.ru>
 <20080614021547.GC32232@shareable.org> <20080614065616.GA32585@2ka.mipt.ru>
 <Pine.LNX.4.64.0806142102550.3341@cobra.newdream.net> <20080615055722.GA2643@2ka.mipt.ru>
 <Pine.LNX.4.64.0806150918460.3341@cobra.newdream.net> <20080615175039.GA21838@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamie Lokier <jamie@shareable.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080615175039.GA21838@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 15 Jun 2008, Evgeniy Polyakov wrote:
> On Sun, Jun 15, 2008 at 09:41:44AM -0700, Sage Weil (sage@newdream.net) wrote:
> > Oh, so you just mean that the caller doesn't, say, hold a mutex for the 
> > socket for the duration of the send _and_ recv?  I'm kind of shocked that 
> > anyone does that, although I suppose in some cases the protocol 
> > effectively demands it.
> 
> First, socket has own internal lock, which protects against simultaneous
> access to its structures, but POHMELFS has own mutex, which guards
> network operations for given network state, so if server disconnected,
> socket can be released and zeroed if needed, so that subsequent access
> could detect it and made appropriate decision like try to reconnect.

Right...

> I really do not understand your surprise :)

Well, I must still be misunderstanding you :(.  It sounded like you were 
saying other network filesystems take the socket exclusively for the 
duration of an entire operation (i.e., only a single RPC call oustanding 
with the server at a time).  And I'm pretty sure that isn't the case...

Which means I'm still confused as to how POHMELFS's transactions are 
fundamentally different here from, say, NFS's use of RPC.  In both cases, 
multiple requests can be in flight, and the server is free to reply to 
requests in any order.  And in the case of a timeout, RPC requests are 
resent (to the same server.. let's ignore failover for the moment).  Am I 
missing something?  Or giving NFS too much credit here?


> > So what happens if the user creates a new file, and then does a stat() to 
> > expose i_ino.  Does that value change later?  It's not just 
> > open-by-inode/cookie that make ino important.  
> 
> Local inode number is returned. Inode number does not change during
> lifetime of the inode, so while it is alive always the same number will
> be returned.

I see.  And if the inode drops out of the client cache, and is later 
reopened, the st_ino seen by an application may change?  st_ino isn't used 
for much, but I wonder if that would impact a large cp or rsync's ability 
to preserve hard links.


> > It looks like the client/server protocol is primarily path-based. What 
> > happens if you do something like
> > 
> > hosta$ cd foo
> > hosta$ touch foo.txt
> > hostb$ mv foo bar
> > hosta$ rm foo.txt
> > 
> > Will hosta realize it really needs to do "unlink /bar/foo.txt"?
> 
> No, since it got a reference to object in local cache. But it will fail
> to do something interesting with it, since it does not really exist on
> server anymore.
> When 'hosta' will reread higher directory (it will when needed, since
> server will  send it cache coherency message, but thanks to your example,
> rename really does not send it, only remove :), so I will update server),
> it will detect that directory changed its name and later will use it.
> After reread system actually can not know if directory was renamed or it
> is completely new one with the same files.
>
> You pointed to very interesting behaviour of the path based approach,
> which bothers me quite for a while:
> since cache coherency messages have own round-trip time, there is always
> a window when one client does not know that another one updated object
> or removed it and created new one with the same name.

Not if the server waits for the cache invalidation to be acked before 
applying the update.  That is, treat the client's cached copy as a lease 
or read lock.  I believe this is how NFSv4 delegations behave, and it's 
how Ceph metadata leases (dentries, inode contents) and file access 
capabilities (which control sync vs async file access) behave.  I'm not 
all that familiar with samba, but my guess is that its leases are broken 
synchronously as well.

> It is trivially possible to extend path cache with storing remote ids,
> so that attempt to access old object would not harm new one with the
> same name, but I want to think about it some more.

That's half of it... ideally, though, the client would have a reference to 
the real object as well, so that the original foo.txt would be removed.  
I.e. not only avoid doing the wrong thing, but also do the right thing.

I have yet to come up with a satisfying solution there.  Doing a d_drop on 
dentry lease revocation gets me most of the way there (Ceph's path 
generation could stop when it hits an unhashed dentry and make the request 
path relative to an inode), but the problem I'm coming up against is that 
there is no explicit communication of the CWD between the VFS and fs 
(well, that I know of), so the client doesn't know when it needs a real 
reference to the directory (and I'm not especially keen on taking 
references for _all_ cached directory inodes).  And I'm not really sure 
how .. is supposed to behave in that context.

Anyway...

sage
