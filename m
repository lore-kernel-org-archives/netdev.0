From: Jochen Friedrich <jochen@scram.de>
Subject: [PATCH] powerpc: Fix fs_enet module build
Date: Tue, 13 Nov 2007 19:32:08 +0100
Message-ID: <4739EDA8.6020800@scram.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: "linuxppc-embedded@ozlabs.org" <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

If fs_enet is build as module, on PPC_CPM_NEW_BINDING platforms
mii-fec/mii-bitbang should be build as module, as well. On other
platforms, mii-fec/mii-bitbang must be included into the main module.
Otherwise some symbols remain undefined. Additionally, fs_enet uses
libphy, so add a select PHYLIB.

  Building modules, stage 2.
  MODPOST 5 modules
ERROR: "fs_scc_ops" [drivers/net/fs_enet/fs_enet.ko] undefined!
make[1]: *** [__modpost] Error 1
make: *** [modules] Error 2

Signed-off-by: Jochen Friedrich <jochen@scram.de>
---

This patch replaces powerpc-fs_enet-select-phylib-as-the-driver-needs-it.patch
from -mm.

 drivers/net/fs_enet/Kconfig  |   11 ++++++++++-
 drivers/net/fs_enet/Makefile |   15 ++++++++++++---
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/fs_enet/Kconfig b/drivers/net/fs_enet/Kconfig
index 2765e49..562ea68 100644
--- a/drivers/net/fs_enet/Kconfig
+++ b/drivers/net/fs_enet/Kconfig
@@ -2,6 +2,7 @@ config FS_ENET
        tristate "Freescale Ethernet Driver"
        depends on CPM1 || CPM2
        select MII
+       select PHYLIB
 
 config FS_ENET_HAS_SCC
 	bool "Chip has an SCC usable for ethernet"
@@ -11,11 +12,19 @@ config FS_ENET_HAS_SCC
 config FS_ENET_HAS_FCC
 	bool "Chip has an FCC usable for ethernet"
 	depends on FS_ENET && CPM2
-	select MDIO_BITBANG
 	default y
 
 config FS_ENET_HAS_FEC
 	bool "Chip has an FEC usable for ethernet"
 	depends on FS_ENET && CPM1
+	select FS_ENET_MDIO_FEC
 	default y
 
+config FS_ENET_MDIO_FEC
+	tristate "MDIO driver for FEC"
+	depends on FS_ENET && CPM1
+
+config FS_ENET_MDIO_FCC
+	tristate "MDIO driver for FCC"
+	depends on FS_ENET && CPM2
+	select MDIO_BITBANG
diff --git a/drivers/net/fs_enet/Makefile b/drivers/net/fs_enet/Makefile
index 02d4dc1..1ffbe07 100644
--- a/drivers/net/fs_enet/Makefile
+++ b/drivers/net/fs_enet/Makefile
@@ -4,7 +4,16 @@
 
 obj-$(CONFIG_FS_ENET) += fs_enet.o
 
-obj-$(CONFIG_8xx) += mac-fec.o mac-scc.o mii-fec.o
-obj-$(CONFIG_CPM2) += mac-fcc.o mii-bitbang.o
+fs_enet-$(CONFIG_FS_ENET_HAS_SCC) += mac-scc.o
+fs_enet-$(CONFIG_FS_ENET_HAS_FEC) += mac-fec.o
+fs_enet-$(CONFIG_FS_ENET_HAS_FCC) += mac-fcc.o
 
-fs_enet-objs := fs_enet-main.o
+ifeq ($(CONFIG_PPC_CPM_NEW_BINDING),y)
+obj-$(CONFIG_FS_ENET_MDIO_FEC) += mii-fec.o
+obj-$(CONFIG_FS_ENET_MDIO_FCC) += mii-bitbang.o
+else
+fs_enet-$(CONFIG_FS_ENET_MDIO_FEC) += mii-fec.o
+fs_enet-$(CONFIG_FS_ENET_MDIO_FCC) += mii-bitbang.o
+endif
+
+fs_enet-objs := fs_enet-main.o $(fs_enet-m)
-- 
1.5.3.5
