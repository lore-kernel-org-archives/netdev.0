From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH V2 net-next] liquidio: show NIC's U-Boot version in a
 dev_info() message
Date: Tue, 29 Aug 2017 12:19:57 -0700
Message-ID: <20170829191957.GA12243@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        weilin.chang@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0045.outbound.protection.outlook.com ([104.47.38.45]:46038
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751186AbdH2TTB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 15:19:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilin Chang <weilin.chang@cavium.com>

Signed-off-by: Weilin Chang <weilin.chang@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
Patch Change Log:
  V1 -> V2:
    * Move octeon_get_uboot_version() to a proper place to avoid forward
      declaration.
    * Remove complicated for-loops that search for substrings; replace them
      with calls to strstr().
    * Don't add unnecessary fields to struct octeon_device.

 .../net/ethernet/cavium/liquidio/octeon_console.c  | 78 ++++++++++++++++++++++
 1 file changed, 78 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 19e5212..ec3dd69 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -574,6 +574,82 @@ int octeon_init_consoles(struct octeon_device *oct)
 	return ret;
 }
 
+static void octeon_get_uboot_version(struct octeon_device *oct)
+{
+	s32 bytes_read, tries, total_read;
+	struct octeon_console *console;
+	u32 console_num = 0;
+	char *uboot_ver;
+	char *buf;
+	char *p;
+
+#define OCTEON_UBOOT_VER_BUF_SIZE 512
+	buf = kmalloc(OCTEON_UBOOT_VER_BUF_SIZE, GFP_KERNEL);
+	if (!buf)
+		return;
+
+	if (octeon_console_send_cmd(oct, "setenv stdout pci\n", 50)) {
+		kfree(buf);
+		return;
+	}
+
+	if (octeon_console_send_cmd(oct, "version\n", 1)) {
+		kfree(buf);
+		return;
+	}
+
+	console = &oct->console[console_num];
+	tries = 0;
+	total_read = 0;
+
+	do {
+		/* Take console output regardless of whether it will
+		 * be logged
+		 */
+		bytes_read =
+			octeon_console_read(oct,
+					    console_num, buf + total_read,
+					    OCTEON_UBOOT_VER_BUF_SIZE - 1 -
+					    total_read);
+		if (bytes_read > 0) {
+			buf[bytes_read] = '\0';
+
+			total_read += bytes_read;
+			if (console->waiting)
+				octeon_console_handle_result(oct, console_num);
+		} else if (bytes_read < 0) {
+			dev_err(&oct->pci_dev->dev, "Error reading console %u, ret=%d\n",
+				console_num, bytes_read);
+		}
+
+		tries++;
+	} while ((bytes_read > 0) && (tries < 16));
+
+	/* If nothing is read after polling the console,
+	 * output any leftovers if any
+	 */
+	if ((total_read == 0) && (console->leftover[0])) {
+		dev_dbg(&oct->pci_dev->dev, "%u: %s\n",
+			console_num, console->leftover);
+		console->leftover[0] = '\0';
+	}
+
+	buf[OCTEON_UBOOT_VER_BUF_SIZE - 1] = '\0';
+
+	uboot_ver = strstr(buf, "U-Boot");
+	if (uboot_ver) {
+		p = strstr(uboot_ver, "mips");
+		if (p) {
+			p--;
+			*p = '\0';
+			dev_info(&oct->pci_dev->dev, "%s\n", uboot_ver);
+		}
+	}
+
+	kfree(buf);
+	octeon_console_send_cmd(oct, "setenv stdout serial\n", 50);
+}
+
 int octeon_add_console(struct octeon_device *oct, u32 console_num,
 		       char *dbg_enb)
 {
@@ -611,6 +687,8 @@ int octeon_add_console(struct octeon_device *oct, u32 console_num,
 
 		work = &oct->console_poll_work[console_num].work;
 
+		octeon_get_uboot_version(oct);
+
 		INIT_DELAYED_WORK(work, check_console);
 		oct->console_poll_work[console_num].ctxptr = (void *)oct;
 		oct->console_poll_work[console_num].ctxul = console_num;
