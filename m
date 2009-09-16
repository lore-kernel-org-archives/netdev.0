From: Eric Paris <eparis@redhat.com>
Subject: Re: fanotify as syscalls
Date: Wed, 16 Sep 2009 05:48:57 -0400
Message-ID: <1253094537.5213.89.camel@dhcp231-106.rdu.redhat.com>
References: <20090911212731.GA19901@shareable.org>
	 <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com>
	 <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org>
	 <20090914140720.GA8564@ioremap.net>
	 <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com>
	 <20090915201620.GB32192@ioremap.net>
	 <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
	 <alpine.LFD.2.01.0909151643540.4950@localhost.localdomain>
	 <1253064391.5213.37.camel@dhcp231-106.rdu.redhat.com>
	 <20090916075219.GA22024@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753307AbZIPJt2@vger.kernel.org>
In-Reply-To: <20090916075219.GA22024@shareable.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-09-16 at 08:52 +0100, Jamie Lokier wrote:
> Eric Paris wrote:
> > On Tue, 2009-09-15 at 16:49 -0700, Linus Torvalds wrote:
> > > And btw, I still want to know what's so wonderful about fanotify that we 
> > > would actually want yet-another-filesystem-notification-interface. So I'm 
> > > not sayying that I'll take a system call interface.
> > 
> > The real thing that fanotify provides is an open fd with the event
> > rather than some arbitrary 'watch descriptor' that userspace must
> > somehow magically map back to data on disk.  This means that it could be
> > used to provide subtree notification, which inotify is completely
> > incapable of doing.
> 
> That's a bit of a spurious claim.

My claim that a watch descriptor plus pathname segment sucks is
spurious?  You've got to be kidding me.  You think that a number which
represents the pathname of an object at some point in the past is a
reasonable piece of information?  If a watch descriptor actually
provided any information about the object on which an event just
happened it would be useful.  Sadly, it doesn't.

> - fanotify does not provide subtree notification in it's
>   present form.  When it is extended to do that, why wouldn't
>   inotify be as well?  That's an fsnotify feature, common to both.

Because I don't believe inotify can be reasonably extended in this way.
It's already clear that an arbitrary watch descriptor which userspace
has to somehow know how to correctly map back to an object (impossible
task) is difficult to use and I personally don't see how watch
descriptor + long path name component is somehow better or even
reasonable.  Path names are such crap and passing a pathname to
userspace is really just telling userspace, something happened to
something that used to be at this location but is possibly long since
gone.  I don't believe that's a good interface or one we should be
allowing to be {ab,}used.

> - fanotify does not provide notification at all for some events that
>   you get with inotify.  It is not a superset, so you can't use
>   fanotify to provide a subtree-capable equivalent to inotify.  What
>   a mess when you need the combination of both features!

This is true, although where possible I plan to rectify this situation
on an ongoing basis.  Absolutely nothing preventing that from happening.

> - fanotify requires you call readlink(/proc/fd/N) for every event to
>   get the path.

And inotify requires magic.  Which one sounds better?

>   It's not a particularly efficient way to get it,

What is?

>   especially when an apps wants to know if it's something in it's
>   region of interest but doesn't care about the actual path.
>   When an apps knows it needs the map back to to path, why make it
>   slow to get it?  That "extensible data format" is being
>   underutilised...

You convince Al Viro that the vfs should give us a path name for an
arbitrary object that honestly might not have one and I'll consider
giving it to userspace in the event notification.  Probably should read
some of the AppArmour arguments before you do though.  You're asking for
something that's impossible and is at best incredibly race prone crap.
At worst is a total lie.

> - fanotify's descriptor may be race-prone as a way to get the subtree
>   used for access, because any of the parent directories could have
>   moved and even been deleted before the app calls
>   readlink(/proc/fd/N).  I don't know if a _reliable_ way to track
>   changes in a subtree can be built on it.  Maybe it can but it
>   appears this hasn't been analysed.  It depends on
>   readlink(/proc/fd/N)'s behaviour when the dentry's have been
>   changed, among other things.

Huh?  Your saying that by the time userspace deals with an event it
might have moved?  True.  So what?  Spurious and irrelevant.  You got an
event that happened to this object.  If subtree notification is added at
some later point you may get an event for an object that was in the
subtree and is now not in the subtree.  That sounds fine to me....

> - Does the descriptor cause umount to fail when user does "do some
>   stuff in baz; umount baz", or does it serialise nicely?  That's one
>   of inotify's nice features - it doesn't cause umounts to fail.

Ah yes, you didn't read the code.  Seeing as how that's an fsnotify
property and fanotify notify is built on fsnotify....

> Seriously, what does system-wide fanotify do when run from a
> chroot/namespace/cgroup, and a file outside them is accessed?

At the moment an fanotify global listener is system wide.  Truely system
wide.  A gentleman from suse is looking rectify the problem so that if
run inside a namespace it stays inside the namespace.  Note that this
particular little tidbit is not in the 8 patches I proposed.  At the
moment those just include the UI and basic notification.

> If the event is delivered with file desciptor, that's a security hole.
> If it's not delivered, that sounds like working subtree support?

What?

> I'd expect anti-malware to want to be run inside VMs quite often...

What?

> Answer questions about use-cases that you're not interested in?  Why
> block them?  What about Evigny's request for an event without an open
> fd - because he needs the pid information (inotify doesn't provide)
> but not the fd?

It's not blocked, it's on the list of things to look at.  It's a
relatively simple change to have the mark add code return a watch
descriptor and use that value instead of an fd.  I believe I already
said that.  It certainly doesn't seem like a merge blocker that some
other feature might come along one day.  There's nothing preventing it
from coming out.  "Here is a patch which implements TCP."  "No, don't
merge that, it doesn't implement UDP as well."  "WTF?"

> I'd like to be able to use it from some applications to accelerate
> userspace caching of things (faster Make, faster Samba) without
> penalising all other applications touching unrelated parts of the
> filesystem.  The attitude "you can live with 10% slowdown" worries me.
> I'm sure that can be fixed with a bit of care.

I've said that using ANYTHING which allows userspace to arbitrate access
decisions for an entries system is going to eat performance.  If you
can't handle that, don't build that damn userspace decision making
portion into your kernel!  Don't buy anti-malware snake oil.  

fanotify as a notification system isn't some performance monster here to
eat your babies.  fanotify as an access control system is, and I can't
really do anything about that, it's the nature of that part of the
horrible beast.  Lets not confuse things...

> If the intention is to maintain fanotify and inotify side-by-side for
> different uses (because fanotify returns open descriptors and blocks
> the accessing process until acked)

I know I've told you this before.  fanotify provides TWO separate
things.  Notification with a fd.  A method to provide access control and
blocking.  Lets not lead people to believe you can't you one without the
other.  They are very distinct.

> , that's ok with me.  It makes
> sense.  But then it's messy that neither offers a superset of the
> other regarding which files and events are tracked.

inotify isn't going away any time soon....

> If it's right that inotify has no room for extensibility (I'm not sure
> about this), than it appears we already made a mess with dnotify and
> inotify, so it would be a shame to repeat the same mistakes again.
> Let's get the next one right, even it takes a bit longer, ok?

Calling inotify a "mess" or "completely inextensible" would probably be
too harsh.  There are ways with inotify_init1() that we could provide a
better or more forward looking data format.  But you are still left with
inotify's fatal flaw: userspace is required to map a random number to an
object in the filesystem.  inotify starts with a reasonably impossible
premise and builds from there.

You show me anything about my proposal that limits any use case you have
in mind and I'll fix it.  I'll fix it today.  My proposal does what it
does very well and leaves the door open to build upon it for whatever
has been mentioned over the last 1.25 years I've been trying to get
comments.  I'm certainly not going to wait until fanotify can leap out
of my computer and make a pot of coffee before I ask for it to be merged
(and no, it doesn't have that forward looking extensibility, I'll add a
syscall flag for it right now, O_COFFEE)

-Eric
