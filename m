From: Zheng Li <lizheng043@gmail.com>
Subject: [PATCH] ipv6: Should use consistent conditional judgement for ip6 fragment between __ip6_append_data and ip6_finish_output
Date: Wed, 28 Dec 2016 23:23:46 +0800
Message-ID: <1482938626-20151-1-git-send-email-lizheng043@gmail.com>
Cc: james.z.li@ericsson.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35819 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbcL1PZU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 10:25:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zheng Li <james.z.li@ericsson.com>

There is an inconsistent conditional judgement between __ip6_append_data
and ip6_finish_output functions, the variable length in __ip6_append_data
just include the length of application's payload and udp6 header, don't
include the length of ipv6 header, but in ip6_finish_output use
(skb->len > ip6_skb_dst_mtu(skb)) as judgement, and skb->len include the
length of ipv6 header.

That causes some particular application's udp6 payloads whose length are
between (MTU - IPv6 Header) and MTU were fragmented by ip6_fragment even
though the rst->dev support UFO feature.

Add the length of ipv6 header to length in __ip6_append_data to keep
consistent conditional judgement as ip6_finish_output for ip6 fragment.

Signed-off-by: Zheng Li <james.z.li@ericsson.com>
---
 net/ipv6/ip6_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 70d0de40..38122d0 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1373,7 +1373,7 @@ static int __ip6_append_data(struct sock *sk,
 	 */
 
 	cork->length += length;
-	if (((length > mtu) ||
+	if ((((length + fragheaderlen) > mtu) ||
 	     (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
-- 
2.7.4
