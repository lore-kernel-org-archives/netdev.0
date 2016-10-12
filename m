From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] xen-netback: fix type mismatch warning
Date: Wed, 12 Oct 2016 16:54:01 +0200
Message-ID: <20161012145434.2493788-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        David Vrabel <david.vrabel@citrix.com>,
        xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Wei Liu <wei.liu2@citrix.com>,
        Paul Durrant <paul.durrant@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wiht the latest rework of the xen-netback driver, we get a warning
on ARM about the types passed into min():

drivers/net/xen-netback/rx.c: In function 'xenvif_rx_next_chunk':
include/linux/kernel.h:739:16: error: comparison of distinct pointer types lacks a cast [-Werror]

The reason is that XEN_PAGE_SIZE is not size_t here. There
is no actual bug, and we can easily avoid the warning using the
min_t() macro instead of min().

Fixes: eb1723a29b9a ("xen-netback: refactor guest rx")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/xen-netback/rx.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netback/rx.c b/drivers/net/xen-netback/rx.c
index 8e9ade6ccf18..aeb150258c6c 100644
--- a/drivers/net/xen-netback/rx.c
+++ b/drivers/net/xen-netback/rx.c
@@ -337,9 +337,9 @@ static void xenvif_rx_next_chunk(struct xenvif_queue *queue,
 	frag_data += pkt->frag_offset;
 	frag_len -= pkt->frag_offset;
 
-	chunk_len = min(frag_len, XEN_PAGE_SIZE - offset);
-	chunk_len = min(chunk_len,
-			XEN_PAGE_SIZE -	xen_offset_in_page(frag_data));
+	chunk_len = min_t(size_t, frag_len, XEN_PAGE_SIZE - offset);
+	chunk_len = min_t(size_t, chunk_len, XEN_PAGE_SIZE -
+					     xen_offset_in_page(frag_data));
 
 	pkt->frag_offset += chunk_len;
 
-- 
2.9.0
