From: roy.qing.li@gmail.com
Subject: [PATCH net-next] core: remove old parameter for __dst_destroy_metrics_generic
Date: Fri, 27 Dec 2013 17:26:45 +0800
Message-ID: <1388136405-25019-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33645 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119Ab3L0J0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 04:26:51 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so8832649pdi.24
        for <netdev@vger.kernel.org>; Fri, 27 Dec 2013 01:26:50 -0800 (PST)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id vh3sm60799643pbc.8.2013.12.27.01.26.47
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 27 Dec 2013 01:26:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

when call __dst_destroy_metrics_generic, we always know who old is, so
do not need to pass it.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 include/net/dst.h |    7 +++----
 net/core/dst.c    |    5 +++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 77eb53f..7c86f3e 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -119,13 +119,12 @@ static inline bool dst_metrics_read_only(const struct dst_entry *dst)
 	return dst->_metrics & DST_METRICS_READ_ONLY;
 }
 
-void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned long old);
+void __dst_destroy_metrics_generic(struct dst_entry *dst);
 
 static inline void dst_destroy_metrics_generic(struct dst_entry *dst)
 {
-	unsigned long val = dst->_metrics;
-	if (!(val & DST_METRICS_READ_ONLY))
-		__dst_destroy_metrics_generic(dst, val);
+	if (!dst_metrics_read_only(dst))
+		__dst_destroy_metrics_generic(dst);
 }
 
 static inline u32 *dst_metrics_write_ptr(struct dst_entry *dst)
diff --git a/net/core/dst.c b/net/core/dst.c
index ca4231e..f1875ee 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -308,10 +308,11 @@ u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old)
 EXPORT_SYMBOL(dst_cow_metrics_generic);
 
 /* Caller asserts that dst_metrics_read_only(dst) is false.  */
-void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned long old)
+void __dst_destroy_metrics_generic(struct dst_entry *dst)
 {
-	unsigned long prev, new;
+	unsigned long prev, new, old;
 
+	old = dst->_metrics;
 	new = ((unsigned long) dst_default_metrics) | DST_METRICS_READ_ONLY;
 	prev = cmpxchg(&dst->_metrics, old, new);
 	if (prev == old)
-- 
1.7.10.4
