From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] icmp: avoid allocating large struct on stack
Date: Sat,  1 Jun 2013 11:24:13 +0800
Message-ID: <1370057053-20519-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47332 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753129Ab3FADYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 23:24:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

struct icmp_bxm is a large struct, reduce stack usage
by allocating it on heap.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 net/ipv4/icmp.c |   37 +++++++++++++++++++++----------------
 1 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5d0d379..8157684 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -482,7 +482,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 {
 	struct iphdr *iph;
 	int room;
-	struct icmp_bxm icmp_param;
+	struct icmp_bxm *icmp_param;
 	struct rtable *rt = skb_rtable(skb_in);
 	struct ipcm_cookie ipc;
 	struct flowi4 fl4;
@@ -558,6 +558,10 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		}
 	}
 
+	icmp_param = kzalloc(sizeof(*icmp_param), GFP_ATOMIC);
+	if (!icmp_param)
+		return;
+
 	sk = icmp_xmit_lock(net);
 	if (sk == NULL)
 		return;
@@ -586,7 +590,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 					   IPTOS_PREC_INTERNETCONTROL) :
 					  iph->tos;
 
-	if (ip_options_echo(&icmp_param.replyopts.opt.opt, skb_in))
+	if (ip_options_echo(&icmp_param->replyopts.opt.opt, skb_in))
 		goto out_unlock;
 
 
@@ -594,19 +598,19 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	 *	Prepare data for ICMP header.
 	 */
 
-	icmp_param.data.icmph.type	 = type;
-	icmp_param.data.icmph.code	 = code;
-	icmp_param.data.icmph.un.gateway = info;
-	icmp_param.data.icmph.checksum	 = 0;
-	icmp_param.skb	  = skb_in;
-	icmp_param.offset = skb_network_offset(skb_in);
+	icmp_param->data.icmph.type	 = type;
+	icmp_param->data.icmph.code	 = code;
+	icmp_param->data.icmph.un.gateway = info;
+	icmp_param->data.icmph.checksum	 = 0;
+	icmp_param->skb	  = skb_in;
+	icmp_param->offset = skb_network_offset(skb_in);
 	inet_sk(sk)->tos = tos;
 	ipc.addr = iph->saddr;
-	ipc.opt = &icmp_param.replyopts.opt;
+	ipc.opt = &icmp_param->replyopts.opt;
 	ipc.tx_flags = 0;
 
 	rt = icmp_route_lookup(net, &fl4, skb_in, iph, saddr, tos,
-			       type, code, &icmp_param);
+			       type, code, icmp_param);
 	if (IS_ERR(rt))
 		goto out_unlock;
 
@@ -618,19 +622,20 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	room = dst_mtu(&rt->dst);
 	if (room > 576)
 		room = 576;
-	room -= sizeof(struct iphdr) + icmp_param.replyopts.opt.opt.optlen;
+	room -= sizeof(struct iphdr) + icmp_param->replyopts.opt.opt.optlen;
 	room -= sizeof(struct icmphdr);
 
-	icmp_param.data_len = skb_in->len - icmp_param.offset;
-	if (icmp_param.data_len > room)
-		icmp_param.data_len = room;
-	icmp_param.head_len = sizeof(struct icmphdr);
+	icmp_param->data_len = skb_in->len - icmp_param->offset;
+	if (icmp_param->data_len > room)
+		icmp_param->data_len = room;
+	icmp_param->head_len = sizeof(struct icmphdr);
 
-	icmp_push_reply(&icmp_param, &fl4, &ipc, &rt);
+	icmp_push_reply(icmp_param, &fl4, &ipc, &rt);
 ende:
 	ip_rt_put(rt);
 out_unlock:
 	icmp_xmit_unlock(sk);
+	kfree(icmp_param);
 out:;
 }
 EXPORT_SYMBOL(icmp_send);
