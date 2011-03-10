From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/6] tcp_cubic: fix comparison of jiffies
Date: Thu, 10 Mar 2011 08:51:25 -0800
Message-ID: <20110310165328.999266946@vyatta.com>
References: <20110310165119.224046957@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sangtae.ha@gmail.com, rhee@ncsu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45022 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753762Ab1CJQ4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 11:56:24 -0500
Content-Disposition: inline; filename=tcp-cubic-jiffies-wrap.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiffies wraps around therefore the correct way to compare is
to use cast to signed value.

Note: cubic is not using full jiffies value on 64 bit arch
because using full unsigned long makes struct bictcp grow too
large for the available ca_priv area.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/tcp_cubic.c	2011-03-10 08:08:32.867492953 -0800
+++ b/net/ipv4/tcp_cubic.c	2011-03-10 08:24:39.658201745 -0800
@@ -342,9 +342,11 @@ static void hystart_update(struct sock *
 		u32 curr_jiffies = jiffies;
 
 		/* first detection parameter - ack-train detection */
-		if (curr_jiffies - ca->last_jiffies <= msecs_to_jiffies(2)) {
+		if ((s32)(curr_jiffies - ca->last_jiffies) <=
+		    msecs_to_jiffies(2)) {
 			ca->last_jiffies = curr_jiffies;
-			if (curr_jiffies - ca->round_start >= ca->delay_min>>4)
+			if ((s32) (curr_jiffies - ca->round_start) <=
+			    ca->delay_min >> 4)
 				ca->found |= HYSTART_ACK_TRAIN;
 		}
 


