From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/7] netpoll: shorten carrier detect timeout
Date: Sun, 06 Mar 2005 02:01:01 +0100
Message-ID: <422A564D.4080809@trash.net>
References: <2.454130102@selenic.com> <422A4A38.4040303@trash.net> <20050306002015.GD3120@waste.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000108030807050108000103"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Jeff Moyer <jmoyer@redhat.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050306002015.GD3120@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000108030807050108000103
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Matt Mackall wrote:
> On Sun, Mar 06, 2005 at 01:09:28AM +0100, Patrick McHardy wrote:
>>
>>The carrier detection looks partially broken to me. The current logic
>>detects an instantly available carrier as flaky because
>>netif_carrier_ok() takes less than 1/10s. This patch does what
>>I assume is intended, make sure the carrier is stable for 1/10s.
> 
> 
> Looks ok, but I've been meaning to change the second loop to something
> like msleep(). 

How about this one ? I also removed oflags, reading it outside of
the locked section was racy.

> Did you try this with a card that otherwise goes into the wait?

Yes, I tried with sk98lin. I don't have a card here that actually
supports netpoll.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------000108030807050108000103
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/core/netpoll.c 1.27 vs edited =====
--- 1.27/net/core/netpoll.c	2005-01-26 06:32:56 +01:00
+++ edited/net/core/netpoll.c	2005-03-06 01:58:48 +01:00
@@ -18,6 +18,7 @@
 #include <linux/interrupt.h>
 #include <linux/netpoll.h>
 #include <linux/sched.h>
+#include <linux/delay.h>
 #include <linux/rcupdate.h>
 #include <net/tcp.h>
 #include <net/udp.h>
@@ -575,16 +576,14 @@
 	}
 
 	if (!netif_running(ndev)) {
-		unsigned short oflags;
 		unsigned long atmost, atleast;
+		long left;
 
 		printk(KERN_INFO "%s: device %s not up yet, forcing it\n",
 		       np->name, np->dev_name);
 
-		oflags = ndev->flags;
-
 		rtnl_shlock();
-		if (dev_change_flags(ndev, oflags | IFF_UP) < 0) {
+		if (dev_change_flags(ndev, ndev->flags | IFF_UP) < 0) {
 			printk(KERN_ERR "%s: failed to open %s\n",
 			       np->name, np->dev_name);
 			rtnl_shunlock();
@@ -592,8 +591,7 @@
 		}
 		rtnl_shunlock();
 
-		atleast = jiffies + HZ/10;
- 		atmost = jiffies + 10*HZ;
+ 		atmost = jiffies + 4*HZ;
 		while (!netif_carrier_ok(ndev)) {
 			if (time_after(jiffies, atmost)) {
 				printk(KERN_NOTICE
@@ -604,12 +602,16 @@
 			cond_resched();
 		}
 
+		atleast = jiffies + HZ/10;
+		while (netif_carrier_ok(ndev) && time_before(jiffies, atleast))
+			cond_resched();
 		if (time_before(jiffies, atleast)) {
 			printk(KERN_NOTICE "%s: carrier detect appears flaky,"
-			       " waiting 10 seconds\n",
+			       " waiting 4 seconds\n",
 			       np->name);
-			while (time_before(jiffies, atmost))
-				cond_resched();
+			left = atmost - jiffies;
+			if (left > 0)
+				msleep(jiffies_to_msecs(left));
 		}
 	}
 

--------------000108030807050108000103--
