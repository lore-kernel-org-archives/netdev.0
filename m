From: "Kambo Lohan" <kambo77@hotmail.com>
Subject: Re: PATCH pktgen hang, memleak, fixes
Date: Sat, 19 Jul 2003 13:34:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Sea2-F21f3ednHM3SOl00002520@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

That patch is bad please use the updated patch ([PATCH] [UPDATED] pktgen 
fixes on netdev)....I will attempt to repost while snipping the whitespace 
change



>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--- linux-2.4.21/net/core/pktgen.c	2002-11-28 18:53:15.000000000 -0500
+++ linux-2.4-kjp/net/core/pktgen.c	2003-07-10 13:22:17.000000000 -0400
@@ -34,6 +34,7 @@
  *   *  The new changes seem to have a performance impact of around 1%,
  *       as far as I can tell.
  *   --Ben Greear <greearb@candelatech.com>
+ * Fix refcount off by one if first packet fails, potential null deref,
memleak 030710- KJP
  *
  * Renamed multiskb to clone_skb and cleaned up sending core for two
distinct
  * skb modes. A clone_skb=0 mode for Ben "ranges" work and a clone_skb != 0
@@ -84,9 +85,9 @@
#define cycles()	((u32)get_cycles())


-#define VERSION "pktgen version 1.2"
+#define VERSION "pktgen version 1.2.1"
static char version[] __initdata =
-  "pktgen.c: v1.2: Packet Generator for packet performance testing.\n";
+  "pktgen.c: v1.2.1: Packet Generator for packet performance testing.\n";

/* Used to help with determining the pkts on receive */

@@ -613,12 +614,11 @@
                                 kfree_skb(skb);
                                 skb = fill_packet(odev, info);
                                 if (skb == NULL) {
-                                        break;
+					goto out_reldev;
                                 }
                                 fp++;
                                 fp_tmp = 0; /* reset counter */
                         }
-                        atomic_inc(&skb->users);
                 }

                 nr_frags = skb_shinfo(skb)->nr_frags;
@@ -626,7 +626,9 @@
		spin_lock_bh(&odev->xmit_lock);
		if (!netif_queue_stopped(odev)) {

+			atomic_inc(&skb->users);
			if (odev->hard_start_xmit(skb, odev)) {
+				atomic_dec(&skb->users);
				if (net_ratelimit()) {
                                    printk(KERN_INFO "Hard xmit error\n");
                                 }
@@ -731,6 +733,8 @@
			     (unsigned long long) info->errors
			     );
	}
+
+	kfree_skb(skb);

out_reldev:
         if (odev) {

_________________________________________________________________
The new MSN 8: advanced junk mail protection and 2 months FREE*  
http://join.msn.com/?page=features/junkmail
