From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [WTF?] random test in netlink_sendmsg()
Date: Sat, 13 Dec 2014 04:51:33 +0000
Message-ID: <20141213045133.GI22149@ZenIV.linux.org.uk>
References: <20141212213242.GE22149@ZenIV.linux.org.uk>
 <20141212.200758.944592759380344519.davem@davemloft.net>
 <20141213015415.GG22149@ZenIV.linux.org.uk>
 <20141212.213313.1419808296502891420.davem@davemloft.net>
 <20141213032500.GH22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53714 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797AbaLMEvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 23:51:35 -0500
Content-Disposition: inline
In-Reply-To: <20141213032500.GH22149@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2014 at 03:25:00AM +0000, Al Viro wrote:
> 	    msg->msg_iter.type == KVEC_ITER &&

ITER_IOVEC, that is.  And that way it even works...  Are you OK with the
commit below?

netlink: make the check for "send from tx_ring" deterministic
    
As it is, zero msg_iovlen means that the first iovec in the kernel
array of iovecs is left uninitialized, so checking if its ->iov_base
is NULL is random.  Since the real users of that thing are doing
sendto(fd, NULL, 0, ...), they are getting msg_iovlen = 1 and
msg_iov[0] = {NULL, 0}, which is what this test is trying to catch.
As suggested by davem, let's just check that msg_iovlen was 1 and
msg_iov[0].iov_base was NULL - _that_ is well-defined and it catches
what we want to catch.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index cc9bcf0..5bcb58c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2304,7 +2304,11 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto out;
 	}
 
+        /* It's a really convoluted way for userland to ask for mmaped
+	 * sendmsg(), but that's what we've got...  */
 	if (netlink_tx_is_mmaped(sk) &&
+	    msg->msg_iter.type == ITER_IOVEC &&
+	    msg->msg_iter.nr_segs == 1 &&
 	    msg->msg_iter.iov->iov_base == NULL) {
 		err = netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group,
 					   siocb);
