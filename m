From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/3] Revert "icmp: avoid allocating large struct on
 stack"
Date: Mon, 09 Jan 2017 16:04:04 +0100
Message-ID: <20170109150404.30215.44512.stgit@firesoul>
References: <20170109150246.30215.63371.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56484 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968730AbdAIPEG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 10:04:06 -0500
In-Reply-To: <20170109150246.30215.63371.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 9a99d4a50cb8 ("icmp: avoid allocating large struct
on stack"), because struct icmp_bxm no really a large struct, and
allocating and free of this small 112 bytes hurts performance.

Fixes: 9a99d4a50cb8 ("icmp: avoid allocating large struct on stack")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/ipv4/icmp.c |   40 +++++++++++++++++-----------------------
 1 file changed, 17 insertions(+), 23 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 0777ea949223..b4b9807329a7 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -571,7 +571,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 {
 	struct iphdr *iph;
 	int room;
-	struct icmp_bxm *icmp_param;
+	struct icmp_bxm icmp_param;
 	struct rtable *rt = skb_rtable(skb_in);
 	struct ipcm_cookie ipc;
 	struct flowi4 fl4;
@@ -648,13 +648,9 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		}
 	}
 
-	icmp_param = kmalloc(sizeof(*icmp_param), GFP_ATOMIC);
-	if (!icmp_param)
-		return;
-
 	sk = icmp_xmit_lock(net);
 	if (!sk)
-		goto out_free;
+		return;
 
 	/*
 	 *	Construct source address and options.
@@ -681,7 +677,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 					  iph->tos;
 	mark = IP4_REPLY_MARK(net, skb_in->mark);
 
-	if (ip_options_echo(&icmp_param->replyopts.opt.opt, skb_in))
+	if (ip_options_echo(&icmp_param.replyopts.opt.opt, skb_in))
 		goto out_unlock;
 
 
@@ -689,22 +685,22 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	 *	Prepare data for ICMP header.
 	 */
 
-	icmp_param->data.icmph.type	 = type;
-	icmp_param->data.icmph.code	 = code;
-	icmp_param->data.icmph.un.gateway = info;
-	icmp_param->data.icmph.checksum	 = 0;
-	icmp_param->skb	  = skb_in;
-	icmp_param->offset = skb_network_offset(skb_in);
+	icmp_param.data.icmph.type	 = type;
+	icmp_param.data.icmph.code	 = code;
+	icmp_param.data.icmph.un.gateway = info;
+	icmp_param.data.icmph.checksum	 = 0;
+	icmp_param.skb	  = skb_in;
+	icmp_param.offset = skb_network_offset(skb_in);
 	inet_sk(sk)->tos = tos;
 	sk->sk_mark = mark;
 	ipc.addr = iph->saddr;
-	ipc.opt = &icmp_param->replyopts.opt;
+	ipc.opt = &icmp_param.replyopts.opt;
 	ipc.tx_flags = 0;
 	ipc.ttl = 0;
 	ipc.tos = -1;
 
 	rt = icmp_route_lookup(net, &fl4, skb_in, iph, saddr, tos, mark,
-			       type, code, icmp_param);
+			       type, code, &icmp_param);
 	if (IS_ERR(rt))
 		goto out_unlock;
 
@@ -716,21 +712,19 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	room = dst_mtu(&rt->dst);
 	if (room > 576)
 		room = 576;
-	room -= sizeof(struct iphdr) + icmp_param->replyopts.opt.opt.optlen;
+	room -= sizeof(struct iphdr) + icmp_param.replyopts.opt.opt.optlen;
 	room -= sizeof(struct icmphdr);
 
-	icmp_param->data_len = skb_in->len - icmp_param->offset;
-	if (icmp_param->data_len > room)
-		icmp_param->data_len = room;
-	icmp_param->head_len = sizeof(struct icmphdr);
+	icmp_param.data_len = skb_in->len - icmp_param.offset;
+	if (icmp_param.data_len > room)
+		icmp_param.data_len = room;
+	icmp_param.head_len = sizeof(struct icmphdr);
 
-	icmp_push_reply(icmp_param, &fl4, &ipc, &rt);
+	icmp_push_reply(&icmp_param, &fl4, &ipc, &rt);
 ende:
 	ip_rt_put(rt);
 out_unlock:
 	icmp_xmit_unlock(sk);
-out_free:
-	kfree(icmp_param);
 out:;
 }
 EXPORT_SYMBOL(icmp_send);
