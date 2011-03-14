From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/7] tcp_cubic: fix comparison of jiffies
Date: Mon, 14 Mar 2011 10:52:13 -0700
Message-ID: <20110314175439.377973202@vyatta.com>
References: <20110314175211.788224699@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58243 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757015Ab1CNSCD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 14:02:03 -0400
Content-Disposition: inline; filename=tcp-cubic-jiffies-wrap.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiffies wraps around therefore the correct way to compare is
to use cast to signed value.

Note: cubic is not using full jiffies value on 64 bit arch
because using full unsigned long makes struct bictcp grow too
large for the available ca_priv area.

Includes correction from Sangtae Ha to improve ack train detection.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/tcp_cubic.c	2011-03-11 09:00:06.856664687 -0800
+++ b/net/ipv4/tcp_cubic.c	2011-03-11 09:02:11.685796371 -0800
@@ -342,9 +342,11 @@ static void hystart_update(struct sock *
 		u32 curr_jiffies = jiffies;
 
 		/* first detection parameter - ack-train detection */
-		if (curr_jiffies - ca->last_jiffies <= msecs_to_jiffies(2)) {
+		if ((s32)(curr_jiffies - ca->last_jiffies) <=
+		    msecs_to_jiffies(2)) {
 			ca->last_jiffies = curr_jiffies;
-			if (curr_jiffies - ca->round_start >= ca->delay_min>>4)
+			if ((s32) (curr_jiffies - ca->round_start) >
+			    ca->delay_min >> 4)
 				ca->found |= HYSTART_ACK_TRAIN;
 		}
 


