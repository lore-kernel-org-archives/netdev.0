From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 09/22] net: niu: fix format string overflow warning:
Date: Fri, 14 Jul 2017 14:07:01 +0200
Message-ID: <20170714120720.906842-10-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Eric Dumazet <edumazet@google.com>,
        stephen hemminger <stephen@networkplumber.org>,
        Jarod Wilson <jarod@redhat.com>
To: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:50878 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753787AbdGNMLC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 08:11:02 -0400
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get a warning for the port_name string that might be longer than
six characters if we had more than 10 ports:

drivers/net/ethernet/sun/niu.c: In function 'niu_put_parent':
drivers/net/ethernet/sun/niu.c:9563:21: error: '%d' directive writing between 1 and 3 bytes into a region of size 2 [-Werror=format-overflow=]
  sprintf(port_name, "port%d", port);
                     ^~~~~~~~
drivers/net/ethernet/sun/niu.c:9563:21: note: directive argument in the range [0, 255]
drivers/net/ethernet/sun/niu.c:9563:2: note: 'sprintf' output between 6 and 8 bytes into a destination of size 6
  sprintf(port_name, "port%d", port);
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/sun/niu.c: In function 'niu_pci_init_one':
drivers/net/ethernet/sun/niu.c:9538:22: error: '%d' directive writing between 1 and 3 bytes into a region of size 2 [-Werror=format-overflow=]
   sprintf(port_name, "port%d", port);
                      ^~~~~~~~
drivers/net/ethernet/sun/niu.c:9538:22: note: directive argument in the range [0, 255]
drivers/net/ethernet/sun/niu.c:9538:3: note: 'sprintf' output between 6 and 8 bytes into a destination of size 6

While we know that the port number is small, there is no harm in
making the format string two bytes longer to avoid the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/sun/niu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 46cb7f8955a2..4bb04aaf9650 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -9532,7 +9532,7 @@ static struct niu_parent *niu_get_parent(struct niu *np,
 		p = niu_new_parent(np, id, ptype);
 
 	if (p) {
-		char port_name[6];
+		char port_name[8];
 		int err;
 
 		sprintf(port_name, "port%d", port);
@@ -9553,7 +9553,7 @@ static void niu_put_parent(struct niu *np)
 {
 	struct niu_parent *p = np->parent;
 	u8 port = np->port;
-	char port_name[6];
+	char port_name[8];
 
 	BUG_ON(!p || p->ports[port] != np);
 
-- 
2.9.0
