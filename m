From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: linux-next: manual merge of the net-next tree with the vfs tree
Date: Sat, 14 Mar 2015 00:43:21 +0000
Message-ID: <20150314004321.GR29656@ZenIV.linux.org.uk>
References: <20150313131543.7c050492@canb.auug.org.au>
 <20150312.232426.1464986797003264151.davem@davemloft.net>
 <20150313035609.GO29656@ZenIV.linux.org.uk>
 <20150313153817.34510752@canb.auug.org.au>
 <20150313163707.GP29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49003 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbbCNAnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 20:43:23 -0400
Content-Disposition: inline
In-Reply-To: <20150313163707.GP29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2015 at 04:37:07PM +0000, Al Viro wrote:
> On Fri, Mar 13, 2015 at 03:38:17PM +1100, Stephen Rothwell wrote:
> 
> > There is also a conflict with e9eab93cc2dc ("fs: don't allow to
> > complete sync iocbs through aio_complete"), though it doesn't show up
> > in the resolution since I I just used the next-next tree bits.  So a
> > common branch containing that as well could be merged into both trees.
> 
> OK, for now I've done just that (vfs.git#iocb in never-rebase mode).
> I still think that vfs.git#gadget ought to go into mainline; arguments
> for the rest of #iocb are weaker and merging it into net-next would
> suffice; as the matter of fact, I have pending stuff for net-next touching
> the same area (further reduction of ->sendmsg()/->recvmsg() argument lists;
> total_len is redundant); might as well deal with that when feeding that
> to Dave...

FWIW, trying to resurrect ->recvmsg() side of those patches (broken by
the same 'remove iocb' series; sendmsg side also had been, but I've
already finished that one), I've run into an interesting question.
There seems to be a confusion about the flags we are passing.  Unlike
sendmsg case, where we pass that in msg->msg_flags (and it's strictly an in
argument), here we have _two_ ways for passing them in - msg->msg_flags and
separate 'flags' argument.

AFAICS, the picture looks so:

recvmsg(2): flags comes from syscall argument, with DONTWAIT possibly
tacked on it.  ->msg_flags comes it as well - CMSG_COMPAT and CMSG_CLOEXEC
bits.  On the way out, ->msg_flags sans CMSG_COMPAT is copied to userland.
BTW, out of those two I would expect CMSG_COMPAT to be kept - after all,
it is related to the layout of what ->msg_control ends up pointing to...

recvmmsg(2): ditto

read(2) et.al.: ->msg_flags and flags alike get 0 or DONTWAIT, depending on
O_NONBLOCK state of file.  On the way out ->msg_flags is discarded.

recvfrom(2): flags is done the same way as in recvmsg(2); ->msg_flags, AFAICS,
is simply uninitialized.  Whatever had been on the stack.  On the way out
->msg_flags is discarded.

kernel-side callers of kernel_recvmsg(): varies.  flags is always explicitly
given; ->msg_flags is sometimes equal to it, sometimes zero, sometimes
uninitialized.  AFAICS, the value of ->msg_flags on the way out is discarded,
except for three cases where we do further ->recvmsg on the same msghdr.

Now, the instances of ->recvmsg(), AFAICS, almost never check ->msg_flags
bits.  Exceptions are CMSG_COMPAT, CMSG_CLOEXEC and (in one case each)
PEEK and TRUNC.  In one really odd case (AF_CAIF/SOCK_SEQPACKET) - OOB
(as in "EOPNOTSUPP if it's set", very likely to have been cargo-culted
from the sendmsg side of things).  PEEK one (in rxrpc_sendmsg()) is probably
also bogus; might be misspelled 'flags & MSG_PEEK'...

Places that check for CMSG_COMPAT and CMSG_CLOEXEC are only reached when
->msg_control is non-NULL, which excludes recvfrom(2) and, AFAICS, those
of kernel_recvmsg() callers that leave ->msg_flags uninitialized.

The place that checks for TRUNC (rawv6_recvmsg()) looks like it assumes
that ->msg_flags & MSG_TRUNC will be zero when it's called; relevant piece
is
        copied = skb->len;
        if (copied > len) {
                copied = len;
                msg->msg_flags |= MSG_TRUNC;
        }

        if (skb_csum_unnecessary(skb)) {
                err = skb_copy_datagram_msg(skb, 0, msg, copied);
        } else if (msg->msg_flags&MSG_TRUNC) {
                if (__skb_checksum_complete(skb))
                        goto csum_copy_err;
                err = skb_copy_datagram_msg(skb, 0, msg, copied);
        } else {

and it smells like it means to check for skb->len > len...

If the above is true, all the places setting ->msg_flags to something non-zero
on the way into kernel_recvmsg() seem to be cargo-culting.  Am I missing
something subtle here?
