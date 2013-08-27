From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] ipnetns: fix ip batch mode when using 'netns exec'
Date: Tue, 27 Aug 2013 09:25:34 +0200
Message-ID: <1377588334-13538-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34562 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321Ab3H0HZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 03:25:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit a05f6511f543, ip batch mode is broken when using 'netns exec' cmd.

When WIFEXITED() returns true, it means that the child exited normally, hence
we must not call exit() but just returns the status. If we call exit, the next
commands in the file file are not executed.
If WIFEXITED() returns false, we can call exit() because it means that the
child failed.

This patch partially reverts commit a05f6511f543.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipnetns.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index c8a47920539c..11dd9b89e503 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -205,11 +205,15 @@ static int netns_exec(int argc, char **argv)
 				exit(1);
 			}
 
-			/* If child failed, propagate status */
-			if (WIFEXITED(status))
-				exit(WEXITSTATUS(status));
+			if (WIFEXITED(status)) {
+				/* ip must returns the status of the child,
+				 * but do_cmd() will add a minus to this,
+				 * so let's add another one here to cancel it.
+				 */
+				return -WEXITSTATUS(status);
+			}
 
-			return 0;
+			exit(1);
 		}
 	}
 
-- 
1.8.2.1
