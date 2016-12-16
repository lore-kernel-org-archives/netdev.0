From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH RFC] liquidio: make timeout HZ independent
Date: Fri, 16 Dec 2016 07:57:20 +0100
Message-ID: <1481871440-24859-1-git-send-email-hofrat@osadl.org>
Cc: Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Nicholas Mc Guire <hofrat@osadl.org>
To: Derek Chickles <derek.chickles@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:59102 "EHLO www.osadl.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751539AbcLPGzo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 01:55:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

schedule_timeout_* takes a timeout in jiffies but the code currently is
passing in a constant which makes this timeout HZ dependent, so pass it
through msecs_to_jiffies() to fix this up.

Fixes: commit b0d66369edcd ("liquidio VF error handling")
Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Problem found by coccinelle spatch

The current wait time can vary by a factor 10 depending on the HZ
setting chose, which does not seem reasonable here.

The below patch sets the timeout to 100ms - it is though not clear
if this is the intent or if it should be longer/shorter as it is not
clear what HZ setting was assumed during design and used for testing.

This needs an ack by someone who knows the device and can confirm that
100ms is reasonable to wait for completion of in-flight requests.

Patch was compile tested with: x86_64_defconfig + CONFIG_LIQUIDIO_VF=m

Patch is against 4.9.0 (localversion-next is -next-20161216)

 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 70d96c1..eca469e 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -189,7 +189,7 @@ static void pcierror_quiesce_device(struct octeon_device *oct)
 	 */
 
 	/* To allow for in-flight requests */
-	schedule_timeout_uninterruptible(100);
+	schedule_timeout_uninterruptible(msecs_to_jiffies(100));
 
 	if (wait_for_pending_requests(oct))
 		dev_err(&oct->pci_dev->dev, "There were pending requests\n");
-- 
2.1.4
