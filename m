From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] 8139too: revisit napi_complete_done() usage
Date: Mon, 18 Sep 2017 13:03:43 -0700
Message-ID: <1505765023.29839.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170407181754.GL30290@intel.com>
         <1491590329.10124.86.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170410121102.GM30290@intel.com> <20170918194630.GH4914@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ville =?ISO-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36222 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdIRUDp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 16:03:45 -0400
Received: by mail-pf0-f193.google.com with SMTP id f84so607198pfj.3
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 13:03:45 -0700 (PDT)
In-Reply-To: <20170918194630.GH4914@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It seems we have to be more careful in napi_complete_done()
use. This patch is not a revert, as it seems we can
avoid bug that Ville reported by moving the napi_complete_done()
test in the spinlock section.

Many thanks to Ville for detective work and all tests.

Fixes: 617f01211baf ("8139too: use napi_complete_done()")
Reported-by: Ville Syrjälä <ville.syrjala@linux.intel.com>
Tested-by: Ville Syrjälä <ville.syrjala@linux.intel.com>
---
 drivers/net/ethernet/realtek/8139too.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 89631753e79962d91456d93b71929af768917da1..cd2dbec331dd796f5296cd378561b3443f231673 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -2135,11 +2135,12 @@ static int rtl8139_poll(struct napi_struct *napi, int budget)
 	if (likely(RTL_R16(IntrStatus) & RxAckBits))
 		work_done += rtl8139_rx(dev, tp, budget);
 
-	if (work_done < budget && napi_complete_done(napi, work_done)) {
+	if (work_done < budget) {
 		unsigned long flags;
 
 		spin_lock_irqsave(&tp->lock, flags);
-		RTL_W16_F(IntrMask, rtl8139_intr_mask);
+		if (napi_complete_done(napi, work_done))
+			RTL_W16_F(IntrMask, rtl8139_intr_mask);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 	spin_unlock(&tp->rx_lock);
