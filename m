From: Jamie Lokier <jamie@shareable.org>
Subject: Re: fanotify as syscalls
Date: Wed, 16 Sep 2009 22:49:16 +0100
Message-ID: <20090916214916.GB6243@shareable.org>
References: <20090915201620.GB32192@ioremap.net> <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com> <alpine.LFD.2.01.0909151643540.4950@localhost.localdomain> <1253064391.5213.37.camel@dhcp231-106.rdu.redhat.com> <20090916075219.GA22024@shareable.org> <20090916114111.2228f0fc@linux.intel.com> <20090916114107.GB29359@shareable.org> <20090916130127.439c9222@lxorguk.ukuu.org.uk> <20090916125658.GF29359@shareable.org> <1253116380.5213.121.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Alan Cox <alan@linux.intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk, hch@infradead.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1253116380.5213.121.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Paris wrote:
> On Wed, 2009-09-16 at 13:56 +0100, Jamie Lokier wrote:
> > Alan Cox wrote:
> > > > You can't rely on the name being non-racy, but you _can_ reliably
> > > > invalidate application-level caches from the sequence of events
> > > > including file writes, creates, renames, links, unlinks, mounts.  And
> > > > revalidate such caches by the absence of pending events.
> > > 
> > > You can't however create the caches reliably because you've no idea if
> > > you are referencing the right object in the first place - which is why
> > > you want a handle in these cases. I see fanotify as a handle producing
> > > addition to inotify, not as a replacement (plus some other bits around
> > > open blocking for HSM etc)
> > 
> > There are two sets of events getting mixed up here.  Inode events -
> > reads, writes, truncates, chmods; and directory events - renames,
> > links, creates, unlinks.
> 
> My understanding of you argument is that fanotify does not yet provide
> all inotify events, namely those of directories operations and thus is
> not suitable to wholesale replace everything inotify can do.

Largely that, plus seeing fanotify look like it'll acquire some
capabilities that would be useful with those inotify events and
inotify not getting them.  Bothered by the apparent direction of
development, really.

Btw, I'm not sure you can use inotify+fanotify together simultaneously
in this way, which may be of benefit - caching might help the
anti-malware-style access controls.  I'll have to think carefully
about ordering of some events, and using fanotify and inotify
independently at the same time loses that ordering.

> I've already said that working towards that goal is something I plan
> to pursue,

Sorry, I missed that, just as I didn't find a reply to Evigny's "I
need pids".  And from another mail, I thought you were stopping at the
things with file descriptors.

> but for now, you still have inotify.

That's right.  And it sucks for subtrees, so that's why I'd like to
absorb improvements on subtree inclusions, and exclusion nodes look
useful too.

> The mlocate/updatedb people ask me about fanotify and it's on the todo
> list to allow global reception of of such events.  The fd you get would
> be of the dir where the event happened.  They didn't care, and I haven't
> decided if we would provide the path component like inotify does.  Most
> users are perfectly happy to stat everything in the dir.

mlocate/updatedb is relatively low performance and of course wants to
be system-wide.  It's not looking so good if a user wants an indexer
just on their /home, and the administrator does not want everyone else
to pay the cost.

But I think we're quite agreed on how useful subtrees would be.
System-wide events won't be needed if we can monitor the / subtree
to get the same effect, and that'll also sort out namespaces and chroots.

Stat'ing every entry in a dir event.  Thinking out loud:

   1. Stat'ing everything in a dir just to find out which 1 file was
      deleted can be quite expensive for some uses (if you have a
      large dir and it happens a lot), and is unpleasant just because
      each change _should_ result in about O(1) work.  Taste, style,
      elegance ;-)

      For POSIX filesystems, I don't see any logical problem with
      this, actually.  You don't need to call stat()!  It's enough to
      call readdir() and look at d_ino to track
      renames/links/creates/unlinks - assuming only directory-change
      events are relevant here.

      Just an unpleasant O(n) scaling with directory size.

      (Note that I ignore mount points not returning the correct
      d_ino, because apps can track the mount list and
      compensate; they should be doing this anyway).

   2. updatedb-style indexing apps don't care about the
      readdir/stat-all-entries cost, because they don't need to read
      the directory after every change, they only need to do it once
      every 24 hours if any events were received in that interval!

      (Obviously this isn't the same for pseudo-real-time indexers.)

      For Samba-style caching, on the other hand, the cost of
      rescanning a large directory when one file is being read often
      and another file in it is changing often might be prohibitive,
      forcing it to use heuristics to decide when to monitor a
      directory and when not to to cache it, depending on directory
      size.  I'd rather avoid that.

   3. Non-POSIX filesystems don't always have stable inode numbers.
      You can't tell that foo was renamed to bar by reading the
      directory and looking at d_ino, or by calling stat on each entry.

      You can assume stable inode numbers for inodes where there's an
      open file descriptor; that *might* be just enough to squeeze
      through the logic of a cache.  I'm not sure right now.

   4. You can't tell when file contents are changed from stat info.

      That means you have to receive an inode event, not a directory
      event for data changes, but that's not a problem of course - the
      name-used-for-access isn't useful for data changes anyway
      (except for debugging perhaps).

   5. stat() doesn't tell you about xattr and ACL changes.  xattrs can
      be large and slow to read on a whole directory.  But as point 4,
      if attribute changes count as inode changes, there's no problem.

   6. Calling stat() pulls a lot into cache that doesn't need to be in
      cache: all those inodes.  But as I mentioned in points 1, 4 and
      5, provided only directory name operations pass the directory to
      be scanned, and inode operations always pass the inode, you can
      use readdir() and avoid stat(), so the inodes don't have to be
      pulled into cache after all.

      Except for non-POSIX inode instability.  Would be good to work
      out if that breaks the algorithm.

In summary, calling readdir() and maybe stat/getxattr on each entry in
a directory might be workable, but I'd rather it was avoidable.
Simple apps may prefer to do it anyway - and let multiple events in a
directory be merged as a result.

While I'm here it would be nice to receive one event instead of two
for operations which involve two paths: link, rename and bind mount.
Having to pair up two events from inotify isn't helpful in any way.

Imho an API that satisfies everything we've talking about would let
you specify which fields you want to receive in the event when you
bind a listener.  Not _everything_ is selectable of course, but
whether you want:

    For inode events (data read/write, attribute/ACL/xattr changes):

    - Open file descriptor of the affected file [Optional].
    - The inode number and device number (always?).
    - A way to identify the vfsmount (due to bind mounts making the
      device number insufficient to identify a directory; always?).

    For directory events (create/unlink/link/rename/reflink/mkdir/rmdir
    /mount/umount):

    - Same as inode above, for the object created/linked/deleted.

    - Same as inode above, for the directory containing the source name.
    - Source name [Optional].
    - Same as above, for the directory containing the target name
    - Target name [Optional]

    Source and target are the two names for
    rename/link/reflink/bind-mount operations.  Otherwise there is
    only one name to include.

Ironically, it begins to look a bit like netlink ;-)

As you can see, I've made the open descriptors optional, and the names
for directory events optional.  For directory events, the object
descriptor option should be independent from the source/target
directory descriptor option.

Add one more option: wait for Ack before file accessing process can
proceed, or don't require Ack.  That basically distinguishes inotify
behaviour from fsnotify behaviour.

It's not obvious, but that option's useful for directory events too,
if you think about it: Think like an anti-malware or other access
control manager, and ask: what if I have to block something which
depends on the layout of files?  Just as directory events are enough
for caching, they are enough for complete access control of
layout-dependent state too.  For example, some line of text is no
problem in a random file, but might be forbidden by the access manager
from appearing in .bash_login, including by "mv harmless .bash_login".

The above is not a final proposal, but I'd be delighted if you'd take
a look at whether it's suitable.  I realise some things may not work
out for implementation reasons.

Meanwhile, I'll take a look at userspace code for my caching algorithm
and see how well that works out.  I think we'll get subtree monitors
out of this before the month is over...

> It's hopefully feasible, but it's going to take some fsnotify hook
> movements and possibly so arguments with Al to get the information I
> want where I want it.

That may, indeed, be a sticking point :-)

> But there is nothing about the interface that
> precludes it and it has been discussed and considered.
> 
> Am I still missing it?

No I think we're on the same wavelength now.  Thanks for being
patient.  (And thanks, Alan, for stepping in and making me describe
what I had in mind better).

-- Jamie
