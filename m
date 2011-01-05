From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] xen: netfront: Drop GSO SKBs which do not have csum_blank.
Date: Wed,  5 Jan 2011 13:23:31 +0000
Message-ID: <1294233811-28123-1-git-send-email-ian.campbell@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel@lists.xensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:11573 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167Ab1AENXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 08:23:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Linux network stack expects all GSO SKBs to have ip_summed ==
CHECKSUM_PARTIAL (which implies that the frame contains a partial
checksum) and the Xen network ring protocol similarly expects an SKB
which has GSO set to also have NETRX_csum_blank (which also implies a
partial checksum). Therefore drop such frames on receive otherwise
they will trigger the warning in skb_gso_segment.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: xen-devel@lists.xensource.com
Cc: netdev@vger.kernel.org
---
 drivers/net/xen-netfront.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index cdbeec9..8b8c480 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -836,6 +836,11 @@ static int handle_incoming_queue(struct net_device *dev,
 				dev->stats.rx_errors++;
 				continue;
 			}
+		} else if (skb_is_gso(skb)) {
+			kfree_skb(skb);
+			packets_dropped++;
+			dev->stats.rx_errors++;
+			continue;
 		}
 
 		dev->stats.rx_packets++;
-- 
1.5.6.5

