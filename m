From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 13/22] liquidio: fix possible eeprom format string overflow
Date: Fri, 14 Jul 2017 14:07:05 +0200
Message-ID: <20170714120720.906842-14-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
        Weilin Chang <weilin.chang@cavium.com>,
        Prasad Kanneganti <prasad.kanneganti@cavium.com>
To: linux-kernel@vger.kernel.org,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc reports that the temporary buffer for computing the
string length may be too small here:

drivers/net/ethernet/cavium/liquidio/lio_ethtool.c: In function 'lio_get_eeprom_len':
/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c:345:21: error: 'sprintf' may write a terminating nul past the end of the destination [-Werror=format-overflow=]
  len = sprintf(buf, "boardname:%s serialnum:%s maj:%lld min:%lld\n",
                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/cavium/liquidio/lio_ethtool.c:345:6: note: 'sprintf' output between 35 and 167 bytes into a destination of size 128
  len = sprintf(buf, "boardname:%s serialnum:%s maj:%lld min:%lld\n",

This extends it to 192 bytes, which is certainly enough. As far
as I could tell, there are no other constraints that require a specific
maximum size.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 28ecda3d3404..ebd353bc78ff 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -335,7 +335,7 @@ lio_ethtool_get_channels(struct net_device *dev,
 
 static int lio_get_eeprom_len(struct net_device *netdev)
 {
-	u8 buf[128];
+	u8 buf[192];
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct_dev = lio->oct_dev;
 	struct octeon_board_info *board_info;
-- 
2.9.0
