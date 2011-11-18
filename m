From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/6] packet: Add needed_tailroom to packet_sendmsg_spkt
Date: Fri, 18 Nov 2011 20:20:05 +0800
Message-ID: <E1RRNQL-0000lf-Jy@gondolin.me.apana.org.au>
References: <20111118121832.GA2868@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	evonlanthen@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, timo.teras@iki.fi
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

packet: Add needed_tailroom to packet_sendmsg_spkt

While auditing LL_ALLOCATED_SPACE I noticed that packet_sendmsg_spkt
did not include needed_tailroom when allocating an skb.  This isn't
a fatal error as we should always tolerate inadequate tail room but
it isn't optimal.

This patch fixes that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/packet/af_packet.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 71c1a75..0da505c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1499,10 +1499,11 @@ retry:
 
 	if (!skb) {
 		size_t reserved = LL_RESERVED_SPACE(dev);
+		int tlen = dev->needed_tailroom;
 		unsigned int hhlen = dev->header_ops ? dev->hard_header_len : 0;
 
 		rcu_read_unlock();
-		skb = sock_wmalloc(sk, len + reserved, 0, GFP_KERNEL);
+		skb = sock_wmalloc(sk, len + reserved + tlen, 0, GFP_KERNEL);
 		if (skb == NULL)
 			return -ENOBUFS;
 		/* FIXME: Save some space for broken drivers that write a hard
