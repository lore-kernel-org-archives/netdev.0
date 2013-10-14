From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 RESEND] {xfrm, sctp} Stick to software crc32 even if hardware is capable of that
Date: Mon, 14 Oct 2013 15:27:38 +0800
Message-ID: <1381735658-15478-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45391 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673Ab3JNH1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 03:27:55 -0400
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
 net/sctp/output.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 0ac3a65..6de6402 100644
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
@@ -536,7 +546,9 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
 	 */
 	if (!sctp_checksum_disable) {
-		if (!(dst->dev->features & NETIF_F_SCTP_CSUM)) {
+		if ((!(dst->dev->features & NETIF_F_SCTP_CSUM)) ||
+			is_xfrm_armed(dst)) {
+
 			__u32 crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
 
 			/* 3) Put the resultant value into the checksum field in the
-- 
1.7.9.5
