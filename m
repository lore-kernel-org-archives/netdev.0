From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 13/39] mv643xx_eth: move MIB offset defines into their only user
Date: Tue,  3 Jun 2008 13:02:28 +0200
Message-ID: <1212490974-23719-14-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48747 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756375AbYFCMAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:45 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only user of the ETH_MIB_VERY_LONG_NAME_HERE defines is the
eth_update_mib_counters() function.  Get rid of the defines by
open-coding the register offsets in the latter.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   92 ++++++++++++++++----------------------------
 1 files changed, 34 insertions(+), 58 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 3c5c992..075ee2a 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -160,42 +160,6 @@ static char mv643xx_driver_version[] = "1.0";
 #define PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
 #define PORT_DEFAULT_RECEIVE_QUEUE_SIZE		400
 
-/* Gigabit Ethernet Unit Global Registers */
-
-/* MIB Counters register definitions */
-#define ETH_MIB_GOOD_OCTETS_RECEIVED_LOW	0x0
-#define ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH	0x4
-#define ETH_MIB_BAD_OCTETS_RECEIVED		0x8
-#define ETH_MIB_INTERNAL_MAC_TRANSMIT_ERR	0xc
-#define ETH_MIB_GOOD_FRAMES_RECEIVED		0x10
-#define ETH_MIB_BAD_FRAMES_RECEIVED		0x14
-#define ETH_MIB_BROADCAST_FRAMES_RECEIVED	0x18
-#define ETH_MIB_MULTICAST_FRAMES_RECEIVED	0x1c
-#define ETH_MIB_FRAMES_64_OCTETS		0x20
-#define ETH_MIB_FRAMES_65_TO_127_OCTETS		0x24
-#define ETH_MIB_FRAMES_128_TO_255_OCTETS	0x28
-#define ETH_MIB_FRAMES_256_TO_511_OCTETS	0x2c
-#define ETH_MIB_FRAMES_512_TO_1023_OCTETS	0x30
-#define ETH_MIB_FRAMES_1024_TO_MAX_OCTETS	0x34
-#define ETH_MIB_GOOD_OCTETS_SENT_LOW		0x38
-#define ETH_MIB_GOOD_OCTETS_SENT_HIGH		0x3c
-#define ETH_MIB_GOOD_FRAMES_SENT		0x40
-#define ETH_MIB_EXCESSIVE_COLLISION		0x44
-#define ETH_MIB_MULTICAST_FRAMES_SENT		0x48
-#define ETH_MIB_BROADCAST_FRAMES_SENT		0x4c
-#define ETH_MIB_UNREC_MAC_CONTROL_RECEIVED	0x50
-#define ETH_MIB_FC_SENT				0x54
-#define ETH_MIB_GOOD_FC_RECEIVED		0x58
-#define ETH_MIB_BAD_FC_RECEIVED			0x5c
-#define ETH_MIB_UNDERSIZE_RECEIVED		0x60
-#define ETH_MIB_FRAGMENTS_RECEIVED		0x64
-#define ETH_MIB_OVERSIZE_RECEIVED		0x68
-#define ETH_MIB_JABBER_RECEIVED			0x6c
-#define ETH_MIB_MAC_RECEIVE_ERROR		0x70
-#define ETH_MIB_BAD_CRC_EVENT			0x74
-#define ETH_MIB_COLLISION			0x78
-#define ETH_MIB_LATE_COLLISION			0x7c
-
 /* Port serial status reg (PSR) */
 #define ETH_INTERFACE_PCM			0x00000001
 #define ETH_LINK_IS_UP				0x00000002
@@ -1147,8 +1111,7 @@ static void eth_clear_mib_counters(struct mv643xx_private *mp)
 	int i;
 
 	/* Perform dummy reads from MIB counters */
-	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION;
-									i += 4)
+	for (i = 0; i < 0x80; i += 4)
 		rdl(mp, MIB_COUNTERS(port_num) + i);
 }
 
@@ -1160,26 +1123,39 @@ static inline u32 read_mib(struct mv643xx_private *mp, int offset)
 static void eth_update_mib_counters(struct mv643xx_private *mp)
 {
 	struct mv643xx_mib_counters *p = &mp->mib_counters;
-	int offset;
-
-	p->good_octets_received +=
-		read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_LOW);
-	p->good_octets_received +=
-		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH) << 32;
-
-	for (offset = ETH_MIB_BAD_OCTETS_RECEIVED;
-			offset <= ETH_MIB_FRAMES_1024_TO_MAX_OCTETS;
-			offset += 4)
-		*(u32 *)((char *)p + offset) += read_mib(mp, offset);
-
-	p->good_octets_sent += read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_LOW);
-	p->good_octets_sent +=
-		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_HIGH) << 32;
-
-	for (offset = ETH_MIB_GOOD_FRAMES_SENT;
-			offset <= ETH_MIB_LATE_COLLISION;
-			offset += 4)
-		*(u32 *)((char *)p + offset) += read_mib(mp, offset);
+
+	p->good_octets_received += read_mib(mp, 0x00);
+	p->good_octets_received += (u64)read_mib(mp, 0x04) << 32;
+	p->bad_octets_received += read_mib(mp, 0x08);
+	p->internal_mac_transmit_err += read_mib(mp, 0x0c);
+	p->good_frames_received += read_mib(mp, 0x10);
+	p->bad_frames_received += read_mib(mp, 0x14);
+	p->broadcast_frames_received += read_mib(mp, 0x18);
+	p->multicast_frames_received += read_mib(mp, 0x1c);
+	p->frames_64_octets += read_mib(mp, 0x20);
+	p->frames_65_to_127_octets += read_mib(mp, 0x24);
+	p->frames_128_to_255_octets += read_mib(mp, 0x28);
+	p->frames_256_to_511_octets += read_mib(mp, 0x2c);
+	p->frames_512_to_1023_octets += read_mib(mp, 0x30);
+	p->frames_1024_to_max_octets += read_mib(mp, 0x34);
+	p->good_octets_sent += read_mib(mp, 0x38);
+	p->good_octets_sent += (u64)read_mib(mp, 0x3c) << 32;
+	p->good_frames_sent += read_mib(mp, 0x40);
+	p->excessive_collision += read_mib(mp, 0x44);
+	p->multicast_frames_sent += read_mib(mp, 0x48);
+	p->broadcast_frames_sent += read_mib(mp, 0x4c);
+	p->unrec_mac_control_received += read_mib(mp, 0x50);
+	p->fc_sent += read_mib(mp, 0x54);
+	p->good_fc_received += read_mib(mp, 0x58);
+	p->bad_fc_received += read_mib(mp, 0x5c);
+	p->undersize_received += read_mib(mp, 0x60);
+	p->fragments_received += read_mib(mp, 0x64);
+	p->oversize_received += read_mib(mp, 0x68);
+	p->jabber_received += read_mib(mp, 0x6c);
+	p->mac_receive_error += read_mib(mp, 0x70);
+	p->bad_crc_event += read_mib(mp, 0x74);
+	p->collision += read_mib(mp, 0x78);
+	p->late_collision += read_mib(mp, 0x7c);
 }
 
 
-- 
1.5.3.4

