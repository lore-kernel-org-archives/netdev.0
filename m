From: Andy Zhou <azhou@nicira.com>
Subject: [net-next] vxlan: Fix bug introduced by commit acbf74a76300
Date: Tue, 23 Sep 2014 01:44:51 -0700
Message-ID: <1411461891-4442-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:58028 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751533AbaIWIuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 04:50:32 -0400
Received: by mail-pd0-f176.google.com with SMTP id z10so4752048pdj.7
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 01:50:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit acbf74a76300 ("vxlan: Refactor vxlan driver to make use of the common UDP tunnel functions." introduced a bug in vxlan_xmit_one()
function, causing it to transmit Vxlan packets without proper
Vxlan header inserted. The change was not needed in the first
place. Revert it.

Reported-by: Tom Herbert <therbert@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 drivers/net/vxlan.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 39c8653..34e102e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1778,11 +1778,11 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 
-		err = udp_tunnel_xmit_skb(vxlan->vn_sock->sock, rt, skb,
-					  fl4.saddr, dst->sin.sin_addr.s_addr,
-					  tos, ttl, df, src_port, dst_port,
-					  !net_eq(vxlan->net,
-						  dev_net(vxlan->dev)));
+		err = vxlan_xmit_skb(vxlan->vn_sock, rt, skb,
+				     fl4.saddr, dst->sin.sin_addr.s_addr,
+				     tos, ttl, df, src_port, dst_port,
+				     htonl(vni << 8),
+				     !net_eq(vxlan->net, dev_net(vxlan->dev)));
 
 		if (err < 0)
 			goto rt_tx_error;
-- 
1.7.9.5
