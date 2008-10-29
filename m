From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 06/13] workaround: detect time stamp when command flags
	are expected
Date: Wed, 29 Oct 2008 15:48:48 +0100
Message-ID: <1226415426.31699.5.camel@ecld0pohly>
References: <1226414697.17450.852.camel@ecld0pohly>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9620 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756081AbYKKO5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 09:57:07 -0500
In-Reply-To: <1226414697.17450.852.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This happens when IP_MULTICAST_LOOP is on. Apparently the time
stamped packet goes through the loop device's start_hard_xmit?!
TODO: find a clean solution.

Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>
---
 net/core/skbuff.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7d714b8..7d9f1dd 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2574,6 +2574,13 @@ void skb_hwtstamp_tx(struct sk_buff *orig_skb,
 	struct sk_buff *skb;
 	int err = -ENOMEM;
 
+	/* sanity check: extra bits set => might be a real time stamp */
+	if (orig_skb->tstamp.tv64 & ~(SKB_TSTAMP_TX_HARDWARE|SKB_TSTAMP_TX_HARDWARE_IN_PROGRESS|SKB_TSTAMP_TX_SOFTWARE)) {
+		printk(KERN_DEBUG
+			"skb_hwtstamp_tx: invalid command flags\n");
+		return;
+	}
+
 	if (!sk)
 		return;
 
-- 
1.6.0.4


