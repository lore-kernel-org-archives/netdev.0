From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/7] bonding: fix parameter parsing
Date: Tue, 29 Jan 2008 18:07:43 -0800
Message-ID: <12016588701127-git-send-email-fubar@us.ibm.com>
References: <12016588691476-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:41122 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877AbYA3CH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 21:07:57 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0U27quN007523
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 21:07:52 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0U27pAu222704
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:51 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0U27pK2015777
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:51 -0700
In-Reply-To: <12016588691476-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	My last fix (commit ece95f7fefe3afae19e641e1b3f5e64b00d5b948)
didn't handle one case correctly.  This resolves that, and it will now
correctly parse parameters with arbitrary white space, and either text
names or mode values.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 49a1982..f3b1e02 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4549,14 +4549,19 @@ static void bond_free_all(void)
 int bond_parse_parm(const char *buf, struct bond_parm_tbl *tbl)
 {
 	int mode = -1, i, rv;
-	char modestr[BOND_MAX_MODENAME_LEN + 1] = { 0, };
+	char *p, modestr[BOND_MAX_MODENAME_LEN + 1] = { 0, };
 
-	rv = sscanf(buf, "%d", &mode);
-	if (!rv) {
+	for (p = (char *)buf; *p; p++)
+		if (!(isdigit(*p) || isspace(*p)))
+			break;
+
+	if (*p)
 		rv = sscanf(buf, "%20s", modestr);
-		if (!rv)
-			return -1;
-	}
+	else
+		rv = sscanf(buf, "%d", &mode);
+
+	if (!rv)
+		return -1;
 
 	for (i = 0; tbl[i].modename; i++) {
 		if (mode == tbl[i].mode)
-- 
1.5.3.4.206.g58ba4-dirty

