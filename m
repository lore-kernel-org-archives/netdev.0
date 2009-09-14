From: Eric Paris <eparis@redhat.com>
Subject: fanotify as syscalls
Date: Mon, 14 Sep 2009 15:08:15 -0400
Message-ID: <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
	 <20090911.114620.260824240.davem@davemloft.net>
	 <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
	 <20090911204602.GA19371@shareable.org>
	 <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com>
	 <20090911212731.GA19901@shareable.org>
	 <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com>
	 <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org>
	 <20090914140720.GA8564@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org,
	torvalds@linux-foundation.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090914140720.GA8564@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Long ago I implemented fanotify as basically a /dev interface using
ioctls().  Alan suggested I use a socket protocol and could then make
use of get/setsockopt() which although still not great is light years
better than ioctl.  Currently the fanotify interface as I want to push
it to Linus and as I've been requesting comments on for the last 1.25
years is just that.  It really makes no use of the networking system
other than bind() and setsockopt() and everyone tends to agree the
things I want to do can't reasonably be done using network hooks and a
'real' socket protocol.  I like this interface, setsockopt() makes it so
easy to add new functionality as we flush out other users.  fanotify as
it stands today has a number of groups who will port to it, has a nubmer
of advantages over inotify, and I have been told privately meets the
needs of the original group of people who paid me to work on it (two
very large anti-malware companies who currently unprotect and hack the
syscall table of their users)

Just this week I got another request to look at syscalls.  So I did, I
haven't prototyped it, but I can do it with syscalls, they would look
like this:

int fanotify_init(int flags, int f_flags, __u64 mask, unsigned int priority);

int fanotify_add_mark(int fanotify_fd, char *path, __u64 mask, __u64 ignored_mask);
int fanotify_add_mark_fd(int fanotify_fd, int fd, __u64 mask, __u64 ignored_mask);
int fanotify_rm_mark(int fanotify_fd, char *path, __u64 mask);
int fanotify_rm_mark_fd(int fanotify_fd, int fd, __u64 mask);
	Those above 4 could probably be squashed into 2 syscalls with an extra
flags field.

int fanotify_clear_marks(int fanotify_fd);

int fanotify_perm_response(int fanotify_fd, __u64 cookie, int response);

int fanotify_ignore_sb(int fanotify_fd, long f_type);
int fanotify_ignore_fsid(int fanotify_fd, fsid_t f_fsid);
	These 2 are the most questionable, they would honestly only be used for
things that wanted system wide notification, I can't imagine that being
many things other than AV vendors.  But they really need a way to
exclude notification when people open/close/read/write to /proc (which
is the point of the ignore_sb.)

Since I don't have a solution to subtree notification I don't know if it
will work in this syscall framework.  I know people want subtree
notification and I'm willing to take a stab at it after the fscking all
notification is accepted.  That's one of the main reasons I like
setsockopt over tons of syscalls.  I can add a new one very easily.  I
also can easily expand arguments by just creating a new sockopt.  No
userspace headaches.

Are there demands that I convert to syscalls?  Do I really gain anything
using 9 new inextensible syscalls over socket(), bind(), and 8
setsockopt() calls?

I'd like to send these patches along, so a ruling from on high would be
great....

-Eric

