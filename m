From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: fanotify as syscalls
Date: Thu, 17 Sep 2009 22:07:01 +0200
Message-ID: <200909172207.01764.agruen@suse.de>
References: <20090912094110.GB24709@ioremap.net> <1253094537.5213.89.camel@dhcp231-106.rdu.redhat.com> <20090916121708.GD29359@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752882AbZIQUJH@vger.kernel.org>
In-Reply-To: <20090916121708.GD29359@shareable.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, 16 September 2009 14:17:08 Jamie Lokier wrote:
> Eric Paris wrote:
> > On Wed, 2009-09-16 at 08:52 +0100, Jamie Lokier wrote:
> > > Seriously, what does system-wide fanotify do when run from a
> > > chroot/namespace/cgroup, and a file outside them is accessed?
> >
> > At the moment an fanotify global listener is system wide.  Truely system
> > wide.  A gentleman from suse is looking rectify the problem so that if
> > run inside a namespace it stays inside the namespace.  Note that this
> > particular little tidbit is not in the 8 patches I proposed.  At the
> > moment those just include the UI and basic notification.
>
> I'll be really interested in the gentleman's solution.

I guess Eric meant me.

>From my point of view, "global" events make no sense, and fanotify listeners 
should register which directories they are interested in (e.g., include "/", 
exclude "/proc"). This takes care of chroots and namespaces as well.

I think we want to register for events on objects rather than in the 
namespace, i.e., for inodes visible in multiple places because of hardlinks 
or bind mounts, we get the same kinds of events no matter which path is used. 
(The path actually used would still show up in /proc/self/fd/x.) When moving 
registered inodes, the registrations would move with them. This is how 
inotify works, except that inotify watches are not recursive.

The difficulty with this is that in the worst case, this would require walking 
the entire namespace and all cached inodes. I don't see how this could be 
done for two reasons:

 * First, we can't take the vfsmount_lock and dcache_lock for the entire time.

 * Second, we would need to pin almost all the inodes, which is a clear no-go.

   [Why pin?  At least we would need to remember which objects a listener has
    registered interest in, so we need to pin the inodes.  We could still
    allow unregistered directory inodes to be thrown out because we can
    recreate their registration status from the parent. We can't recreate the
    registration status of non-directories because of hardlinks, though.]

The only other idea I could come up with is to only allow recursive 
registrations at mount points: instead of inodes, the vfsmounts would be 
included or excluded (probably automatically including bind mounts). This has 
one big drawback though: users would no longer be able to watch arbitrary 
subtrees anymore. Privileged users could still arrange to watch almost all 
subtrees with bind mounts (mount --bind /foo/bar /foo/bar).

Any ideas?

Thanks,
Andreas
