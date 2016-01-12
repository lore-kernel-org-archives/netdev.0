From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH 2/3] dummy: make device count build-time configurable
Date: Tue, 12 Jan 2016 12:57:33 +0100
Message-ID: <1452599853-27399-1-git-send-email-lkundrak@v3.sk>
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Lubomir Rintel <lkundrak@v3.sk>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The devices can be created at run-time for quite some time already and the
load-time device creation collides with attempts to create the device of
the same name:

  # rmmod dummy
  # ip link add dummy0 type dummy
  RTNETLINK answers: File exists

This is pretty much the same situation as was with the block loop devices
which was solved by adding a build-time configuration that the
distributions could use as they deem fit while keeping the default for
compatibility.

Let's do that here as well.

Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
---
 drivers/net/Kconfig | 15 +++++++++++++++
 drivers/net/dummy.c |  2 +-
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 63535b4..f94af69 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -71,6 +71,21 @@ config DUMMY
 	  To compile this driver as a module, choose M here: the module
 	  will be called dummy.
 
+config DUMMY_COUNT
+        int "Number of dummy devices to pre-create at init time"
+        depends on DUMMY
+        default 1
+        help
+          Static number of dummy devices to be unconditionally pre-created
+          at init time.
+
+          This default value can be overwritten on the kernel command
+          line or with module-parameter dummy.numdummies.
+
+          The historic default is 1. If a mid-2007 version of iproute2
+          is used (v2.6.23 or later), it can be set to 0, since needed
+          dummy devices can be dynamically allocated via rtnetlink.
+
 config EQUALIZER
 	tristate "EQL (serial line load balancing) support"
 	---help---
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 69fc840..e4506c9 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -41,7 +41,7 @@
 #define DRV_NAME	"dummy"
 #define DRV_VERSION	"1.0"
 
-static int numdummies = 1;
+static int numdummies = CONFIG_DUMMY_COUNT;
 
 /* fake multicast ability */
 static void set_multicast_list(struct net_device *dev)
-- 
2.5.0
