From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/7] netpoll: shorten carrier detect timeout
Date: Sun, 06 Mar 2005 01:09:28 +0100
Message-ID: <422A4A38.4040303@trash.net>
References: <2.454130102@selenic.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020409060805070303080608"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Jeff Moyer <jmoyer@redhat.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <2.454130102@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020409060805070303080608
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Matt Mackall wrote:
> Shorten carrier detect timeout to 4 seconds.

The carrier detection looks partially broken to me. The current logic
detects an instantly available carrier as flaky because
netif_carrier_ok() takes less than 1/10s. This patch does what
I assume is intended, make sure the carrier is stable for 1/10s.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------020409060805070303080608
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/core/netpoll.c 1.27 vs edited =====
--- 1.27/net/core/netpoll.c	2005-01-26 06:32:56 +01:00
+++ edited/net/core/netpoll.c	2005-03-06 01:07:16 +01:00
@@ -592,8 +592,7 @@
 		}
 		rtnl_shunlock();
 
-		atleast = jiffies + HZ/10;
- 		atmost = jiffies + 10*HZ;
+ 		atmost = jiffies + 4*HZ;
 		while (!netif_carrier_ok(ndev)) {
 			if (time_after(jiffies, atmost)) {
 				printk(KERN_NOTICE
@@ -604,9 +603,15 @@
 			cond_resched();
 		}
 
+		atleast = jiffies + HZ/10;
+		while (netif_carrier_ok(ndev)) {
+			if (time_after(jiffies, atleast))
+				break;
+			cond_resched();
+		}
 		if (time_before(jiffies, atleast)) {
 			printk(KERN_NOTICE "%s: carrier detect appears flaky,"
-			       " waiting 10 seconds\n",
+			       " waiting 4 seconds\n",
 			       np->name);
 			while (time_before(jiffies, atmost))
 				cond_resched();

--------------020409060805070303080608--
