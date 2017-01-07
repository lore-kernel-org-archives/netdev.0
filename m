From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: reduce cycles spend on ICMP replies that
 gets rate limited
Date: Fri, 06 Jan 2017 22:10:42 -0500 (EST)
Message-ID: <20170106.221042.1641025960219244932.davem@davemloft.net>
References: <20170106173907.32104.52294.stgit@firesoul>
        <1483731621.9712.31.camel@edumazet-glaptop3.roam.corp.google.com>
        <1483740486.9712.41.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754841AbdAGDKo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 22:10:44 -0500
In-Reply-To: <1483740486.9712.41.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Jan 2017 14:08:06 -0800

> On Fri, 2017-01-06 at 11:40 -0800, Eric Dumazet wrote:
>> On Fri, 2017-01-06 at 18:39 +0100, Jesper Dangaard Brouer wrote:
>> 
>> 
>> > @@ -648,13 +668,17 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>> >  		}
>> >  	}
>> >  
>> > -	icmp_param = kmalloc(sizeof(*icmp_param), GFP_ATOMIC);
>> > -	if (!icmp_param)
>> > -		return;
>> > -
>> >  	sk = icmp_xmit_lock(net);
>> >  	if (!sk)
>> > -		goto out_free;
>> > +		goto out;
>> > +
>> > +	/* Check global sysctl_icmp_msgs_per_sec ratelimit */
>> > +	if (!icmpv4_global_allow(net, type, code))
>> > +		goto out_unlock;
>> > +
>> > +	icmp_param = kmalloc(sizeof(*icmp_param), GFP_ATOMIC);
>> > +	if (!icmp_param)
>> > +		goto out_unlock;
>> 
> 
> You could call icmp_xmit_lock() _after_ checking global limit perhaps. 

BTW Eric, you asked about kmalloc() allocation, you were CC:'d in the
patch which did this :-)

commit 9a99d4a50cb8ce516adf0f2436138d4c8e6e4535
Author: Cong Wang <amwang@redhat.com>
Date:   Sun Jun 2 15:00:52 2013 +0000

    icmp: avoid allocating large struct on stack
    
    struct icmp_bxm is a large struct, reduce stack usage
    by allocating it on heap.
    
    Cc: Eric Dumazet <eric.dumazet@gmail.com>
    Cc: Joe Perches <joe@perches.com>
    Cc: David S. Miller <davem@davemloft.net>
    Signed-off-by: Cong Wang <amwang@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 2864ca3..5f7d11a 100644
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
@@ -558,9 +558,13 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		}
 	}
 
+	icmp_param = kmalloc(sizeof(*icmp_param), GFP_ATOMIC);
+	if (!icmp_param)
+		return;
+
 	sk = icmp_xmit_lock(net);
 	if (sk == NULL)
-		return;
+		goto out_free;
 
 	/*
 	 *	Construct source address and options.
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
 
@@ -618,19 +622,21 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
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
+out_free:
+	kfree(icmp_param);
 out:;
 }
 EXPORT_SYMBOL(icmp_send);
