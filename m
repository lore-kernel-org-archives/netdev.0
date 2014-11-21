From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Fri, 21 Nov 2014 08:49:56 +0000
Message-ID: <20141121084956.GT7996@ZenIV.linux.org.uk>
References: <CA+55aFyQR2gOzEDROcWFcQzLvTjOxyJRjFJXJ03JB5knd-Gsgg@mail.gmail.com>
 <20141119.161744.1661940121298888832.davem@davemloft.net>
 <20141119213006.GE7996@ZenIV.linux.org.uk>
 <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <1416520542.8629.46.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141120222506.GS7996@ZenIV.linux.org.uk>
 <1416524035.8629.54.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Christoph Hellwig <hch@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416524035.8629.54.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 20, 2014 at 02:53:55PM -0800, Eric Dumazet wrote:
> > And no, your solution doesn't work.  Sorry.  You'll break e.g. smb_send_kvec()
> > that way.  ceph_tcp_sendmsg() as well, IIRC.
> 
> Nowhere in tcp_sendmsg() the iov had const qualifier.

*nod*

> If it was declared as const, this discussion would not happen,
> we would know we are not allowed to modify it.
>
> iov_iter is nice, but not a single time it is used in net/ 
> 
> Please make sure to add const where appropriate.

The situation is a fairly long-standing mess.  Take a look at e.g.
do_sock_write() - what we have there is
static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
                        struct file *file, const struct iovec *iov,
                        unsigned long nr_segs)
...
        msg->msg_iov = (struct iovec *)iov;
...
        return __sock_sendmsg(iocb, sock, msg, size);

That's where const is stripped off.  The reason why memcpy_fromiovec()
is modifying iovec is that it we obviously want subsequent calls to keep
picking new and new parts.  And on sendmsg(2) path iovec is discarded
after the method call anyway, so we get away with "let's do whatever's
more convenient internally, caller won't care anyway".

Unfortunately, it means that other callers (kernel_sendmsg() users, that is)
end up with very unpleasant situation - they can't even predict if iovec
will be fully drained, partially drained or left completely unchanged.
It's protocol-dependent *and* it depends on the codepath taken in ->sendmsg().
Note that "partially drained" is also a real-world case - e.g.
ping_v4_sendmsg() ends up draining the first sizeof(struct icmphdr) and leaves
the rest there.

In some cases it doesn't hurt much - throwaway struct iovec or a short array
of such which is fed to sendmsg and immediately discarded.  The rest either
relies on assumption about the behaviour for (known) protocol, which end
up being incorrect more often than not, or grumbles, makes a throwaway copy
of its iovec array and after the call either drains the original itself or
advances an iov_iter pointing to it.  There's quite a collection of unhappy
comments in those callers about this situation.  On the recvmsg side the
picture is the same.

We would be better off with iov_iter passed to __sock_{send,recv}msg() (as
a part of struct msghdr, instead of ->msg_iov/->msg_iovlen) and always
advanced to match the amount of data actually picked from it.  With iovec
behind it remaining constant.  That would work just as well as the current
variant for sendmsg(2)/recvmsg(2)/etc., be a lot more convenient for
kernel_{send,recv}msg() callers and would allow a lot of other fun stuff.

The problem, of course, is how to get through the conversion without a huge
patch from hell.  I'm reasonably certain that we can do that on the method
side of things - right now the amount of places aware of ->msg_iov in that
branch is much lower than in mainline.  The fun part is keeping the users
of kernel_{send,recv}msg() from breaking while we do the rest of transition.
The ones that use throwaway iovecs are fine - they don't assume any particular
behaviour wrt iovec draining.  A bunch of those will be able to use new
warranties later on, but those are separate patches that should go after the
switch to new rules.  Besides those we have the following:
	iscsit_do_tx_data().  Sends over TCP, assumes iovec drained.
	iscsit_do_rx_data().  Recieves over TCP, assumes iovec drained.
	smb_send_kvec().  Sends, assumes iovec unchanged.
	rxrpc_reject_packets().  Sends, assumes iovec unchanged.
	ceph_tcp_sendmsg().  Sends, assumes iovec unchanged.
The last three are not a problem, obviously - they are not quite correct
right now, but with those changes we get no regressions and the closer
we are to complete conversion, the better off they are.  Which leaves
us with iscsit_do_[rt]x_data().  

For tcp_sendmsg() conversion we need skb_add_data_nocache() and
skb_copy_to_page_nocache() variants that would take iov_iter as data
source.  Then the loop over iovec members and while (seglen > 0) loop
inside it get conflated (with iov_iter_count() instead of seglen).

Another thing is tcp_sendmsg_fastopen() and tcp_send_rcvq().  The latter
should just use copy_from_iter() instead of memcpy_from_iovec(), the former
is dealt with by making tcp_send_syn_data() use the same copy_from_iter()
instead of memcpy_from_iovecend().

All of that depends on ->msg_iter being already introduced and it doesn't break
iscsi_do_tx_data() any worse than it's currently broken.  Moreover, right after
it we'll be able to fix iscsi_do_tx_data() for good, simply by stopping to mess
with ->msg_iter after the first pass through the loop in there.

skb_add_data_nocache() and skb_copy_to_page_nocache() are both wrappers for
skb_do_copy_data_nocache(), which is used only by those two *and* they are
used only by tcp_sendmsg().  So there's no other code to be disrupted by
changes in those.  What skb_do_copy_data_nocache() is doing is a mix of
copy_from_user() (trivial - we just use copy_from_iter() instead),
csum_and_copy_from_user() (new primitive - csum_and_copy_from_iter()) and
__copy_from_user_nocache() (also a new primitive, easily added, but we
are really getting to the point where the amount of boilerplate in iov_iter.c
becomes painful).  Incidentally, xip_file_write() could benefit from the last
one as well, giving us full ->write_iter() for those...

As for the recvmsg() part of story, we'll need a new helper there as well -
csum_and_copy_to_iter(), for use in skb_copy_and_csum_datagram_iovec()
analogue that would take iov_iter.  Which will very shortly replace the
iovec one.  We'll need tp->ucopy.msg instead of tp->ucopy.iov for that;
that can be done as the first step, actually (ucopy.msg is always
->msg_iov of some msghdr with sufficiently long lifetime).  That +
introduction of helpers leaves us with moderately-sized patch converting
tcp_recvmsg() to new semantics.  And unfortunately the same patch will have
to include a (fairly simple) chunk in iscsi_do_rx_data() - same "don't
mess with ->msg_iter on subsequent iterations" thing.

At that point we'll have all kernel_{send,recv}msg() users happy with the
new semantics and are free to switch ->sendmsg()/->recvmsg() instances to
use of iov_iter primitives, not worrying about messing the callers up.
>From that point it's a smooth sailing - a bunch of iovec helpers will become
dead code shortly after that, etc.

One more moderately interesting spot will be around AF_ALG stuff - we'll need
to teach iov_iter_get_pages{,_alloc}() to do the right thing for kvec-backed
iterators.  Not hard to do, fortunately.

Overall, I think I have the whole series plotted in enough details to be
reasonably certain we can pull it off.  Right now I'm dealing with
mm/iov_iter.c stuff; the amount of boilerplate source is already high enough
and with those extra primitives it'll get really unpleasant.

What we need there is something templates-like, as much as I hate C++, and
I'm still not happy with what I have at the moment...  Hopefully I'll get
that in more or less tolerable form today.
