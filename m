From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH net-next] loopback: clear pfmemalloc on outgoing skb's
Date: Wed, 1 Feb 2017 16:04:38 -0500
Message-ID: <1485983078-2372-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <kernel-team@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36993 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751192AbdBAVE7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 16:04:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was seeing random disconnects while testing NBD over loopback.  This turned
out to be because NBD sets pfmemalloc on it's socket, however the receiving side
is a user space application so does not have pfmemalloc set on its socket.  This
means that sk_filter_trim_cap will simply drop this packet, under the assumption
that the other side will simply retransmit.  Well we do retransmit, and then the
packet is just dropped again for the same reason.  To keep this from happening
simply clear skb->pfmemalloc on transmit so that we don't drop the packet on the
receive side.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 drivers/net/loopback.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 1e05b7c..13c9126 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -81,6 +81,13 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 	 */
 	skb_dst_force(skb);
 
+	/* If our transmitter was a pfmemalloc socket we need to clear
+	 * pfmemalloc here, otherwise the receiving socket may not be
+	 * pfmemalloc, and if this is a tcp packet then it'll get dropped and
+	 * all traffic will halt.
+	 */
+	skb->pfmemalloc = false;
+
 	skb->protocol = eth_type_trans(skb, dev);
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */
-- 
2.7.4
