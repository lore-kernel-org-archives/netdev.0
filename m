From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Sat, 24 Oct 2015 03:30:55 +0100
Message-ID: <20151024023054.GZ22011@ZenIV.linux.org.uk>
References: <5628636E.1020107@oracle.com>
 <20151022044458.GP22011@ZenIV.linux.org.uk>
 <20151022060304.GQ22011@ZenIV.linux.org.uk>
 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
 <20151022172146.GS22011@ZenIV.linux.org.uk>
 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
 <20151022190701.GV22011@ZenIV.linux.org.uk>
 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
 <20151022215741.GW22011@ZenIV.linux.org.uk>
 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49948 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbbJXCbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 22:31:03 -0400
Content-Disposition: inline
In-Reply-To: <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 11:52:34AM +0200, Casper.Dik@oracle.com wrote:
> 
> 
> >Ho-hum...  It could even be made lockless in fast path; the problems I see
> >are
> >	* descriptor-to-file lookup becomes unsafe in a lot of locking
> >conditions.  Sure, most of that happens on the entry to some syscall, with
> >very light locking environment, but... auditing every sodding ioctl that
> >might be doing such lookups is an interesting exercise, and then there are
> >->mount() instances doing the same thing.  And procfs accesses.  Probably
> >nothing impossible to deal with, but nothing pleasant either.
> 
> In the Solaris kernel code, the ioctl code is generally not handled a file 
> descriptor but instead a file pointer (i.e., the lookup is done early in 
> the system call).

The one that comes as the first argument of ioctl(2) - sure, but e.g.
BTRFS_IOC_CLONE_RANGE gets a pointer to this:
struct btrfs_ioctl_clone_range_args {
  __s64 src_fd;
  __u64 src_offset, src_length;
  __u64 dest_offset;
};
as the third argument.  VFS sure as hell has no idea of that thing - it's
up to btrfs_ioctl() to copy it in and deal with what it had been given.
While we are at it, ioctl(fd, BTRFS_IOC_CLONE, src_fd) also gets the
second descriptor-to-file lookup in btrfs-specific code; fd, of course,
is looked up by VFS code.  Now, these two are done in locking-neutral
environment, but that's just two of several dozens.

And no, I'm not fond of such irregular ways to pass file descriptors, but
we can't kill ioctl(2) with all weirdness hiding behind it, more's the pity...

> In those specific cases where a system call needs to convert a file 
> descriptor to a file pointer, there is only one routines which can be used.

Obviously, but the problem is deadlock avoidance using it.

> As I said, we do actually use a lock and yes that means that you really  
> want to have a single cache line for each and every entry.  It does make 
> it easy to have non-racy file description updates.  You certainly do not 
> want false sharing when there is a lot of contention.
> 
> Other data is used to make sure that it only takes O(log(n)) to find the 
> lowest available file descriptor entry.  (Where n, I think, is the returned
> descriptor)

TBH, with that kind of memory footprint I would be more interested in
constants than in asymptotics - not that O(log(n)) would be hard to
arrange (a bunch of bitmaps with something like 1:512 ratio between the
levels, to keep the damn thing within a reasonable cacheline size would
probably do with not too horrible constant; 3 levels of that would already
give 128M descriptors, and that's a gigabyte worth of struct file *
alone; with your "cacheline per descriptor" it's what, about 8Gb eaten by
descriptor table?)

Hell knows, might be worth doing regardless of anything else.  Not making
it worse than our plain bitmap variant in any situations shouldn't be hard...

> Not contended locks aren't expensive.  And all is done on a single cache 
> line.

The memory footprint is really scary.  Bitmaps are pretty much noise, but
blowing it by factor of 8 on normal 64bit (or 16 on something like Itanic -
or Venus for that matter, which is more relevant for you guys)

Said that, what's the point of "close won't return until..."?  After all,
you can't guarantee that thread with cancelled syscall won't lose CPU
immediately upon return to userland, so it *can't* make any assumptions
about the descriptor not having been already reused.  I don't get it - what
does that buy for userland code?
