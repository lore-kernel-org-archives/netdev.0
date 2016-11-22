From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH ethtool] ethtool: Fix the "advertise" parameter logic.
Date: Tue, 22 Nov 2016 18:55:47 -0500
Message-ID: <1479858947-25017-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:33217 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752218AbcKVXzz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 18:55:55 -0500
Received: by mail-pg0-f43.google.com with SMTP id 3so12611318pgd.0
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 15:55:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

The current code ignores the value of the advertise parameter.  For example,

ethtool -s ethx advertise 0x1000

The full_advertising_wanted parameter of 0x1000 is not passed to the kernel.
The reason is that advertising_wanted is NULL in this case, and ethtool
will think that the user has given no advertisement input and so it will
proceed to pass all supported advertisement speeds to the kernel.

The older legacy ethtool with similar logic worked because
advertising_wanted was an integer and could take on -1 and 0.  It would pass
the full_advertising_wanted value if advertising_wanted == -1.

This fix is to pass all supported advertisement speeds only when both
advertising_wanted == NULL && full_advertising_wanted == NULL.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ethtool.c b/ethtool.c
index 49ac94e..7715823 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2971,7 +2971,8 @@ static int do_sset(struct cmd_context *ctx)
 				fprintf(stderr,	"\n");
 			}
 			if (autoneg_wanted == AUTONEG_ENABLE &&
-			    advertising_wanted == NULL) {
+			    advertising_wanted == NULL &&
+			    full_advertising_wanted == NULL) {
 				unsigned int i;
 
 				/* Auto negotiation enabled, but with
-- 
1.8.4.5
