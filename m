From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V2 net 2/4] macvlan: Fix passthru macvlan mac address inheritance
Date: Wed, 21 Jun 2017 07:59:17 -0400
Message-ID: <20170621115919.28165-3-vyasevic@redhat.com>
References: <20170621115919.28165-1-vyasevic@redhat.com>
Cc: girish.moodalbail@oracle.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34965 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbdFUL7c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 07:59:32 -0400
Received: by mail-qk0-f194.google.com with SMTP id 16so9736494qkg.2
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 04:59:32 -0700 (PDT)
In-Reply-To: <20170621115919.28165-1-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a lower device of the passthru macvlan changes it's address,
passthru macvlan is supposed to change it's own address as well.
However, that doesn't happen correctly because the check in
macvlan_addr_busy() will catch the fact that the lower level
(port) mac address is the same as the address we are trying to
assign to the macvlan, and return an error.  As a reasult,
the address of the passthru macvlan device is never changed.

The same thing happens when the user attempts to change the
mac address of the passthru macvlan.

The simple solution appers to be to not check against
the lower device in case of passthru macvlan device, since
the 2 addresses are _supposed_ to be the same.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index de214fb..0c9c6da 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -185,7 +185,8 @@ static bool macvlan_addr_busy(const struct macvlan_port *port,
 	 * currently in use by the underlying device or
 	 * another macvlan.
 	 */
-	if (ether_addr_equal_64bits(port->dev->dev_addr, addr))
+	if (!port->passthru &&
+	    ether_addr_equal_64bits(port->dev->dev_addr, addr))
 		return true;
 
 	if (macvlan_hash_lookup(port, addr))
-- 
2.9.4
