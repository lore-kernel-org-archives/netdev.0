From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/2] mv643xx_eth: 64bit mib counter read fix
Date: Wed, 29 Apr 2009 23:58:18 +0200
Message-ID: <20090429215818.GA14729@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:43731 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbZD2Vyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 17:54:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On several mv643xx_eth hardware versions, the two 64bit mib counters
for 'good octets received' and 'good octets sent' are actually 32bit
counters, and reading from the upper half of the register has the same
effect as reading from the lower half of the register: an atomic
read-and-clear of the entire 32bit counter value.  This can under heavy
traffic occasionally lead to small numbers being added to the upper
half of the 64bit mib counter even though no 32bit wrap has occured.

Since we poll the mib counters at least every 30 seconds anyway, we
might as well just skip the reads of the upper halves of the hardware
counters without breaking the stats, which this patch does.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Cc: stable@kernel.org
---
 drivers/net/mv643xx_eth.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 038beff..a400d71 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1255,7 +1255,6 @@ static void mib_counters_update(struct mv643xx_eth_private *mp)
 
 	spin_lock_bh(&mp->mib_counters_lock);
 	p->good_octets_received += mib_read(mp, 0x00);
-	p->good_octets_received += (u64)mib_read(mp, 0x04) << 32;
 	p->bad_octets_received += mib_read(mp, 0x08);
 	p->internal_mac_transmit_err += mib_read(mp, 0x0c);
 	p->good_frames_received += mib_read(mp, 0x10);
@@ -1269,7 +1268,6 @@ static void mib_counters_update(struct mv643xx_eth_private *mp)
 	p->frames_512_to_1023_octets += mib_read(mp, 0x30);
 	p->frames_1024_to_max_octets += mib_read(mp, 0x34);
 	p->good_octets_sent += mib_read(mp, 0x38);
-	p->good_octets_sent += (u64)mib_read(mp, 0x3c) << 32;
 	p->good_frames_sent += mib_read(mp, 0x40);
 	p->excessive_collision += mib_read(mp, 0x44);
 	p->multicast_frames_sent += mib_read(mp, 0x48);
-- 
1.5.6.4
