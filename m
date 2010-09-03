From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 4/4] tipc: Fix misleading error code when enabling Ethernet bearers
Date: Fri,  3 Sep 2010 14:33:42 -0400
Message-ID: <1283538822-25718-4-git-send-email-paul.gortmaker@windriver.com>
References: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54537 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090Ab0ICSdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 14:33:47 -0400
In-Reply-To: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Cause TIPC to return EAGAIN if it is unable to enable a new Ethernet
bearer because one or more recently disabled Ethernet bearers are
temporarily consuming resources during shut down.  (The previous error
code, EDQUOT, is now returned only if all available Ethernet bearer
data structures are fully enabled at the time the request to enable an
additional bearer is received.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/eth_media.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index ff50a17..6e988ba 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -135,6 +135,16 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 	struct eth_bearer *eb_ptr = &eth_bearers[0];
 	struct eth_bearer *stop = &eth_bearers[MAX_ETH_BEARERS];
 	char *driver_name = strchr((const char *)tb_ptr->name, ':') + 1;
+	int pending_dev = 0;
+
+	/* Find unused Ethernet bearer structure */
+
+	while (eb_ptr->dev) {
+		if (!eb_ptr->bearer)
+			pending_dev++;
+		if (++eb_ptr == stop)
+			return pending_dev ? -EAGAIN : -EDQUOT;
+	}
 
 	/* Find device with specified name */
 
-- 
1.7.2.1

