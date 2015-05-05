From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] vxlan: Correctly set flow*i_mark and flow4i_proto in route lookups
Date: Tue,  5 May 2015 15:09:21 +0200
Message-ID: <0a768060aa39d1dfbad87ebc8bcbfd0e4a04c1a7.1430831084.git.tgraf@suug.ch>
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40779 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423323AbbEENJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 09:09:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VXLAN must provide the skb mark and specifiy IPPROTO_UDP when doing
the FIB lookup for the remote ip. Otherwise an invalid route might
be returned.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/vxlan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 27a5f95..3517ab0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1921,6 +1921,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		memset(&fl4, 0, sizeof(fl4));
 		fl4.flowi4_oif = rdst->remote_ifindex;
 		fl4.flowi4_tos = RT_TOS(tos);
+		fl4.flowi4_mark = skb->mark;
+		fl4.flowi4_proto = IPPROTO_UDP;
 		fl4.daddr = dst->sin.sin_addr.s_addr;
 		fl4.saddr = vxlan->saddr.sin.sin_addr.s_addr;
 
@@ -1981,6 +1983,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		fl6.flowi6_oif = rdst->remote_ifindex;
 		fl6.daddr = dst->sin6.sin6_addr;
 		fl6.saddr = vxlan->saddr.sin6.sin6_addr;
+		fl6.flowi6_mark = skb->mark;
 		fl6.flowi6_proto = IPPROTO_UDP;
 
 		if (ipv6_stub->ipv6_dst_lookup(sk, &ndst, &fl6)) {
-- 
2.3.5
