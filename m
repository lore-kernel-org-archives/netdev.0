From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [KJ] [PATCH 29/34] net/shaper: replace sleep_on() with wait_event()
Date: Tue, 25 Jan 2005 16:37:32 -0800
Message-ID: <20050126003732.GU12649@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5213703155203242=="
Cc: netdev@oss.sgi.com, kernel-janitors@lists.osdl.org
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: alan@redhat.com
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============5213703155203242==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Please consider applying.

Description: Use wait_event() instead of the deprecated sleep_on().
Move the in_interrupt() check outside loop, as I do not believe the
process context should change once execution has begun. Patch is
compile-tested.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

--- 2.6.11-rc2-kj-v/drivers/net/shaper.c	2005-01-24 09:34:10.000000000 -0800
+++ 2.6.11-rc2-kj/drivers/net/shaper.c	2005-01-25 11:44:13.000000000 -0800
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
 

--===============5213703155203242==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============5213703155203242==--
