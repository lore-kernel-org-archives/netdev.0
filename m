From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] sfc: Reduce RX scatter buffer size to multiple of 256
Date: Mon, 13 May 2013 18:48:17 +0100
Message-ID: <1368467297.3305.28.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	Linux Kernel Development <linux-kernel@vger.kernel.org>,
	<linux-s390@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29930 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197Ab3EMRsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 13:48:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_start_datapath() asserts that we can fit 2 RX scatter buffers plus
a software structure, each cache-aligned, into a single page.  Where
L1_CACHE_BYTES == 256 and PAGE_SIZE == 4096, which is the case on
s390, this assertion fails.  Reduce EFX_RX_USR_BUF_SIZE to make this
work.

This should also be good for performance, as it ensures that each RX
scatter buffer covers whole cache lines and slightly reduces the use
of DMA writes that can require a read-modify-write on inter-processor
links.

(We could use 2048 - L1_CACHE_BYTES, but EFX_RX_USR_BUF_SIZE also
affects user-level networking where a larger amount of housekeeping
data may be needed.  Although this version of the driver does not
support user-level networking, I prefer to keep scattering behaviour
consistent with the out-of-tree version.)

Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Heiko or Geert, please confirm that this really does fix the build
failure - I don't have an s390 toolchain.

Ben.

 drivers/net/ethernet/sfc/net_driver.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 9bd433a..6c8e1a8 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -72,8 +72,10 @@
 /* Maximum possible MTU the driver supports */
 #define EFX_MAX_MTU (9 * 1024)
 
-/* Size of an RX scatter buffer.  Small enough to pack 2 into a 4K page. */
-#define EFX_RX_USR_BUF_SIZE 1824
+/* Size of an RX scatter buffer.  Small enough to pack 2 into a 4K page,
+ * and should be a multiple of the cache line size.
+ */
+#define EFX_RX_USR_BUF_SIZE	(2048 - 256)
 
 /* Forward declare Precision Time Protocol (PTP) support structure. */
 struct efx_ptp_data;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
