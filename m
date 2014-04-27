From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next] ptp: validate the requested frequency adjustment.
Date: Sun, 27 Apr 2014 15:01:27 +0200
Message-ID: <ab098280c43e23292c28cabaa4cda13d8f21ca29.1398603530.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:57566 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbaD0NBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 09:01:40 -0400
Received: by mail-ee0-f44.google.com with SMTP id e49so4009365eek.31
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2014 06:01:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PTP Hardware Clock drivers specify a maximum frequency adjustment that
their clocks can accommodate. Normally, user space programs will want to
respect the advertised limits. However, no kernel or driver code checks
that the dialed frequency offset is within the bounds, and out of range
values can lead to surprising results.

This patch fixes the issue by rejecting bad values.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_clock.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index e25d2bc..296b0ec 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -142,7 +142,10 @@ static int ptp_clock_adjtime(struct posix_clock *pc, struct timex *tx)
 		delta = ktime_to_ns(kt);
 		err = ops->adjtime(ops, delta);
 	} else if (tx->modes & ADJ_FREQUENCY) {
-		err = ops->adjfreq(ops, scaled_ppm_to_ppb(tx->freq));
+		s32 ppb = scaled_ppm_to_ppb(tx->freq);
+		if (ppb > ops->max_adj || ppb < -ops->max_adj)
+			return -ERANGE;
+		err = ops->adjfreq(ops, ppb);
 		ptp->dialed_frequency = tx->freq;
 	} else if (tx->modes == 0) {
 		tx->freq = ptp->dialed_frequency;
-- 
1.7.10.4
