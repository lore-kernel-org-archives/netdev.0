From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH net 1/1] tipc: revert use of copy_from_iter_full()
Date: Thu, 22 Dec 2016 01:43:21 +0000
Message-ID: <20161222014321.GA2805@ZenIV.linux.org.uk>
References: <1482368497-7103-1-git-send-email-jon.maloy@ericsson.com>
 <20161222012101.GF1555@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        parthasarathy.bhuvaragan@ericsson.com, ying.xue@windriver.com,
        maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49574 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934181AbcLVBnZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 20:43:25 -0500
Content-Disposition: inline
In-Reply-To: <20161222012101.GF1555@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 22, 2016 at 01:21:01AM +0000, Al Viro wrote:
> On Wed, Dec 21, 2016 at 08:01:37PM -0500, Jon Maloy wrote:
> > commit cbbd26b8b1a6 ("[iov_iter] new primitives - copy_from_iter_full()
> > and friends") replaced calls to copy_from_iter() in the function
> > tipc_msg_build(). This causes a an immediate crash as follows:
> 
> Very interesting.
> 
> > [ 1209.597076] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> > [ 1209.607025] IP: copy_from_iter_full+0x43/0x290
> 
> > [ 1209.689257]  tipc_msg_build+0xe1/0x590 [tipc]
> > [ 1209.691479]  ? _raw_spin_unlock_bh+0x1e/0x20
> > [ 1209.694641]  ? tipc_node_find+0x30/0xa0 [tipc]
> > [ 1209.696789]  __tipc_sendmsg+0x189/0x480 [tipc]
> > [ 1209.699017]  ? remove_wait_queue+0x4d/0x60
> > [ 1209.700354]  tipc_connect+0x15f/0x1b0 [tipc]
> > [ 1209.701684]  SYSC_connect+0xd9/0x110
> 
> I don't believe that it's something tipc-specific; could you post an objdump
> of copy_from_iter_full() in your kernel?  That smells like a bug in there
> and it really ought to be fixed...

FWIW, looking at the tipc, am I reading the trace correctly?  We seem to
have tipc_connect() taking an msghdr with empty payload and hitting this
        switch (sk->sk_state) {
        case TIPC_OPEN:
                /* Send a 'SYN-' to destination */
                m.msg_name = dest;
                m.msg_namelen = destlen;

                /* If connect is in non-blocking case, set MSG_DONTWAIT to
                 * indicate send_msg() is never blocked.
                 */
                if (!timeout)
                        m.msg_flags = MSG_DONTWAIT;

                res = __tipc_sendmsg(sock, &m, 0);
which eventually calls
        rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, &pktchain);
possibly more than once, but with explicit "restore m->msg_iter to what
it was before the first call" before each subsequent call.

What's putting anything into m.msg_iter on that codepath?  AFAICS, it should
be completely empty...  Wait.  AAARRRGH!

OK, I see what's going on there - unlike iterate_and_advance(), which
explicitly skips any work in case of empty iterator, iterate_all_kind()
does not.  Could you check if the following fixes your problem?

diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index 228892dabba6..6a0396b8d47f 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -73,19 +73,21 @@
 }
 
 #define iterate_all_kinds(i, n, v, I, B, K) {			\
-	size_t skip = i->iov_offset;				\
-	if (unlikely(i->type & ITER_BVEC)) {			\
-		struct bio_vec v;				\
-		struct bvec_iter __bi;				\
-		iterate_bvec(i, n, v, __bi, skip, (B))		\
-	} else if (unlikely(i->type & ITER_KVEC)) {		\
-		const struct kvec *kvec;			\
-		struct kvec v;					\
-		iterate_kvec(i, n, v, kvec, skip, (K))		\
-	} else {						\
-		const struct iovec *iov;			\
-		struct iovec v;					\
-		iterate_iovec(i, n, v, iov, skip, (I))		\
+	if (i->count) {						\
+		size_t skip = i->iov_offset;			\
+		if (unlikely(i->type & ITER_BVEC)) {		\
+			struct bio_vec v;			\
+			struct bvec_iter __bi;			\
+			iterate_bvec(i, n, v, __bi, skip, (B))	\
+		} else if (unlikely(i->type & ITER_KVEC)) {	\
+			const struct kvec *kvec;		\
+			struct kvec v;				\
+			iterate_kvec(i, n, v, kvec, skip, (K))	\
+		} else {					\
+			const struct iovec *iov;		\
+			struct iovec v;				\
+			iterate_iovec(i, n, v, iov, skip, (I))	\
+		}						\
 	}							\
 }
 
