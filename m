From: Eric Paris <eparis@redhat.com>
Subject: Re: fanotify as syscalls
Date: Thu, 17 Sep 2009 14:53:58 -0400
Message-ID: <1253213638.5213.323.camel@dhcp231-106.rdu.redhat.com>
References: <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com>
	 <20090911212731.GA19901@shareable.org>
	 <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com>
	 <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org>
	 <20090914140720.GA8564@ioremap.net>
	 <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com>
	 <20090915201620.GB32192@ioremap.net>
	 <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
	 <20090916120523.GA12830@ioremap.net> <20090916122723.GE29359@shareable.org>
	 <alpine.LFD.2.01.0909170934450.4950@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754388AbZIQSyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 14:54:54 -0400
In-Reply-To: <alpine.LFD.2.01.0909170934450.4950@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-09-17 at 09:40 -0700, Linus Torvalds wrote:
> 
> On Wed, 16 Sep 2009, Jamie Lokier wrote:
> > 
> > I'd forgotten about Linus' strace argument.  That's a good one.
> > 
> > Of course everything should be a syscall by that argument :-)
> 
> Oh yes, everything _should_ be a syscall.

I rewrote the interface and prototyped out a working fanotify like so:

SYSCALL_DEFINE4(fanotify_init, unsigned int, flags, int, event_f_flags,
		__u64, mask, int, priority)

int flags indicates - things like global or directed, fd's or wd's,
could include fail allow vs fail deny, O_CLOEXEC, O_NONBLOCK, etc
int event_f_flags - flags used when opening an fd for the listener
__u64 mask - in global mode the events of interest
int priority - the order fanotify listeners should be checked (so HSM
		can be before AV scanners)

Do we need a timeout for access decisions?  I left room for that in the
bind address, but we can't just leave room to spare with a syscall...

SYSCALL_DEFINE6(fanotify_modify_mark, int, fanotify_fd,
		unsigned int, flags, int, fd,
		const char  __user *, pathname, __u64, mask,
		__u64, ignored_mask)

int fanotify_fd - duh
int flags - add, remove, flush, events on child, event on subtree?
int fd - either fd to object or fd to dir for relative pathname
const char __user * pathname - either pathname or null if only use fd
__u64 mask - events this inode cares about
__u64 ignored_mask - events this inode does NOT care about

(not yet done, would someone like to comment?)
fanotify_response(int fanotify_fd, __u64 cookie, __u32 response);
__u64 cookie - which of our permission requests we are waiting on
__u32 response - allow, deny, wait longer

Could be done using write(), but I think the strace argument clearly
says that this should be a syscall that can be easily found and reported

(not settled in my mind)
int fanotify_ignore_sb(int fanotify_fd, unsigned int flags,
                       long f_type, fsid_t f_fsid)
int fanotify_fd - duh
unsigned int flags - f_type or fsid?
long f_type - statfs(2) f_type
fsid_t f_fsid - statfs(2) f_fsid

Reads from the fd would return data of this structure:

struct fanotify_event_metadata {
	__u32 event_len;
	__u32 vers;
	__s32 fd;
	__u32 mask;
	__u32 f_flags;
	__s32 pid;
	__s32 uid;
	__s32 tgid;
	__u64 cookie;
}  __attribute__((packed));

Thanks to event_len and vers, we could extend it to include

__u32 filename1_len,
char filename1[filename1_len]
__u32 filename2_len,
char filename2[filename2_len]

This can all take shape as that work is completed and I don't believe
should block merging.

Do my syscalls look pretty enough?  I'm down to 3 or 4.
Jamie, you tend to agree that the interface and the event types are nice
enough that we can build out (if we get the right hooks in the right
places) everywhere we need to go?

-Eric

