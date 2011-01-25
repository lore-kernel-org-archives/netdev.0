From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 2/2] xen: netfront: Drop GSO SKBs which do not have csum_blank.
Date: Tue, 25 Jan 2011 17:10:00 +0000
Message-ID: <1295975400-538-2-git-send-email-ian.campbell@citrix.com>
References: <1295975376.14780.6595.camel@zakaz.uk.xensource.com>
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:35120 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222Ab1AYRKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 12:10:06 -0500
In-Reply-To: <1295975376.14780.6595.camel@zakaz.uk.xensource.com>
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
 drivers/net/xen-netfront.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 4dc347b..0ea47da 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -818,6 +818,10 @@ static int validate_incoming_skb(struct sk_buff *skb)
 	if (skb->ip_summed == CHECKSUM_PARTIAL && skb_checksum_setup(skb))
 		return 0;
 
+	/* A GSO SKB must be partial. */
+	if (skb->ip_summed != CHECKSUM_PARTIAL && skb_is_gso(skb))
+		return 0;
+
 	return 1;
 }
 
-- 
1.5.6.5

