From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] niu: Fix kernel buffer overflow for
 ETHTOOL_GRXCLSRLALL
Date: Tue, 07 Sep 2010 15:35:19 +0100
Message-ID: <1283870119.2270.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Santwona Behera <santwona.behera@sun.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:41042 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757233Ab0IGOfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 10:35:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

niu_get_ethtool_tcam_all() assumes that its output buffer is the right
size, and warns before returning if it is not.  However, the output
buffer size is under user control and ETHTOOL_GRXCLSRLALL is an
unprivileged ethtool command.  Therefore this is at least a local
denial-of-service vulnerability.

Change it to check before writing each entry and to return an error if
the buffer is already full.

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
There may be more of these but AFAIK this is the only RXNFC command that
deals with variable-length data.

I wonder whether it really makes sense for ethtool getter commands to be
generally unprivileged.  Does the convenience outweigh the risk of a
driver bug becoming a local DoS or root hole, or the disclosure of
information such as (in this case) which flows the administrator
considers interesting?

Ben.

 drivers/net/niu.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index b9b9508..340cbec 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -7272,32 +7272,28 @@ static int niu_get_ethtool_tcam_all(struct niu *np,
 	struct niu_parent *parent = np->parent;
 	struct niu_tcam_entry *tp;
 	int i, idx, cnt;
-	u16 n_entries;
 	unsigned long flags;
-
+	int ret = 0;
 
 	/* put the tcam size here */
 	nfc->data = tcam_get_size(np);
 
 	niu_lock_parent(np, flags);
-	n_entries = nfc->rule_cnt;
 	for (cnt = 0, i = 0; i < nfc->data; i++) {
 		idx = tcam_get_index(np, i);
 		tp = &parent->tcam[idx];
 		if (!tp->valid)
 			continue;
+		if (cnt == nfc->rule_cnt) {
+			ret = -EMSGSIZE;
+			break;
+		}
 		rule_locs[cnt] = i;
 		cnt++;
 	}
 	niu_unlock_parent(np, flags);
 
-	if (n_entries != cnt) {
-		/* print warning, this should not happen */
-		netdev_info(np->dev, "niu%d: In %s(): n_entries[%d] != cnt[%d]!!!\n",
-			    np->parent->index, __func__, n_entries, cnt);
-	}
-
-	return 0;
+	return ret;
 }
 
 static int niu_get_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
-- 
1.7.2.1



