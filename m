From: akpm@linux-foundation.org
Subject: [patch 3/3] drivers/net/appletalk: use time_before, time_before_eq, etc
Date: Fri, 18 Apr 2008 13:46:12 -0700
Message-ID: <200804182046.m3IKkCV7014622@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33351 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752935AbYDRUqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 16:46:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The functions time_before, time_before_eq, time_after, and time_after_eq
are more robust for comparing jiffies against other values.

A simplified version of the semantic patch making this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@ change_compare_np @
expression E;
@@

(
- jiffies <= E
+ time_before_eq(jiffies,E)
|
- jiffies >= E
+ time_after_eq(jiffies,E)
|
- jiffies < E
+ time_before(jiffies,E)
|
- jiffies > E
+ time_after(jiffies,E)
)

@ include depends on change_compare_np @
@@

#include <linux/jiffies.h>

@ no_include depends on !include && change_compare_np @
@@

  #include <linux/...>
+ #include <linux/jiffies.h>
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/appletalk/cops.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/net/appletalk/cops.c~drivers-net-appletalk-use-time_before-time_before_eq-etc drivers/net/appletalk/cops.c
--- a/drivers/net/appletalk/cops.c~drivers-net-appletalk-use-time_before-time_before_eq-etc
+++ a/drivers/net/appletalk/cops.c
@@ -69,6 +69,7 @@ static const char *version =
 #include <linux/atalk.h>
 #include <linux/spinlock.h>
 #include <linux/bitops.h>
+#include <linux/jiffies.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
@@ -503,7 +504,7 @@ static void cops_reset(struct net_device
                         long snap=jiffies;
 
 			/* Let card finish initializing, about 1/3 second */
-	                while(jiffies-snap<HZ/3)
+			while (time_before(jiffies, snap + HZ/3))
                                 schedule();
                 }
                 else
_
