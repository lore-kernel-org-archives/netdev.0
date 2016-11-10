From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v13 8/8] openvswitch: allow L3 netdev ports
Date: Thu, 10 Nov 2016 16:28:24 +0100
Message-ID: <6468b56f1dd973ab4c8f141ad09ab94e1fac791f.1478791347.git.jbenc@redhat.com>
References: <cover.1478791347.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@ovn.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5098 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934184AbcKJP2x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 10:28:53 -0500
In-Reply-To: <cover.1478791347.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow ARPHRD_NONE interfaces to be added to ovs bridge.

Based on previous versions by Lorand Jakab and Simon Horman.

Signed-off-by: Lorand Jakab <lojakab@cisco.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
---
 net/openvswitch/vport-netdev.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index e825753de1e0..0389398fa4ab 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -57,8 +57,10 @@ static void netdev_port_receive(struct sk_buff *skb)
 	if (unlikely(!skb))
 		return;
 
-	skb_push(skb, ETH_HLEN);
-	skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
+	if (skb->dev->type == ARPHRD_ETHER) {
+		skb_push(skb, ETH_HLEN);
+		skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
+	}
 	ovs_vport_receive(vport, skb, skb_tunnel_info(skb));
 	return;
 error:
@@ -97,7 +99,8 @@ struct vport *ovs_netdev_link(struct vport *vport, const char *name)
 	}
 
 	if (vport->dev->flags & IFF_LOOPBACK ||
-	    vport->dev->type != ARPHRD_ETHER ||
+	    (vport->dev->type != ARPHRD_ETHER &&
+	     vport->dev->type != ARPHRD_NONE) ||
 	    ovs_is_internal_dev(vport->dev)) {
 		err = -EINVAL;
 		goto error_put;
-- 
1.8.3.1
