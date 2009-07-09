From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH for 2.6.31] cxgb3: Fix crash caused by stashing wrong netdev_queue
Date: Thu, 09 Jul 2009 12:30:25 -0700
Message-ID: <adabpnty7qm.fsf_-_@cisco.com>
References: <adaeisq23rq.fsf@cisco.com> <adaljmyzof4.fsf@cisco.com>
	<4A554A1D.3070703@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:60026 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270AbZGITab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 15:30:31 -0400
In-Reply-To: <4A554A1D.3070703@chelsio.com> (Divy Le Ray's message of "Wed, 08
	Jul 2009 18:38:37 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c3a8c5b6 ("cxgb3: move away from LLTX") exposed a bug in how
cxgb3 looks up the netdev_queue it stashes away in a qset during
initialization.  For multiport devices, the TX queue index it uses is
offset by the first_qset index of each port.  This leads to a crash
once LLTX is removed, since hard_start_xmit is called with one TX
queue lock held, while the TX reclaim timer task grabs a different
(wrong) TX queue lock when it frees skbs.

Fix this by removing the first_qset offset used to look up the TX
queue passed into t3_sge_alloc_qset() from setup_sge_qsets().

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
OK, found the bug that was causing the crash I saw.  With this patch
everything looks solid again.  Please apply.

 drivers/net/cxgb3/cxgb3_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 538dda4..fb5df5c 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -642,8 +642,7 @@ static int setup_sge_qsets(struct adapter *adap)
 		struct port_info *pi = netdev_priv(dev);
 
 		pi->qs = &adap->sge.qs[pi->first_qset];
-		for (j = pi->first_qset; j < pi->first_qset + pi->nqsets;
-		     ++j, ++qset_idx) {
+		for (j = 0; j < pi->nqsets; ++j, ++qset_idx) {
 			set_qset_lro(dev, qset_idx, pi->rx_offload & T3_LRO);
 			err = t3_sge_alloc_qset(adap, qset_idx, 1,
 				(adap->flags & USING_MSIX) ? qset_idx + 1 :
