From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/2] strparser: Queue work when being unpaused
Date: Tue, 23 Aug 2016 11:55:30 -0700
Message-ID: <1471978531-3231140-2-git-send-email-tom@herbertland.com>
References: <1471978531-3231140-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46397 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754146AbcHWTOj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 15:14:39 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7NItAs1000617
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:55:40 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 250tnw0yqv-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:55:40 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 2ecb100a696311e6a0180002c9521c9e-ba1f7aa0 for <netdev@vger.kernel.org>;        Tue,
 23 Aug 2016 11:55:39 -0700
In-Reply-To: <1471978531-3231140-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the upper layer unpauses a stream parser connection we need to
queue rx_work to make sure no events are missed.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/strparser.h   |  5 +----
 net/strparser/strparser.c | 11 +++++++++++
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/include/net/strparser.h b/include/net/strparser.h
index fdb3d67..91fa0b9 100644
--- a/include/net/strparser.h
+++ b/include/net/strparser.h
@@ -88,10 +88,7 @@ static inline void strp_pause(struct strparser *strp)
 }
 
 /* May be called without holding lock for attached socket */
-static inline void strp_unpause(struct strparser *strp)
-{
-	strp->rx_paused = 0;
-}
+void strp_unpause(struct strparser *strp);
 
 static inline void save_strp_stats(struct strparser *strp,
 				   struct strp_aggr_stats *agg_stats)
diff --git a/net/strparser/strparser.c b/net/strparser/strparser.c
index 68334b5..4ecfc10 100644
--- a/net/strparser/strparser.c
+++ b/net/strparser/strparser.c
@@ -445,6 +445,17 @@ int strp_init(struct strparser *strp, struct sock *csk,
 }
 EXPORT_SYMBOL_GPL(strp_init);
 
+void strp_unpause(struct strparser *strp)
+{
+	strp->rx_paused = 0;
+
+	/* Sync setting rx_paused with RX work */
+	smp_mb();
+
+	queue_work(strp_wq, &strp->rx_work);
+}
+EXPORT_SYMBOL_GPL(strp_unpause);
+
 /* strp must already be stopped so that strp_tcp_recv will no longer be called.
  * Note that strp_done is not called with the lower socket held.
  */
-- 
2.8.0.rc2
