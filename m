From: Andy Zhou <azhou@nicira.com>
Subject: [net-next fragmenation icmp 2/2] bridge: do not send icmp on fragmentation or defragmentation error
Date: Tue,  5 May 2015 18:59:54 -0700
Message-ID: <1430877594-32054-3-git-send-email-azhou@nicira.com>
References: <1430877594-32054-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:54288 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752830AbbEFC2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 22:28:06 -0400
Received: by mail-pd0-f170.google.com with SMTP id a3so216342781pde.3
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 19:28:06 -0700 (PDT)
In-Reply-To: <1430877594-32054-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set IPSKB_NO_FRAG_ICMP bit when doing IP fragmentation and
defragmentation in bridging mode.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/bridge/br_netfilter.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index ab55e24..3f3366a 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -663,6 +663,10 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 	if (br_parse_ip_options(skb))
 		return NF_DROP;
 
+	/* In case this is a fragmented packet, do not send icmp packet on
+	 * defragmentation error  */
+	IPCB(skb)->flags |= IPSKB_NO_FRAG_ICMP;
+
 	nf_bridge_put(skb->nf_bridge);
 	if (!nf_bridge_alloc(skb))
 		return NF_DROP;
@@ -875,6 +879,9 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 		skb_copy_from_linear_data_offset(skb, -data->size, data->mac,
 						 data->size);
 
+		/* Do not send ICMP packet on fragmentation error */
+		IPCB(skb)->flags |= IPSKB_NO_FRAG_ICMP;
+
 		ret = ip_fragment(sk, skb, br_nf_push_frag_xmit);
 	} else {
 		ret = br_dev_queue_push_xmit(sk, skb);
-- 
1.9.1
