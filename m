From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH V2] xen/netfront: improve truesize tracking
Date: Mon, 7 Jan 2013 15:32:06 +0000
Message-ID: <1357572726-7059-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>, <xen-devel@lists.xen.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:60795 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab3AGPcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 10:32:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using RX_COPY_THRESHOLD is incorrect if the SKB is actually smaller
than that. We have already accounted for this in
NETFRONT_SKB_CB(skb)->pull_to so use that instead.

Fixes WARN_ON from skb_try_coalesce.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Sander Eikelenboom <linux@eikelenboom.it>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: annie li <annie.li@oracle.com>
Cc: xen-devel@lists.xen.org
Cc: netdev@vger.kernel.org
Cc: stable@kernel.org # 3.7.x only
---
v2:
 - acount frags as a full page as recommended by Eric.
---
 drivers/net/xen-netfront.c |   27 ++++-----------------------
 1 files changed, 4 insertions(+), 23 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index caa0110..b518538 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -959,29 +959,10 @@ err:
 		i = xennet_fill_frags(np, skb, &tmpq);
 
 		/*
-		 * Truesize approximates the size of true data plus
-		 * any supervisor overheads. Adding hypervisor
-		 * overheads has been shown to significantly reduce
-		 * achievable bandwidth with the default receive
-		 * buffer size. It is therefore not wise to account
-		 * for it here.
-		 *
-		 * After alloc_skb(RX_COPY_THRESHOLD), truesize is set
-		 * to RX_COPY_THRESHOLD + the supervisor
-		 * overheads. Here, we add the size of the data pulled
-		 * in xennet_fill_frags().
-		 *
-		 * We also adjust for any unused space in the main
-		 * data area by subtracting (RX_COPY_THRESHOLD -
-		 * len). This is especially important with drivers
-		 * which split incoming packets into header and data,
-		 * using only 66 bytes of the main data area (see the
-		 * e1000 driver for example.)  On such systems,
-		 * without this last adjustement, our achievable
-		 * receive throughout using the standard receive
-		 * buffer size was cut by 25%(!!!).
-		 */
-		skb->truesize += skb->data_len - RX_COPY_THRESHOLD;
+                 * Truesize is the actual allocation size, even if the
+                 * allocation is only partially used.
+                 */
+		skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;
 		skb->len += skb->data_len;
 
 		if (rx->flags & XEN_NETRXF_csum_blank)
-- 
1.7.2.5
