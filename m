From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] ip: fix IP_CHECKSUM handling
Date: Mon, 20 Feb 2017 17:55:39 +0100
Message-ID: <ba355a67bf3e5b3155ee1ead02fa73046be7391f.1487609562.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41412 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754259AbdBTQ4x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 11:56:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skbs processed by ip_cmsg_recv() are not guaranteed to
be linear e.g. when sending UDP packets over loopback with
MSGMORE.
Using csum_partial() on [potentially] the whole skb len
is dangerous; instead be on the safe side and use skb_checksum().

Thanks to syzkaller team to detect the issue and provide the
reproducer.

Fixes: ad6f939ab193 ("ip: Add offset parameter to ip_cmsg_recv")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/ip_sockglue.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 9000117..d88bbe2 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -112,14 +112,15 @@ static void ip_cmsg_recv_checksum(struct msghdr *msg, struct sk_buff *skb,
 				  int tlen, int offset)
 {
 	__wsum csum = skb->csum;
+	int tend_off;
 
 	if (skb->ip_summed != CHECKSUM_COMPLETE)
 		return;
 
-	if (offset != 0)
-		csum = csum_sub(csum,
-				csum_partial(skb_transport_header(skb) + tlen,
-					     offset, 0));
+	if (offset != 0) {
+		tend_off = skb_transport_offset(skb) + tlen;
+		csum = csum_sub(csum, skb_checksum(skb, tend_off, offset, 0));
+	}
 
 	put_cmsg(msg, SOL_IP, IP_CHECKSUM, sizeof(__wsum), &csum);
 }
-- 
2.9.3
