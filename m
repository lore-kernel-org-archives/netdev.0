From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: [PATCH net 3/5] net/ncsi: Disable HWA mode when no channels are found
Date: Thu, 19 Oct 2017 13:43:07 +1100
Message-ID: <20171019024309.13628-3-sam@mendozajonas.com>
References: <20171019024309.13628-1-sam@mendozajonas.com>
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org,
        Samuel Mendoza-Jonas <sam@mendozajonas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:36915 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751091AbdJSCnV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 22:43:21 -0400
In-Reply-To: <20171019024309.13628-1-sam@mendozajonas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <gwshan@linux.vnet.ibm.com>

When there are no NCSI channels probed, HWA (Hardware Arbitration)
mode is enabled. It's not correct because HWA depends on the fact:
NCSI channels exist and all of them support HWA mode. This disables
HWA when no channels are probed.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>
---
 net/ncsi/ncsi-manage.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index b022deb39d31..0966eff48ce7 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -1005,12 +1005,15 @@ static bool ncsi_check_hwa(struct ncsi_dev_priv *ndp)
 	struct ncsi_package *np;
 	struct ncsi_channel *nc;
 	unsigned int cap;
+	bool has_channel = false;
 
 	/* The hardware arbitration is disabled if any one channel
 	 * doesn't support explicitly.
 	 */
 	NCSI_FOR_EACH_PACKAGE(ndp, np) {
 		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			has_channel = true;
+
 			cap = nc->caps[NCSI_CAP_GENERIC].cap;
 			if (!(cap & NCSI_CAP_GENERIC_HWA) ||
 			    (cap & NCSI_CAP_GENERIC_HWA_MASK) !=
@@ -1021,8 +1024,13 @@ static bool ncsi_check_hwa(struct ncsi_dev_priv *ndp)
 		}
 	}
 
-	ndp->flags |= NCSI_DEV_HWA;
-	return true;
+	if (has_channel) {
+		ndp->flags |= NCSI_DEV_HWA;
+		return true;
+	}
+
+	ndp->flags &= ~NCSI_DEV_HWA;
+	return false;
 }
 
 static int ncsi_enable_hwa(struct ncsi_dev_priv *ndp)
-- 
2.14.2
