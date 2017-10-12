From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net] liquidio: fix timespec64_to_ns typo
Date: Thu, 12 Oct 2017 11:48:31 +0200
Message-ID: <20171012094841.3178599-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Intiyaz Basha <intiyaz.basha@cavium.com>,
        Rick Farrington <ricardo.farrington@cavium.com>,
        VSR Burru <veerasenareddy.burru@cavium.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While experimenting with changes to the timekeeping code, I
ran into a build error in the liquidio driver:

drivers/net/ethernet/cavium/liquidio/lio_main.c: In function 'liquidio_ptp_settime':
drivers/net/ethernet/cavium/liquidio/lio_main.c:1850:22: error: passing argument 1 of 'timespec_to_ns' from incompatible pointer type [-Werror=incompatible-pointer-types]

The driver had a type mismatch since it was first merged, but
this never caused problems because it is only built on 64-bit
architectures that define timespec and timespec64 to the same
type.

If we ever want to compile-test the driver on 32-bit or change
the way that 64-bit timespec64 is defined, we need to fix it,
so let's just do it now.

Fixes: f21fb3ed364b ("Add support of Cavium Liquidio ethernet adapters")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 963803bc6633..eafae3eb4fed 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1847,7 +1847,7 @@ static int liquidio_ptp_settime(struct ptp_clock_info *ptp,
 	struct lio *lio = container_of(ptp, struct lio, ptp_info);
 	struct octeon_device *oct = (struct octeon_device *)lio->oct_dev;
 
-	ns = timespec_to_ns(ts);
+	ns = timespec64_to_ns(ts);
 
 	spin_lock_irqsave(&lio->ptp_lock, flags);
 	lio_pci_writeq(oct, ns, CN6XXX_MIO_PTP_CLOCK_HI);
-- 
2.9.0
