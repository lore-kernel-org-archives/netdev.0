From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: avoid frag allocation for small frames
Date: Sat, 22 Oct 2011 14:23:57 +0200
Message-ID: <1319286237.6180.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60043 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696Ab1JVMYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 08:24:04 -0400
Received: by wyg36 with SMTP id 36so4781472wyg.19
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2011 05:24:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_sendmsg() uses select_size() helper to choose skb head size when a
new skb must be allocated.

If GSO is enabled for the socket, current strategy is to force all
payload data to be outside of headroom, in PAGE fragments.

This strategy is not welcome for small packets, wasting memory.

Experiments show that best results are obtained when using 2048 bytes
for skb head (This includes the skb overhead and various headers)

This patch provides better len/truesize ratios for packets sent to
loopback device, and reduce memory needs for in-flight loopback packets,
particularly on arches with big pages.

If a sender sends many 1-byte packets to an unresponsive application,
receiver rmem_alloc will grow faster and will stop queuing these packets
sooner, or will collapse its receive queue to free excess memory.

netperf -t TCP_RR results are improved by ~4 %, and many workloads are
improved as well (tbench, mysql...)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 704adad..cd45b44 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -897,9 +897,12 @@ static inline int select_size(const struct sock *sk, int sg)
 	int tmp = tp->mss_cache;
 
 	if (sg) {
-		if (sk_can_gso(sk))
-			tmp = 0;
-		else {
+		if (sk_can_gso(sk)) {
+			/* Small frames wont use a full page:
+			 * Payload will immediately follow tcp header.
+			 */
+			tmp = SKB_WITH_OVERHEAD(2048 - MAX_TCP_HEADER);
+		} else {
 			int pgbreak = SKB_MAX_HEAD(MAX_TCP_HEADER);
 
 			if (tmp >= pgbreak &&
