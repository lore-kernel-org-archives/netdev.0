From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net 2/2] sfc: Restrict PIO to 64-bit architectures
Date: Tue, 20 May 2014 08:48:29 +0100
Message-ID: <537B08CD.90607@solarflare.com>
References: <537B07ED.4080104@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11130 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbaETHsd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 03:48:33 -0400
In-Reply-To: <537B07ED.4080104@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

The linux net driver uses memcpy_toio() in order to copy into
the PIO buffers.
Even on a 64bit machine this causes 32bit accesses to a write-
combined memory region.
There are hardware limitations that mean that only
64bit naturally aligned accesses are safe in all cases. Due to being
write-combined memory region two 32bit accesses may be coalesced to
form a 64bit non 64bit aligned access.
Solution was to open-code the memory copy routines using pointers
and to only enable PIO for x86_64 machines.

Enable PIO for x86_64 architecture only.
Not tested on platforms other than x86_64.

Fixes:ee45fd92c739db5b7950163d91dfe5f016af6d24

orig-hg-hash: 53dc43553d9bbe1c5a64c49e580ca571ddc470ae
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/io.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/sfc/io.h b/drivers/net/ethernet/sfc/io.h
index 4d3f119..adadcf0 100644
--- a/drivers/net/ethernet/sfc/io.h
+++ b/drivers/net/ethernet/sfc/io.h
@@ -66,10 +66,18 @@
 #define EFX_USE_QWORD_IO 1
 #endif

+/* PIO only works on 64-bit architectures */
+#if BITS_PER_LONG == 64
+/* not strictly necessary to restrict to x86 arch, but done for safety
+ * since unusual write combining behaviour can break PIO.
+ */
+#ifdef CONFIG_X86_64
 /* PIO is a win only if write-combining is possible */
 #ifdef ARCH_HAS_IOREMAP_WC
 #define EFX_USE_PIO 1
 #endif
+#endif
+#endif

 #ifdef EFX_USE_QWORD_IO
 static inline void _efx_writeq(struct efx_nic *efx, __le64 value,
The information contained in this message is confidential and is intended for the addressee(s) only. If you have received this message in error, please notify the sender immediately and delete the message. Unless you are an addressee (or authorized to receive for an addressee), you may not use, copy or disclose to anyone this message or any information contained in this message. The unauthorized use, disclosure, copying or alteration of this message is strictly prohibited.
