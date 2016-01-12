From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH v2] ifb: make device count build-time configurable
Date: Tue, 12 Jan 2016 16:36:51 +0100
Message-ID: <1452613011-2971-1-git-send-email-lkundrak@v3.sk>
References: <1452612711.18559.62.camel@v3.sk>
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Lubomir Rintel <lkundrak@v3.sk>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452612711.18559.62.camel@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The devices can be created at run-time for quite some time already and the
load-time device creation collides with attempts to create the device of
the same name:

  # rmmod ifb
  # ip link add ifb0 type ifb
  RTNETLINK answers: File exists

This is pretty much the same situation as was with the block loop devices
which was solved by adding a build-time configuration that the
distributions could use as they deem fit while keeping the default for
compatibility.

Let's do that here as well.

Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
---
Changes since v1:
    - The default number of devices is 2 not 3.

 drivers/net/Kconfig | 21 +++++++++++++++++----
 drivers/net/ifb.c   |  2 +-
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f184fb5..bb40d30 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -110,12 +110,25 @@ config IFB
 	  This is an intermediate driver that allows sharing of
 	  resources.
 	  To compile this driver as a module, choose M here: the module
-	  will be called ifb.  If you want to use more than one ifb
-	  device at a time, you need to compile this driver as a module.
-	  Instead of 'ifb', the devices will then be called 'ifb0',
-	  'ifb1' etc.
+	  will be called ifb.
+
 	  Look at the iproute2 documentation directory for usage etc
 
+config IFB_COUNT
+        int "Number of ifb devices to pre-create at init time"
+        depends on IFB
+        default 2
+        help
+          Static number of ifb devices to be unconditionally pre-created
+          at init time.
+
+          This default value can be overwritten on the kernel command
+          line or with module-parameter ifb.numifbs.
+
+          The historic default is 3. If a mid-2007 version of iproute2
+          is used (v2.6.23 or later), it can be set to 0, since needed
+          ifb devices can be dynamically allocated via rtnetlink.
+
 source "drivers/net/team/Kconfig"
 
 config MACVLAN
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index cc56fac..911af2c 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -298,7 +298,7 @@ static struct rtnl_link_ops ifb_link_ops __read_mostly = {
  * Note that these legacy devices have one queue.
  * Prefer something like : ip link add ifb10 numtxqueues 8 type ifb
  */
-static int numifbs = 2;
+static int numifbs = CONFIG_IFB_COUNT;
 module_param(numifbs, int, 0);
 MODULE_PARM_DESC(numifbs, "Number of ifb devices");
 
-- 
2.5.0
