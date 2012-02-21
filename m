From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] macvlan: Disable LRO on lowerdev; warn if it's turned
 back on
Date: Tue, 21 Feb 2012 19:13:42 +0000
Message-ID: <1329851622.2689.6.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Shradha Shah <sshah@solarflare.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27524 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754074Ab2BUTNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 14:13:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Large Receive Offload (LRO) is only appropriate for packets that are
destined for the host, and should be disabled if received packets may
be forwarded.

Further, macvtap_skb_to_vnet_hdr() will BUG() on a packet received
with LRO (but not GRO).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I'm not really familiar with macvlan so I'm not certain that this should
be applied to all modes.

Ben.

 drivers/net/macvlan.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9ea9921..c64e26c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -168,6 +168,11 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 	unsigned int len = 0;
 	int ret = NET_RX_DROP;
 
+	if (skb_warn_if_lro(skb)) {
+		kfree_skb(skb);
+		return RX_HANDLER_CONSUMED;
+	}
+
 	port = macvlan_port_get_rcu(skb->dev);
 	if (is_multicast_ether_addr(eth->h_dest)) {
 		skb = ip_check_defrag(skb, IP_DEFRAG_MACVLAN);
@@ -717,6 +722,8 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		memcpy(dev->dev_addr, lowerdev->dev_addr, ETH_ALEN);
 	}
 
+	dev_disable_lro(lowerdev);
+
 	port->count += 1;
 	err = register_netdevice(dev);
 	if (err < 0)
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
