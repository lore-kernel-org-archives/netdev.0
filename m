From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [2/3] POHMELFS: Documentation.
Date: Sun, 15 Jun 2008 21:50:39 +0400
Message-ID: <20080615175039.GA21838@2ka.mipt.ru>
References: <20080613163700.GA25860@2ka.mipt.ru> <20080613164110.GB26166@2ka.mipt.ru> <20080614021547.GC32232@shareable.org> <20080614065616.GA32585@2ka.mipt.ru> <Pine.LNX.4.64.0806142102550.3341@cobra.newdream.net> <20080615055722.GA2643@2ka.mipt.ru> <Pine.LNX.4.64.0806150918460.3341@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Sage Weil <sage@newdream.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806150918460.3341@cobra.newdream.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 15, 2008 at 09:41:44AM -0700, Sage Weil (sage@newdream.net) wrote:
> Oh, so you just mean that the caller doesn't, say, hold a mutex for the 
> socket for the duration of the send _and_ recv?  I'm kind of shocked that 
> anyone does that, although I suppose in some cases the protocol 
> effectively demands it.

First, socket has own internal lock, which protects against simultaneous
access to its structures, but POHMELFS has own mutex, which guards
network operations for given network state, so if server disconnected,
socket can be released and zeroed if needed, so that subsequent access
could detect it and made appropriate decision like try to reconnect.

I really do not understand your surprise :)
But it does possible to create a scheme, when you do not need to hold a
lock between commands for successfull complete. It is even possible not
to _expect_ that something will be received from given socket or
received at all. Courtesy of transactions: system locks only data, which
has to be processed, it does not lock sequence of commands which are
required for that data processing. Ordering is guarded by transactions.

> > That was somewhat old approach, currently inode numbers and things like
> > open-by-inode or NFS style open-by-cookie are not used. I tried to
> > describe caching bits in docuementation I ent, although its a bit rough
> > and likely incomplete :) Feel free to ask if there are some white areas
> > there.
> 
> So what happens if the user creates a new file, and then does a stat() to 
> expose i_ino.  Does that value change later?  It's not just 
> open-by-inode/cookie that make ino important.  

Local inode number is returned. Inode number does not change during
lifetime of the inode, so while it is alive always the same number will
be returned.

> It looks like the client/server protocol is primarily path-based. What 
> happens if you do something like
> 
> hosta$ cd foo
> hosta$ touch foo.txt
> hostb$ mv foo bar
> hosta$ rm foo.txt
> 
> Will hosta realize it really needs to do "unlink /bar/foo.txt"?

No, since it got a reference to object in local cache. But it will fail
to do something interesting with it, since it does not really exist on
server anymore.
When 'hosta' will reread higher directory (it will when needed, since
server will  send it cache coherency message, but thanks to your example,
rename really does not send it, only remove :), so I will update server),
it will detect that directory changed its name and later will use it.
After reread system actually can not know if directory was renamed or it
is completely new one with the same files.

You pointed to very interesting behaviour of the path based approach,
which bothers me quite for a while:
since cache coherency messages have own round-trip time, there is always
a window when one client does not know that another one updated object
or removed it and created new one with the same name.
It is trivially possible to extend path cache with storing remote ids,
so that attempt to access old object would not harm new one with the
same name, but I want to think about it some more.
Correct solution is to use locks of course, and I'm not 100% it worse
changing at all without them, but it is interesting...

-- 
	Evgeniy Polyakov
