From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 v2] ipnetns: fix ip batch mode when using 'netns exec'
Date: Thu, 29 Aug 2013 14:29:07 +0200
Message-ID: <1377779347-7077-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1377588334-13538-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40876 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276Ab3H2M3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 08:29:16 -0400
In-Reply-To: <1377588334-13538-1-git-send-email-nicolas.dichtel@6wind.com>
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

v2: fix a typo in a comment

 ip/ipnetns.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index c8a47920539c..89dda3ffd138 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -205,11 +205,15 @@ static int netns_exec(int argc, char **argv)
 				exit(1);
 			}
 
-			/* If child failed, propagate status */
-			if (WIFEXITED(status))
-				exit(WEXITSTATUS(status));
+			if (WIFEXITED(status)) {
+				/* ip must return the status of the child,
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
