From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v2 6/6] sctp: convert sctp_assoc_set_id to use idr_alloc_cyclic
Date: Wed, 27 Mar 2013 15:29:38 -0400
Message-ID: <1364412578-7462-7-git-send-email-jlayton@redhat.com>
References: <1364412578-7462-1-git-send-email-jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, tj@kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:38604 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754341Ab3C0T3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 15:29:51 -0400
Received: by mail-oa0-f48.google.com with SMTP id j1so9184839oag.21
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 12:29:50 -0700 (PDT)
In-Reply-To: <1364412578-7462-1-git-send-email-jlayton@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Note: compile-tested only)

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Sridhar Samudrala <sri@us.ibm.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-sctp@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 net/sctp/associola.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index d2709e2..fa261a3 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -66,13 +66,6 @@ static void sctp_assoc_bh_rcv(struct work_struct *work);
 static void sctp_assoc_free_asconf_acks(struct sctp_association *asoc);
 static void sctp_assoc_free_asconf_queue(struct sctp_association *asoc);
 
-/* Keep track of the new idr low so that we don't re-use association id
- * numbers too fast.  It is protected by they idr spin lock is in the
- * range of 1 - INT_MAX.
- */
-static u32 idr_low = 1;
-
-
 /* 1st Level Abstractions. */
 
 /* Initialize a new association from provided memory. */
@@ -1601,13 +1594,8 @@ int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
 	if (preload)
 		idr_preload(gfp);
 	spin_lock_bh(&sctp_assocs_id_lock);
-	/* 0 is not a valid id, idr_low is always >= 1 */
-	ret = idr_alloc(&sctp_assocs_id, asoc, idr_low, 0, GFP_NOWAIT);
-	if (ret >= 0) {
-		idr_low = ret + 1;
-		if (idr_low == INT_MAX)
-			idr_low = 1;
-	}
+	/* 0 is not a valid assoc_id, must be >= 1 */
+	ret = idr_alloc_cyclic(&sctp_assocs_id, asoc, 1, 0, GFP_NOWAIT);
 	spin_unlock_bh(&sctp_assocs_id_lock);
 	if (preload)
 		idr_preload_end();
-- 
1.7.11.7
