From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] mv643xx_eth: fix multicast filter programming
Date: Mon, 19 Jan 2009 10:58:13 +0100
Message-ID: <20090119095813.GF17124@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tbm@cyrius.com, pacman@kosh.dhis.org, netdev@vger.kernel.org,
	Matt Sealey <matt@genesi-usa.com>,
	Gabriel Paubert <paubert@iram.es>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:56177 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754098AbZASJ6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 04:58:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 66e63ffbc04706568d8789cbb00eaa8ddbcae648 ("mv643xx_eth:
implement ->set_rx_mode()") cleaned up mv643xx_eth's multicast filter
programming, but broke it as well.

The non-special multicast filter table (for multicast addresses that
are not of the form 01:00:5e:00:00:xx) consists of 256 hash table
buckets organised as 64 32-bit words, where the 'accept' bits are
in the LSB of each byte, so in bits 24 16 8 0 of each 32-bit word.
The old code got this right, but the referenced commit broke this by
using bits 3 2 1 0 instead.  This commit fixes this up.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index e2aa468..8c6979a 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1596,7 +1596,7 @@ oom:
 			entry = addr_crc(a);
 		}
 
-		table[entry >> 2] |= 1 << (entry & 3);
+		table[entry >> 2] |= 1 << (8 * (entry & 3));
 	}
 
 	for (i = 0; i < 0x100; i += 4) {
-- 
1.5.6.4
