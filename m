From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2] CAPI: Silence lockdep warning on get_capi_appl_by_nr usage
Date: Sun, 17 Oct 2010 17:18:15 +0200
Message-ID: <4CBB13B7.8080705@web.de>
References: <4CB9891B.4060606@web.de> <1287311135.1998.154.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	i4ldeveloper@listserv.isdn4linux.de,
	Linux Netdev List <netdev@vger.kernel.org>,
	Karsten Keil <isdn@linux-pingi.de>,
	Peter Zijlstra <peterz@infradead.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:49752 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756919Ab0JQPSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Oct 2010 11:18:18 -0400
In-Reply-To: <1287311135.1998.154.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As long as we hold capi_controller_lock, we can safely access
capi_applications without RCU protection as no one can modify the
application list underneath us. Introduce an RCU-free
__get_capi_appl_by_nr for this purpose. This silences lockdep warnings
on suspicious rcu_dereference usage.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---

v2:
 - use lockdep_assert_held in favor of WARN_ON_ONCE(!mutex_is_locked)
   as suggested by Peter

 drivers/isdn/capi/kcapi.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index 2648d39..2b33b26 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -99,6 +99,16 @@ static inline struct capi_ctr *get_capi_ctr_by_nr(u16 contr)
 	return capi_controller[contr - 1];
 }
 
+static inline struct capi20_appl *__get_capi_appl_by_nr(u16 applid)
+{
+	lockdep_assert_held(&capi_controller_lock);
+
+	if (applid - 1 >= CAPI_MAXAPPL)
+		return NULL;
+
+	return capi_applications[applid - 1];
+}
+
 static inline struct capi20_appl *get_capi_appl_by_nr(u16 applid)
 {
 	if (applid - 1 >= CAPI_MAXAPPL)
@@ -186,10 +196,9 @@ static void notify_up(u32 contr)
 		ctr->state = CAPI_CTR_RUNNING;
 
 		for (applid = 1; applid <= CAPI_MAXAPPL; applid++) {
-			ap = get_capi_appl_by_nr(applid);
-			if (!ap)
-				continue;
-			register_appl(ctr, applid, &ap->rparam);
+			ap = __get_capi_appl_by_nr(applid);
+			if (ap)
+				register_appl(ctr, applid, &ap->rparam);
 		}
 
 		wake_up_interruptible_all(&ctr->state_wait_queue);
@@ -216,7 +225,7 @@ static void ctr_down(struct capi_ctr *ctr, int new_state)
 	memset(ctr->serial, 0, sizeof(ctr->serial));
 
 	for (applid = 1; applid <= CAPI_MAXAPPL; applid++) {
-		ap = get_capi_appl_by_nr(applid);
+		ap = __get_capi_appl_by_nr(applid);
 		if (ap)
 			capi_ctr_put(ctr);
 	}
-- 
1.7.1
