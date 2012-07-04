From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH] netdev/phy: Fixup lockdep warnings in mdio-mux.c
Date: Wed,  4 Jul 2012 15:06:16 -0700
Message-ID: <1341439576-1413-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:58735 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829Ab2GDWGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 18:06:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>

With lockdep enabled we get:

=============================================
[ INFO: possible recursive locking detected ]
3.4.4-Cavium-Octeon+ #313 Not tainted
---------------------------------------------
kworker/u:1/36 is trying to acquire lock:
(&bus->mdio_lock){+.+...}, at: [<ffffffff813da7e8>] mdio_mux_read+0x38/0xa0

but task is already holding lock:
 (&bus->mdio_lock){+.+...}, at: [<ffffffff813d79e4>] mdiobus_read+0x44/0x88

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(&bus->mdio_lock);
  lock(&bus->mdio_lock);

 *** DEADLOCK ***

 May be due to missing lock nesting notation
.
.
.

This is a false positive, since we are indeed using 'nested' locking,
we need to use mutex_lock_nested().

Now in theory we can stack multiple MDIO multiplexers, but that would
require passing the nesting level (which is difficult to know) to
mutex_lock_nested().  Instead we assume the simple case of a single
level of nesting.  Since these are only warning messages, it isn't so
important to solve the general case.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/phy/mdio-mux.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 39ea067..5c12018 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -46,7 +46,13 @@ static int mdio_mux_read(struct mii_bus *bus, int phy_id, int regnum)
 	struct mdio_mux_parent_bus *pb = cb->parent;
 	int r;
 
-	mutex_lock(&pb->mii_bus->mdio_lock);
+	/* In theory multiple mdio_mux could be stacked, thus creating
+	 * more than a single level of nesting.  But in practice,
+	 * SINGLE_DEPTH_NESTING will cover the vast majority of use
+	 * cases.  We use it, instead of trying to handle the general
+	 * case.
+	 */
+	mutex_lock_nested(&pb->mii_bus->mdio_lock, SINGLE_DEPTH_NESTING);
 	r = pb->switch_fn(pb->current_child, cb->bus_number, pb->switch_data);
 	if (r)
 		goto out;
@@ -71,7 +77,7 @@ static int mdio_mux_write(struct mii_bus *bus, int phy_id,
 
 	int r;
 
-	mutex_lock(&pb->mii_bus->mdio_lock);
+	mutex_lock_nested(&pb->mii_bus->mdio_lock, SINGLE_DEPTH_NESTING);
 	r = pb->switch_fn(pb->current_child, cb->bus_number, pb->switch_data);
 	if (r)
 		goto out;
-- 
1.7.2.3
