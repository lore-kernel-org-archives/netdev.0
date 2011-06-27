From: Jon Mason <mason@myri.com>
Subject: [PATCH 5/9] myri10ge: add support for set_phys_id
Date: Mon, 27 Jun 2011 10:05:04 -0500
Message-ID: <1309187108-12715-5-git-send-email-mason@myri.com>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:63222 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468Ab1F0PFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 11:05:34 -0400
Received: by pvg12 with SMTP id 12so2905371pvg.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 08:05:34 -0700 (PDT)
In-Reply-To: <1309187108-12715-1-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add myri10ge driver support for the ethtool identify operation.
NOTE: Rather than blinking (which is the normal case), when identify is
used, the yellow LED turns solid.

Signed-off-by: Jon Mason <mason@myri.com>
---
 drivers/net/myri10ge/myri10ge.c                |   55 ++++++++++++++++++++++++
 drivers/net/myri10ge/myri10ge_mcp_gen_header.h |    2 +
 2 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 71461e5..83cbf2c 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1911,6 +1911,60 @@ static u32 myri10ge_get_msglevel(struct net_device *netdev)
 	return mgp->msg_enable;
 }
 
+/*
+ * Use a low-level command to change the LED behavior. Rather than
+ * blinking (which is the normal case), when identify is used, the
+ * yellow LED turns solid.
+ */
+static int myri10ge_led(struct myri10ge_priv *mgp, int on)
+{
+	struct mcp_gen_header *hdr;
+	struct device *dev = &mgp->pdev->dev;
+	size_t hdr_off, pattern_off, hdr_len;
+	u32 pattern = 0xfffffffe;
+
+	/* find running firmware header */
+	hdr_off = swab32(readl(mgp->sram + MCP_HEADER_PTR_OFFSET));
+	if ((hdr_off & 3) || hdr_off + sizeof(*hdr) > mgp->sram_size) {
+		dev_err(dev, "Running firmware has bad header offset (%d)\n",
+			(int)hdr_off);
+		return -EIO;
+	}
+	hdr_len = swab32(readl(mgp->sram + hdr_off +
+			       offsetof(struct mcp_gen_header, header_length)));
+	pattern_off = hdr_off + offsetof(struct mcp_gen_header, led_pattern);
+	if (pattern_off >= (hdr_len + hdr_off)) {
+		dev_info(dev, "Firmware does not support LED identification\n");
+		return -EINVAL;
+	}
+	if (!on)
+		pattern = swab32(readl(mgp->sram + pattern_off + 4));
+	writel(htonl(pattern), mgp->sram + pattern_off);
+	return 0;
+}
+
+static int
+myri10ge_phys_id(struct net_device *netdev, enum ethtool_phys_id_state state)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	int rc;
+
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		rc = myri10ge_led(mgp, 1);
+		break;
+
+	case ETHTOOL_ID_INACTIVE:
+		rc =  myri10ge_led(mgp, 0);
+		break;
+
+	default:
+		rc = -EINVAL;
+	}
+
+	return rc;
+}
+
 static const struct ethtool_ops myri10ge_ethtool_ops = {
 	.get_settings = myri10ge_get_settings,
 	.get_drvinfo = myri10ge_get_drvinfo,
@@ -1925,6 +1979,7 @@ static const struct ethtool_ops myri10ge_ethtool_ops = {
 	.get_ethtool_stats = myri10ge_get_ethtool_stats,
 	.set_msglevel = myri10ge_set_msglevel,
 	.get_msglevel = myri10ge_get_msglevel,
+	.set_phys_id = myri10ge_phys_id,
 };
 
 static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
diff --git a/drivers/net/myri10ge/myri10ge_mcp_gen_header.h b/drivers/net/myri10ge/myri10ge_mcp_gen_header.h
index 62a1cba..7ec4b86 100644
--- a/drivers/net/myri10ge/myri10ge_mcp_gen_header.h
+++ b/drivers/net/myri10ge/myri10ge_mcp_gen_header.h
@@ -45,6 +45,8 @@ struct mcp_gen_header {
 	unsigned bss_addr;	/* start of bss */
 	unsigned features;
 	unsigned ee_hdr_addr;
+	unsigned led_pattern;
+	unsigned led_pattern_dflt;
 	/* 8 */
 };
 
-- 
1.7.5.4

