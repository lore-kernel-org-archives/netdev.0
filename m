From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] pktgen handle netdev device getting full.
Date: Thu, 16 Sep 2004 14:43:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916144332.37f19fcb@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jamal Hadi Salim <hadi@znyx.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller"
 <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I was trying out pktgen on a NIC with an undersized ring, so 
hard_start_xmit would always return non-zero when full.  This caused a slew
of console messages.  Better to just have pktgen retry in this case.

Also, can use do_div to do the 64 bit divide rather than doing long string
of if statements when computing results.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/core/pktgen.c b/net/core/pktgen.c
--- a/net/core/pktgen.c	2004-09-16 14:42:25 -07:00
+++ b/net/core/pktgen.c	2004-09-16 14:42:25 -07:00
@@ -589,7 +589,7 @@
 {
 	struct net_device *odev = NULL;
 	struct sk_buff *skb = NULL;
-	__u64 total = 0;
+	__u32 total = 0;
 	__u64 idle = 0;
 	__u64 lcount = 0;
 	int nr_frags = 0;
@@ -636,28 +636,20 @@
 		   
 		if (!(odev->features & NETIF_F_LLTX))
 			spin_lock_bh(&odev->xmit_lock);
-		if (!netif_queue_stopped(odev)) {
 
+		last_ok = 0;
+		if (!netif_queue_stopped(odev)) {
 			atomic_inc(&skb->users);
 
-			if (odev->hard_start_xmit(skb, odev)) {
-
+			if (odev->hard_start_xmit(skb, odev) == NETDEV_TX_OK) {
+				last_ok = 1;	
+				info->sofar++;
+				info->seq_num++;
+			} else {
+				/* Device kicked us out :(
+				   so retry again */
 				atomic_dec(&skb->users);
-				if (net_ratelimit()) {
-				   printk(KERN_INFO "Hard xmit error\n");
-				}
-				info->errors++;
-				last_ok = 0;
 			}
-			else {
-			   last_ok = 1;	
-			   info->sofar++;
-			   info->seq_num++;
-			}
-		}
-		else {
-			/* Re-try it next time */
-			last_ok = 0;
 		}
 		
 		if (!(odev->features & NETIF_F_LLTX))
@@ -733,15 +725,9 @@
 	{
 		char *p = info->result;
 		__u64 bps, pps = 0;
-
-		if (total > 1000)
-			pps = (__u32)(info->sofar * 1000) / ((__u32)(total) / 1000);
-		else if(total > 100)
-			pps = (__u32)(info->sofar * 10000) / ((__u32)(total) / 100);
-		else if(total > 10)
-			pps = (__u32)(info->sofar * 100000) / ((__u32)(total) / 10);
-		else if(total > 1)
-			pps = (__u32)(info->sofar * 1000000) / (__u32)total;
+		
+		pps = info->sofar * 1000000;
+		do_div(pps, total);
 
 		bps = pps * 8 * (info->pkt_size + 4); /* take 32bit ethernet CRC into account */
 		p += sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte,%dfrags) %llupps %lluMb/sec (%llubps)  errors: %llu",
