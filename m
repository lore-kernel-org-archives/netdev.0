From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] remove FCS from pktgen bandwidth calculation
Date: Wed, 8 Dec 2004 21:11:16 +0100
Message-ID: <20041208201116.GA10691@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This patch stops pktgen from counting the FCS in the 'total number of
bytes transmitted' and 'bits per second' calculations.


cheers,
Lennert


--- pktgen.c.orig	2004-11-28 22:27:50.000000000 +0100
+++ pktgen.c	2004-12-08 21:09:00.511175266 +0100
@@ -2564,7 +2564,6 @@
 static void show_results(struct pktgen_dev *pkt_dev, int nr_frags)
 {
        __u64 total_us, bps, mbps, pps, idle;
-       int size = pkt_dev->cur_pkt_size + 4; /* incl 32bit ethernet CRC */
        char *p = pkt_dev->result;
 
        total_us = pkt_dev->stopped_at - pkt_dev->started_at;
@@ -2576,7 +2575,7 @@
 
        p += sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte,%dfrags)\n",
                     total_us, (unsigned long long)(total_us - idle), idle,
-                    pkt_dev->sofar, size, nr_frags);
+                    pkt_dev->sofar, pkt_dev->cur_pkt_size, nr_frags);
 
        pps = pkt_dev->sofar * USEC_PER_SEC;
        
@@ -2588,7 +2587,7 @@
 
        do_div(pps, total_us);
        
-       bps = pps * 8 * size;
+       bps = pps * 8 * pkt_dev->cur_pkt_size;
 
        mbps = bps;
        do_div(mbps, 1000000);
@@ -2777,7 +2776,7 @@
 			pkt_dev->last_ok = 1;    
 			pkt_dev->sofar++;
 			pkt_dev->seq_num++;
-			pkt_dev->tx_bytes += (pkt_dev->cur_pkt_size + 4); /* count csum */
+			pkt_dev->tx_bytes += pkt_dev->cur_pkt_size;
 			
 		} else if (ret == NETDEV_TX_LOCKED 
 			   && (odev->features & NETIF_F_LLTX)) {
