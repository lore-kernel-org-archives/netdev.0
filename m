From: Vlad Yasevich <vyasevich@gmail.com>
Subject: [PATCH v4 net 3/3] sctp: Perform software checksum if packet has to be fragmented.
Date: Tue, 15 Oct 2013 22:01:31 -0400
Message-ID: <1381888891-31186-4-git-send-email-vyasevich@gmail.com>
References: <1381888891-31186-1-git-send-email-vyasevich@gmail.com>
Cc: linux-sctp@vger.kernel.org, fan.du@windriver.com,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f53.google.com ([209.85.128.53]:37196 "EHLO
	mail-qe0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933096Ab3JPCCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 22:02:09 -0400
In-Reply-To: <1381888891-31186-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IP/IPv6 fragmentation knows how to compute only TCP/UDP checksum.
This causes problems if SCTP packets has to be fragmented and
ipsummed has been set to PARTIAL due to checksum offload support.
This condition can happen when retransmitting after MTU discover,
or when INIT or other control chunks are larger then MTU.
Check for the rare fragmentation condition in SCTP and use software
checksum calculation in this case.

CC: Fan Du <fan.du@windriver.com>
Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
---
 net/sctp/output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index d35b54c..3191373 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -537,7 +537,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 */
 	if (!sctp_checksum_disable) {
 		if (!(dst->dev->features & NETIF_F_SCTP_CSUM) ||
-		    (dst_xfrm(dst) != NULL)) {
+		    (dst_xfrm(dst) != NULL) || packet->ipfragok) {
 			__u32 crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
 
 			/* 3) Put the resultant value into the checksum field in the
-- 
1.8.3.1
