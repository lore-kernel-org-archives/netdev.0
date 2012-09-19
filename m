From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: more accurate network taps in transmit path
Date: Wed, 19 Sep 2012 08:44:49 +0200
Message-ID: <1348037089.26523.397.camel@edumazet-glaptop>
References: <20120918193208.GA19030@darkstar>
	 <1347998905.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120918211423.GA19115@darkstar>
	 <1348034050.26523.325.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamie Gloudon <jamie.gloudon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48082 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260Ab2ISGoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 02:44:54 -0400
Received: by bkwj10 with SMTP id j10so297032bkw.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 23:44:53 -0700 (PDT)
In-Reply-To: <1348034050.26523.325.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

dev_queue_xmit_nit() should be called right before ndo_start_xmit()
calls or we might give wrong packet contents to taps users :

Packet checksum can be changed, or packet can be linearized or
segmented, and segments partially sent for the later case.

Also a memory allocation can fail and packet never really hit the
driver entry point.

Reported-by: Jamie Gloudon <jamie.gloudon@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index dcc673d..52cd1d7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2213,9 +2213,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(skb);
 
-		if (!list_empty(&ptype_all))
-			dev_queue_xmit_nit(skb, dev);
-
 		features = netif_skb_features(skb);
 
 		if (vlan_tx_tag_present(skb) &&
@@ -2250,6 +2247,9 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			}
 		}
 
+		if (!list_empty(&ptype_all))
+			dev_queue_xmit_nit(skb, dev);
+
 		skb_len = skb->len;
 		rc = ops->ndo_start_xmit(skb, dev);
 		trace_net_dev_xmit(skb, rc, dev, skb_len);
@@ -2272,6 +2272,9 @@ gso:
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(nskb);
 
+		if (!list_empty(&ptype_all))
+			dev_queue_xmit_nit(nskb, dev);
+
 		skb_len = nskb->len;
 		rc = ops->ndo_start_xmit(nskb, dev);
 		trace_net_dev_xmit(nskb, rc, dev, skb_len);
