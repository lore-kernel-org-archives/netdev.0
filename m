From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [RFC] tun: Support VIRTIO_NET_HDR_F_DATA_VALID in tun_get_user
Date: Fri, 24 Jun 2016 20:21:02 -0600
Message-ID: <1466821262-11176-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: lorenzo@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57678 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbcFYCVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 22:21:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userspace applications might sometimes process packets from hardware
which has already validated checksum, perform trivial operations and
then queue them back to the network stack. By not recomputing the
checksum here, we can see significant improvement in performance.

Sample application here is CLAT which does IPv6 to IPv4 translation.
IPv6 packets for which checksum is validated in hardware are captured
in CLAT and then translated to IPv4 and then queued back to network
stack. In this case, it is expected that the application would not
corrupt the packet and recomputing the checksum would be redundant.

Pass the hint to kernel to skip checksum validation if
VIRTIO_NET_HDR_F_DATA_VALID is set from userspace.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 drivers/net/tun.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e16487c..a5828a5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1263,6 +1263,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		}
 	}
 
+	if (gso.flags & VIRTIO_NET_HDR_F_DATA_VALID)
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case IFF_TUN:
 		if (tun->flags & IFF_NO_PI) {
-- 
1.9.1
