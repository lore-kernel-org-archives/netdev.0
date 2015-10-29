From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 28 Oct 2015 20:29:41 -0700
Message-ID: <1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445991236.7476.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028123543.GB22011@ZenIV.linux.org.uk>
	 <1446038672.7476.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446043677.7476.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028211347.GC22011@ZenIV.linux.org.uk>
	 <1446068668.7476.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028223330.GD22011@ZenIV.linux.org.uk>
	 <1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151029001532.GE22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20151029001532.GE22011@ZenIV.linux.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-10-29 at 00:15 +0000, Al Viro wrote:
> On Wed, Oct 28, 2015 at 04:08:29PM -0700, Eric Dumazet wrote:
> > > > Except for legacy stuff and stdin/stdout/stderr games, I really doubt
> > > > lot of applications absolutely rely on the POSIX thing...
> > > 
> > > We obviously can't turn that into default behaviour, though.  BTW, what
> > > distribution do you have in mind for those random descriptors?  Uniform
> > > on [0,INT_MAX] is a bad idea for obvious reasons - you'll blow the
> > > memory footprint pretty soon...
> > 
> > Simply [0 , fdt->max_fds] is working well in most cases.
> 
> Umm...  So first you dup2() to establish the ->max_fds you want, then
> do such opens?

Yes, dup2() is done at program startup, knowing the expected max load
(in term of concurrent fd) + ~10 % (actual fd array size can be more
than this because of power of two rounding in alloc_fdtable() )

But this is an optimization : If you do not use the initial dup2(), the
fd array can be automatically expanded if needed (all slots are in use)

>   What used/unused ratio do you expect to deal with?
> And what kind of locking are you going to use?  Keep in mind that
> e.g. dup2() is dependent on the lack of allocations while it's working,
> so it's not as simple as "we don't need no stinkin' ->files_lock"...

No locking change. files->file_lock is still taken.

We only want to minimize time to find an empty slot.

The trick is to not start bitmap search at files->next_fd, but a random
point. This is a win if we assume there are enough holes.

low = start;
if (low < files->next_fd)
    low = files->next_fd;

res = -1;
if (flags & O_FD_FASTALLOC) {
	random_point = pick_random_between(low, fdt->max_fds);

	res = find_next_zero_bit(fdt->open_fds, fdt->max_fds,
				random_point);
	/* No empty slot found, try the other range */
	if (res >= fdt->max_fds) {
		res = find_next_zero_bit(fdt->open_fds,
				low, random_point);
		if (res >= random_point)
			res = -1;
	}
}
...




