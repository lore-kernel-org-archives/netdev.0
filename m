From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 6/6] e1000: fix schedule while atomic when called from mii-tool
Date: Tue, 13 Nov 2007 15:11:38 -0800
Message-ID: <20071113231138.13177.67320.stgit@localhost.localdomain>
References: <20071113231110.13177.27339.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48443 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759169AbXKMXLk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 18:11:40 -0500
In-Reply-To: <20071113231110.13177.27339.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

mii-tool can cause the driver to call msleep during nway reset,
bugzilla.kernel.org bug 8430.  Fix by simply calling reinit_locked
outside of the spinlock, which is safe from ethtool, so it should be
safe from here.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index dc4934d..b7c3070 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4794,6 +4794,7 @@ e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 			spin_unlock_irqrestore(&adapter->stats_lock, flags);
 			return -EIO;
 		}
+		spin_unlock_irqrestore(&adapter->stats_lock, flags);
 		if (adapter->hw.media_type == e1000_media_type_copper) {
 			switch (data->reg_num) {
 			case PHY_CTRL:
@@ -4814,12 +4815,8 @@ e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 						   DUPLEX_HALF;
 					retval = e1000_set_spd_dplx(adapter,
 								    spddplx);
-					if (retval) {
-						spin_unlock_irqrestore(
-							&adapter->stats_lock,
-							flags);
+					if (retval)
 						return retval;
-					}
 				}
 				if (netif_running(adapter->netdev))
 					e1000_reinit_locked(adapter);
@@ -4828,11 +4825,8 @@ e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 				break;
 			case M88E1000_PHY_SPEC_CTRL:
 			case M88E1000_EXT_PHY_SPEC_CTRL:
-				if (e1000_phy_reset(&adapter->hw)) {
-					spin_unlock_irqrestore(
-						&adapter->stats_lock, flags);
+				if (e1000_phy_reset(&adapter->hw))
 					return -EIO;
-				}
 				break;
 			}
 		} else {
@@ -4847,7 +4841,6 @@ e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 				break;
 			}
 		}
-		spin_unlock_irqrestore(&adapter->stats_lock, flags);
 		break;
 	default:
 		return -EOPNOTSUPP;
