From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] pktgen - output formatting
Date: Wed, 22 Sep 2004 14:23:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922142301.6618c24d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller"
 <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This changes how the results of pktgen are computed.
 * use do_div to get 64 by 32 divide,  scale as needed to handle really long
   runs where total us > 2^32.
 * communication data rates are supposed to be reported as 1Meg = 1000000
 * split long line.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/core/pktgen.c b/net/core/pktgen.c
--- a/net/core/pktgen.c	2004-09-22 14:24:02 -07:00
+++ b/net/core/pktgen.c	2004-09-22 14:24:02 -07:00
@@ -584,16 +584,48 @@
 	return skb;
 }
 
+static void show_results(struct pktgen_info* info, int nr_frags)
+{
+	__u64 total, bps, mbps, pps;
+	unsigned long idle;
+	int size = info->pkt_size + 4; /* incl 32bit ethernet CRC */
+	char *p = info->result;
+
+	total = (info->stopped_at.tv_sec - info->started_at.tv_sec) * 1000000ull
+		+ info->stopped_at.tv_usec - info->started_at.tv_usec;
+
+	BUG_ON(cpu_speed == 0);
+
+	idle = info->idle_acc;
+	do_div(idle, cpu_speed);
+
+	p += sprintf(p, "OK: %llu(c%llu+d%lu) usec, %llu (%dbyte,%dfrags)\n",
+		     total, total - idle, idle,
+		     info->sofar, size, nr_frags);
+
+	pps = info->sofar * USEC_PER_SEC;
+	
+	while ((total >> 32) != 0) {
+		pps >>= 1;
+		total >>= 1;
+	}
+
+	do_div(pps, total);
+	
+	bps = pps * 8 * size;
+
+	mbps = bps;
+	do_div(mbps, 1000000);
+	p += sprintf(p, "  %llupps %lluMb/sec (%llubps) errors: %llu",
+		     pps, mbps, bps, info->errors);
+}
 
 static void inject(struct pktgen_info* info)
 {
 	struct net_device *odev;
 	struct sk_buff *skb = NULL;
-	__u64 total = 0;
-	__u64 idle = 0;
 	__u64 lcount = 0;
 	int ret;
-	int nr_frags = 0;
 	int last_ok = 1;	   /* Was last skb sent? 
 				    * Or a failed transmit of some sort?  This will keep
 				    * sequence numbers in order, for example.
@@ -633,8 +665,6 @@
 			}
 		}
 
-		nr_frags = skb_shinfo(skb)->nr_frags;
-		   
 		if (!(odev->features & NETIF_F_LLTX))
 			spin_lock_bh(&odev->xmit_lock);
 		if (!netif_queue_stopped(odev)) {
@@ -730,38 +760,7 @@
 
 	do_gettimeofday(&(info->stopped_at));
 
-	total = (info->stopped_at.tv_sec - info->started_at.tv_sec) * 1000000 +
-		info->stopped_at.tv_usec - info->started_at.tv_usec;
-
-	idle = (__u32)(info->idle_acc)/(__u32)(cpu_speed);
-
-	{
-		char *p = info->result;
-		__u64 bps, pps = 0;
-
-		if (total > 1000)
-			pps = (__u32)(info->sofar * 1000) / ((__u32)(total) / 1000);
-		else if(total > 100)
-			pps = (__u32)(info->sofar * 10000) / ((__u32)(total) / 100);
-		else if(total > 10)
-			pps = (__u32)(info->sofar * 100000) / ((__u32)(total) / 10);
-		else if(total > 1)
-			pps = (__u32)(info->sofar * 1000000) / (__u32)total;
-
-		bps = pps * 8 * (info->pkt_size + 4); /* take 32bit ethernet CRC into account */
-		p += sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte,%dfrags) %llupps %lluMb/sec (%llubps)  errors: %llu",
-			     (unsigned long long) total,
-			     (unsigned long long) (total - idle),
-			     (unsigned long long) idle,
-			     (unsigned long long) info->sofar,
-			     skb->len + 4, /* Add 4 to account for the ethernet checksum */
-			     nr_frags,
-			     (unsigned long long) pps,
-			     (unsigned long long) (bps / (u64) 1024 / (u64) 1024),
-			     (unsigned long long) bps,
-			     (unsigned long long) info->errors
-			     );
-	}
+	show_results(info, skb_shinfo(skb)->nr_frags);
 
 	kfree_skb(skb);
 
