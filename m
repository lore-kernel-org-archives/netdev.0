From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] pktgen - handle NETDEV_TX_LOCKED
Date: Wed, 22 Sep 2004 14:11:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922141158.3a16416c@dell_ss3.pdx.osdl.net>
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

Change pktgen to handle drivers that return TX_LOCKED better.
This isn't a real busy state so just spin.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/core/pktgen.c b/net/core/pktgen.c
--- a/net/core/pktgen.c	2004-09-22 14:13:45 -07:00
+++ b/net/core/pktgen.c	2004-09-22 14:13:45 -07:00
@@ -587,11 +587,12 @@
 
 static void inject(struct pktgen_info* info)
 {
-	struct net_device *odev = NULL;
+	struct net_device *odev;
 	struct sk_buff *skb = NULL;
 	__u64 total = 0;
 	__u64 idle = 0;
 	__u64 lcount = 0;
+	int ret;
 	int nr_frags = 0;
 	int last_ok = 1;	   /* Was last skb sent? 
 				    * Or a failed transmit of some sort?  This will keep
@@ -640,19 +641,23 @@
 
 			atomic_inc(&skb->users);
 
-			if (odev->hard_start_xmit(skb, odev)) {
-
+		retry:
+			ret = odev->hard_start_xmit(skb, odev);
+			if (likely(ret == NETDEV_TX_OK)) {
+				last_ok = 1;	
+				info->sofar++;
+				info->seq_num++;
+			} else if (ret == NETDEV_TX_LOCKED 
+				   && (odev->features & NETIF_F_LLTX)) {
+				cpu_relax();
+				goto retry;
+			} else {
 				atomic_dec(&skb->users);
 				if (net_ratelimit()) {
 				   printk(KERN_INFO "Hard xmit error\n");
 				}
 				info->errors++;
 				last_ok = 0;
-			}
-			else {
-			   last_ok = 1;	
-			   info->sofar++;
-			   info->seq_num++;
 			}
 		}
 		else {
