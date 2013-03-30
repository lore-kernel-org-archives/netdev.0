From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH] ip_gre: don't overwrite iflink during net_dev init
Date: Sat, 30 Mar 2013 18:07:37 +0100
Message-ID: <1364663257-14717-1-git-send-email-ordex@autistici.org>
References: <20130330115245.GA4024@ritirata.org>
Cc: linux-kernel@vger.kernel.org,
	Fengguang Wu <fengguang.wu@intel.com>,
	Antonio Quartulli <ordex@autistici.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:44244 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756916Ab3C3Rbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 13:31:49 -0400
In-Reply-To: <20130330115245.GA4024@ritirata.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iflink is currently set to 0 in __gre_tunnel_init(). This
function is invoked in gre_tap_init() and
ipgre_tunnel_init() which are both used to initialise the
ndo_init field of the respective net_device_ops structs
(ipgre.. and gre_tap..) used by GRE interfaces.

However, in netdevice_register() iflink is first set to -1,
then ndo_init is invoked and then iflink is assigned to a
proper value if and only if it still was -1.

Assigning 0 to iflink in ndo_init is therefore first
preventing netdev_register() to correctly assign it a proper
value and then breaking iflink at all since 0 has not
correct meaning.

Fix this by removing the iflink assignment in
__gre_tunnel_init().

Introduced by c54419321455631079c7d6e60bc732dd0c5914c5
("GRE: Refactor GRE tunneling code.")

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/ipv4/ip_gre.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index ad662e9..e5dfd28 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -660,7 +660,6 @@ static void __gre_tunnel_init(struct net_device *dev)
 
 	dev->needed_headroom	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
 	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr) - 4;
-	dev->iflink		= 0;
 
 	dev->features		|= NETIF_F_NETNS_LOCAL | GRE_FEATURES;
 	dev->hw_features	|= GRE_FEATURES;
-- 
1.8.1.5
