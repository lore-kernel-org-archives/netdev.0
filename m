From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] ipv6: Fix udp checksums with raw sockets
Date: Thu, 14 May 2015 20:34:08 -0400
Message-ID: <1431650048-16189-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Wolfgang Walter <linux@stwm.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:33457 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423286AbbEOAeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 20:34:20 -0400
Received: by qkp63 with SMTP id 63so23824064qkp.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 17:34:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was reported that trancerout6 would cause
a kernel to crash when trying to compute checksums
on raw UDP packets.  The cause was the check in
__ip6_append_data that would attempt to use
partial checksums on the packet.  However,
raw sockets do not initialize partial checksum
fields so partial checksums can't be used.

Solve this the same way IPv4 does it.  raw sockets
pass transhdrlen value of 0 to ip_append_data which
causes the checksum to be computed in software.  Use
the same check in ip6_append_data (check transhdrlen).

Reported-by: Wolfgang Walter <linux@stwm.de>
CC: Wolfgang Walter <linux@stwm.de>
CC: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/ipv6/ip6_output.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7fde1f2..2a7c537 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1277,8 +1277,10 @@ emsgsize:
 
 	/* If this is the first and only packet and device
 	 * supports checksum offloading, let's use it.
+	 * Use transhdrlen, same as IPv4, because partial
+	 * sums only work when transhdrlen is set.
 	 */
-	if (!skb && sk->sk_protocol == IPPROTO_UDP &&
+	if (transhdrlen && sk->sk_protocol == IPPROTO_UDP &&
 	    length + fragheaderlen < mtu &&
 	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
 	    !exthdrlen)
-- 
1.9.3
