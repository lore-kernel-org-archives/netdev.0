From: tim.gardner@canonical.com
Subject: [PATCH v4.4-rc8 3/7] isdn: eicon: idifunc: Silence frame size warning
Date: Fri,  8 Jan 2016 05:32:51 -0700
Message-ID: <1452256375-24223-4-git-send-email-tim.gardner@canonical.com>
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

drivers/isdn/hardware/eicon/idifunc.c: In function 'connect_didd':
drivers/isdn/hardware/eicon/idifunc.c:223:1: warning: the frame size of 1152 bytes is larger than 1024 bytes [-Wframe-larger-than=]

gcc version 5.3.1 20151219 (Ubuntu 5.3.1-4ubuntu1)

Cc: Armin Schindler <mac@melware.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/isdn/hardware/eicon/idifunc.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/idifunc.c b/drivers/isdn/hardware/eicon/idifunc.c
index fef6586..e7ca4bc 100644
--- a/drivers/isdn/hardware/eicon/idifunc.c
+++ b/drivers/isdn/hardware/eicon/idifunc.c
@@ -186,9 +186,13 @@ static int __init connect_didd(void)
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
@@ -202,7 +206,8 @@ static int __init connect_didd(void)
 			DAdapter.request((ENTITY *)&req);
 			if (req.didd_notify.e.Rc != 0xff) {
 				stop_dbg();
-				return (0);
+				dadapter = 0;
+				goto out;
 			}
 			notify_handle = req.didd_notify.info.handle;
 		} else if (DIDD_Table[x].type == IDI_DIMAINT) {	/* MAINT found */
@@ -219,6 +224,8 @@ static int __init connect_didd(void)
 		stop_dbg();
 	}
 
+out:
+	kfree(DIDD_Table);
 	return (dadapter);
 }
 
-- 
1.9.1
