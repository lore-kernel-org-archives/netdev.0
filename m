From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net] tcp: consider recv buf for the initial window scale
Date: Thu, 28 Jul 2016 23:11:34 -0400
Message-ID: <1469761894-26014-1-git-send-email-soheil.kdev@gmail.com>
Cc: edumazet@google.com, ycheng@google.com, ncardwell@google.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35622 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbcG2DLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 23:11:55 -0400
Received: by mail-qk0-f195.google.com with SMTP id q62so6203713qkf.2
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2016 20:11:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

tcp_select_initial_window() intends to advertise a window
scaling for the maximum possible window size. To do so,
it considers the maximum of net.ipv4.tcp_rmem[2] and
net.core.rmem_max as the only possible upper-bounds.
However, users with CAP_NET_ADMIN can use SO_RCVBUFFORCE
to set the socket's receive buffer size to values
larger than net.ipv4.tcp_rmem[2] and net.core.rmem_max.
Thus, SO_RCVBUFFORCE is effectively ignored by
tcp_select_initial_window().

To fix this, consider the maximum of net.ipv4.tcp_rmem[2],
net.core.rmem_max and socket's initial buffer space.

This part of the code does not have git history and as a
result this patch does not have a `Fixes:` tag.

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Suggested-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_output.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b26aa87..bdaef7f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -236,7 +236,8 @@ void tcp_select_initial_window(int __space, __u32 mss,
 		/* Set window scaling on max possible window
 		 * See RFC1323 for an explanation of the limit to 14
 		 */
-		space = max_t(u32, sysctl_tcp_rmem[2], sysctl_rmem_max);
+		space = max_t(u32, space, sysctl_tcp_rmem[2]);
+		space = max_t(u32, space, sysctl_rmem_max);
 		space = min_t(u32, space, *window_clamp);
 		while (space > 65535 && (*rcv_wscale) < 14) {
 			space >>= 1;
-- 
2.8.0.rc3.226.g39d4020
