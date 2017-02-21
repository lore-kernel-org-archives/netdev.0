From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net v2] ip: fix IP_CHECKSUM handling
Date: Tue, 21 Feb 2017 09:33:18 +0100
Message-ID: <3274d7c98d7d5ea07058d8b73f987fc60b6e8b6c.1487612303.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Tom Herbert <tom@herbertland.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36090 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750992AbdBUIdd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 03:33:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skbs processed by ip_cmsg_recv() are not guaranteed to
be linear e.g. when sending UDP packets over loopback with
MSGMORE.
Using csum_partial() on [potentially] the whole skb len
is dangerous; instead be on the safe side and use skb_checksum().

Thanks to syzkaller team to detect the issue and provide the
reproducer.

v1 -> v2:
 - move the variable declaration in a tighter scope

Fixes: ad6f939ab193 ("ip: Add offset parameter to ip_cmsg_recv")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/ip_sockglue.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 9000117..fc4bf4d 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -116,10 +116,10 @@ static void ip_cmsg_recv_checksum(struct msghdr *msg, struct sk_buff *skb,
 	if (skb->ip_summed != CHECKSUM_COMPLETE)
 		return;
 
-	if (offset != 0)
-		csum = csum_sub(csum,
-				csum_partial(skb_transport_header(skb) + tlen,
-					     offset, 0));
+	if (offset != 0) {
+		int tend_off = skb_transport_offset(skb) + tlen;
+		csum = csum_sub(csum, skb_checksum(skb, tend_off, offset, 0));
+	}
 
 	put_cmsg(msg, SOL_IP, IP_CHECKSUM, sizeof(__wsum), &csum);
 }
-- 
2.9.3
