From: Sangtae Ha <sangtae.ha@gmail.com>
Subject: [PATCH 3/3] tcp_cubic: fix low utilization of CUBIC with HyStart
Date: Sun, 13 Mar 2011 20:04:33 -0400
Message-ID: <1300061073-24209-1-git-send-email-sangtae.ha@gmail.com>
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Injong Rhee <rhee@ncsu.edu>,
	Bill Fink <billfink@mindspring.com>, <netdev@vger.kernel.org>,
	Sangtae Ha <sangtae.ha@gmail.com>
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:51689 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755565Ab1CNAEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 20:04:40 -0400
Received: by qyg14 with SMTP id 14so3915569qyg.19
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2011 17:04:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HyStart sets the initial exit point of slow start.
Suppose that HyStart exits at 0.5BDP in a BDP network and no history exists.
If the BDP of a network is large, CUBIC's initial cwnd growth may be
too conservative to utilize the link.
CUBIC increases the cwnd 20% per RTT in this case.

Signed-off-by: Sangtae Ha <sangtae.ha@gmail.com>
---
 net/ipv4/tcp_cubic.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index b758db1..a170778 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -270,6 +270,15 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 		ca->cnt = 100 * cwnd;              /* very small increment*/
 	}
 
+	/*
+	 * The initial growth of cubic function may be too conservative
+	 * when the available bandwidth is still unknown.
+	 */
+	if (ca->loss_cwnd == 0) {
+		if (ca->cnt > 20)	/* increase cwnd 5% per RTT */
+			ca->cnt = 20;
+	}
+
 	/* TCP Friendly */
 	if (tcp_friendliness) {
 		u32 scale = beta_scale;
-- 
1.7.0.4

