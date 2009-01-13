From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [PATCH] xen/netfront: do not mark packets of length < MSS as GSO
Date: Tue, 13 Jan 2009 15:30:55 +0000
Message-ID: <1231860655-13182-1-git-send-email-Ian.Campbell@citrix.com>
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:36223 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbZAMPbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 10:31:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux assumes that skbs marked for GSO are longer than MSS. In
particular tcp_tso_segment assumes that skb_segment will return a
chain of at least 2 skbs.

Therefore netfront should not pass such a packet up the stack.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: jgarzik@pobox.com
Cc: netdev@vger.kernel.org
---
 drivers/net/xen-netfront.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index cd6184e..3777c09 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -953,6 +953,11 @@ err:
 		else if (rx->flags & NETRXF_data_validated)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
+		if (skb->data_len < skb_shinfo(skb)->gso_size) {
+			skb_shinfo(skb)->gso_size = 0;
+			skb_shinfo(skb)->gso_type = 0;
+		}
+
 		__skb_queue_tail(&rxq, skb);
 
 		np->rx.rsp_cons = ++i;
-- 
1.5.6.5

