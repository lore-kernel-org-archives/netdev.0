From: tim.gardner@canonical.com
Subject: [PATCH v4.4-rc8 4/7] isdn: eicon: mntfunc: Silence frame size warning
Date: Fri,  8 Jan 2016 05:32:52 -0700
Message-ID: <1452256375-24223-5-git-send-email-tim.gardner@canonical.com>
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

drivers/isdn/hardware/eicon/mntfunc.c: In function 'connect_didd':
drivers/isdn/hardware/eicon/mntfunc.c:112:1: warning: the frame size of 1152 bytes is larger than 1024 bytes [-Wframe-larger-than=]

gcc version 5.3.1 20151219 (Ubuntu 5.3.1-4ubuntu1)

Cc: Armin Schindler <mac@melware.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/isdn/hardware/eicon/mntfunc.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/mntfunc.c b/drivers/isdn/hardware/eicon/mntfunc.c
index 1cd9aff..4c25f30 100644
--- a/drivers/isdn/hardware/eicon/mntfunc.c
+++ b/drivers/isdn/hardware/eicon/mntfunc.c
@@ -77,9 +77,13 @@ static int __init connect_didd(void)
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
@@ -91,8 +95,10 @@ static int __init connect_didd(void)
 			req.didd_notify.info.callback = (void *)didd_callback;
 			req.didd_notify.info.context = NULL;
 			DAdapter.request((ENTITY *)&req);
-			if (req.didd_notify.e.Rc != 0xff)
-				return (0);
+			if (req.didd_notify.e.Rc != 0xff) {
+				dadapter = 0;
+				goto out;
+			}
 			notify_handle = req.didd_notify.info.handle;
 			/* Register MAINT (me) */
 			req.didd_add_adapter.e.Req = 0;
@@ -101,13 +107,18 @@ static int __init connect_didd(void)
 			req.didd_add_adapter.info.descriptor =
 				(void *) &MaintDescriptor;
 			DAdapter.request((ENTITY *)&req);
-			if (req.didd_add_adapter.e.Rc != 0xff)
-				return (0);
+			if (req.didd_add_adapter.e.Rc != 0xff) {
+				dadapter = 0;
+				goto out;
+			}
 		} else if ((DIDD_Table[x].type > 0)
 			   && (DIDD_Table[x].type < 16)) {
 			diva_mnt_add_xdi_adapter(&DIDD_Table[x]);
 		}
 	}
+
+out:
+	kfree(DIDD_Table);
 	return (dadapter);
 }
 
-- 
1.9.1
