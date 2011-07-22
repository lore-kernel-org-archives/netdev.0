From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 10/10] bna: Header File Consolidation
Date: Fri, 22 Jul 2011 11:07:49 -0700
Message-ID: <1311358069-32067-11-git-send-email-rmody@brocade.com>
References: <1311358069-32067-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37636 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754575Ab1GVSIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 14:08:53 -0400
In-Reply-To: <1311358069-32067-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Consolidated bfa_sm.h and bfa_wc.h into bfa_cs.h

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_cs.h   |  140 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/bna/bfa_ioc.h  |    2 +-
 drivers/net/bna/bfa_sm.h   |   88 ---------------------------
 drivers/net/bna/bfa_wc.h   |   69 ----------------------
 drivers/net/bna/bna.h      |    2 +-
 drivers/net/bna/bna_ctrl.c |    3 +-
 drivers/net/bna/bna_txrx.c |    2 +-
 7 files changed, 144 insertions(+), 162 deletions(-)
 create mode 100644 drivers/net/bna/bfa_cs.h
 delete mode 100644 drivers/net/bna/bfa_sm.h
 delete mode 100644 drivers/net/bna/bfa_wc.h

diff --git a/drivers/net/bna/bfa_cs.h b/drivers/net/bna/bfa_cs.h
new file mode 100644
index 0000000..3da1a94
--- /dev/null
+++ b/drivers/net/bna/bfa_cs.h
@@ -0,0 +1,140 @@
+/*
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ */
+
+/**
+ * @file bfa_cs.h BFA common services
+ */
+
+#ifndef __BFA_CS_H__
+#define __BFA_CS_H__
+
+#include "cna.h"
+
+/**
+ * @ BFA state machine interfaces
+ */
+
+typedef void (*bfa_sm_t)(void *sm, int event);
+
+/**
+ * oc - object class eg. bfa_ioc
+ * st - state, eg. reset
+ * otype - object type, eg. struct bfa_ioc
+ * etype - object type, eg. enum ioc_event
+ */
+#define bfa_sm_state_decl(oc, st, otype, etype)			\
+	static void oc ## _sm_ ## st(otype * fsm, etype event)
+
+#define bfa_sm_set_state(_sm, _state)	((_sm)->sm = (bfa_sm_t)(_state))
+#define bfa_sm_send_event(_sm, _event)	((_sm)->sm((_sm), (_event)))
+#define bfa_sm_get_state(_sm)		((_sm)->sm)
+#define bfa_sm_cmp_state(_sm, _state)	((_sm)->sm == (bfa_sm_t)(_state))
+
+/**
+ * For converting from state machine function to state encoding.
+ */
+struct bfa_sm_table {
+	bfa_sm_t	sm;	/*!< state machine function	*/
+	int		state;	/*!< state machine encoding	*/
+	char		*name;	/*!< state name for display	*/
+};
+#define BFA_SM(_sm)		((bfa_sm_t)(_sm))
+
+/**
+ * State machine with entry actions.
+ */
+typedef void (*bfa_fsm_t)(void *fsm, int event);
+
+/**
+ * oc - object class eg. bfa_ioc
+ * st - state, eg. reset
+ * otype - object type, eg. struct bfa_ioc
+ * etype - object type, eg. enum ioc_event
+ */
+#define bfa_fsm_state_decl(oc, st, otype, etype)			\
+	static void oc ## _sm_ ## st(otype * fsm, etype event);		\
+	static void oc ## _sm_ ## st ## _entry(otype * fsm)
+
+#define bfa_fsm_set_state(_fsm, _state) do {				\
+	(_fsm)->fsm = (bfa_fsm_t)(_state);				\
+	_state ## _entry(_fsm);						\
+} while (0)
+
+#define bfa_fsm_send_event(_fsm, _event)	((_fsm)->fsm((_fsm), (_event)))
+#define bfa_fsm_get_state(_fsm)			((_fsm)->fsm)
+#define bfa_fsm_cmp_state(_fsm, _state)					\
+	((_fsm)->fsm == (bfa_fsm_t)(_state))
+
+static inline int
+bfa_sm_to_state(const struct bfa_sm_table *smt, bfa_sm_t sm)
+{
+	int	i = 0;
+
+	while (smt[i].sm && smt[i].sm != sm)
+		i++;
+	return smt[i].state;
+}
+
+/**
+ * @ Generic wait counter.
+ */
+
+typedef void (*bfa_wc_resume_t) (void *cbarg);
+
+struct bfa_wc {
+	bfa_wc_resume_t wc_resume;
+	void		*wc_cbarg;
+	int		wc_count;
+};
+
+static inline void
+bfa_wc_up(struct bfa_wc *wc)
+{
+	wc->wc_count++;
+}
+
+static inline void
+bfa_wc_down(struct bfa_wc *wc)
+{
+	wc->wc_count--;
+	if (wc->wc_count == 0)
+		wc->wc_resume(wc->wc_cbarg);
+}
+
+/**
+ * Initialize a waiting counter.
+ */
+static inline void
+bfa_wc_init(struct bfa_wc *wc, bfa_wc_resume_t wc_resume, void *wc_cbarg)
+{
+	wc->wc_resume = wc_resume;
+	wc->wc_cbarg = wc_cbarg;
+	wc->wc_count = 0;
+	bfa_wc_up(wc);
+}
+
+/**
+ * Wait for counter to reach zero
+ */
+static inline void
+bfa_wc_wait(struct bfa_wc *wc)
+{
+	bfa_wc_down(wc);
+}
+
+#endif /* __BFA_CS_H__ */
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index 4b5dc98..bda866b 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -19,7 +19,7 @@
 #ifndef __BFA_IOC_H__
 #define __BFA_IOC_H__
 
-#include "bfa_sm.h"
+#include "bfa_cs.h"
 #include "bfi.h"
 #include "cna.h"
 
diff --git a/drivers/net/bna/bfa_sm.h b/drivers/net/bna/bfa_sm.h
deleted file mode 100644
index 46462c4..0000000
--- a/drivers/net/bna/bfa_sm.h
+++ /dev/null
@@ -1,88 +0,0 @@
-/*
- * Linux network driver for Brocade Converged Network Adapter.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License (GPL) Version 2 as
- * published by the Free Software Foundation
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License for more details.
- */
-/*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
- * All rights reserved
- * www.brocade.com
- */
-
-/**
- * @file bfasm.h State machine defines
- */
-
-#ifndef __BFA_SM_H__
-#define __BFA_SM_H__
-
-#include "cna.h"
-
-typedef void (*bfa_sm_t)(void *sm, int event);
-
-/**
- * oc - object class eg. bfa_ioc
- * st - state, eg. reset
- * otype - object type, eg. struct bfa_ioc
- * etype - object type, eg. enum ioc_event
- */
-#define bfa_sm_state_decl(oc, st, otype, etype)		\
-	static void oc ## _sm_ ## st(otype * fsm, etype event)
-
-#define bfa_sm_set_state(_sm, _state)	((_sm)->sm = (bfa_sm_t)(_state))
-#define bfa_sm_send_event(_sm, _event)	((_sm)->sm((_sm), (_event)))
-#define bfa_sm_get_state(_sm)		((_sm)->sm)
-#define bfa_sm_cmp_state(_sm, _state)	((_sm)->sm == (bfa_sm_t)(_state))
-
-/**
- * For converting from state machine function to state encoding.
- */
-struct bfa_sm_table {
-	bfa_sm_t	sm;	/*!< state machine function	*/
-	int		state;	/*!< state machine encoding	*/
-	char		*name;	/*!< state name for display	*/
-};
-#define BFA_SM(_sm)	((bfa_sm_t)(_sm))
-
-/**
- * State machine with entry actions.
- */
-typedef void (*bfa_fsm_t)(void *fsm, int event);
-
-/**
- * oc - object class eg. bfa_ioc
- * st - state, eg. reset
- * otype - object type, eg. struct bfa_ioc
- * etype - object type, eg. enum ioc_event
- */
-#define bfa_fsm_state_decl(oc, st, otype, etype)		\
-	static void oc ## _sm_ ## st(otype * fsm, etype event);	\
-	static void oc ## _sm_ ## st ## _entry(otype * fsm)
-
-#define bfa_fsm_set_state(_fsm, _state) do {	\
-	(_fsm)->fsm = (bfa_fsm_t)(_state);	\
-	_state ## _entry(_fsm);			\
-} while (0)
-
-#define bfa_fsm_send_event(_fsm, _event)	((_fsm)->fsm((_fsm), (_event)))
-#define bfa_fsm_get_state(_fsm)			((_fsm)->fsm)
-#define bfa_fsm_cmp_state(_fsm, _state)		\
-	((_fsm)->fsm == (bfa_fsm_t)(_state))
-
-static inline int
-bfa_sm_to_state(const struct bfa_sm_table *smt, bfa_sm_t sm)
-{
-	int	i = 0;
-
-	while (smt[i].sm && smt[i].sm != sm)
-		i++;
-	return smt[i].state;
-}
-#endif
diff --git a/drivers/net/bna/bfa_wc.h b/drivers/net/bna/bfa_wc.h
deleted file mode 100644
index d0e4cae..0000000
--- a/drivers/net/bna/bfa_wc.h
+++ /dev/null
@@ -1,69 +0,0 @@
-/*
- * Linux network driver for Brocade Converged Network Adapter.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License (GPL) Version 2 as
- * published by the Free Software Foundation
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License for more details.
- */
-/*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
- * All rights reserved
- * www.brocade.com
- */
-
-/**
- * @file bfa_wc.h Generic wait counter.
- */
-
-#ifndef __BFA_WC_H__
-#define __BFA_WC_H__
-
-typedef void (*bfa_wc_resume_t) (void *cbarg);
-
-struct bfa_wc {
-	bfa_wc_resume_t wc_resume;
-	void		*wc_cbarg;
-	int		wc_count;
-};
-
-static inline void
-bfa_wc_up(struct bfa_wc *wc)
-{
-	wc->wc_count++;
-}
-
-static inline void
-bfa_wc_down(struct bfa_wc *wc)
-{
-	wc->wc_count--;
-	if (wc->wc_count == 0)
-		wc->wc_resume(wc->wc_cbarg);
-}
-
-/**
- * Initialize a waiting counter.
- */
-static inline void
-bfa_wc_init(struct bfa_wc *wc, bfa_wc_resume_t wc_resume, void *wc_cbarg)
-{
-	wc->wc_resume = wc_resume;
-	wc->wc_cbarg = wc_cbarg;
-	wc->wc_count = 0;
-	bfa_wc_up(wc);
-}
-
-/**
- * Wait for counter to reach zero
- */
-static inline void
-bfa_wc_wait(struct bfa_wc *wc)
-{
-	bfa_wc_down(wc);
-}
-
-#endif
diff --git a/drivers/net/bna/bna.h b/drivers/net/bna/bna.h
index 6b14c1d..21e9155 100644
--- a/drivers/net/bna/bna.h
+++ b/drivers/net/bna/bna.h
@@ -13,7 +13,7 @@
 #ifndef __BNA_H__
 #define __BNA_H__
 
-#include "bfa_wc.h"
+#include "bfa_cs.h"
 #include "bfa_ioc.h"
 #include "cna.h"
 #include "bfi_ll.h"
diff --git a/drivers/net/bna/bna_ctrl.c b/drivers/net/bna/bna_ctrl.c
index 7d9bc2f..cb2594c 100644
--- a/drivers/net/bna/bna_ctrl.c
+++ b/drivers/net/bna/bna_ctrl.c
@@ -16,8 +16,7 @@
  * www.brocade.com
  */
 #include "bna.h"
-#include "bfa_sm.h"
-#include "bfa_wc.h"
+#include "bfa_cs.h"
 
 static void bna_device_cb_port_stopped(void *arg, enum bna_cb_status status);
 
diff --git a/drivers/net/bna/bna_txrx.c b/drivers/net/bna/bna_txrx.c
index 4d4f4d9..f0983c8 100644
--- a/drivers/net/bna/bna_txrx.c
+++ b/drivers/net/bna/bna_txrx.c
@@ -16,7 +16,7 @@
  * www.brocade.com
  */
 #include "bna.h"
-#include "bfa_sm.h"
+#include "bfa_cs.h"
 #include "bfi.h"
 
 /**
-- 
1.7.1

