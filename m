From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net 1/2] sfc: use 64-bit writes for PIO.
Date: Tue, 20 May 2014 08:48:14 +0100
Message-ID: <537B08BE.4080807@solarflare.com>
References: <537B07ED.4080104@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11121 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbaETHsR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 03:48:17 -0400
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

Patch to open-code the memory copy routines.
32bit writes over the PCI bus causes data corruption.

Fixes:ee45fd92c739db5b7950163d91dfe5f016af6d24

orig-hg-hash: 853f313def1e5e9c733f980f2b4e6330a7d063ef
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/tx.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index fa94753..bd6a4b8 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -189,6 +189,20 @@ struct efx_short_copy_buffer {
        u8 buf[L1_CACHE_BYTES];
 };

+/* Copy in explicit 64-bit writes. */
+static void efx_memcpy_64(void *dest, void *src, size_t len)
+{
+       uint64_t *src64 = src, *dest64 = dest;
+       size_t i, l64 = len / 8;
+
+       WARN_ON_ONCE(len % 8 != 0);
+       WARN_ON_ONCE(((u8 *)dest - (u8 *) 0) % 8 != 0);
+       BUILD_BUG_ON(sizeof(uint64_t) != 8);
+
+       for(i = 0; i < l64; ++i)
+               dest64[i] = src64[i];
+}
+
 /* Copy to PIO, respecting that writes to PIO buffers must be dword aligned.
  * Advances piobuf pointer. Leaves additional data in the copy buffer.
  */
@@ -198,7 +212,7 @@ static void efx_memcpy_toio_aligned(struct efx_nic *efx, u8 __iomem **piobuf,
 {
        int block_len = len & ~(sizeof(copy_buf->buf) - 1);

-       memcpy_toio(*piobuf, data, block_len);
+       efx_memcpy_64(*piobuf, data, block_len);
        *piobuf += block_len;
        len -= block_len;

@@ -230,7 +244,7 @@ static void efx_memcpy_toio_aligned_cb(struct efx_nic *efx, u8 __iomem **piobuf,
                if (copy_buf->used < sizeof(copy_buf->buf))
                        return;

-               memcpy_toio(*piobuf, copy_buf->buf, sizeof(copy_buf->buf));
+               efx_memcpy_64(*piobuf, copy_buf->buf, sizeof(copy_buf->buf));
                *piobuf += sizeof(copy_buf->buf);
                data += copy_to_buf;
                len -= copy_to_buf;
@@ -245,7 +259,7 @@ static void efx_flush_copy_buffer(struct efx_nic *efx, u8 __iomem *piobuf,
 {
        /* if there's anything in it, write the whole buffer, including junk */
        if (copy_buf->used)
-               memcpy_toio(piobuf, copy_buf->buf, sizeof(copy_buf->buf));
+               efx_memcpy_64(piobuf, copy_buf->buf, sizeof(copy_buf->buf));
 }

 /* Traverse skb structure and copy fragments in to PIO buffer.
@@ -304,8 +318,8 @@ efx_enqueue_skb_pio(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
                 */
                BUILD_BUG_ON(L1_CACHE_BYTES >
                             SKB_DATA_ALIGN(sizeof(struct skb_shared_info)));
-               memcpy_toio(tx_queue->piobuf, skb->data,
-                           ALIGN(skb->len, L1_CACHE_BYTES));
+               efx_memcpy_64(tx_queue->piobuf, skb->data,
+                             ALIGN(skb->len, L1_CACHE_BYTES));
        }

        EFX_POPULATE_QWORD_5(buffer->option,

The information contained in this message is confidential and is intended for the addressee(s) only. If you have received this message in error, please notify the sender immediately and delete the message. Unless you are an addressee (or authorized to receive for an addressee), you may not use, copy or disclose to anyone this message or any information contained in this message. The unauthorized use, disclosure, copying or alteration of this message is strictly prohibited.
