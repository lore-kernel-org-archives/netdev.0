From: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
Subject: [PATCH] net: VRF: Pass original iif to ip_route_input()
Date: Mon, 12 Sep 2016 13:45:53 +1200
Message-ID: <20160912014553.20927-1-mark.tomlinson@alliedtelesis.co.nz>
Cc: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:52415 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755365AbcILBqc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 21:46:32 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 8BD2180666
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 13:46:28 +1200 (NZST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function ip_rcv_finish() calls l3mdev_ip_rcv(). On any VRF except
the global VRF, this replaces skb->dev with the VRF master interface.
When calling ip_route_input_noref() from here, the checks for forwarding
look at this master device instead of the initial ingress interface.
This will allow packets to be routed which normally would be dropped.
For example, an interface that is not assigned an IP address should
drop packets, but because the checking is against the master device, the
packet will be forwarded.

The fix here is to still call l3mdev_ip_rcv(), but remember the initial
net_device. This is passed to the other functions within ip_rcv_finish,
so they still see the original interface.

Please note that while this patch fixes my issue, I am not entirely sure
why the skb->dev is changed to the master device, so I am not sure this
is the right fix.

Signed-off-by: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
---
 net/ipv4/ip_input.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 4b351af..d6feabb 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -312,6 +312,7 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
+	struct net_device *dev = skb->dev;
 
 	/* if ingress device is enslaved to an L3 master device pass the
 	 * skb to its handler for processing
@@ -341,7 +342,7 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 	 */
 	if (!skb_valid_dst(skb)) {
 		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
-					       iph->tos, skb->dev);
+					       iph->tos, dev);
 		if (unlikely(err)) {
 			if (err == -EXDEV)
 				__NET_INC_STATS(net, LINUX_MIB_IPRPFILTER);
@@ -370,7 +371,7 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 		__IP_UPD_PO_STATS(net, IPSTATS_MIB_INBCAST, skb->len);
 	} else if (skb->pkt_type == PACKET_BROADCAST ||
 		   skb->pkt_type == PACKET_MULTICAST) {
-		struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
+		struct in_device *in_dev = __in_dev_get_rcu(dev);
 
 		/* RFC 1122 3.3.6:
 		 *
-- 
2.9.3
