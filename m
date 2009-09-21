From: Jamie Lokier <jamie@shareable.org>
Subject: Re: fanotify as syscalls
Date: Mon, 21 Sep 2009 21:28:23 +0100
Message-ID: <20090921202823.GB14700@shareable.org>
References: <20090912094110.GB24709@ioremap.net> <200909190000.43556.agruen@suse.de> <1253329471.2630.30.camel@dhcp231-106.rdu.redhat.com> <200909212204.51077.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Andreas Gruenbacher <agruen@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753906AbZIUU2i@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200909212204.51077.agruen@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Gruenbacher wrote:
> On Saturday, 19 September 2009 5:04:31 Eric Paris wrote:
> > Let me start by saying I am agreeing I should pursue subtree
> > notification.  It's what I think everyone really wants.  It's a great
> > idea, and I think you might have a simple way to get close.  Clearly
> > these are avenues I'm willing and hoping to pursue.  Also I say it
> > again, I believe the interface as proposed (except maybe some of my
> > exclusion stuff) is flexible enough to implement any of these ideas.
> > Does anyone disagree?
> 
> It does seem flexible enough. However, the current interface assumes "global" 
> listeners (the mask argument of fanotify_init):
> 
>   int fanotify_init(int flags, int f_flags, __u64 mask,
> 		    unsigned int priority);
> 
> Once subtree support is added, this parameter becomes obsolete. That's pretty 
> broken for a syscall yet to be introduced.
> 
> > BUT to solve one of the main problems fanotify is intending to solve it
> > needs a way to be the 'fscking all notifier.'  It needs to be the whole
> > damn system.
> 
> Think of a system after boot, with a single global namespace. Whatever you 
> access by filename is reachable from the namespace root. At this point, 
> nothing more global exists. A listener can watch the mount points of 
> interest, and everything's fine.
> 
> What's a bit more tricky is to ensure that this listener will continue to 
> receive all events from whatever else is mounted anywhere, irrespective of 
> namespaces. I think we can get there.

I think so to, and that'd be a great all round solution.

We _have_ to receive mount & umount events to do this.  But even
inotify-style tracking needs those if it's to be accurate, so it's not
an additional burden.

It would be logical if fanotify could block and ack those in the same
way as it can block and ack other accesses (with the usual filtering
rules on which inodes trigger events, and which don't or are cached).

As in to prevent: mount --bind innocent .bash_login, but also to
ensure it always knows what's mounted when another event occurs.

> By the way, Documentation/filesystems/sharedsubtree.txt describes how 
> filesystem namespaces work.

Fortunately, after making a new namespace you can read the mounts in
the new namespace from /proc/self/mount* (I think) without having to
know anything about the shared subtree rules.

So to follow monitoring/checking across all namespaces, it would (I
think) be enough to receive a fanotify "new namespace" event, and Ack
that event to allow the CLONE_NS to proceed.  It's still tricky stuff
though.

-- Jamie
