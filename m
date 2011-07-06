From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] AF_PACKET fanout support
Date: Tue, 05 Jul 2011 23:55:37 -0700 (PDT)
Message-ID: <20110705.235537.2209662830319369211.davem@davemloft.net>
References: <20110705.201950.199250194399828543.davem@davemloft.net>
	<1309925266.2545.48.camel@edumazet-laptop>
	<20110705.234424.2099388019260070145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, victor@inliniac.net, netdev@vger.kernel.org,
	willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45334 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197Ab1GFGzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 02:55:46 -0400
In-Reply-To: <20110705.234424.2099388019260070145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 05 Jul 2011 23:44:24 -0700 (PDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 06 Jul 2011 06:07:46 +0200
> 
>> I suspect this can be solved adding a third policy : hash by CPU only
> 
> Agreed, I'll implement this policy.

packet: Add 'cpu' fanout policy.

Unfortunately we have to use a real modulus here as
the multiply trick won't work as effectively with cpu
numbers as it does with rxhash values.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 84e684e..c148606 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -53,6 +53,7 @@ struct sockaddr_ll {
 
 #define PACKET_FANOUT_HASH		0
 #define PACKET_FANOUT_LB		1
+#define PACKET_FANOUT_CPU		2
 #define PACKET_FANOUT_FLAG_DEFRAG	0x8000
 
 struct tpacket_stats {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 7ba6871..41f0489 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -447,6 +447,13 @@ static struct sock *fanout_demux_lb(struct packet_fanout *f, struct sk_buff *skb
 	return f->arr[cur];
 }
 
+static struct sock *fanout_demux_cpu(struct packet_fanout *f, struct sk_buff *skb, unsigned int num)
+{
+	unsigned int cpu = smp_processor_id();
+
+	return f->arr[cpu % num];
+}
+
 static struct sk_buff *fanout_check_defrag(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
@@ -482,8 +489,8 @@ static struct sk_buff *fanout_check_defrag(struct sk_buff *skb)
 	return skb;
 }
 
-static int packet_rcv_fanout_hash(struct sk_buff *skb, struct net_device *dev,
-				  struct packet_type *pt, struct net_device *orig_dev)
+static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
+			     struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct packet_fanout *f = pt->af_packet_priv;
 	unsigned int num = f->num_members;
@@ -496,35 +503,25 @@ static int packet_rcv_fanout_hash(struct sk_buff *skb, struct net_device *dev,
 		return 0;
 	}
 
-	if (f->defrag) {
-		skb = fanout_check_defrag(skb);
-		if (!skb)
-			return 0;
-	}
-
-	skb_get_rxhash(skb);
-
-	sk = fanout_demux_hash(f, skb, num);
-	po = pkt_sk(sk);
-
-	return po->prot_hook.func(skb, dev, &po->prot_hook, orig_dev);
-}
-
-static int packet_rcv_fanout_lb(struct sk_buff *skb, struct net_device *dev,
-				struct packet_type *pt, struct net_device *orig_dev)
-{
-	struct packet_fanout *f = pt->af_packet_priv;
-	unsigned int num = f->num_members;
-	struct packet_sock *po;
-	struct sock *sk;
-
-	if (!net_eq(dev_net(dev), read_pnet(&f->net)) ||
-	    !num) {
-		kfree_skb(skb);
-		return 0;
+	switch (f->type) {
+	case PACKET_FANOUT_HASH:
+	default:
+		if (f->defrag) {
+			skb = fanout_check_defrag(skb);
+			if (!skb)
+				return 0;
+		}
+		skb_get_rxhash(skb);
+		sk = fanout_demux_hash(f, skb, num);
+		break;
+	case PACKET_FANOUT_LB:
+		sk = fanout_demux_lb(f, skb, num);
+		break;
+	case PACKET_FANOUT_CPU:
+		sk = fanout_demux_cpu(f, skb, num);
+		break;
 	}
 
-	sk = fanout_demux_lb(f, skb, num);
 	po = pkt_sk(sk);
 
 	return po->prot_hook.func(skb, dev, &po->prot_hook, orig_dev);
@@ -571,6 +568,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	switch (type) {
 	case PACKET_FANOUT_HASH:
 	case PACKET_FANOUT_LB:
+	case PACKET_FANOUT_CPU:
 		break;
 	default:
 		return -EINVAL;
@@ -606,14 +604,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 			atomic_set(&match->sk_ref, 0);
 			match->prot_hook.type = po->prot_hook.type;
 			match->prot_hook.dev = po->prot_hook.dev;
-			switch (type) {
-			case PACKET_FANOUT_HASH:
-				match->prot_hook.func = packet_rcv_fanout_hash;
-				break;
-			case PACKET_FANOUT_LB:
-				match->prot_hook.func = packet_rcv_fanout_lb;
-				break;
-			}
+			match->prot_hook.func = packet_rcv_fanout;
 			match->prot_hook.af_packet_priv = match;
 			dev_add_pack(&match->prot_hook);
 			list_add(&match->list, &fanout_list);
