From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v2] bridge: skip fdb add if the port shouldn't learn
Date: Mon, 25 May 2015 06:39:31 -0700
Message-ID: <1432561171-4965-1-git-send-email-nikolay@cumulusnetworks.com>
References: <1432204977-4293-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35841 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbEYNjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 09:39:44 -0400
Received: by pdfh10 with SMTP id h10so70107763pdf.3
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 06:39:43 -0700 (PDT)
In-Reply-To: <1432204977-4293-1-git-send-email-nikolay@cumulusnetworks.com>
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
v2: return an error instead of silently failing.

 net/bridge/br_fdb.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index e0670d7054f9..7896cf143045 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -736,6 +736,12 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 	struct net_bridge_fdb_entry *fdb;
 	bool modified = false;
 
+	/* If the port cannot learn allow only local and static entries */
+	if (!(state & NUD_PERMANENT) && !(state & NUD_NOARP) &&
+	    !(source->state == BR_STATE_LEARNING ||
+	      source->state == BR_STATE_FORWARDING))
+		return -EPERM;
+
 	fdb = fdb_find(head, addr, vid);
 	if (fdb == NULL) {
 		if (!(flags & NLM_F_CREATE))
-- 
1.7.10.4
