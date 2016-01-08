From: tim.gardner@canonical.com
Subject: [PATCH v4.4-rc8 5/7] isdn: eicon: divasfunc: Silence frame size warning
Date: Fri,  8 Jan 2016 05:32:53 -0700
Message-ID: <1452256375-24223-6-git-send-email-tim.gardner@canonical.com>
References: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner@canonical.com>
To: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Gardner <tim.gardner@canonical.com>

drivers/isdn/hardware/eicon/divasfunc.c: In function 'connect_didd':
drivers/isdn/hardware/eicon/divasfunc.c:192:1: warning: the frame size of 1152 bytes is larger than 1024 bytes [-Wframe-larger-than=]

gcc version 5.3.1 20151219 (Ubuntu 5.3.1-4ubuntu1)

Cc: Armin Schindler <mac@melware.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/isdn/hardware/eicon/divasfunc.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/divasfunc.c b/drivers/isdn/hardware/eicon/divasfunc.c
index 4be5f88..ac4c04a 100644
--- a/drivers/isdn/hardware/eicon/divasfunc.c
+++ b/drivers/isdn/hardware/eicon/divasfunc.c
@@ -158,10 +158,13 @@ static int __init connect_didd(void)
 	int x = 0;
 	int dadapter = 0;
 	IDI_SYNC_REQ req;
-	DESCRIPTOR DIDD_Table[MAX_DESCRIPTORS];
+	DESCRIPTOR *DIDD_Table;
 
-	DIVA_DIDD_Read(DIDD_Table, sizeof(DIDD_Table));
+	DIDD_Table = kcalloc(MAX_DESCRIPTORS, sizeof(*DIDD_Table), GFP_KERNEL);
+	if (!DIDD_Table)
+		goto out;
 
+	DIVA_DIDD_Read(DIDD_Table, MAX_DESCRIPTORS * sizeof(*DIDD_Table));
 	for (x = 0; x < MAX_DESCRIPTORS; x++) {
 		if (DIDD_Table[x].type == IDI_DADAPTER) {	/* DADAPTER found */
 			dadapter = 1;
@@ -174,7 +177,8 @@ static int __init connect_didd(void)
 			DAdapter.request((ENTITY *)&req);
 			if (req.didd_notify.e.Rc != 0xff) {
 				stop_dbg();
-				return (0);
+				dadapter = 0;
+				goto out;
 			}
 			notify_handle = req.didd_notify.info.handle;
 		} else if (DIDD_Table[x].type == IDI_DIMAINT) {	/* MAINT found */
@@ -188,6 +192,8 @@ static int __init connect_didd(void)
 		stop_dbg();
 	}
 
+out:
+	kfree(DIDD_Table);
 	return (dadapter);
 }
 
-- 
1.9.1
