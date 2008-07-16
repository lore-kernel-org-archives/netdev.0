From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 3/20] mib: add net to IP_INC_STATS
Date: Wed, 16 Jul 2008 12:10:59 +0400
Message-ID: <487DAD13.1070501@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:36847 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753706AbYGPIND (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:13:03 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the callers already have either the net itself, or the place
where to get it from.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/ip.h      |    2 +-
 net/ipv4/ip_forward.c |    2 +-
 net/ipv4/ip_output.c  |   30 +++++++++++++++---------------
 net/ipv4/raw.c        |    2 +-
 4 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 673ecdb..b9aaa32 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -157,7 +157,7 @@ struct ipv4_config
 
 extern struct ipv4_config ipv4_config;
 DECLARE_SNMP_STAT(struct ipstats_mib, ip_statistics);
-#define IP_INC_STATS(field)		SNMP_INC_STATS(ip_statistics, field)
+#define IP_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(ip_statistics, field); } while (0)
 #define IP_INC_STATS_BH(field)		SNMP_INC_STATS_BH(ip_statistics, field)
 #define IP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(ip_statistics, field, val)
 DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index da14725..7f78a5a 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -88,7 +88,7 @@ int ip_forward(struct sk_buff *skb)
 
 	if (unlikely(skb->len > dst_mtu(&rt->u.dst) && !skb_is_gso(skb) &&
 		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
-		IP_INC_STATS(IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS(dev_net(rt->u.dst.dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(dst_mtu(&rt->u.dst)));
 		goto drop;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index f003186..465544f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -182,9 +182,9 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	unsigned int hh_len = LL_RESERVED_SPACE(dev);
 
 	if (rt->rt_type == RTN_MULTICAST)
-		IP_INC_STATS(IPSTATS_MIB_OUTMCASTPKTS);
+		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTMCASTPKTS);
 	else if (rt->rt_type == RTN_BROADCAST)
-		IP_INC_STATS(IPSTATS_MIB_OUTBCASTPKTS);
+		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTBCASTPKTS);
 
 	/* Be paranoid, rather than too clever. */
 	if (unlikely(skb_headroom(skb) < hh_len && dev->header_ops)) {
@@ -244,7 +244,7 @@ int ip_mc_output(struct sk_buff *skb)
 	/*
 	 *	If the indicated interface is up and running, send the packet.
 	 */
-	IP_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
+	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTREQUESTS);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
@@ -298,7 +298,7 @@ int ip_output(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dst->dev;
 
-	IP_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
+	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTREQUESTS);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
@@ -389,7 +389,7 @@ packet_routed:
 	return ip_local_out(skb);
 
 no_route:
-	IP_INC_STATS(IPSTATS_MIB_OUTNOROUTES);
+	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
 	return -EHOSTUNREACH;
 }
@@ -451,7 +451,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 	iph = ip_hdr(skb);
 
 	if (unlikely((iph->frag_off & htons(IP_DF)) && !skb->local_df)) {
-		IP_INC_STATS(IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(ip_skb_dst_mtu(skb)));
 		kfree_skb(skb);
@@ -542,7 +542,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 			err = output(skb);
 
 			if (!err)
-				IP_INC_STATS(IPSTATS_MIB_FRAGCREATES);
+				IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
 			if (err || !frag)
 				break;
 
@@ -552,7 +552,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 		}
 
 		if (err == 0) {
-			IP_INC_STATS(IPSTATS_MIB_FRAGOKS);
+			IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
 			return 0;
 		}
 
@@ -561,7 +561,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 			kfree_skb(frag);
 			frag = skb;
 		}
-		IP_INC_STATS(IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 		return err;
 	}
 
@@ -673,15 +673,15 @@ slow_path:
 		if (err)
 			goto fail;
 
-		IP_INC_STATS(IPSTATS_MIB_FRAGCREATES);
+		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
 	}
 	kfree_skb(skb);
-	IP_INC_STATS(IPSTATS_MIB_FRAGOKS);
+	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
 	return err;
 
 fail:
 	kfree_skb(skb);
-	IP_INC_STATS(IPSTATS_MIB_FRAGFAILS);
+	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 	return err;
 }
 
@@ -1047,7 +1047,7 @@ alloc_new_skb:
 
 error:
 	inet->cork.length -= length;
-	IP_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
 
@@ -1189,7 +1189,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 
 error:
 	inet->cork.length -= size;
-	IP_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
 
@@ -1298,7 +1298,7 @@ out:
 	return err;
 
 error:
-	IP_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
 	goto out;
 }
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 7f39ea4..cd97574 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -385,7 +385,7 @@ error_fault:
 	err = -EFAULT;
 	kfree_skb(skb);
 error:
-	IP_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
 
-- 
1.5.5.1

