From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH RFC] liquidio: make timeout HZ independent
Date: Mon, 22 Aug 2016 17:45:12 +0200
Message-ID: <1471880712-8823-1-git-send-email-hofrat@osadl.org>
Cc: Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Nicholas Mc Guire <hofrat@osadl.org>
To: Derek Chickles <derek.chickles@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

schedule_timeout_* takes a timeout in jiffies but the code currently is
passing in a constant which makes this timeout HZ dependent, so pass it
through msecs_to_jiffies() to fix this up.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Problem found by coccinelle script

The below patch sets the timeout to 100ms - it is not clear though if this
is the intent or if it should be longer/shorter as it is not clear
what HZ setting was assumed during design and used for testing.
This needs an ack by someone who knows the driver and can confirm that
100ms is reasonable to wait for draining in-flight packets.

Patch was compile tested with: x86_64_defconfig + CONFIG_LIQUIDIO=m

Patch is against 4.8.0-rc2 (localversion-next is -next-20160822)

 drivers/net/ethernet/cavium/liquidio/lio_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 20d6942..bdd6c82 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -379,7 +379,7 @@ static inline void pcierror_quiesce_device(struct octeon_device *oct)
 	force_io_queues_off(oct);
 
 	/* To allow for in-flight requests */
-	schedule_timeout_uninterruptible(100);
+	schedule_timeout_uninterruptible(msecs_to_jiffies(100));
 
 	if (wait_for_pending_requests(oct))
 		dev_err(&oct->pci_dev->dev, "There were pending requests\n");
-- 
2.1.4
