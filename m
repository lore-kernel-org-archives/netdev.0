From: Jamie Lokier <jamie@shareable.org>
Subject: Re: fanotify as syscalls
Date: Wed, 16 Sep 2009 13:17:08 +0100
Message-ID: <20090916121708.GD29359@shareable.org>
References: <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org> <20090914140720.GA8564@ioremap.net> <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com> <20090915201620.GB32192@ioremap.net> <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com> <alpine.LFD.2.01.0909151643540.4950@localhost.localdomain> <1253064391.5213.37.camel@dhcp231-106.rdu.redhat.com> <20090916075219.GA22024@shareable.org> <1253094537.5213.89.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:40584 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbZIPMRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 08:17:20 -0400
Content-Disposition: inline
In-Reply-To: <1253094537.5213.89.camel@dhcp231-106.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Paris wrote:
> On Wed, 2009-09-16 at 08:52 +0100, Jamie Lokier wrote:
> > Eric Paris wrote:
> > > On Tue, 2009-09-15 at 16:49 -0700, Linus Torvalds wrote:
> > > rather than some arbitrary 'watch descriptor' that userspace must
> > > somehow magically map back to data on disk.  This means that it could be
> > > used to provide subtree notification, which inotify is completely
> > > incapable of doing.
> > 
> > That's a bit of a spurious claim.
> 
> My claim that a watch descriptor plus pathname segment sucks is
> spurious?  You've got to be kidding me.  You think that a number which
> represents the pathname of an object at some point in the past is a
> reasonable piece of information?  If a watch descriptor actually
> provided any information about the object on which an event just
> happened it would be useful.  Sadly, it doesn't.

It's subtler than that.  Too subtle, apparently.

For directory changes, the event represents the path in that
directory, which is useful, yes, even though the path may not be valid
by the time you receive the message.

It's useful because it tells userspace to invalidate any cached
information about that path, and because the _lack_ of such a message
after reading the inotify descriptor tells you that the path was valid
before the point where you started the read (if not memory-coherent,
then good enough for some applications).

I know, I know, it's sounding a bit obscure and questionable.

This is going to need explaining with real userspace code, so I'll
hack on that (when I have time - next few days) and get back to you.

I see now that my arguments aren't helping without clear working code,
mainly because you believe I'm talking poo and haven't a clue what I'm
talking about.

> It's already clear that an arbitrary watch descriptor which userspace
> has to somehow know how to correctly map back to an object (impossible
> task) is difficult to use and I personally don't see how watch
> descriptor + long path name component is somehow better or even
> reasonable.  Path names are such crap and passing a pathname to
> userspace is really just telling userspace, something happened to
> something that used to be at this location but is possibly long since
> gone.  I don't believe that's a good interface or one we should be
> allowing to be {ab,}used.

It's subtler than that.  Application caches depend on lookups as well
as inode operations.  A simple stat("/foo/bar") does.  Those path
components in events are the only way to invalidate/revalidate data
dependent on lookups.  Inodes (fstat->st_ino from the descriptor
returned by fanotify) are insufficient and cannot be used to
revalidate path lookups or data dependent on them.

Yes, it works even though the paths in events are not valid by the
time you get them.  In fact it _depends_ on getting those paths which
aren't valid by the time you get them.

> >   especially when an apps wants to know if it's something in it's
> >   region of interest but doesn't care about the actual path.
> >   When an apps knows it needs the map back to to path, why make it
> >   slow to get it?  That "extensible data format" is being
> >   underutilised...
> 
> You convince Al Viro that the vfs should give us a path name for an
> arbitrary object that honestly might not have one and I'll consider
> giving it to userspace in the event notification.  Probably should read
> some of the AppArmour arguments before you do though.  You're asking for
> something that's impossible and is at best incredibly race prone crap.
> At worst is a total lie.

No, I'm asking for something that clearly is not being understood here

I'm well aware of AppArmour and it's races etc.; it doesn't apply.

> > Seriously, what does system-wide fanotify do when run from a
> > chroot/namespace/cgroup, and a file outside them is accessed?
> 
> At the moment an fanotify global listener is system wide.  Truely system
> wide.  A gentleman from suse is looking rectify the problem so that if
> run inside a namespace it stays inside the namespace.  Note that this
> particular little tidbit is not in the 8 patches I proposed.  At the
> moment those just include the UI and basic notification.

I'll be really interested in the gentleman's solution.

In general bind mounts complicate cache maintenance with inotify
rather a lot.  That's another corner case to tidy up.  Bind mounts and
namespaces have a lot in common.

> Because I don't believe inotify can be reasonably extended in this way.

I do, so give me a few days to code something and explain / settle it.

I don't think I can code it using fanotify - the descriptor doesn't
provide enough context.  I think that's why we see them so differently
- the different ways to use the events means that sometimes the
inotify info does not work, and sometimes the fanotify descriptor does
not work, because each provides some critical information (subtly)
that the other does not.

-- Jamie
