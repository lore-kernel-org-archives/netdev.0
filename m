From: domen@coderock.org
Subject: [patch 17/26] net/shaper: replace sleep_on() with wait_event()
Date: Sun, 06 Mar 2005 11:33:32 +0100
Message-ID: <20050306103333.385001F204@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Use wait_event() instead of the deprecated sleep_on().
Move the in_interrupt() check outside loop, as I do not believe the
process context should change once execution has begun. Patch is
compile-tested.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/shaper.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff -puN drivers/net/shaper.c~sleep_on-drivers_net_shaper drivers/net/shaper.c
--- kj/drivers/net/shaper.c~sleep_on-drivers_net_shaper	2005-03-05 16:11:49.000000000 +0100
+++ kj-domen/drivers/net/shaper.c	2005-03-05 16:11:49.000000000 +0100
@@ -83,6 +83,7 @@
 #include <linux/if_arp.h>
 #include <linux/init.h>
 #include <linux/if_shaper.h>
+#include <linux/wait.h>
 
 #include <net/dst.h>
 #include <net/arp.h>
@@ -109,14 +110,9 @@ static int shaper_lock(struct shaper *sh
 	/*
 	 *	Lock in an interrupt must fail
 	 */
-	while (test_and_set_bit(0, &sh->locked))
-	{
-		if (!in_interrupt())
-			sleep_on(&sh->wait_queue);
-		else
-			return 0;
-			
-	}
+	if (in_interrupt())
+		return 0;
+	wait_event(sh->wait_queue, !test_and_set_bit(0, &sh->locked));
 	return 1;
 }
 
_
