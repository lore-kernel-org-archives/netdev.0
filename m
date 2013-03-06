From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net/ipv4: Timestamp option cannot overflow with prespecified addresses
Date: Tue, 5 Mar 2013 22:06:32 -0500
Message-ID: <1362539192-9343-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:53594 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750961Ab3CFDGq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Mar 2013 22:06:46 -0500
Received: from LLE2K7-HUB02.mitll.ad.local (LLE2K7-HUB02.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id r2636jCH009248 for <netdev@vger.kernel.org>; Tue, 5 Mar 2013 22:06:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a router forwards a packet that contains the IPv4 timestamp option,
if there is no space left in the option for the router to add its own
timestamp, then the router increments the Overflow value in the option.

However, if the addresses of the routers are prespecified in the option,
then the overflow condition cannot happen: the option is structured so
that each prespecified router has a place to write its timestamp. Other
routers do not add a timestamp, so there will never be a lack of space.

This fix ensures that the Overflow value in the IPv4 timestamp option is
not incremented when the addresses of the routers are prespecified, even
if the Pointer value is greater than the Length value.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/ipv4/ip_options.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index f6289bf..310a364 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -423,7 +423,7 @@ int ip_options_compile(struct net *net,
 					put_unaligned_be32(midtime, timeptr);
 					opt->is_changed = 1;
 				}
-			} else {
+			} else if ((optptr[3]&0xF) != IPOPT_TS_PRESPEC) {
 				unsigned int overflow = optptr[3]>>4;
 				if (overflow == 15) {
 					pp_ptr = optptr + 3;
-- 
1.7.1
