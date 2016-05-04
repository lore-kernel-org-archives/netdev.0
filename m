From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v9 net-next 2/7] openvswitch: set skb protocol when receiving on internal device
Date: Wed,  4 May 2016 16:36:28 +0900
Message-ID: <1462347393-22354-3-git-send-email-simon.horman@netronome.com>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34185 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757240AbcEDHg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 03:36:56 -0400
Received: by mail-pa0-f50.google.com with SMTP id r5so21734055pag.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 00:36:56 -0700 (PDT)
In-Reply-To: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set skb protocol based on contents of packet. I have observed this is
necessary to get actual protocol of a packet when it is injected into an
internal device e.g. by libnet in which case skb protocol will be set to
ETH_ALL.

The motivation for this is that support for outputting to layer 3 (non-tap)
GRE tunnels as implemented by a subsequent patch depends on protocol being
set correctly in order to provide the protocol for the inner packet.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
v9
* New patch
---
 net/openvswitch/vport-internal_dev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 2ee48e447b72..4ce2ad8c3a5c 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -48,6 +48,8 @@ static int internal_dev_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	int len, err;
 
+	skb->protocol = eth_type_trans(skb, netdev);
+	skb_push(skb, ETH_HLEN);
 	len = skb->len;
 	rcu_read_lock();
 	err = ovs_vport_receive(internal_dev_priv(netdev)->vport, skb, NULL);
-- 
2.7.0.rc3.207.g0ac5344
