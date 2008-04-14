From: Ian Kent <raven@themaw.net>
Subject: Re: [PATCH 4/4] autofs4 - add miscelaneous device for ioctls
Date: Mon, 14 Apr 2008 12:45:27 +0800
Message-ID: <1208148327.3505.65.camel@raven.themaw.net>
References: <Pine.LNX.4.64.0802261151400.8490@raven.themaw.net>
	 <Pine.LNX.4.64.0802261218230.8490@raven.themaw.net>
	 <20080227211723.d5d27c09.akpm@linux-foundation.org>
	 <1204302250.19890.22.camel@raven.themaw.net>
	 <Pine.LNX.4.64.0804111425290.32624@raven.themaw.net>
	 <20080411210316.6e385236.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
	autofs mailing list <autofs@linux.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Thomas Graf <tgraf@redhat.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080411210316.6e385236.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2008-04-11 at 21:03 -0700, Andrew Morton wrote: 
> On Fri, 11 Apr 2008 15:02:39 +0800 (WST) Ian Kent <raven@themaw.net> wrote:
> 
> > On Sat, 1 Mar 2008, Ian Kent wrote:
> > 
> > > 
> > > On Wed, 2008-02-27 at 21:17 -0800, Andrew Morton wrote:
> > > > On Tue, 26 Feb 2008 12:23:55 +0900 (WST) Ian Kent <raven@themaw.net> wrote:
> > > > 
> > > > > Hi Andrew,
> > > > > 
> > > > > Patch to add miscellaneous device to autofs4 module for
> > > > > ioctls.
> > > > 
> > > > Could you please document the new kernel interface which you're proposing? 
> > > > In Docmentation/ or in the changelog?
> > > > 
> > > > We seem to be passing some string into a miscdevice ioctl and getting some
> > > > results back.  Be aware that this won't be a terribly popular proposal, so
> > > > I'd suggest that you fully describe the problem which it's trying to solve,
> > > > and how it solves it, and why the various alternatives (sysfs, netlink,
> > > > mount options, etc) were judged unsuitable.
> > > 
> > > It appears I could do this with the generic netlink subsystem.
> > > I'll have a go at it.
> > > 
> > 
> > I've spent several weeks on this now and I'm having considerable 
> > difficulty with the expire function.
> > 
> > First, I think using a raw netlink implementation defeats the point of 
> > using this approach at all due to increased complexity. So I've used the 
> > generic netlink facility and the libnl library for user space. While the 
> > complexity on the kernel side is acceptable that isn't the case in user 
> > space, the code for the library to issue mount point control commands has 
> > more than doubled in size and is still not working for mount point 
> > expiration.  This has been made more difficult because libnl isn't 
> > thread safe, but I have overcome this limitation for everything but 
> > the expire function, I now can't determine whether the problem I have with 
> > receiving multicast messages, possibly out of order, on individual 
> > netlink sockets opened specifically for this purpose, is due to this or is 
> > something I'm doing wrong.
> > 
> > The generic netlink implementation allows only one message to be in flight 
> > at a time. But my expire selects an expire candidate (if possible), sends 
> > a request to the daemon to do the umount, obtains the result status and 
> > returns this as the result to the original expire request. Consequently, I 
> > need to spawn a kernel thread to do this and return, then listen for the
> > matching multicast message containing the result. I don't particularly 
> > like spawning a thread to do this because it opens the possibility of 
> > orphaned threads which introduces other difficulties cleaning them up if 
> > the user space application goes away or misbehaves. But I'm also having 
> > problems catching the multicast messages. This works fine in normal 
> > operation but fails badly when I have multiple concurrent expires 
> > happening, such as when shutting down the daemon with several hundred 
> > active mounts. I can't avoid the fact that netlink doesn't provide the 
> > same functionality as the ioctl interface and clearly isn't meant to.
> 
> Gee, it sounds like you went above and beyond the call there.

Hahaha, maybe, but I have to be sure it's not just my own lack of
understanding giving me grief!

> 
> The one-message-in-flight limitation of genetlink is suprising - one would
> expect a kernel subsystem (especially a networking one) to support
> queueing.  I guess it was expedient and the need had not arisen.

I'm not sure but I think there are some special requirements for such a
message bus architecture. I've only skimmed the code but it looked like
a mutex for each genetlink family or, ideally, for each socket should
be possible.

We also need to face the fact that this isn't designed to be a drop in
replacement for ioctls as it can't provide (and probably can never
provide) the not often used independently re-entrant function call like
semantic of the ioctl interface.

> 
> > So, the question is, what are the criteria to use for deciding that a 
> > netlink based implementation isn't appropriate because I think I'm well 
> > past it now?
> > 
> > Comments please.
> 
> Do I recall correctly in remembering that your original design didn't
> really add any _new_ concepts to autofs interfacing?  That inasmuch as
> the patch sinned, it was repeating already-committed sins?

Almost, it is a re-implementation of the existing ioctl interface.

It has an extra entry point so we can obtain a file handle to an autofs
mount that has been over mounted and another to get owner info for mount
re-construction on daemon restart. Which is what we need to be able to
solve the active restart problem.

I also made a couple of improvements, namely, allow actual failure
status to be returned from the daemon to the kernel rather than always
using ENOENT (long overdue, still need to update the daemon though) and
added an additional entry point to check if a path is a mount point so
we can eliminate some of the high overhead mount table scanning in the
daemon.

> 
> And: you know more about this than anyone else, and you are (now) unbiased
> by the presence of existing code.  What's your opinion?

There's no question that genetlink is an elegant solution for common
case ioctl functions but, as I say, it's not a complete replacement
probably because it's primary purpose in life is to be a message bus
implementation rather than specifically an ioctl replacement.

As is often the case after posting a "please help" message it occurred
to me that there is another way I might be able to do this. Instead of
sending an independent umount request I could check, and if a candidate
is found, set the expiring flag and return a "yes" status to the daemon
and have the same function do the umount, then clear the when returning
the status. That would eliminate the ugliness in the daemon and the need
to use kernel threads but would open the possibility of the "expiring
flag" remaining set if the daemon went away. That would prevent lookups
(since we wait for expires to complete) and so prevent manual umount
cleanup so I'm not sure yet what the implications of this really are.

There is one other concern, the expire in the daemon has become far to
complex because I enumerate umount candidates, almost for no other
reason than to "count" the number of times I need to call the expire
ioctl. This involves scanning the mount table which has proven to be a
bit of a killer for large maps. I think the best way to improve this is
try and get back to the way the expire was done long ago. That is, when
an expire comes in for a mount (file handle) continually call back to
the daemon until we can't umount any more mounts, then return the
appropriate status to the daemon (now we just expire one mount at a
time). This changed because we were getting infinite loops on umount
fails in some cases but I think my approach to fixing that was just
plain wrong. A genetlink implementation will exclude this possibility
and due to the requirements of the message bus architecture I don't
think that is likely to change any time soon, if ever.

All things considered I'm leaning toward using a misc device to route
the ioctls.

Ian


