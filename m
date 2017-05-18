From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH 2/5] mlx5: fix bug reading rss_hash_type from
 CQE
Date: Thu, 18 May 2017 17:41:38 +0200
Message-ID: <149512209807.14733.12774004120782832472.stgit@firesoul>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
        netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36860 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933155AbdERPlj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 11:41:39 -0400
In-Reply-To: <149512205297.14733.15729847433404265933.stgit@firesoul>
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
