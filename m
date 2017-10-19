From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net 7/7] net: aquantia: Bad udp rate on default interrupt coalescing
Date: Thu, 19 Oct 2017 18:23:59 +0300
Message-ID: <d657a264bc7682895ee625e6ef307a76cea3ecb2.1508159232.git.igor.russkikh@aquantia.com>
References: <cover.1508159232.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0061.outbound.protection.outlook.com ([104.47.32.61]:30197
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753698AbdJSPZG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 11:25:06 -0400
In-Reply-To: <cover.1508159232.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Default Tx rates cause very long ISR delays on Tx.
0xff is 510us delay, giving only ~ 2000 interrupts per seconds for
Tx rings cleanup. With these settings udp tx rate was never higher than
~800Mbps on a single stream. Changing min delay to 0xF makes it
way better with ~6Gbps

TCP stream performance is almost unaffected by this change, since LSO
optimizations play important role.

CPU load is affected insignificantly by this change.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Signed-off-by: Igor Russkikh <igor.russkikh@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
index 11f7e71..ec68c20 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
@@ -821,12 +821,12 @@ static int hw_atl_b0_hw_interrupt_moderation_set(struct aq_hw_s *self)
 			itr_rx |= rx_max_timer << 0x10U;
 		} else {
 			static unsigned int hw_atl_b0_timers_table_tx_[][2] = {
-				{0xffU, 0xffU}, /* 10Gbit */
-				{0xffU, 0x1ffU}, /* 5Gbit */
-				{0xffU, 0x1ffU}, /* 5Gbit 5GS */
-				{0xffU, 0x1ffU}, /* 2.5Gbit */
-				{0xffU, 0x1ffU}, /* 1Gbit */
-				{0xffU, 0x1ffU}, /* 100Mbit */
+				{0xfU, 0xffU}, /* 10Gbit */
+				{0xfU, 0x1ffU}, /* 5Gbit */
+				{0xfU, 0x1ffU}, /* 5Gbit 5GS */
+				{0xfU, 0x1ffU}, /* 2.5Gbit */
+				{0xfU, 0x1ffU}, /* 1Gbit */
+				{0xfU, 0x1ffU}, /* 100Mbit */
 			};
 
 			static unsigned int hw_atl_b0_timers_table_rx_[][2] = {
-- 
2.7.4
