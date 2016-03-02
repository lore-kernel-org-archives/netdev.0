From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: mellanox: add DEVLINK dependencies
Date: Wed,  2 Mar 2016 10:40:54 +0100
Message-ID: <1456911665-1424389-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	Yishai Hadas <yishaih@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Ido Schimmel <idosch@mellanox.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new NET_DEVLINK infrastructure can be a loadable module, but the drivers
using it might be built-in, which causes link errors like:

drivers/net/built-in.o: In function `mlx4_load_one':
:(.text+0x2fbfda): undefined reference to `devlink_port_register'
:(.text+0x2fc084): undefined reference to `devlink_port_unregister'
drivers/net/built-in.o: In function `mlxsw_sx_port_remove':
:(.text+0x33a03a): undefined reference to `devlink_port_type_clear'
:(.text+0x33a04e): undefined reference to `devlink_port_unregister'

There are multiple ways to avoid this:

a) add 'depends on NET_DEVLINK || !NET_DEVLINK' dependencies
   for each user
b) use 'select NET_DEVLINK' from each driver that uses it
   and hide the symbol in Kconfig.
c) make NET_DEVLINK a 'bool' option so we don't have to
   list it as a dependency, and rely on the APIs to be
   stubbed out when it is disabled
d) use IS_REACHABLE() rather than IS_ENABLED() to check for
   NET_DEVLINK in include/net/devlink.h

This implements a variation of approach a) by adding an
intermediate symbol that drivers can depend on, and changes
the three drivers using it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 09d4d087cd48 ("mlx4: Implement devlink interface")
Fixes: c4745500e988 ("mlxsw: Implement devlink interface")
---
 drivers/infiniband/hw/mlx4/Kconfig          | 1 +
 drivers/net/ethernet/mellanox/mlx4/Kconfig  | 1 +
 drivers/net/ethernet/mellanox/mlxsw/Kconfig | 1 +
 net/Kconfig                                 | 9 +++++++++
 4 files changed, 12 insertions(+)

diff --git a/drivers/infiniband/hw/mlx4/Kconfig b/drivers/infiniband/hw/mlx4/Kconfig
index fc01deac1d3c..db4aa13ebae0 100644
--- a/drivers/infiniband/hw/mlx4/Kconfig
+++ b/drivers/infiniband/hw/mlx4/Kconfig
@@ -1,6 +1,7 @@
 config MLX4_INFINIBAND
 	tristate "Mellanox ConnectX HCA support"
 	depends on NETDEVICES && ETHERNET && PCI && INET
+	depends on MAY_USE_DEVLINK
 	select NET_VENDOR_MELLANOX
 	select MLX4_CORE
 	---help---
diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
index 1486ce902a56..9ca3734ebb6b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -4,6 +4,7 @@
 
 config MLX4_EN
 	tristate "Mellanox Technologies 1/10/40Gbit Ethernet support"
+	depends on MAY_USE_DEVLINK
 	depends on PCI
 	select MLX4_CORE
 	select PTP_1588_CLOCK
diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index ce26adcb4988..2ad7f67854d5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -4,6 +4,7 @@
 
 config MLXSW_CORE
 	tristate "Mellanox Technologies Switch ASICs support"
+	depends on MAY_USE_DEVLINK
 	---help---
 	  This driver supports Mellanox Technologies Switch ASICs family.
 
diff --git a/net/Kconfig b/net/Kconfig
index 6c9cfb0d7639..2760825e53fa 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -403,6 +403,15 @@ config NET_DEVLINK
 	  infrastructure to support access to physical chip-wide config and
 	  monitoring.
 
+config MAY_USE_DEVLINK
+	tristate
+	default m if NET_DEVLINK=m
+	default y if NET_DEVLINK=y || NET_DEVLINK=n
+	help
+	  Drivers using the devlink infrastructure should have a dependency
+	  on MAY_USE_DEVLINK to ensure they do not cause link errors when
+	  devlink is a loadable module and the driver using it is built-in.
+
 endif   # if NET
 
 # Used by archs to tell that they support BPF_JIT
-- 
2.7.0
