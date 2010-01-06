From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] e1000: enhance frame fragment detection
Date: Wed, 6 Jan 2010 15:27:42 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1001061525050.4056@jbrandeb-desk1.amr.corp.intel.com>
References: <20091228201005.GC18422@hmsreliant.think-freely.org> <alpine.WNT.2.00.1001051341110.4056@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>, jesse.brandeburg@intel.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37274 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756530Ab0AFX1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 18:27:43 -0500
In-Reply-To: <alpine.WNT.2.00.1001051341110.4056@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

a counter patch, without atomic ops, since we are protected by napi when 
modifying this variable.

Originally From: Neil Horman <nhorman@tuxdriver.com>
Modified by: Jesse Brandeburg <jesse.brandeburg@intel.com>

<original message>
Hey all-
	A security discussion was recently given:
http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
And a patch that I submitted awhile back was brought up.  Apparently some of
their testing revealed that they were able to force a buffer fragment in e1000
in which the trailing fragment was greater than 4 bytes.  As a result the
fragment check I introduced failed to detect the fragement and a partial
invalid frame was passed up into the network stack.  I've written this patch
to correct it.  I'm in the process of testing it now, but it makes good
logical sense to me.  Effectively it maintains a per-adapter state variable
which detects a non-EOP frame, and discards it and subsequent non-EOP frames
leading up to _and_ _including_ the next positive-EOP frame (as it is by
definition the last fragment).  This should prevent any and all partial frames
from entering the network stack from e1000.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000/e1000.h      |    2 ++
 drivers/net/e1000/e1000_main.c |   13 +++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)


diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 2a567df..e8932db 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -326,6 +326,8 @@ struct e1000_adapter {
 	/* for ioport free */
 	int bars;
 	int need_ioport;
+
+	bool discarding;
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7e855f9..9bc9fcd 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3850,13 +3850,22 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		length = le16_to_cpu(rx_desc->length);
 		/* !EOP means multiple descriptors were used to store a single
-		 * packet, also make sure the frame isn't just CRC only */
-		if (unlikely(!(status & E1000_RXD_STAT_EOP) || (length <= 4))) {
+		 * packet, if thats the case we need to toss it.  In fact, we
+		 * to toss every packet with the EOP bit clear and the next
+		 * frame that _does_ have the EOP bit set, as it is by
+		 * definition only a frame fragment
+		 */
+		if (unlikely(!(status & E1000_RXD_STAT_EOP)))
+			adapter->discarding = true;
+
+		if (adapter->discarding) {
 			/* All receives must fit into a single buffer */
 			E1000_DBG("%s: Receive packet consumed multiple"
 				  " buffers\n", netdev->name);
 			/* recycle */
 			buffer_info->skb = skb;
+			if (status & E1000_RXD_STAT_EOP)
+				adapter->discarding = false;
 			goto next_desc;
 		}
 
