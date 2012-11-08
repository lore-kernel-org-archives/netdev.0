From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] ipv4: Handle very small SO_SNDTIMEOs
Date: Thu,  8 Nov 2012 07:51:48 -0800
Message-ID: <1352389908-28587-1-git-send-email-andi@firstfloor.org>
Cc: netdev@vger.kernel.org, Andi Kleen <ak@linux.intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3804 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464Ab2KHPvw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2012 10:51:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

When the SO_SNDTIMEO timeout is short enough it may round down to zero
jiffies.   This causes unexpected behaviour because the socket
essentially becomes always non blocking.

Round up the timeout to at least two jiffies, so that
we guarantee waiting for at least some time. With one jiffie
we could potentially still wait zero time because we might
be just at the edge of the jiffie, and if it flips over
in the middle of the check it could be still zero.

This has been observed in a real application.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 net/core/sock.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index a6000fb..93c0060 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -362,8 +362,15 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 	*timeo_p = MAX_SCHEDULE_TIMEOUT;
 	if (tv.tv_sec == 0 && tv.tv_usec == 0)
 		return 0;
-	if (tv.tv_sec < (MAX_SCHEDULE_TIMEOUT/HZ - 1))
+	if (tv.tv_sec < (MAX_SCHEDULE_TIMEOUT/HZ - 1)) {
 		*timeo_p = tv.tv_sec*HZ + (tv.tv_usec+(1000000/HZ-1))/(1000000/HZ);
+		/* Do at least two jiffies to ensure we wait at all.
+		 * Otherwise we may be on the edge of the next jiffie already,
+		 * and then essentially non block.
+		 */
+		if ((unsigned long)*timeo_p < 2)
+			*timeo_p = 2;
+	}
 	return 0;
 }
 
-- 
1.7.7.6
