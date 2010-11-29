From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 5/5] firewire: net: ratelimit error messages
Date: Mon, 29 Nov 2010 04:09:53 +0200
Message-ID: <1290996593-32416-6-git-send-email-maximlevitsky@gmail.com>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: linux1394-devel <linux1394-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48670 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754112Ab0K2CKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 21:10:46 -0500
Received: by mail-bw0-f46.google.com with SMTP id 15so3474612bwz.19
        for <netdev@vger.kernel.org>; Sun, 28 Nov 2010 18:10:45 -0800 (PST)
In-Reply-To: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unfortunelly its easy to trigger such error messages
by removing the cable while sending streams of data
over the link.

Such errors are normal, and therefore this patch
stops firewire-net from flooding the kernel log
with these errors,
by combining series of same errors together.


Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/firewire/net.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index d422519..ac563d6 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -999,15 +999,23 @@ static void fwnet_transmit_packet_failed(struct fwnet_packet_task *ptask)
 static void fwnet_write_complete(struct fw_card *card, int rcode,
 				 void *payload, size_t length, void *data)
 {
-	struct fwnet_packet_task *ptask;
-
-	ptask = data;
+	struct fwnet_packet_task *ptask = data;
+	static unsigned long j;
+	static int last_rcode, errors_skipped;
 
 	if (rcode == RCODE_COMPLETE) {
 		fwnet_transmit_packet_done(ptask);
 	} else {
-		fw_error("fwnet_write_complete: failed: %x\n", rcode);
 		fwnet_transmit_packet_failed(ptask);
+
+		if (printk_timed_ratelimit(&j,  1000) || rcode != last_rcode) {
+			fw_error("fwnet_write_complete: "
+				"failed: %x (skipped %d)\n", rcode, errors_skipped);
+
+			errors_skipped = 0;
+			last_rcode = rcode;
+		} else
+			errors_skipped++;
 	}
 }
 
-- 
1.7.1

