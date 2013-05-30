From: Alan Robertson <alanr@unix.sh>
Subject: [PATCH net] rtnetlink: ndo_dflt_fdb_del() never works
Date: Thu, 30 May 2013 16:01:55 -0600
Message-ID: <1369951315-14742-1-git-send-email-alanr@unix.sh>
Cc: Alan Robertson <alanr@unix.sh>
To: netdev@vger.kernel.org, "David S. Miller" <davem@gavemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:25485 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758693Ab3E3WL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 18:11:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndo_dflt_fdb_del is checking for a condition which is opposite that
which ndo_dflt_fdb_add enforces.  ndo_dflt_fdb_add declares an error
if (ndm->ndm_state && !(ndm->ndm_state) & NUD_PERMANENT)) - that is, if the
entry is static.  This is consistent with the failure error message.

On the other hand, ndo_dflt_del() declares an error
if (ndm_state & NUD_PERMANENT) - which is inconsistent with the add
precondition, and inconsistent with its failure message text.
As it is now, you can't delete any entry which add allows to be added -
so entry deletion always fails.

Signed-off-by: Alan Robertson <alanr@unix.sh>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a08bd2b..373a8e7 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2142,7 +2142,7 @@ int ndo_dflt_fdb_del(struct ndmsg *ndm,
 	/* If aging addresses are supported device will need to
 	 * implement its own handler for this.
 	 */
-	if (ndm->ndm_state & NUD_PERMANENT) {
+	if (!(ndm->ndm_state & NUD_PERMANENT)) {
 		pr_info("%s: FDB only supports static addresses\n", dev->name);
 		return -EINVAL;
 	}
-- 
1.8.1.4
