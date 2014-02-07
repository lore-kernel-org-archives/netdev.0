From: Pravin <pshelar@nicira.com>
Subject: [PATCH net] net: Clear local_df only if crossing namespace.
Date: Fri,  7 Feb 2014 14:12:38 -0800
Message-ID: <1391811158-11433-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin <pshelar@nicira.com>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:45755 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751352AbaBGWMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 17:12:41 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so3292607pdb.24
        for <netdev@vger.kernel.org>; Fri, 07 Feb 2014 14:12:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 239c78db9c41a8 (net: clear local_df when passing skb between
namespaces) clears local_df unconditionally.  But upper layer should
be able request local fragmentation within a namespace.  Currently
OVS sets local_df for tunnel packets and then skb_scrub_packe()
resets it which is not correct.

Therefore following patch resets local_df only packet is crossing
namespace.

CC: Templin, Fred L <Fred.L.Templin@boeing.com>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/core/skbuff.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5976ef0..4ba262f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3905,12 +3905,13 @@ EXPORT_SYMBOL(skb_try_coalesce);
  */
 void skb_scrub_packet(struct sk_buff *skb, bool xnet)
 {
-	if (xnet)
+	if (xnet) {
 		skb_orphan(skb);
+		skb->local_df = 0;
+	}
 	skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
 	skb->skb_iif = 0;
-	skb->local_df = 0;
 	skb_dst_drop(skb);
 	skb->mark = 0;
 	secpath_reset(skb);
-- 
1.7.9.5
