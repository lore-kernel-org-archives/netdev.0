From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH net-next] dp83640: Fix length check for event timestamp status messages
Date: Thu, 21 Aug 2014 15:17:04 +0200
Message-ID: <1408627024-12932-1-git-send-email-christian.riesch@omicron.at>
Cc: Christian Riesch <christian.riesch@omicron.at>,
	Richard Cochran <richardcochran@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay02.ispgateway.de ([80.67.31.25]:60573 "EHLO
	smtprelay02.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754808AbaHUNYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 09:24:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Event timestamp status messages have a variable length, ranging from
1 to 5 words (16 bit words). The current code however requires
a minimum message length of sizeof(*phy_txts). In most cases this
condition is fulfilled due to padding bytes. However, if several events
are signaled in a single message, padding bytes may not be present.
For short event timestamp status messages, the length check will fail,
and the event timestamp will be dropped.

Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
Cc: Richard Cochran <richardcochran@gmail.com>
---

Hi,
I admit that I have never observed any problems due to the
current length check in my application. But I guess this should
be fixed nevertheless.
Cheers,
Christian

 drivers/net/phy/dp83640.c |   23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index c301e4c..d5991ac 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -721,7 +721,7 @@ static inline u16 exts_chan_to_edata(int ch)
 }
 
 static int decode_evnt(struct dp83640_private *dp83640,
-		       void *data, u16 ests)
+		       void *data, int len, u16 ests)
 {
 	struct phy_txts *phy_txts;
 	struct ptp_clock_event event;
@@ -729,6 +729,16 @@ static int decode_evnt(struct dp83640_private *dp83640,
 	int words = (ests >> EVNT_TS_LEN_SHIFT) & EVNT_TS_LEN_MASK;
 	u16 ext_status = 0;
 
+	/* calculate length of the event timestamp status message */
+	if (ests & MULT_EVNT)
+		parsed = (words + 2) * sizeof(u16);
+	else
+		parsed = (words + 1) * sizeof(u16);
+
+	/* check if enough data is available */
+	if (len < parsed)
+		return len;
+
 	if (ests & MULT_EVNT) {
 		ext_status = *(u16 *) data;
 		data += sizeof(ext_status);
@@ -747,10 +757,7 @@ static int decode_evnt(struct dp83640_private *dp83640,
 		dp83640->edata.ns_lo = phy_txts->ns_lo;
 	}
 
-	if (ext_status) {
-		parsed = words + 2;
-	} else {
-		parsed = words + 1;
+	if (!ext_status) {
 		i = ((ests >> EVNT_NUM_SHIFT) & EVNT_NUM_MASK) - EXT_EVENT;
 		ext_status = exts_chan_to_edata(i);
 	}
@@ -768,7 +775,7 @@ static int decode_evnt(struct dp83640_private *dp83640,
 		}
 	}
 
-	return parsed * sizeof(u16);
+	return parsed;
 }
 
 static int match(struct sk_buff *skb, unsigned int type, struct rxts *rxts)
@@ -905,9 +912,9 @@ static void decode_status_frame(struct dp83640_private *dp83640,
 			decode_txts(dp83640, phy_txts);
 			size = sizeof(*phy_txts);
 
-		} else if (PSF_EVNT == type && len >= sizeof(*phy_txts)) {
+		} else if (PSF_EVNT == type) {
 
-			size = decode_evnt(dp83640, ptr, ests);
+			size = decode_evnt(dp83640, ptr, len, ests);
 
 		} else {
 			size = 0;
-- 
1.7.9.5
