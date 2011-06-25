From: Barry Grussling <barry@grussling.com>
Subject: [PATCH V3 1/1] DSA: Enable cascading in multi-chip 6131 configuration
Date: Fri, 24 Jun 2011 22:53:51 -0700
Message-ID: <1308981231-2561-1-git-send-email-barry@grussling.com>
Cc: buytenh@wantstofly.org, Barry Grussling <barry@grussling.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:64274 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab1FYFyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 01:54:04 -0400
Received: by pvg12 with SMTP id 12so2070195pvg.19
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 22:54:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barry Grussling <barry@grussling.com>

This patch enables the 6131 family of chips to forward DSA
packets to other switch chips.  This is needed if multiple
DSA chips are used in a device.  Without this patch the
chip will drop any DSA packets not destined for it.

This patch only enables the forwarding of DSA packets if
multiple chips are used in the switch configuration.

Signed-off-by: Barry Grussling <barry@grussling.com>

---

diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
index 45f7411..9bd1061 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -118,10 +118,14 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	REG_WRITE(REG_GLOBAL, 0x1a, (dsa_upstream_port(ds) * 0x1100) | 0x00f0);
 
 	/*
-	 * Disable cascade port functionality, and set the switch's
+	 * Disable cascade port functionality unless this device
+	 * is used in a cascade configuration, and set the switch's
 	 * DSA device number.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x1c, 0xe000 | (ds->index & 0x1f));
+	if (ds->dst->pd->nr_chips > 1)
+		REG_WRITE(REG_GLOBAL, 0x1c, 0xf000 | (ds->index & 0x1f));
+	else
+		REG_WRITE(REG_GLOBAL, 0x1c, 0xe000 | (ds->index & 0x1f));
 
 	/*
 	 * Send all frames with destination addresses matching
-- 
1.7.4.1

