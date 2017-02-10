From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v3 net-next 1/9] sunvnet: make sunvnet common code dynamically loadable
Date: Fri, 10 Feb 2017 09:38:17 -0800
Message-ID: <1486748305-240339-2-git-send-email-shannon.nelson@oracle.com>
References: <1486748305-240339-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23134 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbdBJRpK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 12:45:10 -0500
In-Reply-To: <1486748305-240339-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the sunvnet_common code was split out for use by both sunvnet
and the newer ldmvsw, it was made into a static kernel library, which
limits the usefulness of sunvnet and ldmvsw as loadables, since most
of the real work is being done in the shared code.  Also, this is
simply dead code in kernels that aren't running the LDoms.

This patch makes the sunvnet_common into a dynamically loadable
module and makes sunvnet and ldmvsw dependent on sunvnet_common.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/Kconfig          |    8 ++++++--
 drivers/net/ethernet/sun/sunvnet_common.c |    5 +++++
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/Kconfig b/drivers/net/ethernet/sun/Kconfig
index a4b40e3..a7d91da 100644
--- a/drivers/net/ethernet/sun/Kconfig
+++ b/drivers/net/ethernet/sun/Kconfig
@@ -70,19 +70,23 @@ config CASSINI
 	  <http://docs.oracle.com/cd/E19113-01/giga.ether.pci/817-4341-10/817-4341-10.pdf>.
 
 config SUNVNET_COMMON
-	bool
+	tristate "Common routines to support Sun Virtual Networking"
 	depends on SUN_LDOMS
-	default y if SUN_LDOMS
+	default m if SUN_LDOMS
 
 config SUNVNET
 	tristate "Sun Virtual Network support"
+	default m
 	depends on SUN_LDOMS
+	depends on SUNVNET_COMMON
 	---help---
 	  Support for virtual network devices under Sun Logical Domains.
 
 config LDMVSW
 	tristate "Sun4v LDoms Virtual Switch support"
+	default m
 	depends on SUN_LDOMS
+	depends on SUNVNET_COMMON
 	---help---
 	  Support for virtual switch devices under Sun4v Logical Domains.
 	  This driver adds a network interface for every vsw-port node
diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 191c8ad..c71f000 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -37,6 +37,11 @@
  */
 #define	VNET_MAX_RETRIES	10
 
+MODULE_AUTHOR("David S. Miller (davem@davemloft.net)");
+MODULE_DESCRIPTION("Sun LDOM virtual network support library");
+MODULE_LICENSE("GPL");
+MODULE_VERSION("1.1");
+
 static int __vnet_tx_trigger(struct vnet_port *port, u32 start);
 static void vnet_port_reset(struct vnet_port *port);
 
-- 
1.7.1
