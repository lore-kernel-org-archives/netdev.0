From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 1/8] gso: Do not perform partial GSO if number
 of partial segments is 1 or less
Date: Mon, 02 May 2016 09:38:12 -0700
Message-ID: <20160502163812.11809.15101.stgit@ahduyck-xeon-server>
References: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, alexander.duyck@gmail.com,
	davem@davemloft.net, galp@mellanox.com, ogerlitz@mellanox.com,
	eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36633 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbcEBQiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:38:14 -0400
Received: by mail-pa0-f54.google.com with SMTP id bt5so75642897pac.3
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:38:14 -0700 (PDT)
In-Reply-To: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the event that the number of partial segments is equal to 1 we don't
really need to perform partial segmentation offload.  As such we should
skip multiplying the MSS and instead just clear the partial_segs value
since it will not provide any gain to advertise the frame as being GSO when
it is a single frame.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/skbuff.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7a1d48983f81..b8dd2d2e2256 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3101,7 +3101,10 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	 */
 	if (features & NETIF_F_GSO_PARTIAL) {
 		partial_segs = len / mss;
-		mss *= partial_segs;
+		if (partial_segs > 1)
+			mss *= partial_segs;
+		else
+			partial_segs = 0;
 	}
 
 	headroom = skb_headroom(head_skb);
