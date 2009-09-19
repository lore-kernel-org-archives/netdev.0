From: Eric Paris <eparis@redhat.com>
Subject: Re: fanotify as syscalls
Date: Fri, 18 Sep 2009 23:04:31 -0400
Message-ID: <1253329471.2630.30.camel@dhcp231-106.rdu.redhat.com>
References: <20090912094110.GB24709@ioremap.net>
	 <200909172207.01764.agruen@suse.de>
	 <1253307128.2552.21.camel@dhcp231-106.rdu.redhat.com>
	 <200909190000.43556.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Andreas Gruenbacher <agruen@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <200909190000.43556.agruen@suse.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2009-09-19 at 00:00 +0200, Andreas Gruenbacher wrote:
> On Friday, 18 September 2009 22:52:08 Eric Paris wrote:
> > On Thu, 2009-09-17 at 22:07 +0200, Andreas Gruenbacher wrote:
> > > From my point of view, "global" events make no sense, and fanotify
> > > listeners should register which directories they are interested in (e.g.,
> > > include "/", exclude "/proc"). This takes care of chroots and namespaces
> > > as well.
> >
> > While I completely agree that most users don't want global events, the
> > antimalware vendors who today, unprotect and hack the syscall table on
> > their unsuspecting customer's machines to intercept every read, write,
> > open, close, mmap, etc syscall want EXACTLY that.
> 
> I understand that "global" is what those guys get today for lack of a 
> reasonable mechanism, but it's not what anybody can ge given by fanotify: it 
> conflicts with filesystem namespaces.
> 
> Consider running several "virtual machines" in separate namespaces on the same 
> kernel. With "global" you are forced to run the same global fanotify 
> listeners everywhere; with per-mount-point listeners, you can choose 
> between "global" and something more fine-grained by identifying which 
> vfsmounts you are interested in. (Filesystem namespaces correspond to 
> vfsmount hierarchies.)

Let me start by saying I am agreeing I should pursue subtree
notification.  It's what I think everyone really wants.  It's a great
idea, and I think you might have a simple way to get close.  Clearly
these are avenues I'm willing and hoping to pursue.  Also I say it
again, I believe the interface as proposed (except maybe some of my
exclusion stuff) is flexible enough to implement any of these ideas.
Does anyone disagree?

BUT to solve one of the main problems fanotify is intending to solve it
needs a way to be the 'fscking all notifier.'  It needs to be the whole
damn system.  I totally agree that what I have in my tree today (yet
unposted) restricting global notification (CAP_SYS_ADMIN) is highly
inadequate.  If any root task in any namespace could easily hop on out
of it's namespace using fanotify, that's a problem.  No arguments with
me.

But there must be a way for fanotify to globally get everything.  That's
one of the main points of fanotify.  It needs to be a fscking all
notifier, even of things in a completely detached namespace.  AV vendors
are going to get it.  Their customers our users are going to load kernel
modules that do horrible things.  These are the realities of the world
in which we live.  Do we really throw 10's or 100's of thousands of our
users under the bus because we don't like the software they are using on
philosophical grounds?

I'm sure namespace people are calling me an idiot and tell me to stay in
my namespace.  I want to stay in my namespace for 'most' root users, but
I need a way to get a global scanner.  I want to know what is the sanest
way?  And for people who feel it's insane, just don't compile it in.
I'll make global listeners a build option.  But global listeners is an
absolute requirement.  I was considering saying you needed cap_sys_admin
and you needed current->ns_proxy->mnt_ns == the original init task's
mnt_ns.  Maybe this isn't a great way to determine if a task should be
allowed to use global listeners.  Is there a better way to restrict it?

Think about your web hosting company.  They sell 'cheap' vm's to
customers in a private name.  The web hosting company want to run an AV
scanner that scans every file on the computer, their files, their
customer's files, everything.  Certainly we don't want the customer to
break out of their namespace.  So, what is the sanest, even if you hate
the idea so much you compile it out, way to let the hosting company get
information about files in their customer's detached namespace which not
letting their customers get information about each other?

-Eric

