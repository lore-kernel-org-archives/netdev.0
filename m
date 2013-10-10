From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net] {xfrm, sctp} Stick to software crc32 even if hardware is capable of that
Date: Thu, 10 Oct 2013 13:51:36 +0800
Message-ID: <1381384296-1821-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40766 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026Ab3JJFvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 01:51:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

igb/ixgbe have hardware sctp checksum support, when this feature is enabled
and also IPsec is armed to protect sctp traffic, ugly things happened as
xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum every thing
up and pack the 16bits result in the checksum field). The result is fail
establishment of sctp communication.

And I saw another point in this part of code, when IPsec is not armed,
sctp communication is good, however setting setting CHECKSUM_PARTIAL will
make xfrm_output compute dummy checksum values which will be overwritten by
hardware lately.

So this patch try to solve above two issues together.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
note:
  igb/ixgbe hardware is not handy on my side, so just build test only.

---
 net/sctp/output.c |   27 +++++++++++++++++++--------
 1 file changed, 19 insertions(+), 8 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 0ac3a65..f0b9cc5 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -372,6 +372,16 @@ static void sctp_packet_set_owner_w(struct sk_buff *skb, struct sock *sk)
 	atomic_inc(&sk->sk_wmem_alloc);
 }
 
+static int is_xfrm_armed(struct dst_entry *dst)
+{
+#ifdef CONFIG_XFRM
+	/* If dst->xfrm is valid, this skb needs to be transformed */
+	return dst->xfrm != NULL;
+#else
+	return 0;
+#endif
+}
+
 /* All packets are sent to the network through this function from
  * sctp_outq_tail().
  *
@@ -536,20 +546,21 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
 	 */
 	if (!sctp_checksum_disable) {
-		if (!(dst->dev->features & NETIF_F_SCTP_CSUM)) {
+		if ((!(dst->dev->features & NETIF_F_SCTP_CSUM)) ||
+			is_xfrm_armed(dst)) {
+
 			__u32 crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
 
 			/* 3) Put the resultant value into the checksum field in the
 			 *    common header, and leave the rest of the bits unchanged.
 			 */
 			sh->checksum = sctp_end_cksum(crc32);
-		} else {
-			/* no need to seed pseudo checksum for SCTP */
-			nskb->ip_summed = CHECKSUM_PARTIAL;
-			nskb->csum_start = (skb_transport_header(nskb) -
-			                    nskb->head);
-			nskb->csum_offset = offsetof(struct sctphdr, checksum);
-		}
+		} else
+			/* Mark skb as CHECKSUM_UNNECESSARY to let hardware compute
+			 * the checksum, and also avoid xfrm_output to do unceccessary
+			 * checksum.
+			 */
+			nskb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
 	/* IP layer ECN support
-- 
1.7.9.5
