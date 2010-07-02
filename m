From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: postpone the checksum calculation
Date: Fri,  2 Jul 2010 14:02:57 +0800
Message-ID: <1278050577-3358-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netfilter: postpone the checksum calculation.

postpone the checksum calculation, then if the output NIC supports checksum
offloading, we can utlize it. And though the output NIC doesn't support
checksum offloading, but we'll mangle this packet, this can free us from
updating the checksum, as the checksum calculation occurs later.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ipv4/netfilter/ipt_REJECT.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index f5f4a88..3d0e064 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -95,10 +95,11 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	}
 
 	tcph->rst	= 1;
-	tcph->check	= tcp_v4_check(sizeof(struct tcphdr),
-				       niph->saddr, niph->daddr,
-				       csum_partial(tcph,
-						    sizeof(struct tcphdr), 0));
+	tcph->check = ~tcp_v4_check(sizeof(struct tcphdr), niph->saddr,
+				    niph->daddr, 0);
+	nskb->ip_summed = CHECKSUM_PARTIAL;
+	nskb->csum_start = (unsigned char *)tcph - nskb->head;
+	nskb->csum_offset = offsetof(struct tcphdr, check);
 
 	addr_type = RTN_UNSPEC;
 	if (hook != NF_INET_FORWARD
@@ -115,7 +116,6 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 		goto free_nskb;
 
 	niph->ttl	= dst_metric(skb_dst(nskb), RTAX_HOPLIMIT);
-	nskb->ip_summed = CHECKSUM_NONE;
 
 	/* "Never happens" */
 	if (nskb->len > dst_mtu(skb_dst(nskb)))
