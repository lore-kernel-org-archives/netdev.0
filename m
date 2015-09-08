From: "D. Hugh Redelmeier" <hugh@mimosa.com>
Subject: PATCH: netdev: add a cast NLMSG_OK to avoid a GCC warning in users'
 code
Date: Tue, 8 Sep 2015 09:46:56 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1509080933340.4754@redclaw.mimosa.com>
Reply-To: "D. Hugh Redelmeier" <hugh@mimosa.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-d.mimosa.com ([209.161.207.149]:43498 "EHLO gw-d.mimosa.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754355AbbIHOP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2015 10:15:59 -0400
Received: from redclaw.mimosa.com (redclaw.mimosa.com [192.139.70.88])
	by gw-d.mimosa.com (8.12.8/8.12.8) with ESMTP id t88Dj5Zv031982
	for <netdev@vger.kernel.org>; Tue, 8 Sep 2015 09:45:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using netlink.h's NLMSG_OK correctly will cause GCC to issue a warning
on systems with 32-bit userland.  The definition can easily be changed
to avoid this.

GCC's warning is to flag comparisons where C's implicit "Usual
Arithmetic Conversions" could lead to a surprising result.

Consider this context:
	int i;
	unsigned u;
The C standard says that i<u is evaluated as (unsigned)i < u.
This can easily be a surprise because a negative value of i will be 
silently treated as a very large positive value.

In include/uapi/linux/netlink.h:
#define NLMSG_OK(nlh,len) ((len) >= (int)sizeof(struct nlmsghdr) && \
			   (nlh)->nlmsg_len >= sizeof(struct nlmsghdr) && \
			   (nlh)->nlmsg_len <= (len))

This comparison looks suspicious to GCC:
	(nlh)->nlmsg_len <= (len)
nlmsg_len is of type __u32.  If int is 32 bits, this compare will be
done as
	(nlh)->nlmsg_len <= (unsigned)(len)
We know that this is actually safe because the first conjunct
determined that len isn't negative but the GCC apparently doesn't know.

A change that would calm GCC and also be correct would be to add
a cast to unsigned:
	(nlh)->nlmsg_len <= (unsigned)(len))
But I imagine that len might well actually have type ssize_t.  It is
often the result of a call to recvfrom(2), which is a ssize_t.  So I
think that this would be safer:
	(nlh)->nlmsg_len <= (size_t)(len))
I know of no system where size_t is narrower than unsigned.

This problem came up when building a userland component of libreswan in a 
32-bit environment with a recent GCC and was reported by Lennart Sorensen.

Signed-off-by: D. Hugh Redelmeier <hugh@mimosa.com>

diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index 6f3fe16..dd15537 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -86,7 +86,7 @@ struct nlmsghdr {
 				  (struct nlmsghdr*)(((char*)(nlh)) + NLMSG_ALIGN((nlh)->nlmsg_len)))
 #define NLMSG_OK(nlh,len) ((len) >= (int)sizeof(struct nlmsghdr) && \
 			   (nlh)->nlmsg_len >= sizeof(struct nlmsghdr) && \
-			   (nlh)->nlmsg_len <= (len))
+			   (nlh)->nlmsg_len <= (size_t)(len))
 #define NLMSG_PAYLOAD(nlh,len) ((nlh)->nlmsg_len - NLMSG_SPACE((len)))
 
 #define NLMSG_NOOP		0x1	/* Nothing.		*/
