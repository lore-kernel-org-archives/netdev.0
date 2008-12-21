From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: [PATCH] netlink: fix (theoretical) overrun in message iteration
Date: Sun, 21 Dec 2008 14:42:18 +0100
Message-ID: <20081221134218.GA7959@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Eugene Teo <eugeneteo@kernel.sg>,
	Andrew Morton <akpm@linux-foundation.org>,
	Al Viro <viro@zeniv.linux.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.176]:25894 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbYLUNkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 08:40:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From bb805d89e84ddb11c9bb58afcfd9a6b37bbe5a9b Mon Sep 17 00:00:00 2001
From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Sun, 21 Dec 2008 14:20:49 +0100
Subject: [PATCH] netlink: fix (theoretical) overrun in message iteration

See commit 1045b03e07d85f3545118510a587035536030c1c for a detailed
explanation of why this patch is necessary.

In short, nlmsg_next() can make "remaining" go negative, and the
remaining >= sizeof(...) comparison will promote "remaining" to an
unsigned type, which means that the expression will evaluate to
true for negative numbers, even though it was not intended.

I put "theoretical" in the title because I have no evidence that
this can actually happen, but I suspect that a crafted netlink
packet can trigger some badness.

Note that the last test, which seemingly has the exact same
problem (also true for nla_ok()), is perfectly OK, since we
already know that remaining is positive.

Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>
---
 include/net/netlink.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 3643bbb..13dd525 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -332,7 +332,7 @@ static inline int nlmsg_attrlen(const struct nlmsghdr *nlh, int hdrlen)
  */
 static inline int nlmsg_ok(const struct nlmsghdr *nlh, int remaining)
 {
-	return (remaining >= sizeof(struct nlmsghdr) &&
+	return (remaining >= (int) sizeof(struct nlmsghdr) &&
 		nlh->nlmsg_len >= sizeof(struct nlmsghdr) &&
 		nlh->nlmsg_len <= remaining);
 }
-- 
1.5.6.5

