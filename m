From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 04/10] wimax/i2400m: factor out 'state report's TLV handling to a function
Date: Thu, 28 May 2009 18:12:08 -0700
Message-ID: <8ac1101f8cd58a62517ba86745bc000d3a21f09b.1243559425.git.inaky@linux.intel.com>
References: <cover.1243559425.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:45064 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753677AbZE2EL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 00:11:56 -0400
In-Reply-To: <cover.1243559425.git.inaky@linux.intel.com>
In-Reply-To: <cover.1243559425.git.inaky@linux.intel.com>
References: <cover.1243559425.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i2400m_report_state_hook() is going to get messier as we add handling
code.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |   89 ++++++++++++++++++++----------------
 1 files changed, 50 insertions(+), 39 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index 0f58418..b42e347 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -400,7 +400,53 @@ out:
 
 
 /*
- * Parse a 'state report' and extract carrier on/off information
+ * Process a TLV from a 'state report'
+ *
+ * @i2400m: device descriptor
+ * @tlv: pointer to the TLV header; it has been already validated for
+ *     consistent size.
+ * @tag: for error messages
+ *
+ * Act on the TLVs from a 'state report'.
+ */
+static
+void i2400m_report_state_parse_tlv(struct i2400m *i2400m,
+				   const struct i2400m_tlv_hdr *tlv,
+				   const char *tag)
+{
+	struct device *dev = i2400m_dev(i2400m);
+	const struct i2400m_tlv_media_status *ms;
+	const struct i2400m_tlv_system_state *ss;
+	const struct i2400m_tlv_rf_switches_status *rfss;
+
+	if (0 == i2400m_tlv_match(tlv, I2400M_TLV_SYSTEM_STATE, sizeof(*ss))) {
+		ss = container_of(tlv, typeof(*ss), hdr);
+		d_printf(2, dev, "%s: system state TLV "
+			 "found (0x%04x), state 0x%08x\n",
+			 tag, I2400M_TLV_SYSTEM_STATE,
+			 le32_to_cpu(ss->state));
+		i2400m_report_tlv_system_state(i2400m, ss);
+	}
+	if (0 == i2400m_tlv_match(tlv, I2400M_TLV_RF_STATUS, sizeof(*rfss))) {
+		rfss = container_of(tlv, typeof(*rfss), hdr);
+		d_printf(2, dev, "%s: RF status TLV "
+			 "found (0x%04x), sw 0x%02x hw 0x%02x\n",
+			 tag, I2400M_TLV_RF_STATUS,
+			 le32_to_cpu(rfss->sw_rf_switch),
+			 le32_to_cpu(rfss->hw_rf_switch));
+		i2400m_report_tlv_rf_switches_status(i2400m, rfss);
+	}
+	if (0 == i2400m_tlv_match(tlv, I2400M_TLV_MEDIA_STATUS, sizeof(*ms))) {
+		ms = container_of(tlv, typeof(*ms), hdr);
+		d_printf(2, dev, "%s: Media Status TLV: %u\n",
+			 tag, le32_to_cpu(ms->media_status));
+		i2400m_report_tlv_media_status(i2400m, ms);
+	}
+}
+
+
+/*
+ * Parse a 'state report' and extract information
  *
  * @i2400m: device descriptor
  * @l3l4_hdr: pointer to message; it has been already validated for
@@ -409,13 +455,7 @@ out:
  *        declaration is assumed to be congruent with @size (as in
  *        sizeof(*l3l4_hdr) + l3l4_hdr->length == size)
  *
- * Extract from the report state the system state TLV and infer from
- * there if we have a carrier or not. Update our local state and tell
- * netdev.
- *
- * When setting the carrier, it's fine to set OFF twice (for example),
- * as netif_carrier_off() will not generate two OFF events (just on
- * the transitions).
+ * Walk over the TLVs in a report state and act on them.
  */
 static
 void i2400m_report_state_hook(struct i2400m *i2400m,
@@ -424,9 +464,6 @@ void i2400m_report_state_hook(struct i2400m *i2400m,
 {
 	struct device *dev = i2400m_dev(i2400m);
 	const struct i2400m_tlv_hdr *tlv;
-	const struct i2400m_tlv_system_state *ss;
-	const struct i2400m_tlv_rf_switches_status *rfss;
-	const struct i2400m_tlv_media_status *ms;
 	size_t tlv_size = le16_to_cpu(l3l4_hdr->length);
 
 	d_fnstart(4, dev, "(i2400m %p, l3l4_hdr %p, size %zu, %s)\n",
@@ -434,34 +471,8 @@ void i2400m_report_state_hook(struct i2400m *i2400m,
 	tlv = NULL;
 
 	while ((tlv = i2400m_tlv_buffer_walk(i2400m, &l3l4_hdr->pl,
-					     tlv_size, tlv))) {
-		if (0 == i2400m_tlv_match(tlv, I2400M_TLV_SYSTEM_STATE,
-					  sizeof(*ss))) {
-			ss = container_of(tlv, typeof(*ss), hdr);
-			d_printf(2, dev, "%s: system state TLV "
-				 "found (0x%04x), state 0x%08x\n",
-				 tag, I2400M_TLV_SYSTEM_STATE,
-				 le32_to_cpu(ss->state));
-			i2400m_report_tlv_system_state(i2400m, ss);
-		}
-		if (0 == i2400m_tlv_match(tlv, I2400M_TLV_RF_STATUS,
-					  sizeof(*rfss))) {
-			rfss = container_of(tlv, typeof(*rfss), hdr);
-			d_printf(2, dev, "%s: RF status TLV "
-				 "found (0x%04x), sw 0x%02x hw 0x%02x\n",
-				 tag, I2400M_TLV_RF_STATUS,
-				 le32_to_cpu(rfss->sw_rf_switch),
-				 le32_to_cpu(rfss->hw_rf_switch));
-			i2400m_report_tlv_rf_switches_status(i2400m, rfss);
-		}
-		if (0 == i2400m_tlv_match(tlv, I2400M_TLV_MEDIA_STATUS,
-					  sizeof(*ms))) {
-			ms = container_of(tlv, typeof(*ms), hdr);
-			d_printf(2, dev, "%s: Media Status TLV: %u\n",
-				 tag, le32_to_cpu(ms->media_status));
-			i2400m_report_tlv_media_status(i2400m, ms);
-		}
-	}
+					     tlv_size, tlv)))
+		i2400m_report_state_parse_tlv(i2400m, tlv, tag);
 	d_fnend(4, dev, "(i2400m %p, l3l4_hdr %p, size %zu, %s) = void\n",
 		i2400m, l3l4_hdr, size, tag);
 }
-- 
1.6.2.3

