From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Fri, 7 Nov 2014 22:11:14 +0000
Message-ID: <20141107221114.GB7996@ZenIV.linux.org.uk>
References: <20141105210745.GT7996@ZenIV.linux.org.uk>
 <20141105.165719.835728206041332333.davem@davemloft.net>
 <20141106032533.GU7996@ZenIV.linux.org.uk>
 <20141107.164859.951682597018909290.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141107.164859.951682597018909290.davem@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 07, 2014 at 04:48:59PM -0500, David Miller wrote:
> From: Al Viro <viro@ZenIV.linux.org.uk>
> Date: Thu, 6 Nov 2014 03:25:34 +0000
> 
> > OK, I've taken the beginning of the old queue on top of net-next; it's
> > in git://git.kernel.org//pub/scm/linux/kernel/git/viro/vfs.git iov_iter-net.
> 
> What I see in there looks good.   I wonder if we can somehow make msghdr
> pointer args const... but this is not so important now.
> 
> Some minor coding style nits, comments:
> 
> 	/* Like
> 	 * this.
> 	 */
> 
> and for multi-line function calls in the networking, align the second
> and subsequent lines at the first column after the openning parenthesis
> of the first line.

OK...  I played with csum side of things a bit, and I've noticed something
really nasty - iov_iter primitives all assume that iovec has been validated,
_including_ access_ok() on all ranges.  That allows us to use __copy_...()
in primitives, and on the read/write/readv/writev/aio side of things we have
that validation done when we copy iovec from userland (or set a single-element
iovec over the userland-supplied range, as in read(2)/write(2)).

net/* primitives, OTOH, do access_ok() themselves - syscalls do _not_ check
access_ok() on iovec from untrusted source and rely on the low-level stuff
to do such checks.

Result: regular IO syscalls on sockets (i.e. not recvmsg/sendmsg, usual
read/write) do these checks (at least) twice and use of copy_from_iter()
in ->recvmsg() opens quite a nasty hole - one can call recvmsg(2) with
kernel address in ->msg_iov[0].base and have such an instance of ->recvmsg()
stomp on the kernel memory.  At the very least, with Herbert's patches
we need to validate that somewhere on the way to tun and macvtap recvmsg
instances.  We can do that right there, and as a stopgap measure it might
be a good idea.  However, it's not a sane long-term solution.

We could, of course, add those access_ok() in mm/iov_iter.c and drop them
from fs/read_write.c and fs/aio.c, but I really don't see the point - why
not do that along with the checks we do in verify_iovec() anyway?  And drop
them from memcpy_fromiovec() et.al.

I'm looking through the tree right now; so far it looks like we can just
move those suckers to the point where we validate iovec and lose them
from low-level iovec and csum copying completely.  I still haven't finished
tracing all possible paths for address to arrive at the points where we
currently check that stuff, but so far it looks very doable.

Comments?
