From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH 3/3] bonding: make device count build-time configurable
Date: Tue, 12 Jan 2016 12:58:36 +0100
Message-ID: <1452599916-27511-1-git-send-email-lkundrak@v3.sk>
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Lubomir Rintel <lkundrak@v3.sk>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The devices can be created at run-time for quite some time already and the
load-time device creation collides with attempts to create the device of
the same name:

  # rmmod bonding
  # ip link add bond0 type bond
  RTNETLINK answers: File exists

This is pretty much the same situation as was with the block loop devices
which was solved by adding a build-time configuration that the
distributions could use as they deem fit while keeping the default for
compatibility.

Let's do that here as well.

Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
---
 drivers/net/Kconfig             | 15 +++++++++++++++
 drivers/net/bonding/bond_main.c |  2 +-
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f94af69..51de664 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -55,6 +55,21 @@ config BONDING
 	  To compile this driver as a module, choose M here: the module
 	  will be called bonding.
 
+config BONDING_COUNT
+        int "Number of bonding devices to pre-create at init time"
+        depends on BONDING
+        default 1
+        help
+          Static number of bonding devices to be unconditionally pre-created
+          at init time.
+
+          This default value can be overwritten on the kernel command
+          line or with module-parameter bonding.max_bonds.
+
+          The historic default is 1. If a mid-2007 version of iproute2
+          is used (v2.6.23 or later), it can be set to 0, since needed
+          bonding devices can be dynamically allocated via rtnetlink.
+
 config DUMMY
 	tristate "Dummy net driver support"
 	---help---
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9e0f8a7..f013cfa 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -88,7 +88,7 @@
 
 /* monitor all links that often (in milliseconds). <=0 disables monitoring */
 
-static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
+static int max_bonds	= CONFIG_BONDING_COUNT;
 static int tx_queues	= BOND_DEFAULT_TX_QUEUES;
 static int num_peer_notif = 1;
 static int miimon;
-- 
2.5.0
