From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] ping: ICMP error replies while errno < 0 is a hard error
Date: Tue,  7 Jun 2016 14:05:22 +0200
Message-ID: <20160607120522.9474-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org, hideaki@yoshifuji.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:43054 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751196AbcFGMKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 08:10:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some odd conditions in which a device will return an error for
sendto, while at the same time an ICMP error response is generated. In
this case, with the current code, the packet is retransmitted in a
flood, which is not what anybody wants. In fact, when these two
conditions occur, we want to treat the packet as a "hard local error"
and do the ordinary pause as before. The reasoning is that if we did
receive an ICMP error message, then the packet was transmitted, and so
it should be accounted for. But, since we also received an errno, this
should be reported to the user, as something is wonky with their network
interface.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 ping_common.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/ping_common.c b/ping_common.c
index 6054a91..89c0463 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -567,9 +567,14 @@ resend:
 		return MININTERVAL;
 	} else {
 		if ((i=receive_error_msg()) > 0) {
-			/* An ICMP error arrived. */
-			tokens += interval;
-			return MININTERVAL;
+			/* An ICMP error arrived. In this case, we've received
+			 * an error from sendto(), but we've also received an
+			 * ICMP message, which means the packet did in fact
+			 * send in some capacity. So, in this odd case, report
+			 * the more specific errno as the error, and treat this
+			 * as a hard local error. */
+			i = 0;
+			goto hard_local_error;
 		}
 		/* Compatibility with old linuces. */
 		if (i == 0 && confirm_flag && errno == EINVAL) {
@@ -580,6 +585,7 @@ resend:
 			goto resend;
 	}
 
+hard_local_error:
 	/* Hard local error. Pretend we sent packet. */
 	advance_ntransmitted();
 
-- 
2.8.3
