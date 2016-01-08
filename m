From: tim.gardner@canonical.com
Subject: [PATCH v4.4-rc8 2/7] isdn: eicon: capifunc: Silence frame size warning
Date: Fri,  8 Jan 2016 05:32:50 -0700
Message-ID: <1452256375-24223-3-git-send-email-tim.gardner@canonical.com>
References: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner@canonical.com>
To: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35571 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754842AbcAHMdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 07:33:35 -0500
Received: by mail-pa0-f51.google.com with SMTP id ho8so21068578pac.2
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 04:33:34 -0800 (PST)
In-Reply-To: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Gardner <tim.gardner@canonical.com>

drivers/isdn/hardware/eicon/capifunc.c: In function 'divacapi_connect_didd':
drivers/isdn/hardware/eicon/capifunc.c:1094:1: warning: the frame size of 1152 bytes is larger than 1024 bytes [-Wframe-larger-than=]

gcc version 5.3.1 20151219 (Ubuntu 5.3.1-4ubuntu1)

Cc: Armin Schindler <mac@melware.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/isdn/hardware/eicon/capifunc.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/capifunc.c b/drivers/isdn/hardware/eicon/capifunc.c
index 7a0bdbd..5fb441f 100644
--- a/drivers/isdn/hardware/eicon/capifunc.c
+++ b/drivers/isdn/hardware/eicon/capifunc.c
@@ -1053,9 +1053,13 @@ static int divacapi_connect_didd(void)
 	int x = 0;
 	int dadapter = 0;
 	IDI_SYNC_REQ req;
-	DESCRIPTOR DIDD_Table[MAX_DESCRIPTORS];
+	DESCRIPTOR *DIDD_Table;
 
-	DIVA_DIDD_Read(DIDD_Table, sizeof(DIDD_Table));
+	DIDD_Table = kcalloc(MAX_DESCRIPTORS, sizeof(*DIDD_Table), GFP_KERNEL);
+	if (!DIDD_Table)
+		goto out;
+
+	DIVA_DIDD_Read(DIDD_Table, MAX_DESCRIPTORS * sizeof(*DIDD_Table));
 
 	for (x = 0; x < MAX_DESCRIPTORS; x++) {
 		if (DIDD_Table[x].type == IDI_DIMAINT) {	/* MAINT found */
@@ -1077,7 +1081,8 @@ static int divacapi_connect_didd(void)
 			DAdapter.request((ENTITY *)&req);
 			if (req.didd_notify.e.Rc != 0xff) {
 				stop_dbg();
-				return (0);
+				dadapter = 0;
+				goto out;
 			}
 			notify_handle = req.didd_notify.info.handle;
 		}
@@ -1090,6 +1095,8 @@ static int divacapi_connect_didd(void)
 		stop_dbg();
 	}
 
+out:
+	kfree(DIDD_Table);
 	return (dadapter);
 }
 
-- 
1.9.1
