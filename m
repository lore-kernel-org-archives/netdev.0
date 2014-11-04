From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [0/3] net: Kill skb_copy_datagram_const_iovec
Date: Tue, 4 Nov 2014 05:45:13 +0000
Message-ID: <20141104054513.GB7996@ZenIV.linux.org.uk>
References: <20141103002207.GA26588@gondor.apana.org.au>
 <20141103004503.GX7996@ZenIV.linux.org.uk>
 <20141103053751.GA27845@gondor.apana.org.au>
 <20141103.150553.633529234958324183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141103.150553.633529234958324183.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 03, 2014 at 03:05:53PM -0500, David Miller wrote:

> I'll see if I can make some progress converting the networking over
> to iov_iter.  It can't be that difficult... albeit perhaps a little
> time consuming.

FWIW, I have a queue that got started back in April; basically, the plan
of attack was
	* separate kernel-side and userland msghdr.
	* localize ->msg_iov uses - most of that gets taken care of by
several new helpers, as in
    new helper: skb_copy_datagram_msg()
    
    Absolute majority of skb_copy_datagram_iovec() callers (49 out of 56)
    are passing it msg->msg_iov as iovec.  Provide a trivial wrapper that
    takes msg as argument instead of iovec.
and several like that (the numbers in the above are probably incorrect these
days - it was done more than half a year ago).
	* switch kernel-side msghdr to iov_iter.  That means diverging
layouts; it's really not hard, since we have copying of msghdr from
userland already localized.  Initially - just a mechanical conversion
(i.e. direct uses of iov_iter fields instead of ->msg_iov/->msg_iovlen;
note that after the introduction of wrappers the number of such places
is very much reduced).
	* start converting those relatively few places to iov_iter primitives.

And that's where it got stalled, since we have to deal with expectations
of callers.  Syscall ones are trivial; that's not a problem.  Unfortunately,
there are kernel_{send,recv}msg() users, and those do care about the state the
iovec is left in.  Strictly speaking, the state of iovec after e.g.
->sendmsg() is undefined.  And it's not just protocol-dependent - unless
I'm seriously misreading it, tcp_sendmsg() ends up modifying iovec in case
when it hits tcp_send_rcvq(), while in the normal case it leaves iovec
unmodified.  So in general you need to feed ->{send,recv}msg() a throwaway copy
of iovec.  Leads to wonders like
        /* NB we can't trust socket ops to either consume our iovs
         * or leave them alone. */
        LASSERT (niov > 0);

        for (nob = i = 0; i < niov; i++) {
                scratchiov[i] = iov[i];
                nob += scratchiov[i].iov_len;
        }
        LASSERT (nob <= conn->ksnc_rx_nob_wanted);

        rc = kernel_recvmsg(conn->ksnc_sock, &msg,
                (struct kvec *)scratchiov, niov, nob, MSG_DONTWAIT);
etc.  However, there are places that don't bother and do this:
        while (total_rx < data) {
                rx_loop = kernel_recvmsg(conn->sock, &msg, iov_p, iov_len,
                                        (data - total_rx), MSG_WAITALL);
                if (rx_loop <= 0) {
                        pr_debug("rx_loop: %d total_rx: %d\n",
                                rx_loop, total_rx); 
                        return rx_loop;
                }
                total_rx += rx_loop;
                pr_debug("rx_loop: %d, total_rx: %d, data: %d\n",
                                rx_loop, total_rx, data);
        }
(that's iscsit_do_rx_data()).  Maybe it's a bug; maybe it's relying on
specific behaviour of the protocol known to be used - this code clearly
expects recvmsg to advance iovec, which seems to depend only on the
protocol.  At the moment.  In any case, it's very brittle...

Hell knows; I hadn't finished digging through that zoo - got sidetracked back
then.  *IF* all such places either use a throwaway copy or assume that iovec
gets modified, we can do the following: switch the access to iovecs to
iov_iter primitives, with the first kind of callers creating a throwaway
iov_iter and the second just feeding the same iov_iter to e.g.
kernel_recvmsg().  iovec will remain constant, iov_iter will be advanced.
Moreover, in a lot of cases of first kind will be able to get rid of
throwaway iov_iter (and of manually advancing it), effectively converting
to the second one.

If we have places that currently rely on iovec remaining unchanged (i.e.
manually advancing it after kernel_{send,recv}msg()), the series will be
more painful ;-/  I very much hope that no such places exist...

FWIW, there is also a tactical question that needs to be dealt with.  We
can, of course, start with renaming the "kernel-side" (i.e. post
copy_msghdr_from_user()/get_compat_msghdr()) to struct kmsghdr.  OTOH,
that's a _lot_ of churn for very little reason - most of the instances
in the tree are of that kind.  So I did it the other way round - introduced
struct user_msghdr (only in linux/socket.h; note that we do *not* have
struct msghdr in uabi/linux/socket.h, or anywhere else in uabi/*),
made the syscalls take pointers to it and (initially) rely upon the identical
layouts in copy_msghdr_from_user(); once we put iov_iter into kernel-side
msghdr, we'll just do it like get_compat_msghdr() does.

Is that acceptable?  It would greatly reduce the amount of churn in net/* -
we don't need to pass iov_iter separately and most of the functions in
the middle of call chains are completely unchanged.  Only the originators
of ->sendmsg()/->recvmsg() and the places doing actual data copying
need to be touched.  OTOH, it makes for kernel struct msghdr looking
odd - instead of normal ->msg_iov and ->msg_iovlen it would have
->msg_iov_iter, with ->sendmsg()/->recvmsg() callers needing to set it
up...  OTTH, the things *are* odd from userland programmer POV - sendmsg(2)
and recvmsg(2) leave the iovec unchanged, and having it changed unpredicatably
in the kernel-side counterparts seems to make for a nasty trap.  Certainly
makes for a bunch of nasty comments in the code using those...

Comments?
