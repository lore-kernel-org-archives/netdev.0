From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/7] tcp_cubic: fix low utilization of CUBIC with HyStart
Date: Mon, 14 Mar 2011 10:52:18 -0700
Message-ID: <20110314175439.844558845@vyatta.com>
References: <20110314175211.788224699@vyatta.com>
Cc: netdev@vger.kernel.org, Sangtae Ha <sangtae.ha@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58253 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757057Ab1CNSCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 14:02:04 -0400
Content-Disposition: inline; filename=tcp-cubic-initial-growth.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sangtae Ha <sangtae.ha@gmail.com>

HyStart sets the initial exit point of slow start.
Suppose that HyStart exits at 0.5BDP in a BDP network and no history exists.
If the BDP of a network is large, CUBIC's initial cwnd growth may be
too conservative to utilize the link.
CUBIC increases the cwnd 20% per RTT in this case.

Signed-off-by: Sangtae Ha <sangtae.ha@gmail.com>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 net/ipv4/tcp_cubic.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

--- a/net/ipv4/tcp_cubic.c	2011-03-14 08:32:46.347993869 -0700
+++ b/net/ipv4/tcp_cubic.c	2011-03-14 10:57:00.846549449 -0700
@@ -270,6 +270,13 @@ static inline void bictcp_update(struct
 		ca->cnt = 100 * cwnd;              /* very small increment*/
 	}
 
+	/*
+	 * The initial growth of cubic function may be too conservative
+	 * when the available bandwidth is still unknown.
+	 */
+	if (ca->loss_cwnd == 0 && ca->cnt > 20)
+		ca->cnt = 20;	/* increase cwnd 5% per RTT */
+
 	/* TCP Friendly */
 	if (tcp_friendliness) {
 		u32 scale = beta_scale;


