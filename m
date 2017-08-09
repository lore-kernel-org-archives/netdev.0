From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] igb: Remove incorrect "unexpected SYS WRAP" log message
Date: Wed,  9 Aug 2017 14:47:38 -0700
Message-ID: <20170809214746.28139-5-jeffrey.t.kirsher@intel.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Cc: Corinna Vinschen <vinschen@redhat.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:44498 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752298AbdHIVr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 17:47:56 -0400
In-Reply-To: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corinna Vinschen <vinschen@redhat.com>

TSAUXC.DisableSystime is never set, so SYSTIM runs into a SYS WRAP
every 1100 secs on 80580/i350/i354 (40 bit SYSTIM) and every 35000
secs on 80576 (45 bit SYSTIM).

This wrap event sets the TSICR.SysWrap bit unconditionally.

However, checking TSIM at interrupt time shows that this event does not
actually cause the interrupt.  Rather, it's just bycatch while the
actual interrupt is caused by, for instance, TSICR.TXTS.

The conclusion is that the SYS WRAP is actually expected, so the
"unexpected SYS WRAP" message is entirely bogus and just helps to
confuse users.  Drop it.

Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
Acked-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 5d0a75c1ba0c..1a99164d5d11 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5746,8 +5746,6 @@ static void igb_tsync_interrupt(struct igb_adapter *adapter)
 		event.type = PTP_CLOCK_PPS;
 		if (adapter->ptp_caps.pps)
 			ptp_clock_event(adapter->ptp_clock, &event);
-		else
-			dev_err(&adapter->pdev->dev, "unexpected SYS WRAP");
 		ack |= TSINTR_SYS_WRAP;
 	}
 
-- 
2.13.3
