From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH] igb: fix PHC stopping on max freq
Date: Tue, 19 Mar 2013 15:42:51 +0100
Message-ID: <f254bc583cbe1f623bd6ebb4ff375e440696d8b2.1363703896.git.jbenc@redhat.com>
Cc: e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Stefan Assmann <sassmann@redhat.com>,
	Miroslav Lichvar <mlichvar@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50780 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753152Ab3CSOnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 10:43:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For 82576 MAC type, max_adj is reported as 1000000000 ppb. However, if
this value is passed to igb_ptp_adjfreq_82576, incvalue overflows out of
INCVALUE_82576_MASK, resulting in setting of zero TIMINCA.incvalue, stopping
the PHC (instead of going at twice the nominal speed).

Fix the advertised max_adj value to the largest value hardware can handle.
As there is no min_adj value available (-max_adj is used instead), this will
also prevent stopping the clock intentionally. It's probably not a big deal,
other igb MAC types don't support stopping the clock, either.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 0987822..0a23750 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -740,7 +740,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 	case e1000_82576:
 		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
 		adapter->ptp_caps.owner = THIS_MODULE;
-		adapter->ptp_caps.max_adj = 1000000000;
+		adapter->ptp_caps.max_adj = 999999881;
 		adapter->ptp_caps.n_ext_ts = 0;
 		adapter->ptp_caps.pps = 0;
 		adapter->ptp_caps.adjfreq = igb_ptp_adjfreq_82576;
-- 
1.7.6.5
