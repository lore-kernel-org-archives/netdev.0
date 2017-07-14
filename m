From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 10/22] bnx2x: fix format overflow warning
Date: Fri, 14 Jul 2017 14:07:02 +0200
Message-ID: <20170714120720.906842-11-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
        Colin Ian King <colin.king@canonical.com>,
        Philippe Reynes <tremyfr@gmail.com>
To: linux-kernel@vger.kernel.org, Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        everest-linux-l2@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc notices that large queue numbers would overflow the queue name
string:

drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c: In function 'bnx2x_get_strings':
drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c:3165:25: error: '%d' directive writing between 1 and 10 bytes into a region of size 5 [-Werror=format-overflow=]
drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c:3165:25: note: directive argument in the range [0, 2147483647]
drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c:3165:5: note: 'sprintf' output between 2 and 11 bytes into a destination of size 5

There is a hard limit in place that makes the number at most two
digits, so the code is fine. This changes it to use snprintf()
to truncate instead of overflowing, which shuts up that warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 21bc4bed6b26..1e33abde4a3e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -3162,7 +3162,8 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 		if (is_multi(bp)) {
 			for_each_eth_queue(bp, i) {
 				memset(queue_name, 0, sizeof(queue_name));
-				sprintf(queue_name, "%d", i);
+				snprintf(queue_name, sizeof(queue_name),
+					 "%d", i);
 				for (j = 0; j < BNX2X_NUM_Q_STATS; j++)
 					snprintf(buf + (k + j)*ETH_GSTRING_LEN,
 						ETH_GSTRING_LEN,
-- 
2.9.0
