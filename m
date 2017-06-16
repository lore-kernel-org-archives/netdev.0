From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net 2/4] macvlan: Fix passthru macvlan mac address inheritance
Date: Fri, 16 Jun 2017 09:36:47 -0400
Message-ID: <20170616133649.24622-3-vyasevic@redhat.com>
References: <20170616133649.24622-1-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36276 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753767AbdFPNhB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 09:37:01 -0400
Received: by mail-qt0-f196.google.com with SMTP id s33so10245265qtg.3
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 06:37:00 -0700 (PDT)
In-Reply-To: <20170616133649.24622-1-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a lower device of the passthru macvlan changes it's address,
passthru macvlan is supposed to change it's own address as well.
However, that doesn't happen correctly because the check in
macvlan_addr_busy() will catch the fact that the lower level
(port) mac address is the same as the address we are trying to
assign to the macvlan, and return an error.  As a result,
the address of the passthru macvlan device is never changed.

The same thing happens when the user attempts to change the
mac address of the passthru macvlan.

The simple solution appears to be to not check against
the lower device in case of passthru macvlan device, since
the 2 addresses are _supposed_ to be the same.

Fixes: e289fd281 (macvlan: fix the problem when mac address changes for passthru mode)
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index de214fb..a735a64 100644
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
