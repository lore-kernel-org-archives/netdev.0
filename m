From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: cubic scaling error
Date: Wed, 25 Oct 2006 10:52:29 -0700
Message-ID: <20061025105229.3b93aa17@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Douglas Leith <doug.leith@nuim.ie>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:65484 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1422747AbWJYXCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 19:02:43 -0400
Received: from smtp.osdl.org (smtp.osdl.org [65.172.181.4])
	by zeus1.kernel.org (8.13.7/8.13.1) with ESMTP id k9PN2Sqc000484
	for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 23:02:41 GMT
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Doug Leith observed a discrepancy between the version of CUBIC described
in the papers and the version in 2.6.18. A math error related to scaling
causes Cubic to grow too slowly.

Patch is from "Sangtae Ha" <sha2@ncsu.edu>. I validated that
it does fix the problems.

See the following to show behavior over 500ms 100 Mbit link.

Sender (2.6.19-rc3) ---  Bridge (2.6.18-rt7) ------- Receiver (2.6.19-rc3)
                    1G      [netem]           100M

	http://developer.osdl.org/shemminger/tcp/2.6.19-rc3/cubic-orig.png
	http://developer.osdl.org/shemminger/tcp/2.6.19-rc3/cubic-fix.png

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- a/net/ipv4/tcp_cubic.c	2006-09-25 16:25:43.000000000 -0700
+++ b/net/ipv4/tcp_cubic.c	2006-10-25 09:17:28.000000000 -0700
@@ -190,7 +190,7 @@
          */
 
 	/* change the unit from HZ to bictcp_HZ */
-        t = ((tcp_time_stamp + ca->delay_min - ca->epoch_start)
+        t = ((tcp_time_stamp + (ca->delay_min>>3) - ca->epoch_start)
 	     << BICTCP_HZ) / HZ;
 
         if (t < ca->bic_K)		/* t - K */
@@ -259,7 +259,7 @@
 	    (s32)(tcp_time_stamp - ca->epoch_start) < HZ)
 		return;
 
-	delay = tcp_time_stamp - tp->rx_opt.rcv_tsecr;
+	delay = (tcp_time_stamp - tp->rx_opt.rcv_tsecr)<<3;
 	if (delay == 0)
 		delay = 1;
 
@@ -366,7 +366,7 @@
 
 	beta_scale = 8*(BICTCP_BETA_SCALE+beta)/ 3 / (BICTCP_BETA_SCALE - beta);
 
-	cube_rtt_scale = (bic_scale << 3) / 10;	/* 1024*c/rtt */
+	cube_rtt_scale = (bic_scale * 10);	/* 1024*c/rtt */
 
 	/* calculate the "K" for (wmax-cwnd) = c/rtt * K^3
 	 *  so K = cubic_root( (wmax-cwnd)*rtt/c )
