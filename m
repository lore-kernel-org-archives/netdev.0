From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] scm: fix scm_fp_list->list initialization made in wrong place
Date: Fri, 14 Nov 2008 17:32:58 +0300
Message-ID: <491D8C1A.5060003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:16450 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259AbYKNOdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 09:33:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the next page of the scm recursion story (the commit 
f8d570a4 net: Fix recursive descent in __scm_destroy()).

In function scm_fp_dup(), the INIT_LIST_HEAD(&fpl->list) of newly
created fpl is done *before* the subsequent memcpy from the old 
structure and thus the freshly initialized list is overwritten.

But that's OK, since this initialization is not required at all,
since the fpl->list is list_add-ed at the destruction time in any
case (and is unused in other code), so I propose to drop both
initializations, rather than moving it after the memcpy.

Please, correct me if I miss something significant.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/scm.c b/net/core/scm.c
index ab242cc..b12303d 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -75,7 +75,6 @@ static int scm_fp_copy(struct cmsghdr *cmsg, struct scm_fp_list **fplp)
 		if (!fpl)
 			return -ENOMEM;
 		*fplp = fpl;
-		INIT_LIST_HEAD(&fpl->list);
 		fpl->count = 0;
 	}
 	fpp = &fpl->fp[fpl->count];
@@ -301,7 +300,6 @@ struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
 
 	new_fpl = kmalloc(sizeof(*fpl), GFP_KERNEL);
 	if (new_fpl) {
-		INIT_LIST_HEAD(&new_fpl->list);
 		for (i=fpl->count-1; i>=0; i--)
 			get_file(fpl->fp[i]);
 		memcpy(new_fpl, fpl, sizeof(*fpl));
