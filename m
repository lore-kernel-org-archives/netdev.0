From: Lauri Tarkkala <ltarkkala@safenet-inc.com>
Subject: [PATCH] ip multicast, kernel 2.4.2*, 2.6.*
Date: Wed, 14 Apr 2004 07:17:31 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040414041731.GA2010@safenet-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


There is an obnoxious problem in the sending of both ipv4 and ipv6
multicast/broadcast packets in both the 2.4 and 2.6 series and
netfilter modules.

The processing is roughly as follows:
1. If packet is multicast/broadcast, duplicate it.
2. Pass the duplicate packet through netfilter hooks using
   NF_HOOK_SLOW(IP_POST_ROUTING).
3. Set skb.type to PACKET_LOOPBACK in the netfilter hook callback
   and pass the packet to netif_rx().
4. Send the original packet out via NF_HOOK(IP_POST_ROUTING).

The reason for this processing (my guess), is that the inbound
(duplicate) packet will not be sent, unless the original
passes the netfilter hooks. This has the side-effect that netfilter
hooks have no way of detecting whether packets are intended to or are
going to be looped back. The looped-back packet will of course still go
through the inbound hooks.

This is quite error-prone, both in terms of configuring policy for
netfilter modules, not to mention optimization and implementation. There
are also some cases that just can not be handled correctly.

My first choice would be to simply change the behaviour so that
the duplicate packet is not bassed through the IP_POST_ROUTING hook.
Below is a patch that does exactly this.. The patch works against 
recent 2.4.x and 2.6.x series kernels.

I can not think of a (good) reason for the current behaviour. If someone
with more history knowledge could enlighten me, I'd be grateful.

Lauri

-- 
Lauri Tarkkala
Safenet Inc. 
http://www.safenet-inc.com/


diff -aur -p linux-2.4.25/net/ipv4/ip_output.c linux-2.4.25-fixed/net/ipv4/ip_output.c
--- linux-2.4.25/net/ipv4/ip_output.c	2004-04-14 06:00:52.000000000 +0300
+++ linux-2.4.25-fixed/net/ipv4/ip_output.c	2004-04-14 06:01:04.000000000 +0300
@@ -233,9 +233,7 @@ int ip_mc_output(struct sk_buff *skb)
 		) {
 			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 			if (newskb)
-				NF_HOOK(PF_INET, NF_IP_POST_ROUTING, newskb, NULL,
-					newskb->dev, 
-					ip_dev_loopback_xmit);
+			        ip_dev_loopback_xmit(newskb);
 		}
 
 		/* Multicasts with ttl 0 must not go beyond the host */
@@ -249,8 +247,7 @@ int ip_mc_output(struct sk_buff *skb)
 	if (rt->rt_flags&RTCF_BROADCAST) {
 		struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 		if (newskb)
-			NF_HOOK(PF_INET, NF_IP_POST_ROUTING, newskb, NULL,
-				newskb->dev, ip_dev_loopback_xmit);
+		        ip_dev_loopback_xmit(newskb);
 	}
 
 	return ip_finish_output(skb);
diff -aur -p linux-2.4.25/net/ipv6/ip6_output.c linux-2.4.25-fixed/net/ipv6/ip6_output.c
--- linux-2.4.25/net/ipv6/ip6_output.c	2004-04-14 06:00:52.000000000 +0300
+++ linux-2.4.25-fixed/net/ipv6/ip6_output.c	2004-04-14 05:44:40.000000000 +0300
@@ -118,9 +118,7 @@ int ip6_output(struct sk_buff *skb)
 			   is not supported in any case.
 			 */
 			if (newskb)
-				NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, newskb, NULL,
-					newskb->dev,
-					ip6_dev_loopback_xmit);
+			        ip6_dev_loopback_xmit(newskb);
 
 			if (skb->nh.ipv6h->hop_limit == 0) {
 				kfree_skb(skb);
