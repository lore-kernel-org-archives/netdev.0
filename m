From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/3] eth: Rename and properly align
 br_reserved_address array
Date: Thu, 1 Nov 2012 19:12:02 +0000
Message-ID: <1351797122.2883.14.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39102 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752285Ab2KATMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 15:12:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since this array is no longer part of the bridge driver, it should
have an 'eth' prefix not 'br'.

We also assume that either it's 16-bit-aligned or the architecture has
efficient unaligned access.  Ensure the first of these is true by
explicitly aligning it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/etherdevice.h |    5 +++--
 net/bridge/br_device.c      |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 7cf2516..243eea1 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -52,7 +52,8 @@ extern struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 #define alloc_etherdev_mq(sizeof_priv, count) alloc_etherdev_mqs(sizeof_priv, count, count)
 
 /* Reserved Ethernet Addresses per IEEE 802.1Q */
-static const u8 br_reserved_address[ETH_ALEN] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
+static const u8 eth_reserved_addr_base[ETH_ALEN] __aligned(2) =
+{ 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
 
 /**
  * is_link_local_ether_addr - Determine if given Ethernet address is link-local
@@ -64,7 +65,7 @@ static const u8 br_reserved_address[ETH_ALEN] = { 0x01, 0x80, 0xc2, 0x00, 0x00,
 static inline bool is_link_local_ether_addr(const u8 *addr)
 {
 	__be16 *a = (__be16 *)addr;
-	static const __be16 *b = (const __be16 *)br_reserved_address;
+	static const __be16 *b = (const __be16 *)eth_reserved_addr_base;
 	static const __be16 m = cpu_to_be16(0xfff0);
 
 	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | ((a[2] ^ b[2]) & m)) == 0;
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 4245e99..7c78e26 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -358,7 +358,7 @@ void br_dev_setup(struct net_device *dev)
 	br->bridge_id.prio[0] = 0x80;
 	br->bridge_id.prio[1] = 0x00;
 
-	memcpy(br->group_addr, br_reserved_address, ETH_ALEN);
+	memcpy(br->group_addr, eth_reserved_addr_base, ETH_ALEN);
 
 	br->stp_enabled = BR_NO_STP;
 	br->group_fwd_mask = BR_GROUPFWD_DEFAULT;
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
