From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 2/2] ipv6: udp: leverage scratch area helpers
Date: Mon, 26 Jun 2017 19:01:51 +0200
Message-ID: <25b5acf02803369bf68b1947c0bbcd3f337f4edd.1498493975.git.pabeni@redhat.com>
References: <cover.1498493975.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41708 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751406AbdFZRCz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 13:02:55 -0400
In-Reply-To: <cover.1498493975.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit b65ac44674dd ("udp: try to avoid 2 cache miss on dequeue")
leveraged the scratched area helpers for UDP v4 but I forgot to
update accordingly the IPv6 code path.

This change extends the scratch area usage to the IPv6 code, synching
the two implementations and giving some performance benefit.
IPv6 is again almost on the same level of IPv4, performance-wide.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/udp.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d1d7288..450829d 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -362,7 +362,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	if (!skb)
 		return err;
 
-	ulen = skb->len;
+	ulen = udp_skb_len(skb);
 	copied = len;
 	if (copied > ulen - off)
 		copied = ulen - off;
@@ -379,14 +379,18 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 
 	if (copied < ulen || peeking ||
 	    (is_udplite && UDP_SKB_CB(skb)->partial_cov)) {
-		checksum_valid = !udp_lib_checksum_complete(skb);
+		checksum_valid = udp_skb_csum_unnecessary(skb) ||
+				!__udp_lib_checksum_complete(skb);
 		if (!checksum_valid)
 			goto csum_copy_err;
 	}
 
-	if (checksum_valid || skb_csum_unnecessary(skb))
-		err = skb_copy_datagram_msg(skb, off, msg, copied);
-	else {
+	if (checksum_valid || udp_skb_csum_unnecessary(skb)) {
+		if (udp_skb_is_linear(skb))
+			err = copy_linear_skb(skb, copied, off, &msg->msg_iter);
+		else
+			err = skb_copy_datagram_msg(skb, off, msg, copied);
+	} else {
 		err = skb_copy_and_csum_datagram_msg(skb, off, msg);
 		if (err == -EINVAL)
 			goto csum_copy_err;
-- 
2.9.4
