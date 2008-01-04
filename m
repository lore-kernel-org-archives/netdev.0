From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/6]: [CASSINI]: Fix endianness bug.
Date: Fri, 04 Jan 2008 00:33:04 -0800 (PST)
Message-ID: <20080104.003304.103588850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panther@balabit.hu, bazsi@balabit.hu, hidden@sch.bme.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51620
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753532AbYADIvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 03:51:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[CASSINI]: Fix endianness bug.

Here's proposed fix for RX checksum handling in cassini; it affects
little-endian working with half-duplex gigabit, but obviously needs
testing on big-endian too.

The problem is, we need to convert checksum to fixed-endian *before*
correcting for (unstripped) FCS.  On big-endian it won't matter
(conversion is no-op), on little-endian it will, but only if FCS is
not stripped by hardware; i.e. in half-duplex gigabit mode when
->crc_size is set.

cassini.c part is that fix, cassini.h one consists of trivial
endianness annotations.  With that applied the sucker is endian-clean,
according to sparse.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/cassini.c |    8 +++++---
 drivers/net/cassini.h |   18 +++++++++---------
 2 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 7df31b5..9030ca5 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -1979,6 +1979,7 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 	struct cas_page *page;
 	struct sk_buff *skb;
 	void *addr, *crcaddr;
+	__sum16 csum;
 	char *p;
 
 	hlen = CAS_VAL(RX_COMP2_HDR_SIZE, words[1]);
@@ -2158,14 +2159,15 @@ end_copy_pkt:
 		skb_put(skb, alloclen);
 	}
 
-	i = CAS_VAL(RX_COMP4_TCP_CSUM, words[3]);
+	csum = (__force __sum16)htons(CAS_VAL(RX_COMP4_TCP_CSUM, words[3]));
 	if (cp->crc_size) {
 		/* checksum includes FCS. strip it out. */
-		i = csum_fold(csum_partial(crcaddr, cp->crc_size, i));
+		csum = csum_fold(csum_partial(crcaddr, cp->crc_size,
+					      csum_unfold(csum)));
 		if (addr)
 			cas_page_unmap(addr);
 	}
-	skb->csum = ntohs(i ^ 0xffff);
+	skb->csum = csum_unfold(~csum);
 	skb->ip_summed = CHECKSUM_COMPLETE;
 	skb->protocol = eth_type_trans(skb, cp->dev);
 	return len;
diff --git a/drivers/net/cassini.h b/drivers/net/cassini.h
index 2f93f83..552af89 100644
--- a/drivers/net/cassini.h
+++ b/drivers/net/cassini.h
@@ -4122,8 +4122,8 @@ cas_saturn_patch_t cas_saturn_patch[] = {
 							     inserted into
 							     outgoing frame. */
 struct cas_tx_desc {
-	u64     control;
-	u64     buffer;
+	__le64     control;
+	__le64     buffer;
 };
 
 /* descriptor ring for free buffers contains page-sized buffers. the index
@@ -4131,8 +4131,8 @@ struct cas_tx_desc {
  * the completion ring.
  */
 struct cas_rx_desc {
-	u64     index;
-	u64     buffer;
+	__le64     index;
+	__le64     buffer;
 };
 
 /* received packets are put on the completion ring. */
@@ -4210,10 +4210,10 @@ struct cas_rx_desc {
 #define RX_INDEX_RELEASE                  0x0000000000002000ULL
 
 struct cas_rx_comp {
-	u64     word1;
-	u64     word2;
-	u64     word3;
-	u64     word4;
+	__le64     word1;
+	__le64     word2;
+	__le64     word3;
+	__le64     word4;
 };
 
 enum link_state {
@@ -4252,7 +4252,7 @@ struct cas_init_block {
 	struct cas_rx_comp rxcs[N_RX_COMP_RINGS][INIT_BLOCK_RX_COMP];
 	struct cas_rx_desc rxds[N_RX_DESC_RINGS][INIT_BLOCK_RX_DESC];
 	struct cas_tx_desc txds[N_TX_RINGS][INIT_BLOCK_TX];
-	u64 tx_compwb;
+	__le64 tx_compwb;
 };
 
 /* tiny buffers to deal with target abort issue. we allocate a bit
-- 
1.5.4.rc2.17.g257f

