From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/9] tc: m_xt: Prevent segfault with standard targets
Date: Fri, 10 Jun 2016 13:42:00 +0200
Message-ID: <1465558928-19657-2-git-send-email-phil@nwl.cc>
References: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35055 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbcFJLnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 07:43:18 -0400
In-Reply-To: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Iptables standard targets like DROP or REJECT don't implement the print
callback in libxtables. Hence the following command would segfault:

| tc filter add dev d0 parent ffff: u32 match u32 0 0 action xt -j DROP

With this patch standard targets still can't be used (and are not really
useful anyway), but at least it doesn't crash anymore.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index c3f866df14749..62ec6d7f18e73 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -250,8 +250,12 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 	fprintf(stdout, "tablename: %s hook: %s\n ", tname, ipthooks[hook]);
 	fprintf(stdout, "\ttarget: ");
 
-	if (m)
-		m->print(NULL, m->t, 0);
+	if (m) {
+		if (m->print)
+			m->print(NULL, m->t, 0);
+		else
+			printf("%s ", m->name);
+	}
 	fprintf(stdout, " index %d\n", index);
 
 	if (strlen(tname) > 16) {
-- 
2.8.2
