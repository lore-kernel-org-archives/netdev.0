From: Joe Jin <joe.jin@oracle.com>
Subject: [PATCH] e1000e: disable rxhash when try to enable
 jumbo frame also rxhash and rxcsum have enabled
Date: Fri, 08 Jun 2012 09:06:40 +0800
Message-ID: <4FD15020.7090709@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Guru Anbalagane <guru.anbalagane@oracle.com>,
	Adnan Misherfi <adnan.misherfi@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Upstream commit 70495a5 check if both rxhash and rxcsum enabled when enabling
jumbo frames and disallowed all of them enabled at the same time.

Since jumbo frame widely be used in real world, so when try to enable jumbo
frames but rxhash and rxcsum have enabled, change the default behavior to
disable receive hashing.

Signed-off-by: Joe Jin <joe.jin@oracle.com>
Signed-off-by: Guru Anbalagane <guru.anbalagane@oracle.com>
Acked-by: Adnan Misherfi <adnan.misherfi@oracle.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a4b0435..b9f0857 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -66,6 +66,8 @@ module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
 static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state);
+static int e1000_set_features(struct net_device *netdev,
+			      netdev_features_t features);
 
 static const struct e1000_info *e1000_info_tbl[] = {
 	[board_82571]		= &e1000_82571_info,
@@ -5254,8 +5256,15 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		 */
 		if ((netdev->features & NETIF_F_RXCSUM) &&
 		    (netdev->features & NETIF_F_RXHASH)) {
-			e_err("Jumbo frames cannot be enabled when both receive checksum offload and receive hashing are enabled.  Disable one of the receive offload features before enabling jumbos.\n");
-			return -EINVAL;
+			netdev_features_t features;
+
+			/* Disable receive hashing if conflicted */
+			features = netdev->features & (~NETIF_F_RXHASH);
+			if (e1000_set_features(netdev, features)) {
+				e_err("Jumbo frames cannot be enabled when both receive checksum offload and receive hashing are enabled.  Disable one of the receive offload features before enabling jumbos.\n");
+				return -EINVAL;
+			}
+			e_info("Jumbo frames cannot be enabled when both receive checksum offload and receive hashing are enabled. Disabling Receive Hashing.\n");
 		}
 	}
 
-- 
1.7.10.2


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
