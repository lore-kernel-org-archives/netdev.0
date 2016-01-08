From: tim.gardner@canonical.com
Subject: [PATCH v4.4-rc8 6/7] isdn: eicon: diddfunc: Silence frame size warning
Date: Fri,  8 Jan 2016 05:32:54 -0700
Message-ID: <1452256375-24223-7-git-send-email-tim.gardner@canonical.com>
References: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner@canonical.com>
To: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35654 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754977AbcAHMdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 07:33:46 -0500
Received: by mail-pa0-f53.google.com with SMTP id ho8so21070903pac.2
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 04:33:46 -0800 (PST)
In-Reply-To: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Gardner <tim.gardner@canonical.com>

drivers/isdn/hardware/eicon/diddfunc.c: In function 'connect_didd':
drivers/isdn/hardware/eicon/diddfunc.c:77:1: warning: the frame size of 1152 bytes is larger than 1024 bytes [-Wframe-larger-than=]

gcc version 5.3.1 20151219 (Ubuntu 5.3.1-4ubuntu1)

Cc: Armin Schindler <mac@melware.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/isdn/hardware/eicon/diddfunc.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/diddfunc.c b/drivers/isdn/hardware/eicon/diddfunc.c
index b0b23ed..a9feb4f 100644
--- a/drivers/isdn/hardware/eicon/diddfunc.c
+++ b/drivers/isdn/hardware/eicon/diddfunc.c
@@ -52,9 +52,13 @@ static int __init connect_didd(void)
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
 		if (DIDD_Table[x].type == IDI_DADAPTER) {	/* DADAPTER found */
@@ -66,13 +70,18 @@ static int __init connect_didd(void)
 			req.didd_notify.info.callback = (void *)didd_callback;
 			req.didd_notify.info.context = NULL;
 			_DAdapter.request((ENTITY *)&req);
-			if (req.didd_notify.e.Rc != 0xff)
-				return (0);
+			if (req.didd_notify.e.Rc != 0xff) {
+				dadapter = 0;
+				goto out;
+			}
 			notify_handle = req.didd_notify.info.handle;
 		} else if (DIDD_Table[x].type == IDI_DIMAINT) {	/* MAINT found */
 			DbgRegister("DIDD", DRIVERRELEASE_DIDD, DBG_DEFAULT);
 		}
 	}
+
+out:
+	kfree(DIDD_Table);
 	return (dadapter);
 }
 
-- 
1.9.1
