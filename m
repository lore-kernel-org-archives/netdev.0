From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net PATCH] mlx5: fix bug reading rss_hash_type from CQE
Date: Mon, 22 May 2017 20:13:07 +0200
Message-ID: <149547678696.10455.14428063974882319686.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>, netdev@vger.kernel.org,
        Tariq Toukan <tariqt@mellanox.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47538 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752289AbdEVSNL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 14:13:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Masks for extracting part of the Completion Queue Entry (CQE)
field rss_hash_type was swapped, namely CQE_RSS_HTYPE_IP and
CQE_RSS_HTYPE_L4.

The bug resulted in setting skb->l4_hash, even-though the
rss_hash_type indicated that hash was NOT computed over the
L4 (UDP or TCP) part of the packet.

Added comments from the datasheet, to make it more clear what
these masks are selecting.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/mlx5/device.h |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index dd9a263ed368..a940ec6a046c 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -787,8 +787,14 @@ enum {
 };
 
 enum {
-	CQE_RSS_HTYPE_IP	= 0x3 << 6,
-	CQE_RSS_HTYPE_L4	= 0x3 << 2,
+	CQE_RSS_HTYPE_IP	= 0x3 << 2,
+	/* cqe->rss_hash_type[3:2] - IP destination selected for hash
+	 * (00 = none,  01 = IPv4, 10 = IPv6, 11 = Reserved)
+	 */
+	CQE_RSS_HTYPE_L4	= 0x3 << 6,
+	/* cqe->rss_hash_type[7:6] - L4 destination selected for hash
+	 * (00 = none, 01 = TCP. 10 = UDP, 11 = IPSEC.SPI
+	 */
 };
 
 enum {
