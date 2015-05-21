From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: skip fdb add if the port shouldn't learn
Date: Thu, 21 May 2015 03:42:57 -0700
Message-ID: <1432204977-4293-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36143 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753309AbbEUKns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 06:43:48 -0400
Received: by pabts4 with SMTP id ts4so101232270pab.3
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 03:43:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wilson Kok <wkok@cumulusnetworks.com>

Check in fdb_add_entry() if the source port should learn, similar
check is used in br_fdb_update.
Note that new fdb entries which are added manually or
as local ones are still permitted.
This patch has been tested by running traffic via a bridge port and
switching the port's state, also by manually adding/removing entries
from the bridge's fdb.

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
Nik: Maybe it'd be better if we returned an error even though it
     doesn't look necessary. I'm open to suggestions.

 net/bridge/br_fdb.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index e0670d7054f9..27de0b7bd76b 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -736,6 +736,12 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 	struct net_bridge_fdb_entry *fdb;
 	bool modified = false;
 
+	/* If the port cannot learn allow only local and static entries */
+	if (!(state & NUD_PERMANENT) && !(state & NUD_NOARP) &&
+	    !(source->state == BR_STATE_LEARNING ||
+	      source->state == BR_STATE_FORWARDING))
+		return 0;
+
 	fdb = fdb_find(head, addr, vid);
 	if (fdb == NULL) {
 		if (!(flags & NLM_F_CREATE))
-- 
1.9.3
