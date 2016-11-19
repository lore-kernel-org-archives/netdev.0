From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] udp: avoid one cache line miss in recvmsg()
Date: Fri, 18 Nov 2016 17:18:03 -0800
Message-ID: <1479518283.8455.312.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35544 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753085AbcKSBSG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 20:18:06 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so22050681pga.2
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 17:18:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

UDP_SKB_CB(skb)->partial_cov is located at offset 66 in skb,
requesting a cold cache line being read in cpu cache.

We can avoid this cache line miss for UDP sockets,
as partial_cov has a meaning only for UDPLite.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/udp.c |    3 ++-
 net/ipv6/udp.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e1fc0116e8d59d8185670c6e55d1219bde55610d..b949770fdc08398a10f3974505a50b2b4f4b2cf3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1389,7 +1389,8 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	 * coverage checksum (UDP-Lite), do it before the copy.
 	 */
 
-	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov || peeking) {
+	if (copied < ulen || peeking ||
+	    (is_udplite && UDP_SKB_CB(skb)->partial_cov)) {
 		checksum_valid = !udp_lib_checksum_complete(skb);
 		if (!checksum_valid)
 			goto csum_copy_err;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4f99417d9b401f2a65c7828e7d6b86d1d6161794..8fd4d89380b86c8630f7fd27ce4e9958497a2b89 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -363,7 +363,8 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	 * coverage checksum (UDP-Lite), do it before the copy.
 	 */
 
-	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov || peeking) {
+	if (copied < ulen || peeking ||
+	    (is_udplite && UDP_SKB_CB(skb)->partial_cov)) {
 		checksum_valid = !udp_lib_checksum_complete(skb);
 		if (!checksum_valid)
 			goto csum_copy_err;
