From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v10 2/5] openvswitch: set skb protocol and mac_len when receiving on internal device
Date: Thu,  2 Jun 2016 15:24:43 +0900
Message-ID: <1464848686-7656-3-git-send-email-simon.horman@netronome.com>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
Cc: dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34388 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbcFBGY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 02:24:59 -0400
Received: by mail-pf0-f181.google.com with SMTP id 62so27477595pfd.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 23:24:59 -0700 (PDT)
In-Reply-To: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Set skb protocol based on contents of packet. I have observed this is
  necessary to get actual protocol of a packet when it is injected into an
  internal device e.g. by libnet in which case skb protocol will be set to
  ETH_ALL.

* Set the mac_len which has been observed to not be set up correctly when
  an ARP packet is generated and sent via an openvswitch bridge.
  My test case is a scenario where there are two open vswtich bridges.
  One outputs to a tunnel port which egresses on the other.

The motivation for this is that support for outputting to layer 3 (non-tap)
GRE tunnels as implemented by a subsequent patch depends on protocol and
mac_len being set correctly on receive.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
v10
* Set mac_len

v9
* New patch
---
 net/openvswitch/vport-internal_dev.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 2ee48e447b72..f89b1efa88f1 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -48,6 +48,10 @@ static int internal_dev_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	int len, err;
 
+	skb->protocol = eth_type_trans(skb, netdev);
+	skb_push(skb, ETH_HLEN);
+	skb_reset_mac_len(skb);
+
 	len = skb->len;
 	rcu_read_lock();
 	err = ovs_vport_receive(internal_dev_priv(netdev)->vport, skb, NULL);
-- 
2.1.4
