From: Barry Grussling <barry@grussling.com>
Subject: [PATCH V2 2/4] DSA: Convert repeated msleep calls to timeouts
Date: Tue,  8 Jan 2013 18:05:54 -0800
Message-ID: <1357697156-5767-3-git-send-email-barry@grussling.com>
References: <1357697156-5767-1-git-send-email-barry@grussling.com>
Cc: Barry Grussling <barry@grussling.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:62086 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756723Ab3AICGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 21:06:16 -0500
Received: by mail-da0-f44.google.com with SMTP id z20so479840dae.31
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 18:06:15 -0800 (PST)
In-Reply-To: <1357697156-5767-1-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barry Grussling <barry@grussling.com>

Convert DSA msleep calls to timeout/usleep_range calls
as reported by checkpatch.pl.

Signed-off-by: Barry Grussling <barry@grussling.com>
---
 drivers/net/dsa/mv88e6060.c       |   12 ++++++++----
 drivers/net/dsa/mv88e6123_61_65.c |   12 ++++++++----
 drivers/net/dsa/mv88e6131.c       |   12 ++++++++----
 drivers/net/dsa/mv88e6xxx.c       |   16 ++++++++++------
 4 files changed, 34 insertions(+), 18 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 637373c..8548f8d 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -8,6 +8,8 @@
  * (at your option) any later version.
  */
 
+#include <linux/delay.h>
+#include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -66,6 +68,7 @@ static int mv88e6060_switch_reset(struct dsa_switch *ds)
 {
 	int i;
 	int ret;
+	unsigned long timeout;
 
 	/* Set all ports to the disabled state. */
 	for (i = 0; i < 6; i++) {
@@ -74,20 +77,21 @@ static int mv88e6060_switch_reset(struct dsa_switch *ds)
 	}
 
 	/* Wait for transmit queues to drain. */
-	msleep(2);
+	usleep_range(2000, 4000);
 
 	/* Reset the switch. */
 	REG_WRITE(REG_GLOBAL, 0x0a, 0xa130);
 
 	/* Wait up to one second for reset to complete. */
-	for (i = 0; i < 1000; i++) {
+	timeout = jiffies + 1 * HZ;
+	while (time_before(jiffies, timeout)) {
 		ret = REG_READ(REG_GLOBAL, 0x00);
 		if ((ret & 0x8000) == 0x0000)
 			break;
 
-		msleep(1);
+		usleep_range(1000, 2000);
 	}
-	if (i == 1000)
+	if (time_after(jiffies, timeout))
 		return -ETIMEDOUT;
 
 	return 0;
diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index a644fc9..41ee5b6 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -8,6 +8,8 @@
  * (at your option) any later version.
  */
 
+#include <linux/delay.h>
+#include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -50,6 +52,7 @@ static int mv88e6123_61_65_switch_reset(struct dsa_switch *ds)
 {
 	int i;
 	int ret;
+	unsigned long timeout;
 
 	/* Set all ports to the disabled state. */
 	for (i = 0; i < 8; i++) {
@@ -58,20 +61,21 @@ static int mv88e6123_61_65_switch_reset(struct dsa_switch *ds)
 	}
 
 	/* Wait for transmit queues to drain. */
-	msleep(2);
+	usleep_range(2000, 4000);
 
 	/* Reset the switch. */
 	REG_WRITE(REG_GLOBAL, 0x04, 0xc400);
 
 	/* Wait up to one second for reset to complete. */
-	for (i = 0; i < 1000; i++) {
+	timeout = jiffies + 1 * HZ;
+	while (time_before(jiffies, timeout)) {
 		ret = REG_READ(REG_GLOBAL, 0x00);
 		if ((ret & 0xc800) == 0xc800)
 			break;
 
-		msleep(1);
+		usleep_range(1000, 2000);
 	}
-	if (i == 1000)
+	if (time_after(jiffies, timeout))
 		return -ETIMEDOUT;
 
 	return 0;
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index b613818..dadfafb 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -8,6 +8,8 @@
  * (at your option) any later version.
  */
 
+#include <linux/delay.h>
+#include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -42,6 +44,7 @@ static int mv88e6131_switch_reset(struct dsa_switch *ds)
 {
 	int i;
 	int ret;
+	unsigned long timeout;
 
 	/* Set all ports to the disabled state. */
 	for (i = 0; i < 11; i++) {
@@ -50,20 +53,21 @@ static int mv88e6131_switch_reset(struct dsa_switch *ds)
 	}
 
 	/* Wait for transmit queues to drain. */
-	msleep(2);
+	usleep_range(2000, 4000);
 
 	/* Reset the switch. */
 	REG_WRITE(REG_GLOBAL, 0x04, 0xc400);
 
 	/* Wait up to one second for reset to complete. */
-	for (i = 0; i < 1000; i++) {
+	timeout = jiffies + 1 * HZ;
+	while (time_before(jiffies, timeout)) {
 		ret = REG_READ(REG_GLOBAL, 0x00);
 		if ((ret & 0xc800) == 0xc800)
 			break;
 
-		msleep(1);
+		usleep_range(1000, 2000);
 	}
-	if (i == 1000)
+	if (time_after(jiffies, timeout))
 		return -ETIMEDOUT;
 
 	return 0;
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index d436668..afe7d80 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -8,6 +8,8 @@
  * (at your option) any later version.
  */
 
+#include <linux/delay.h>
+#include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -196,14 +198,15 @@ int mv88e6xxx_phy_write(struct dsa_switch *ds, int addr, int regnum, u16 val)
 static int mv88e6xxx_ppu_disable(struct dsa_switch *ds)
 {
 	int ret;
-	int i;
+	unsigned long timeout;
 
 	ret = REG_READ(REG_GLOBAL, 0x04);
 	REG_WRITE(REG_GLOBAL, 0x04, ret & ~0x4000);
 
-	for (i = 0; i < 1000; i++) {
+	timeout = jiffies + 1 * HZ;
+	while (time_before(jiffies, timeout)) {
 	        ret = REG_READ(REG_GLOBAL, 0x00);
-	        msleep(1);
+		usleep_range(1000, 2000);
 	        if ((ret & 0xc000) != 0xc000)
 	                return 0;
 	}
@@ -214,14 +217,15 @@ static int mv88e6xxx_ppu_disable(struct dsa_switch *ds)
 static int mv88e6xxx_ppu_enable(struct dsa_switch *ds)
 {
 	int ret;
-	int i;
+	unsigned long timeout;
 
 	ret = REG_READ(REG_GLOBAL, 0x04);
 	REG_WRITE(REG_GLOBAL, 0x04, ret | 0x4000);
 
-	for (i = 0; i < 1000; i++) {
+	timeout = jiffies + 1 * HZ;
+	while (time_before(jiffies, timeout)) {
 	        ret = REG_READ(REG_GLOBAL, 0x00);
-	        msleep(1);
+		usleep_range(1000, 2000);
 	        if ((ret & 0xc000) == 0xc000)
 	                return 0;
 	}
-- 
1.7.9.5
