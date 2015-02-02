From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 01/18] netlink: make the check for "send from tx_ring" deterministic
Date: Mon,  2 Feb 2015 07:59:20 +0000
Message-ID: <1422863977-17668-1-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:32957 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932719AbbBBH7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 02:59:38 -0500
In-Reply-To: <20150131035513.GK29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

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
 net/netlink/af_netlink.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a36777b..af51d58 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2298,7 +2298,11 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto out;
 	}
 
+        /* It's a really convoluted way for userland to ask for mmaped
+	 * sendmsg(), but that's what we've got...  */
 	if (netlink_tx_is_mmaped(sk) &&
+	    msg->msg_iter.type == ITER_IOVEC &&
+	    msg->msg_iter.nr_segs == 1 &&
 	    msg->msg_iter.iov->iov_base == NULL) {
 		err = netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group,
 					   &scm);
-- 
2.1.4
