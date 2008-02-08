From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 5/5] claw/lcs/netiucv: check s390dbf level before sprints
Date: Fri, 08 Feb 2008 13:09:05 +0100
Message-ID: <20080208121515.181990000@linux.vnet.ibm.com>
References: <20080208120900.295604000@linux.vnet.ibm.com>
Cc: Peter Tiedemann <ptiedem@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:40356 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760196AbYBHMPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 07:15:18 -0500
Content-Disposition: inline; filename=765-dbf-macros.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>

additional check of s390dbf level results in better performance
if the default low debugging level is active.

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/claw.h    |   17 +++++++++++++----
 drivers/s390/net/lcs.h     |   16 ++++++++++++----
 drivers/s390/net/netiucv.c |   22 ++++++++++++++++------
 3 files changed, 41 insertions(+), 14 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/claw.h
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/claw.h
+++ linux-2.6-uschi/drivers/s390/net/claw.h
@@ -114,11 +114,20 @@ do { \
 	debug_event(claw_dbf_##name,level,(void*)(addr),len); \
 } while (0)
 
+/* Allow to sort out low debug levels early to avoid wasted sprints */
+static inline int claw_dbf_passes(debug_info_t *dbf_grp, int level)
+{
+	return (level <= dbf_grp->level);
+}
+
 #define CLAW_DBF_TEXT_(level,name,text...) \
-do {                                       \
-	sprintf(debug_buffer, text);  \
-		debug_text_event(claw_dbf_##name,level, debug_buffer);\
-} while (0)
+	do { \
+		if (claw_dbf_passes(claw_dbf_##name, level)) { \
+			sprintf(debug_buffer, text); \
+			debug_text_event(claw_dbf_##name, level, \
+						debug_buffer); \
+		} \
+	} while (0)
 
 /*******************************************************
 *  Define Control Blocks                               *
Index: linux-2.6-uschi/drivers/s390/net/lcs.h
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/lcs.h
+++ linux-2.6-uschi/drivers/s390/net/lcs.h
@@ -16,11 +16,19 @@ do { \
 	debug_event(lcs_dbf_##name,level,(void*)(addr),len); \
 } while (0)
 
+/* Allow to sort out low debug levels early to avoid wasted sprints */
+static inline int lcs_dbf_passes(debug_info_t *dbf_grp, int level)
+{
+	return (level <= dbf_grp->level);
+}
+
 #define LCS_DBF_TEXT_(level,name,text...) \
-do {                                       \
-	sprintf(debug_buffer, text);  \
-		debug_text_event(lcs_dbf_##name,level, debug_buffer);\
-} while (0)
+	do { \
+		if (lcs_dbf_passes(lcs_dbf_##name, level)) { \
+			sprintf(debug_buffer, text); \
+			debug_text_event(lcs_dbf_##name, level, debug_buffer); \
+		} \
+	} while (0)
 
 /**
  *	sysfs related stuff
Index: linux-2.6-uschi/drivers/s390/net/netiucv.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/netiucv.c
+++ linux-2.6-uschi/drivers/s390/net/netiucv.c
@@ -97,12 +97,22 @@ MODULE_DESCRIPTION ("Linux for S/390 IUC
 
 DECLARE_PER_CPU(char[256], iucv_dbf_txt_buf);
 
-#define IUCV_DBF_TEXT_(name,level,text...)				\
-	do {								\
-		char* iucv_dbf_txt_buf = get_cpu_var(iucv_dbf_txt_buf);	\
-		sprintf(iucv_dbf_txt_buf, text);			\
-		debug_text_event(iucv_dbf_##name,level,iucv_dbf_txt_buf); \
-		put_cpu_var(iucv_dbf_txt_buf);				\
+/* Allow to sort out low debug levels early to avoid wasted sprints */
+static inline int iucv_dbf_passes(debug_info_t *dbf_grp, int level)
+{
+	return (level <= dbf_grp->level);
+}
+
+#define IUCV_DBF_TEXT_(name, level, text...) \
+	do { \
+		if (iucv_dbf_passes(iucv_dbf_##name, level)) { \
+			char* iucv_dbf_txt_buf = \
+					get_cpu_var(iucv_dbf_txt_buf); \
+			sprintf(iucv_dbf_txt_buf, text); \
+			debug_text_event(iucv_dbf_##name, level, \
+						iucv_dbf_txt_buf); \
+			put_cpu_var(iucv_dbf_txt_buf); \
+		} \
 	} while (0)
 
 #define IUCV_DBF_SPRINTF(name,level,text...) \

-- 
