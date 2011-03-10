From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: skip forwarding delay if not using STP
Date: Thu, 10 Mar 2011 07:57:04 -0800
Message-ID: <20110310075704.47f91bd5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40485 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398Ab1CJP5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 10:57:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

f Spanning Tree Protocol is not enabled, there is no good reason for
the bridge code to wait for the forwarding delay period before enabling
the link. The purpose of the forwarding delay is to allow STP to
learn about other bridges before nominating itself.

The only possible impact is that when starting up a new port
the bridge may flood a packet now, where previously it might have
seen traffic from the other host and preseeded the forwarding table.

Includes change for local variable br already available in that func.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_stp.c	2011-03-07 14:56:45.660973568 -0800
+++ b/net/bridge/br_stp.c	2011-03-07 14:57:47.373590362 -0800
@@ -375,12 +375,12 @@ static void br_make_forwarding(struct ne
 	if (p->state != BR_STATE_BLOCKING)
 		return;
 
-	if (br->forward_delay == 0) {
+	if (br->stp_enabled == BR_NO_STP || br->forward_delay == 0) {
 		p->state = BR_STATE_FORWARDING;
 		br_topology_change_detection(br);
 		del_timer(&p->forward_delay_timer);
 	}
-	else if (p->br->stp_enabled == BR_KERNEL_STP)
+	else if (br->stp_enabled == BR_KERNEL_STP)
 		p->state = BR_STATE_LISTENING;
 	else
 		p->state = BR_STATE_LEARNING;
