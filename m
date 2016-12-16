From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] liquidio CN23XX: make timeout HZ independent
Date: Fri, 16 Dec 2016 09:10:39 +0100
Message-ID: <1481875839-30860-1-git-send-email-hofrat@osadl.org>
Cc: Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Nicholas Mc Guire <hofrat@osadl.org>
To: Derek Chickles <derek.chickles@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:32890 "EHLO www.osadl.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757141AbcLPIJE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 03:09:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

schedule_timeout_* takes a timeout in jiffies but the code currently is
passing in a constant which makes this timeout HZ dependent, so pass it
through msecs_to_jiffies() to fix this up.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Problem found by coccinelle spatch

The current delay can vary by a factor 10 depending on the HZ
setting chose, which does not seem reasonable here.

The below patch sets the timeout to 10ms - it is though not clear
if this is the intent or if it should be longer/shorter as it is not
clear what HZ setting was assumed during design and used for testing.

This needs an ack by someone who knows the device and can confirm that
10ms is reasonable to wait for completion of queuing.

Patch was compile tested with: x86_64_defconfig + CONFIG_LIQUIDIO_VF=m
Note that this driver has a large number of sparse warnings !

Patch is against 4.9.0 (localversion-next is -next-20161216)

 drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c | 2 ++-
 1 file changed, 2 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
index 73696b42..1a0fcbe 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
@@ -171,7 +171,8 @@ int octeon_mbox_write(struct octeon_device *oct,
 			count = 0;
 			while (readq(mbox->mbox_write_reg) !=
 			       OCTEON_PFVFACK) {
-				schedule_timeout_uninterruptible(10);
+				schedule_timeout_uninterruptible(
+							msecs_to_jiffies(10));
 				if (count++ == LIO_MBOX_WRITE_WAIT_CNT) {
 					ret = OCTEON_MBOX_STATUS_FAILED;
 					break;
-- 
2.1.4
