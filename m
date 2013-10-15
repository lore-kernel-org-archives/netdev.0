From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv3 net] {xfrm, sctp} Stick to software crc32 even if hardware is capable of that
Date: Tue, 15 Oct 2013 17:19:37 +0800
Message-ID: <1381828777-15894-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59151 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180Ab3JOJT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 05:19:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

igb/ixgbe have hardware sctp checksum support, when this feature is enabled
and also IPsec is armed to protect sctp traffic, ugly things happened as
xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum every thing
up and pack the 16bits result in the checksum field). The result is fail
establishment of sctp communication.

Signed-off-by: Fan Du <fan.du@windriver.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Acked-by: Vlad Yasevich <vyasevich@gmail.com>
---
v3:
  - Rename is_xfrm_armed by dst_xfrm
  - Move this funtion in include/net/dst.h

v2:
  - Split v1 into two separate patches.

---
 include/net/dst.h |   12 ++++++++++++
 net/sctp/output.c |    3 ++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 211dcf1..44995c1 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -478,10 +478,22 @@ static inline struct dst_entry *xfrm_lookup(struct net *net,
 {
 	return dst_orig;
 } 
+
+static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
+{
+	return NULL;
+}
+
 #else
 struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 			      const struct flowi *fl, struct sock *sk,
 			      int flags);
+
+/* skb attached with this dst needs transformation if dst->xfrm is valid */
+static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
+{
+	return dst->xfrm;
+}
 #endif
 
 #endif /* _NET_DST_H */
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 0ac3a65..24b3718 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -536,7 +536,8 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
 	 */
 	if (!sctp_checksum_disable) {
-		if (!(dst->dev->features & NETIF_F_SCTP_CSUM)) {
+		if (!(dst->dev->features & NETIF_F_SCTP_CSUM) ||
+			(dst_xfrm(dst) != NULL)) {
 			__u32 crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
 
 			/* 3) Put the resultant value into the checksum field in the
-- 
1.7.9.5
