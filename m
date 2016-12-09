From: Zheng Li <lizheng043@gmail.com>
Subject: [PATCH] ipv4: Should use consistent conditional judgement for ip fragment in __ip_append_data and ip_finish_output
Date: Fri,  9 Dec 2016 11:08:38 +0800
Message-ID: <1481252918-3514-1-git-send-email-lizheng043@gmail.com>
Cc: james.z.li@ericsson.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: zheng li <james.z.li@ericsson.com>

There is an inconsitent conditional judgement in __ip_append_data and
ip_finish_output functions, the variable length in __ip_append_data just
include the length of applicatoin's payload and udp header, don't include
the length of ip header, but in ip_finish_output use
(skb->len > ip_skb_dst_mtu(skb)) as judgement, and skb->len include the
length of ip header.

That cuase some particular applicatoin's udp payload whose length is
between (MTU - IP Header) and MTU were framented by ip_fragment even
though the rst->dev support UFO feature.

Add the length of ip header to length in __ip_append_data to keep
consistent conditional judgement as ip_finish_output for ip fragment.

Signed-off-by: Zheng Li <james.z.li@ericsson.com>
---
 net/ipv4/ip_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 877bdb0..12a0149 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -936,7 +936,7 @@ static int __ip_append_data(struct sock *sk,
 		csummode = CHECKSUM_PARTIAL;
 
 	cork->length += length;
-	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
+	if ((((length + fragheaderlen) > mtu) || (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
 	    (sk->sk_type == SOCK_DGRAM) && !sk->sk_no_check_tx) {
-- 
2.7.4
