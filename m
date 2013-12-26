From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next v2] sctp: move skb_dst_set() a bit downwards in sctp_packet_transmit()
Date: Thu, 26 Dec 2013 13:55:56 +0800
Message-ID: <52BBC4EC.2070303@huawei.com>
References: <52BA8DA2.6030405@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:1441 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab3LZF4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 00:56:40 -0500
In-Reply-To: <52BA8DA2.6030405@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_dst_set will use dst, if dst is NULL although is not a problem,
then goto the 'no_route' and free nskb, so do the skb_dst_set is pointless.
so move the skb_dst_set after dst check.
Remove the unnecessary initialization as well.

v2: fix the subject line because it would confuse people,
    as pointed out by Daniel.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/output.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 3be70a4..9b76d62 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -387,7 +387,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	int err = 0;
 	int padding;		/* How much padding do we need?  */
 	__u8 has_data = 0;
-	struct dst_entry *dst = tp->dst;
+	struct dst_entry *dst;
 	unsigned char *auth = NULL;	/* pointer to auth in skb data */
 
 	pr_debug("%s: packet:%p\n", __func__, packet);
@@ -420,9 +420,9 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 		}
 	}
 	dst = dst_clone(tp->dst);
-	skb_dst_set(nskb, dst);
 	if (!dst)
 		goto no_route;
+	skb_dst_set(nskb, dst);
 
 	/* Build the SCTP header.  */
 	sh = (struct sctphdr *)skb_push(nskb, sizeof(struct sctphdr));
-- 
1.7.12
