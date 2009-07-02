From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/4] ixgbe: fix inconsistent SFP/SFP+ failure results.
Date: Thu, 02 Jul 2009 15:50:52 -0700
Message-ID: <20090702225051.22746.79159.stgit@localhost.localdomain>
References: <20090702225012.22746.57218.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:51584
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753106AbZGBWvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 18:51:06 -0400
In-Reply-To: <20090702225012.22746.57218.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Currently if we loaded the driver, insert an unsupported module, and then
attempt to "ifconfig up" the device it will be brought down but the netdev
would not be unregistered. This behavior is different than all other
code paths. This patch corrects that by down'ing the device and then
scheduling the sfp_config_module_task tasklet. The tasklet will detect
this condition (like it does with other code paths) and do the
unregister_netdev().

I also removed the log message as this condition (an unsupported SFP+
module) will be logged in sfp_config_module_task.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index cf39f5a..a3061aa 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2706,12 +2706,12 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	if (hw->phy.type == ixgbe_phy_unknown) {
 		err = hw->phy.ops.identify(hw);
 		if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
-			dev_err(&adapter->pdev->dev, "failed to initialize "
-				"because an unsupported SFP+ module type "
-				"was detected.\n"
-				"Reload the driver after installing a "
-				"supported module.\n");
+			/*
+			 * Take the device down and schedule the sfp tasklet
+			 * which will unregister_netdev and log it.
+			 */
 			ixgbe_down(adapter);
+			schedule_work(&adapter->sfp_config_module_task);
 			return err;
 		}
 	}

