From: Jamie Lokier <jamie@shareable.org>
Subject: Re: fanotify as syscalls
Date: Wed, 16 Sep 2009 12:41:07 +0100
Message-ID: <20090916114107.GB29359@shareable.org>
References: <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org> <20090914140720.GA8564@ioremap.net> <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com> <20090915201620.GB32192@ioremap.net> <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com> <alpine.LFD.2.01.0909151643540.4950@localhost.localdomain> <1253064391.5213.37.camel@dhcp231-106.rdu.redhat.com> <20090916075219.GA22024@shareable.org> <20090916114111.2228f0fc@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk, hch@infradead.org
To: Alan Cox <alan@linux.intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090916114111.2228f0fc@linux.intel.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> > - fanotify does not provide subtree notification in it's
> >   present form.  When it is extended to do that, why wouldn't
> >   inotify be as well?  That's an fsnotify feature, common to both.
> 
> Because inotify gives you no reliable access to the object monitored as
> the name passed back is not an object reference and is racy. Inotify is
> fine for making pretty icons pop up on desktops and making file
> selectors update, but it is somewhat inadequate for indexers and
> completely useless for stuff like HSM.

That was my point.  (Why do people keep not getting it?)

You can't rely on the name being non-racy, but you _can_ reliably
invalidate application-level caches from the sequence of events
including file writes, creates, renames, links, unlinks, mounts.  And
revalidate such caches by the absence of pending events.

(There is one obscure case which inotify is missing, though, which
means it cannot detect file changes in certain cases with hard links.
I intend to fix that one.)

For that, an inode isn't useful, a descriptor isn't useful, a
directory descriptor/inode and pathname isn't useful, and file write
events by themselves aren't useful.  None of them quite do it by
themselves.

But with the correct combination of events, you can maintain very
efficient application-level caching of file data / directory listing
and lookups / stat results you have previously read from the
filesystem.  That's because the information you have previously
depended upon, including path lookups, are all notified as one sort of
inotify event or another when changed.

Which doesn't sound all that special until you realise you can very
quickly revalidate application-caches of any data structure calculated
from reading things from the filesystem, no matter how many
prerequisites or how complex the data structures, in a single system
call.  Amortised over many revalidations if you have them in parallel.

That can apply to things like git, make, ccache, samba, rsync, httpd
path walks, and virtually any "web templating" framework.  Of course
it takes userspace support as well, but that's where I'm coming from
regarding "acceleration" and the essential kernel infrastructure.

Clearly, I'm going to have to explain with working code :-)

> but it is somewhat inadequate for indexers

For indexers, the real inadequacy is the need to attach inotify
watches to every directory at system startup, and to stat() everything
to check it hasn't changed since the indexer was last running.  Both
are very slow on a large directory tree.  The former can be dealt with
using subtree watches (yes, even with hard links - I have proposed an
algorithm for this but I think nobody understood it ;-).  The latter
needs filesystem support for a persistent change attribute.

> > - fanotify requires you call readlink(/proc/fd/N) for every event to
> >   get the path.  It's not a particularly efficient way to get it,
> 
> IFF you want the path, but the path isn't usually the most valuable bit.
> Plus you'll find the readlink is extremely quick anyway.

I agree, you don't usually want the whole path.

So what was the point about fanotify making subtree tracking possible
with it's file descriptor, if not by readlink(/proc/fd/N)?
Descriptors don't tell you which subtree a file is in any better than
inotify watches.  I.e. they do, if you track them and their containing
directories all individually.

> > People who want to break out of chroot/namespace jails using the
> > conveniently provided open file descriptor? :-)
> 
> chroot isn't a security model. You can already do this with AF_UNIX
> sockets (and there are apps that intentionally use fchdir that way)

Ah, no.  AF_UNIX works with explicit sender cooperation.

fanotify gives you access to files without sender cooperation, as it
intercepts every open().

> > I'd expect anti-malware to want to be run inside VMs quite often...
> 
> Inside of containers - unlikely.

Why not?  Some people run entire distributions in containiners, and
present them as VMs to the world for other people to admin.

> > the accessing process until acked), that's ok with me.  It makes
> > sense.  But then it's messy that neither offers a superset of the
> > other regarding which files and events are tracked.
> 
> Agreed.

In the end this is my main gripe.

-- Jamie

