From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net] e1000e: fix numeric overflow in phc settime method.
Date: Mon, 22 Apr 2013 15:53:36 +0200
Message-ID: <1455e8dd5f574fef93377b61cea8b494102091ef.1366638698.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeroen Van den Keybus <jeroen.vandenkeybus@triphase.com>,
	bruce.w.allan@intel.com, <e1000-devel@lists.sourceforge.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:59850 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466Ab3DVNxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 09:53:50 -0400
Received: by mail-wg0-f46.google.com with SMTP id e11so919633wgh.25
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 06:53:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PTP Hardware Clock settime function in the e1000e driver
computes nanoseconds from a struct timespec. The code converts the
seconds field .tv_sec by multiplying it with NSEC_PER_SEC. However,
both operands are of type long, resulting in an unintended overflow.
The patch fixes the issue by using the helper function from time.h.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/e1000e/ptp.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index b477fa5..065f8c8 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -145,8 +145,7 @@ static int e1000e_phc_settime(struct ptp_clock_info *ptp,
 	unsigned long flags;
 	u64 ns;
 
-	ns = ts->tv_sec * NSEC_PER_SEC;
-	ns += ts->tv_nsec;
+	ns = timespec_to_ns(ts);
 
 	/* reset the timecounter */
 	spin_lock_irqsave(&adapter->systim_lock, flags);
-- 
1.7.2.5
