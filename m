From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net-next] tcp: Fix bug in ofo queue pruning MIB stats
Date: Wed, 21 Dec 2011 15:50:01 -0800
Message-ID: <1324511401-2640-1-git-send-email-subramanian.vijay@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:42309 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121Ab1LUXrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 18:47:53 -0500
Received: by iaeh11 with SMTP id h11so12583447iae.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 15:47:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux MIB LINUX_MIB_OFOPRUNED is supposed to count the number of packets
dropped from the out-of-order queue due to socket buffer overrun. Instead
of counting the number of skbs freed, it counts the number of calls make to
__skb_queue_purge() which is not what the user (see f.e. netstat) is expecting.
Fix this by  incrementing the counter correctly.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 net/ipv4/tcp_input.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2877c3e..0e2c21b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4833,7 +4833,8 @@ static int tcp_prune_ofo_queue(struct sock *sk)
 	int res = 0;
 
 	if (!skb_queue_empty(&tp->out_of_order_queue)) {
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_OFOPRUNED);
+		NET_ADD_STATS_BH(sock_net(sk), LINUX_MIB_OFOPRUNED,
+				 tp->out_of_order_queue.qlen);
 		__skb_queue_purge(&tp->out_of_order_queue);
 
 		/* Reset SACK state.  A conforming SACK implementation will
-- 
1.7.0.4
