From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] vxlan: fix oops in dev_fill_metadata_dst
Date: Fri, 17 Feb 2017 19:14:27 +0100
Message-ID: <8682ee54bd3198c8ce7be1249c829741987c7b11.1487354433.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38352 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934536AbdBQSWv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 13:22:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the commit 0c1d70af924b ("net: use dst_cache for vxlan device")
vxlan_fill_metadata_dst() calls vxlan_get_route() passing a NULL
dst_cache pointer, so the latter should explicitly check for
valid dst_cache ptr. Unfortunately the commit d71785ffc7e7 ("net: add
dst_cache to ovs vxlan lwtunnel") removed said check.

As a result is possible to trigger a null pointer access calling
vxlan_fill_metadata_dst(), e.g. with:

ovs-vsctl add-br ovs-br0
ovs-vsctl add-port ovs-br0 vxlan0 -- set interface vxlan0 \
	type=vxlan options:remote_ip=192.168.1.1 \
	options:key=1234 options:dst_port=4789 ofport_request=10
ip address add dev ovs-br0 172.16.1.2/24
ovs-vsctl set Bridge ovs-br0 ipfix=@i -- --id=@i create IPFIX \
	targets=\"172.16.1.1:1234\" sampling=1
iperf -c 172.16.1.1 -u -l 1000 -b 10M -t 1 -p 1234

This commit addresses the issue passing to vxlan_get_route() the
dst_cache already available into the lwt info processed by
vxlan_fill_metadata_dst().

Fixes: d71785ffc7e7 ("net: add dst_cache to ovs vxlan lwtunnel")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 drivers/net/vxlan.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 50b62db..30b04cf 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2439,7 +2439,8 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 
 		rt = vxlan_get_route(vxlan, dev, sock4, skb, 0, info->key.tos,
 				     info->key.u.ipv4.dst,
-				     &info->key.u.ipv4.src, dport, sport, NULL, info);
+				     &info->key.u.ipv4.src, dport, sport,
+				     &info->dst_cache, info);
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
 		ip_rt_put(rt);
@@ -2450,7 +2451,8 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 
 		ndst = vxlan6_get_route(vxlan, dev, sock6, skb, 0, info->key.tos,
 					info->key.label, &info->key.u.ipv6.dst,
-					&info->key.u.ipv6.src, dport, sport, NULL, info);
+					&info->key.u.ipv6.src, dport, sport,
+					&info->dst_cache, info);
 		if (IS_ERR(ndst))
 			return PTR_ERR(ndst);
 		dst_release(ndst);
-- 
2.9.3
