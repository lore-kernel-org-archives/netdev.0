From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] net: fix incorrect counting in __scm_destroy()
Date: Wed, 4 Nov 2009 05:04:26 -0500
Message-ID: <20091104100717.4785.57149.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Amerigo Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751045AbZKDKEY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 05:04:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It seems that in __scm_destroy() we forgot to decrease
the ->count after fput(->fp[i]), this may cause some
problem when we recursively call fput() again.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: David S. Miller <davem@davemloft.net>

---
diff --git a/net/core/scm.c b/net/core/scm.c
index b7ba91b..fa53219 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -120,8 +120,10 @@ void __scm_destroy(struct scm_cookie *scm)
 				fpl = list_first_entry(&work_list, struct scm_fp_list, list);
 
 				list_del(&fpl->list);
-				for (i=fpl->count-1; i>=0; i--)
+				for (i = fpl->count-1; i >= 0; i--) {
 					fput(fpl->fp[i]);
+					fpl->count--;
+				}
 				kfree(fpl);
 			}
 
