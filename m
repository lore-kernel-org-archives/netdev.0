From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 2/3] etherdev: Process is_multicast_ether_addr at same size
 as other operations
Date: Thu, 30 Apr 2015 14:53:54 -0700
Message-ID: <20150430215354.1798.89685.stgit@ahduyck-vm-fedora22>
References: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077AbbD3Vxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 17:53:55 -0400
In-Reply-To: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that we process the address in
is_multicast_ether_addr at the same size as the other calls.  This allows
us to avoid duplicate reads when used with other calls such as
is_zero_ether_addr or eth_addr_copy.  In addition I have added a 64 bit
version of the function so in eth_type_trans we can process the destination
address as a 64 bit value throughout.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/etherdevice.h |   24 +++++++++++++++++++++++-
 net/ethernet/eth.c          |    2 +-
 2 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 606563ef8a72..c4a10f991fe0 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -110,7 +110,29 @@ static inline bool is_zero_ether_addr(const u8 *addr)
  */
 static inline bool is_multicast_ether_addr(const u8 *addr)
 {
-	return 0x01 & addr[0];
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+	u32 a = *(const u32 *)addr;
+#else
+	u16 a = *(const u16 *)addr;
+#endif
+#ifdef __BIG_ENDIAN
+	return 0x01 & (a >> ((sizeof(a) * 8) - 8));
+#else
+	return 0x01 & a;
+#endif
+}
+
+static inline bool is_multicast_ether_addr_64bits(const u8 addr[6+2])
+{
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+#ifdef __BIG_ENDIAN
+	return 0x01 & ((*(const u64 *)addr) >> 56);
+#else
+	return 0x01 & (*(const u64 *)addr);
+#endif
+#else
+	return is_multicast_ether_addr(addr);
+#endif
 }
 
 /**
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 60069318d5d1..21c211e9fd5a 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -159,7 +159,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	skb_pull_inline(skb, ETH_HLEN);
 	eth = eth_hdr(skb);
 
-	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {
+	if (unlikely(is_multicast_ether_addr_64bits(eth->h_dest))) {
 		if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
 			skb->pkt_type = PACKET_BROADCAST;
 		else
