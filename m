From: tim.gardner@canonical.com
Subject: [PATCH v4.4-rc8 7/7] isdn: eicon: consolidate descriptor allocation
Date: Fri,  8 Jan 2016 05:32:55 -0700
Message-ID: <1452256375-24223-8-git-send-email-tim.gardner@canonical.com>
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

Collapse multiple instances of open coded descriptor allocation
and initialization into di_alloc_descriptors(). Also clean
up the various DIVA_DIDD_Read() prototypes.

Cc: Armin Schindler <mac@melware.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/isdn/hardware/eicon/capifunc.c  |  6 +-----
 drivers/isdn/hardware/eicon/di_defs.h   | 13 +++++++++++++
 drivers/isdn/hardware/eicon/diddfunc.c  |  5 +----
 drivers/isdn/hardware/eicon/diva_didd.c |  2 --
 drivers/isdn/hardware/eicon/divasfunc.c |  5 +----
 drivers/isdn/hardware/eicon/idifunc.c   |  5 +----
 drivers/isdn/hardware/eicon/mntfunc.c   |  6 +-----
 7 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/capifunc.c b/drivers/isdn/hardware/eicon/capifunc.c
index 5fb441f..427095a 100644
--- a/drivers/isdn/hardware/eicon/capifunc.c
+++ b/drivers/isdn/hardware/eicon/capifunc.c
@@ -57,8 +57,6 @@ static u16 diva_send_message(struct capi_ctr *,
 			     diva_os_message_buffer_s *);
 extern void diva_os_set_controller_struct(struct capi_ctr *);
 
-extern void DIVA_DIDD_Read(DESCRIPTOR *, int);
-
 /*
  * debug
  */
@@ -1055,12 +1053,10 @@ static int divacapi_connect_didd(void)
 	IDI_SYNC_REQ req;
 	DESCRIPTOR *DIDD_Table;
 
-	DIDD_Table = kcalloc(MAX_DESCRIPTORS, sizeof(*DIDD_Table), GFP_KERNEL);
+	DIDD_Table = di_alloc_descriptors();
 	if (!DIDD_Table)
 		goto out;
 
-	DIVA_DIDD_Read(DIDD_Table, MAX_DESCRIPTORS * sizeof(*DIDD_Table));
-
 	for (x = 0; x < MAX_DESCRIPTORS; x++) {
 		if (DIDD_Table[x].type == IDI_DIMAINT) {	/* MAINT found */
 			memcpy(&MAdapter, &DIDD_Table[x], sizeof(DAdapter));
diff --git a/drivers/isdn/hardware/eicon/di_defs.h b/drivers/isdn/hardware/eicon/di_defs.h
index a5094d2..032bc80 100644
--- a/drivers/isdn/hardware/eicon/di_defs.h
+++ b/drivers/isdn/hardware/eicon/di_defs.h
@@ -103,6 +103,19 @@ typedef struct {
 	word                  features;
 	IDI_CALL              request;
 } DESCRIPTOR;
+
+extern void DIVA_DIDD_Read(void *, int);
+
+static inline DESCRIPTOR *di_alloc_descriptors(void)
+{
+	size_t len = MAX_DESCRIPTORS * sizeof(DESCRIPTOR);
+	DESCRIPTOR *d = kmalloc(len, GFP_KERNEL);
+
+	if (d)
+		DIVA_DIDD_Read(d, len);
+	return d;
+}
+
 /* descriptor type field coding */
 #define IDI_ADAPTER_S           1
 #define IDI_ADAPTER_PR          2
diff --git a/drivers/isdn/hardware/eicon/diddfunc.c b/drivers/isdn/hardware/eicon/diddfunc.c
index a9feb4f..cbf8930 100644
--- a/drivers/isdn/hardware/eicon/diddfunc.c
+++ b/drivers/isdn/hardware/eicon/diddfunc.c
@@ -20,7 +20,6 @@
 #define DBG_DEFAULT  (DBG_MINIMUM + DL_XLOG + DL_REG)
 
 
-extern void DIVA_DIDD_Read(void *, int);
 extern char *DRIVERRELEASE_DIDD;
 static dword notify_handle;
 static DESCRIPTOR _DAdapter;
@@ -54,12 +53,10 @@ static int __init connect_didd(void)
 	IDI_SYNC_REQ req;
 	DESCRIPTOR *DIDD_Table;
 
-	DIDD_Table = kcalloc(MAX_DESCRIPTORS, sizeof(*DIDD_Table), GFP_KERNEL);
+	DIDD_Table = di_alloc_descriptors();
 	if (!DIDD_Table)
 		goto out;
 
-	DIVA_DIDD_Read(DIDD_Table, MAX_DESCRIPTORS * sizeof(*DIDD_Table));
-
 	for (x = 0; x < MAX_DESCRIPTORS; x++) {
 		if (DIDD_Table[x].type == IDI_DADAPTER) {	/* DADAPTER found */
 			dadapter = 1;
diff --git a/drivers/isdn/hardware/eicon/diva_didd.c b/drivers/isdn/hardware/eicon/diva_didd.c
index fab6ccf..3f2f8e0 100644
--- a/drivers/isdn/hardware/eicon/diva_didd.c
+++ b/drivers/isdn/hardware/eicon/diva_didd.c
@@ -42,8 +42,6 @@ MODULE_LICENSE("GPL");
 extern int diddfunc_init(void);
 extern void diddfunc_finit(void);
 
-extern void DIVA_DIDD_Read(void *, int);
-
 static struct proc_dir_entry *proc_didd;
 struct proc_dir_entry *proc_net_eicon = NULL;
 
diff --git a/drivers/isdn/hardware/eicon/divasfunc.c b/drivers/isdn/hardware/eicon/divasfunc.c
index ac4c04a..633a9d6 100644
--- a/drivers/isdn/hardware/eicon/divasfunc.c
+++ b/drivers/isdn/hardware/eicon/divasfunc.c
@@ -23,8 +23,6 @@
 
 static int debugmask;
 
-extern void DIVA_DIDD_Read(void *, int);
-
 extern PISDN_ADAPTER IoAdapters[MAX_ADAPTER];
 
 extern char *DRIVERRELEASE_DIVAS;
@@ -160,11 +158,10 @@ static int __init connect_didd(void)
 	IDI_SYNC_REQ req;
 	DESCRIPTOR *DIDD_Table;
 
-	DIDD_Table = kcalloc(MAX_DESCRIPTORS, sizeof(*DIDD_Table), GFP_KERNEL);
+	DIDD_Table = di_alloc_descriptors();
 	if (!DIDD_Table)
 		goto out;
 
-	DIVA_DIDD_Read(DIDD_Table, MAX_DESCRIPTORS * sizeof(*DIDD_Table));
 	for (x = 0; x < MAX_DESCRIPTORS; x++) {
 		if (DIDD_Table[x].type == IDI_DADAPTER) {	/* DADAPTER found */
 			dadapter = 1;
diff --git a/drivers/isdn/hardware/eicon/idifunc.c b/drivers/isdn/hardware/eicon/idifunc.c
index e7ca4bc..61763df 100644
--- a/drivers/isdn/hardware/eicon/idifunc.c
+++ b/drivers/isdn/hardware/eicon/idifunc.c
@@ -21,7 +21,6 @@
 
 extern char *DRIVERRELEASE_IDI;
 
-extern void DIVA_DIDD_Read(void *, int);
 extern int diva_user_mode_idi_create_adapter(const DESCRIPTOR *, int);
 extern void diva_user_mode_idi_remove_adapter(int);
 
@@ -188,12 +187,10 @@ static int __init connect_didd(void)
 	IDI_SYNC_REQ req;
 	DESCRIPTOR *DIDD_Table;
 
-	DIDD_Table = kcalloc(MAX_DESCRIPTORS, sizeof(*DIDD_Table), GFP_KERNEL);
+	DIDD_Table = di_alloc_descriptors();
 	if (!DIDD_Table)
 		goto out;
 
-	DIVA_DIDD_Read(DIDD_Table, MAX_DESCRIPTORS * sizeof(*DIDD_Table));
-
 	for (x = 0; x < MAX_DESCRIPTORS; x++) {
 		if (DIDD_Table[x].type == IDI_DADAPTER) {	/* DADAPTER found */
 			dadapter = 1;
diff --git a/drivers/isdn/hardware/eicon/mntfunc.c b/drivers/isdn/hardware/eicon/mntfunc.c
index 4c25f30..5305458 100644
--- a/drivers/isdn/hardware/eicon/mntfunc.c
+++ b/drivers/isdn/hardware/eicon/mntfunc.c
@@ -21,8 +21,6 @@ extern char *DRIVERRELEASE_MNT;
 #define DBG_MINIMUM  (DL_LOG + DL_FTL + DL_ERR)
 #define DBG_DEFAULT  (DBG_MINIMUM + DL_XLOG + DL_REG)
 
-extern void DIVA_DIDD_Read(void *, int);
-
 static dword notify_handle;
 static DESCRIPTOR DAdapter;
 static DESCRIPTOR MAdapter;
@@ -79,12 +77,10 @@ static int __init connect_didd(void)
 	IDI_SYNC_REQ req;
 	DESCRIPTOR *DIDD_Table;
 
-	DIDD_Table = kcalloc(MAX_DESCRIPTORS, sizeof(*DIDD_Table), GFP_KERNEL);
+	DIDD_Table = di_alloc_descriptors();
 	if (!DIDD_Table)
 		goto out;
 
-	DIVA_DIDD_Read(DIDD_Table, MAX_DESCRIPTORS * sizeof(*DIDD_Table));
-
 	for (x = 0; x < MAX_DESCRIPTORS; x++) {
 		if (DIDD_Table[x].type == IDI_DADAPTER) {	/* DADAPTER found */
 			dadapter = 1;
-- 
1.9.1
