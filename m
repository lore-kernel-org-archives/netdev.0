From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 07/15] nfp: correct return codes when msleep gets interrupted
Date: Tue, 21 Mar 2017 17:59:13 -0700
Message-ID: <20170322005921.10965-8-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36564 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758543AbdCVBHw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:07:52 -0400
Received: by mail-pg0-f41.google.com with SMTP id g2so100802175pge.3
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:07:52 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

msleep_interruptible() returns time left to wait, not error
code.  Return ERESTARTSYS when interrupted.

While at it correct a comment and make the polling a bit
more aggressive.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
index 34c50987c377..17822ae4a17f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
@@ -209,9 +209,8 @@ nfp_nsp_wait_reg(struct nfp_cpp *cpp, u64 *reg,
 		if ((*reg & mask) == val)
 			return 0;
 
-		err = msleep_interruptible(100);
-		if (err)
-			return err;
+		if (msleep_interruptible(25))
+			return -ERESTARTSYS;
 
 		if (time_after(start_time, wait_until))
 			return -ETIMEDOUT;
@@ -228,7 +227,7 @@ nfp_nsp_wait_reg(struct nfp_cpp *cpp, u64 *reg,
  *
  * Return: 0 for success with no result
  *
- *	 1..255 for NSP completion with a result code
+ *	 positive value for NSP completion with a result code
  *
  *	-EAGAIN if the NSP is not yet present
  *	-ENODEV if the NSP is not a supported model
@@ -380,9 +379,10 @@ int nfp_nsp_wait(struct nfp_nsp *state)
 		if (err != -EAGAIN)
 			break;
 
-		err = msleep_interruptible(100);
-		if (err)
+		if (msleep_interruptible(25)) {
+			err = -ERESTARTSYS;
 			break;
+		}
 
 		if (time_after(start_time, wait_until)) {
 			err = -ETIMEDOUT;
-- 
2.11.0
