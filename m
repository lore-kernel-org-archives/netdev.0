From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [WTF?] random test in netlink_sendmsg()
Date: Fri, 28 Nov 2014 06:23:15 +0000
Message-ID: <20141128062315.GC29748@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54389 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbaK1GXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 01:23:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	In netlink_sendmsg() we have the following:

        if (netlink_tx_is_mmaped(sk) &&
            msg->msg_iov->iov_base == NULL) {
                err = netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group,
                                           siocb);
                goto out;
        }

Now, suppose sendmsg(2) is called with msg.msg_iovlen == 0.  We'll have
->msg_iov in kernel-side copy pointing at the uninitialized array in
stack frame of ___sys_sendmsg() - neither new nor old code touches elements
past the first msg_iovlen ones.  So in that case it checks if an
uninitialized word on stack is zero.

	What is that check trying to do?  Is that simply missing
"(msg->msg_iovlen > 0) &&"?  And why on the Earth didn't it simply use
zero msg_iovlen as the indicator, instead of messing with iovec contents?
Obviously too late to change, but... ouch.

Patrick, it had been that way since your commit last year ("netlink: implement
memory mapped sendmsg()"); could you explain what's the intended ABI?

Incidentally, WTF is "atomic_read(&nlk->mapped) > 1" part of check in
netlink_mmap_sendmsg() trying to achieve?  AFAICS, ->mapped tries to
keep track of the number of VMAs, right?  If so, it's bloody pointless -
one can have memory accessible in more than one process without any
extra VMAs.  Just clone(2) with CLONE_VM.  Voila - child shares the
entire address space.  No extra VMAs or calls of ->open() in sight...
