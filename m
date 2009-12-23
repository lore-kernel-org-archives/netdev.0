From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] pktgen: ndo_start_xmit can return NET_XMIT_xxx values
Date: Wed, 23 Dec 2009 15:39:52 -0800
Message-ID: <20091223233951.17072.93304.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: robert@herjulf.net, netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:33539
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756364AbZLWXkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:40:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

This updates pktgen so that it does not decrement skb->users
when it receives valid NET_XMIT_xxx values.  These are now
valid return values from ndo_start_xmit in net-next-2.6.
They also indicate the skb has been consumed.

This fixes pktgen to work correctly with vlan devices.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/core/pktgen.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index a23b45f..de0c2c7 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -250,8 +250,7 @@ struct pktgen_dev {
 	__u64 count;		/* Default No packets to send */
 	__u64 sofar;		/* How many pkts we've sent so far */
 	__u64 tx_bytes;		/* How many bytes we've transmitted */
-	__u64 errors;		/* Errors when trying to transmit,
-				   pkts will be re-sent */
+	__u64 errors;		/* Errors when trying to transmit, */
 
 	/* runtime counters relating to clone_skb */
 
@@ -3465,6 +3464,12 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->seq_num++;
 		pkt_dev->tx_bytes += pkt_dev->last_pkt_size;
 		break;
+	case NET_XMIT_DROP:
+	case NET_XMIT_CN:
+	case NET_XMIT_POLICED:
+		/* skb has been consumed */
+		pkt_dev->errors++;
+		break;
 	default: /* Drivers are not supposed to return other values! */
 		if (net_ratelimit())
 			pr_info("pktgen: %s xmit error: %d\n",

