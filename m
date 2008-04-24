From: frank.blaschka@de.ibm.com
Subject: [patch 04/11] qeth module size reduction.
Date: Thu, 24 Apr 2008 10:15:21 +0200
Message-ID: <20080424081904.171852000@de.ibm.com>
References: <20080424081517.987104000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Peter Tiedemann <ptiedem@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:11074 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbYDXITG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:19:06 -0400
Content-Disposition: inline; filename=703-qeth-dbf.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>

Replace complex macro for s390dbf calls by equivalent function. This reduces
module size about 10% without visible performance impact.

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |   18 ++----------------
 drivers/s390/net/qeth_core_main.c |   15 ++++++++++++---
 drivers/s390/net/qeth_l2_main.c   |    3 ---
 drivers/s390/net/qeth_l3.h        |    3 ---
 drivers/s390/net/qeth_l3_main.c   |    2 --
 5 files changed, 14 insertions(+), 27 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2008-04-23 17:52:28.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2008-04-23 17:55:50.000000000 +0200
@@ -72,22 +72,7 @@ struct qeth_dbf_info {
 	debug_sprintf_event(qeth_dbf[QETH_DBF_MSG].id, level, text)
 
 #define QETH_DBF_TEXT_(name, level, text...) \
-	do { \
-		if (qeth_dbf_passes(qeth_dbf[QETH_DBF_##name].id, level)) { \
-			char *dbf_txt_buf = \
-				get_cpu_var(QETH_DBF_TXT_BUF); \
-			sprintf(dbf_txt_buf, text); \
-			debug_text_event(qeth_dbf[QETH_DBF_##name].id, \
-					level, dbf_txt_buf); \
-			put_cpu_var(QETH_DBF_TXT_BUF); \
-		} \
-	} while (0)
-
-/* Allow to sort out low debug levels early to avoid wasted sprints */
-static inline int qeth_dbf_passes(debug_info_t *dbf_grp, int level)
-{
-	return (level <= dbf_grp->level);
-}
+	qeth_dbf_longtext(QETH_DBF_##name, level, text)
 
 /**
  * some more debug stuff
@@ -894,6 +879,7 @@ void qeth_core_get_ethtool_stats(struct 
 				struct ethtool_stats *, u64 *);
 void qeth_core_get_strings(struct net_device *, u32, u8 *);
 void qeth_core_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
+void qeth_dbf_longtext(enum qeth_dbf_names dbf_nix, int level, char *text, ...);
 
 /* exports for OSN */
 int qeth_osn_assist(struct net_device *, void *, int);
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2008-04-23 17:55:50.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2008-04-23 17:55:50.000000000 +0200
@@ -26,9 +26,6 @@
 #include "qeth_core.h"
 #include "qeth_core_offl.h"
 
-static DEFINE_PER_CPU(char[256], qeth_core_dbf_txt_buf);
-#define QETH_DBF_TXT_BUF qeth_core_dbf_txt_buf
-
 struct qeth_dbf_info qeth_dbf[QETH_DBF_INFOS] = {
 	/* define dbf - Name, Pages, Areas, Maxlen, Level, View, Handle */
 	/*                   N  P  A    M  L  V                      H  */
@@ -4067,6 +4064,18 @@ static void qeth_unregister_dbf_views(vo
 	}
 }
 
+void qeth_dbf_longtext(enum qeth_dbf_names dbf_nix, int level, char *text, ...)
+{
+	char dbf_txt_buf[32];
+
+	if (level > (qeth_dbf[dbf_nix].id)->level)
+		return;
+	snprintf(dbf_txt_buf, sizeof(dbf_txt_buf), text);
+	debug_text_event(qeth_dbf[dbf_nix].id, level, dbf_txt_buf);
+	
+}
+EXPORT_SYMBOL_GPL(qeth_dbf_longtext);
+
 static int qeth_register_dbf_views(void)
 {
 	int ret;
diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2008-04-23 17:52:28.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2008-04-23 17:55:50.000000000 +0200
@@ -22,9 +22,6 @@
 #include "qeth_core.h"
 #include "qeth_core_offl.h"
 
-#define QETH_DBF_TXT_BUF qeth_l2_dbf_txt_buf
-static DEFINE_PER_CPU(char[256], qeth_l2_dbf_txt_buf);
-
 static int qeth_l2_set_offline(struct ccwgroup_device *);
 static int qeth_l2_stop(struct net_device *);
 static int qeth_l2_send_delmac(struct qeth_card *, __u8 *);
diff -urpN linux-2.6/drivers/s390/net/qeth_l3.h linux-2.6-patched/drivers/s390/net/qeth_l3.h
--- linux-2.6/drivers/s390/net/qeth_l3.h	2008-04-23 17:52:28.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3.h	2008-04-23 17:55:50.000000000 +0200
@@ -13,9 +13,6 @@
 
 #include "qeth_core.h"
 
-#define QETH_DBF_TXT_BUF qeth_l3_dbf_txt_buf
-DECLARE_PER_CPU(char[256], qeth_l3_dbf_txt_buf);
-
 struct qeth_ipaddr {
 	struct list_head entry;
 	enum qeth_ip_types type;
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2008-04-23 17:52:28.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2008-04-23 17:55:50.000000000 +0200
@@ -28,8 +28,6 @@
 #include "qeth_l3.h"
 #include "qeth_core_offl.h"
 
-DEFINE_PER_CPU(char[256], qeth_l3_dbf_txt_buf);
-
 static int qeth_l3_set_offline(struct ccwgroup_device *);
 static int qeth_l3_recover(void *);
 static int qeth_l3_stop(struct net_device *);

-- 
