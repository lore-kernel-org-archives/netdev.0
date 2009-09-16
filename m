From: Eric Paris <eparis@redhat.com>
Subject: Re: fanotify as syscalls
Date: Wed, 16 Sep 2009 18:33:21 -0400
Message-ID: <1253140401.5213.189.camel@dhcp231-106.rdu.redhat.com>
References: <20090915201620.GB32192@ioremap.net>
	 <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
	 <alpine.LFD.2.01.0909151643540.4950@localhost.localdomain>
	 <1253064391.5213.37.camel@dhcp231-106.rdu.redhat.com>
	 <20090916075219.GA22024@shareable.org>
	 <20090916114111.2228f0fc@linux.intel.com>
	 <20090916114107.GB29359@shareable.org>
	 <20090916130127.439c9222@lxorguk.ukuu.org.uk>
	 <20090916125658.GF29359@shareable.org>
	 <1253116380.5213.121.camel@dhcp231-106.rdu.redhat.com>
	 <20090916214916.GB6243@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Alan Cox <alan@linux.intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk, hch@infradead.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760230AbZIPWdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 18:33:47 -0400
In-Reply-To: <20090916214916.GB6243@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-16 at 22:49 +0100, Jamie Lokier wrote:
> Eric Paris wrote:
> > On Wed, 2009-09-16 at 13:56 +0100, Jamie Lokier wrote:
> > > Alan Cox wrote:
> > > > > You can't rely on the name being non-racy, but you _can_ reliably
> > > > > invalidate application-level caches from the sequence of events
> > > > > including file writes, creates, renames, links, unlinks, mounts.  And
> > > > > revalidate such caches by the absence of pending events.
> > > > 
> > > > You can't however create the caches reliably because you've no idea if
> > > > you are referencing the right object in the first place - which is why
> > > > you want a handle in these cases. I see fanotify as a handle producing
> > > > addition to inotify, not as a replacement (plus some other bits around
> > > > open blocking for HSM etc)
> > > 
> > > There are two sets of events getting mixed up here.  Inode events -
> > > reads, writes, truncates, chmods; and directory events - renames,
> > > links, creates, unlinks.
> > 
> > My understanding of you argument is that fanotify does not yet provide
> > all inotify events, namely those of directories operations and thus is
> > not suitable to wholesale replace everything inotify can do.
> 
> Largely that, plus seeing fanotify look like it'll acquire some
> capabilities that would be useful with those inotify events and
> inotify not getting them.  Bothered by the apparent direction of
> development, really.
> 
> Btw, I'm not sure you can use inotify+fanotify together simultaneously
> in this way, which may be of benefit - caching might help the
> anti-malware-style access controls.  I'll have to think carefully
> about ordering of some events, and using fanotify and inotify
> independently at the same time loses that ordering.

As soon as you say "ordering" you lose   :)

> 
> > I've already said that working towards that goal is something I plan
> > to pursue,
> 
> Sorry, I missed that, just as I didn't find a reply to Evigny's "I
> need pids".  And from another mail, I thought you were stopping at the
> things with file descriptors.
> 
> > but for now, you still have inotify.
> 
> That's right.  And it sucks for subtrees, so that's why I'd like to
> absorb improvements on subtree inclusions, and exclusion nodes look
> useful too.
> 
> > The mlocate/updatedb people ask me about fanotify and it's on the todo
> > list to allow global reception of of such events.  The fd you get would
> > be of the dir where the event happened.  They didn't care, and I haven't
> > decided if we would provide the path component like inotify does.  Most
> > users are perfectly happy to stat everything in the dir.
> 
> mlocate/updatedb is relatively low performance and of course wants to
> be system-wide.  It's not looking so good if a user wants an indexer
> just on their /home, and the administrator does not want everyone else
> to pay the cost.
> 
> But I think we're quite agreed on how useful subtrees would be.
> System-wide events won't be needed if we can monitor the / subtree
> to get the same effect, and that'll also sort out namespaces and chroots.
> 
> Stat'ing every entry in a dir event.  Thinking out loud:
> 
>    1. Stat'ing everything in a dir just to find out which 1 file was
>       deleted can be quite expensive for some uses (if you have a
>       large dir and it happens a lot), and is unpleasant just because
>       each change _should_ result in about O(1) work.  Taste, style,
>       elegance ;-)
>
>       For POSIX filesystems, I don't see any logical problem with
>       this, actually.  You don't need to call stat()!  It's enough to
>       call readdir() and look at d_ino to track
>       renames/links/creates/unlinks - assuming only directory-change
>       events are relevant here.
> 
>       Just an unpleasant O(n) scaling with directory size.
> 
>       (Note that I ignore mount points not returning the correct
>       d_ino, because apps can track the mount list and
>       compensate; they should be doing this anyway).

I think we generally agree here.

> 
>    2. updatedb-style indexing apps don't care about the
>       readdir/stat-all-entries cost, because they don't need to read
>       the directory after every change, they only need to do it once
>       every 24 hours if any events were received in that interval!
> 
>       (Obviously this isn't the same for pseudo-real-time indexers.)

See, that's why the mlocate/updatedb contacted me.  They don't want it
to be a 24 hour thing.  They was pseudo real time without thrashing the
hd.  Turns out, the interface is there, and the backend just needs
struct path information available to give it to them.

>       For Samba-style caching, on the other hand, the cost of
>       rescanning a large directory when one file is being read often
>       and another file in it is changing often might be prohibitive,
>       forcing it to use heuristics to decide when to monitor a
>       directory and when not to to cache it, depending on directory
>       size.  I'd rather avoid that.

This seems like you are confusing the events that happen to a directory
(mv/rename) and the events that happen to a file (read/write.)   (The
former I do not have code for, the latter I do) Which is surprising
since you so clearly delineate them later, so maybe I'm
misunderstanding.

>    3. Non-POSIX filesystems don't always have stable inode numbers.
>       You can't tell that foo was renamed to bar by reading the
>       directory and looking at d_ino, or by calling stat on each entry.
> 
>       You can assume stable inode numbers for inodes where there's an
>       open file descriptor; that *might* be just enough to squeeze
>       through the logic of a cache.  I'm not sure right now.
> 
>    4. You can't tell when file contents are changed from stat info.
> 
>       That means you have to receive an inode event, not a directory
>       event for data changes, but that's not a problem of course - the
>       name-used-for-access isn't useful for data changes anyway
>       (except for debugging perhaps).
> 
>    5. stat() doesn't tell you about xattr and ACL changes.  xattrs can
>       be large and slow to read on a whole directory.  But as point 4,
>       if attribute changes count as inode changes, there's no problem.
> 
>    6. Calling stat() pulls a lot into cache that doesn't need to be in
>       cache: all those inodes.  But as I mentioned in points 1, 4 and
>       5, provided only directory name operations pass the directory to
>       be scanned, and inode operations always pass the inode, you can
>       use readdir() and avoid stat(), so the inodes don't have to be
>       pulled into cache after all.
> 
>       Except for non-POSIX inode instability.  Would be good to work
>       out if that breaks the algorithm.
> 
> In summary, calling readdir() and maybe stat/getxattr on each entry in
> a directory might be workable, but I'd rather it was avoidable.
> Simple apps may prefer to do it anyway - and let multiple events in a
> directory be merged as a result.
> 
> While I'm here it would be nice to receive one event instead of two
> for operations which involve two paths: link, rename and bind mount.
> Having to pair up two events from inotify isn't helpful in any way.

What do you propose the format of the event should be.  Is this
precluded in what's been proposed?

> Imho an API that satisfies everything we've talking about would let
> you specify which fields you want to receive in the event when you
> bind a listener.  Not _everything_ is selectable of course, but
> whether you want:
> 
>     For inode events (data read/write, attribute/ACL/xattr changes):
> 
>     - Open file descriptor of the affected file [Optional].

Could be added and I've agreed to take a look.  I'm just not sure
bringing back the major flaw of inotify is really moving us forward.

>     - The inode number and device number (always?).

hmmm, if you have the fd you have both, if you choose to get a wd like
inotify, I say you're still own your own to do the magic map.  I don't
want to copy tons of almost always useless data into userspace.

>     - A way to identify the vfsmount (due to bind mounts making the
>       device number insufficient to identify a directory; always?).

Now you want reliable path names?  I need a vfsmount in kernel to open
the fd for userspace, but I don't see how that's translatable to
anything even remotely useable by userspace....

>     For directory events (create/unlink/link/rename/reflink/mkdir/rmdir
>     /mount/umount):
> 
>     - Same as inode above, for the object created/linked/deleted.
> 
>     - Same as inode above, for the directory containing the source name.
>     - Source name [Optional].
>     - Same as above, for the directory containing the target name
>     - Target name [Optional]
> 
>     Source and target are the two names for
>     rename/link/reflink/bind-mount operations.  Otherwise there is
>     only one name to include.
> 
> Ironically, it begins to look a bit like netlink ;-)
> 
> As you can see, I've made the open descriptors optional, and the names
> for directory events optional.  For directory events, the object
> descriptor option should be independent from the source/target
> directory descriptor option.
> 
> Add one more option: wait for Ack before file accessing process can
> proceed, or don't require Ack.  That basically distinguishes inotify
> behaviour from fsnotify behaviour.

Those 2 things are completely independent.  If you request read with
blocking you get read with blocking.  If you request just read, you get
just read.

> It's not obvious, but that option's useful for directory events too,
> if you think about it: Think like an anti-malware or other access
> control manager, and ask: what if I have to block something which
> depends on the layout of files?  Just as directory events are enough
> for caching, they are enough for complete access control of
> layout-dependent state too.  For example, some line of text is no
> problem in a random file, but might be forbidden by the access manager
> from appearing in .bash_login, including by "mv harmless .bash_login".

I'd say they can realize the bad data when .bash_login is next opened
and deny access then  :)

No, it's honestly a good idea, and one that is going to likely take
serious hook movement.  A lot of these things can go on the todo list,
but don't sound like show stoppers to me....

> > It's hopefully feasible, but it's going to take some fsnotify hook
> > movements and possibly so arguments with Al to get the information I
> > want where I want it.
> 
> That may, indeed, be a sticking point :-)

My silent comrade from suse is looking at moving some hooks as we speak
so hopefully directory events can get added shortly after a merge.  I
don't think we should wait until every conceived (but not necessarily
needed) possibility is coded.  We have things that work, meet needs, and
hopefully you'll agree leave us with a place to go in the future.  Do
you?

-Eric

