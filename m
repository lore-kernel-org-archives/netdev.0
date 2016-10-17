From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 27/28] rocker: fix maybe-uninitialized warning
Date: Tue, 18 Oct 2016 00:16:15 +0200
Message-ID: <20161017221650.1902729-8-arnd@arndb.de>
References: <20161017220342.1627073-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Ido Schimmel <idosch@mellanox.com>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017220342.1627073-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In some rare configurations, we get a warning about the 'index' variable
being used without an initialization:

drivers/net/ethernet/rocker/rocker_ofdpa.c: In function ‘ofdpa_port_fib_ipv4.isra.16.constprop’:
drivers/net/ethernet/rocker/rocker_ofdpa.c:2425:92: warning: ‘index’ may be used uninitialized in this function [-Wmaybe-uninitialized]

This is a false positive, the logic is just a bit too complex for gcc
to follow here. Moving the intialization of 'index' a little further
down makes it clear to gcc that the function always returns an error
if it is not initialized.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 431a608..4ca4613 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -1493,8 +1493,6 @@ static int ofdpa_port_ipv4_nh(struct ofdpa_port *ofdpa_port,
 	spin_lock_irqsave(&ofdpa->neigh_tbl_lock, lock_flags);
 
 	found = ofdpa_neigh_tbl_find(ofdpa, ip_addr);
-	if (found)
-		*index = found->index;
 
 	updating = found && adding;
 	removing = found && !adding;
@@ -1508,9 +1506,11 @@ static int ofdpa_port_ipv4_nh(struct ofdpa_port *ofdpa_port,
 		resolved = false;
 	} else if (removing) {
 		ofdpa_neigh_del(trans, found);
+		*index = found->index;
 	} else if (updating) {
 		ofdpa_neigh_update(found, trans, NULL, false);
 		resolved = !is_zero_ether_addr(found->eth_dst);
+		*index = found->index;
 	} else {
 		err = -ENOENT;
 	}
-- 
2.9.0
