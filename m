From: Jamie Lokier <jamie@shareable.org>
Subject: Re: fanotify as syscalls
Date: Wed, 16 Sep 2009 08:52:19 +0100
Message-ID: <20090916075219.GA22024@shareable.org>
References: <20090911212731.GA19901@shareable.org> <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com> <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org> <20090914140720.GA8564@ioremap.net> <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com> <20090915201620.GB32192@ioremap.net> <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com> <alpine.LFD.2.01.0909151643540.4950@localhost.localdomain> <1253064391.5213.37.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1253064391.5213.37.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Paris wrote:
> On Tue, 2009-09-15 at 16:49 -0700, Linus Torvalds wrote:
> > And btw, I still want to know what's so wonderful about fanotify that we 
> > would actually want yet-another-filesystem-notification-interface. So I'm 
> > not sayying that I'll take a system call interface.
> 
> The real thing that fanotify provides is an open fd with the event
> rather than some arbitrary 'watch descriptor' that userspace must
> somehow magically map back to data on disk.  This means that it could be
> used to provide subtree notification, which inotify is completely
> incapable of doing.

That's a bit of a spurious claim.

- fanotify does not provide subtree notification in it's
  present form.  When it is extended to do that, why wouldn't
  inotify be as well?  That's an fsnotify feature, common to both.

- fanotify does not provide notification at all for some events that
  you get with inotify.  It is not a superset, so you can't use
  fanotify to provide a subtree-capable equivalent to inotify.  What
  a mess when you need the combination of both features!

- fanotify requires you call readlink(/proc/fd/N) for every event to
  get the path.  It's not a particularly efficient way to get it,
  especially when an apps wants to know if it's something in it's
  region of interest but doesn't care about the actual path.
  When an apps knows it needs the map back to to path, why make it
  slow to get it?  That "extensible data format" is being
  underutilised...

- fanotify's descriptor may be race-prone as a way to get the subtree
  used for access, because any of the parent directories could have
  moved and even been deleted before the app calls
  readlink(/proc/fd/N).  I don't know if a _reliable_ way to track
  changes in a subtree can be built on it.  Maybe it can but it
  appears this hasn't been analysed.  It depends on
  readlink(/proc/fd/N)'s behaviour when the dentry's have been
  changed, among other things.

- Does the descriptor cause umount to fail when user does "do some
  stuff in baz; umount baz", or does it serialise nicely?  That's one
  of inotify's nice features - it doesn't cause umounts to fail.

> And it can be used to provide system wide notification.  We all know
> who wants that.

People who want to break out of chroot/namespace jails using the
conveniently provided open file descriptor? :-)

Seriously, what does system-wide fanotify do when run from a
chroot/namespace/cgroup, and a file outside them is accessed?

If the event is delivered with file desciptor, that's a security hole.
If it's not delivered, that sounds like working subtree support?

I'd expect anti-malware to want to be run inside VMs quite often...

Note that there's no such thing as "the real system root" any more.

> It provides an extensible data format which allows growth impossible in
> inotify.  I don't know if anyone remember the inotify patches which
> wanted to overload the inotify cookie field for some other information,
> but inotify information extension is not reasonable or backwards
> compatible.

I agree with this (although that's what flags are for -- see clone).

I don't have a problem with the next interface being fanotify (despite
arguing a lot); I just want to see the next one being useful for the
things I would otherwise be proposing my own yet-another-interface
for.  So we don't need a fourth one soon after the third due to
easily foreseen limitations.

> I've got private commitments for two very large anti malware companies,
> both of which unprotect and hack syscall tables in their customer's
> kernels, that they would like to move to an fanotify interface.  Both
> Red Hat and Suse have expressed interest in these patches and have
> contributed to the patch set.
> 
> The patch set is actually rather small (entire set of about 20 patches
> is 1800 lines) as it builds on the fsnotify work already in 2.6.31 to
> reuse code from inotify rather than reimplement the same things over and
> over (like we previously had with inotify and dnotify)

I don't have any problem with either of these, and _fs_notify
generally seems like an improvement.  I don't have a problem with
fanotify either.  For what it does, it's ok.

> Don't know what else to say.....

Answer questions about use-cases that you're not interested in?  Why
block them?  What about Evigny's request for an event without an open
fd - because he needs the pid information (inotify doesn't provide)
but not the fd?

Sorry to be so harsh.  I'm really trying to make sure we don't repeat
the mistakes of dnotify and inotify, and end up with a third interface
which also is too restrictive (because it's good enough for your
anti-malware and HSM customers) so that a fourth interface will be
needed soon after.

I'd like to be able to use it from some applications to accelerate
userspace caching of things (faster Make, faster Samba) without
penalising all other applications touching unrelated parts of the
filesystem.  The attitude "you can live with 10% slowdown" worries me.
I'm sure that can be fixed with a bit of care.

If the intention is to maintain fanotify and inotify side-by-side for
different uses (because fanotify returns open descriptors and blocks
the accessing process until acked), that's ok with me.  It makes
sense.  But then it's messy that neither offers a superset of the
other regarding which files and events are tracked.

If it's right that inotify has no room for extensibility (I'm not sure
about this), than it appears we already made a mess with dnotify and
inotify, so it would be a shame to repeat the same mistakes again.
Let's get the next one right, even it takes a bit longer, ok?

-- Jamie
