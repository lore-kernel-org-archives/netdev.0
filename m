From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 03/15] wimax/i2400m: be smarter about copying command buffer to bm_cmd_buf
Date: Wed,  4 Nov 2009 13:39:44 -0800
Message-ID: <77e1251a7cc64c1e483a31c41c139fdf8121e75e.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20702 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932700AbZKDVl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:56 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because some underlying bus APIs (like USB) don't like data buffers in
the stack or vmalloced areas, the i2400m driver provides a scratch
buffer (i2400m->bm_cmd_buf) for said low-level drivers to copy command
data to before passing it to said API. This is only used during boot
mode.

However, at some the code was copying the buffer even when the command
was already specified in said buffer. This is ok, but it needs to be
more careful. As thus, change so that:

(a) the copy happens only if command buffer is not the scratch buffer

(b) use memmove() in case there is overlapping

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c      |    1 -
 drivers/net/wimax/i2400m/sdio-fw.c |    3 ++-
 drivers/net/wimax/i2400m/usb-fw.c  |    3 ++-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 55bd69e..0018cdb 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -343,7 +343,6 @@ ssize_t i2400m_bm_cmd(struct i2400m *i2400m,
 	BUG_ON(i2400m->boot_mode == 0);
 
 	if (cmd != NULL) {		/* send the command */
-		memcpy(i2400m->bm_cmd_buf, cmd, cmd_size);
 		result = i2400m->bus_bm_cmd_send(i2400m, cmd, cmd_size, flags);
 		if (result < 0)
 			goto error_cmd_send;
diff --git a/drivers/net/wimax/i2400m/sdio-fw.c b/drivers/net/wimax/i2400m/sdio-fw.c
index c8dc538..8e02541 100644
--- a/drivers/net/wimax/i2400m/sdio-fw.c
+++ b/drivers/net/wimax/i2400m/sdio-fw.c
@@ -118,7 +118,8 @@ ssize_t i2400ms_bus_bm_cmd_send(struct i2400m *i2400m,
 	if (cmd_size > I2400M_BM_CMD_BUF_SIZE)
 		goto error_too_big;
 
-	memcpy(i2400m->bm_cmd_buf, _cmd, cmd_size);	/* Prep command */
+	if (_cmd != i2400m->bm_cmd_buf)
+		memmove(i2400m->bm_cmd_buf, _cmd, cmd_size);
 	cmd = i2400m->bm_cmd_buf;
 	if (cmd_size_a > cmd_size)			/* Zero pad space */
 		memset(i2400m->bm_cmd_buf + cmd_size, 0, cmd_size_a - cmd_size);
diff --git a/drivers/net/wimax/i2400m/usb-fw.c b/drivers/net/wimax/i2400m/usb-fw.c
index a2250e4..f162c81 100644
--- a/drivers/net/wimax/i2400m/usb-fw.c
+++ b/drivers/net/wimax/i2400m/usb-fw.c
@@ -172,7 +172,8 @@ ssize_t i2400mu_bus_bm_cmd_send(struct i2400m *i2400m,
 	result = -E2BIG;
 	if (cmd_size > I2400M_BM_CMD_BUF_SIZE)
 		goto error_too_big;
-	memcpy(i2400m->bm_cmd_buf, _cmd, cmd_size);
+	if (_cmd != i2400m->bm_cmd_buf)
+		memmove(i2400m->bm_cmd_buf, _cmd, cmd_size);
 	cmd = i2400m->bm_cmd_buf;
 	if (cmd_size_a > cmd_size)			/* Zero pad space */
 		memset(i2400m->bm_cmd_buf + cmd_size, 0, cmd_size_a - cmd_size);
-- 
1.6.2.5

