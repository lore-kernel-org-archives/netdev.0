From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 02/10] wimax/i2400m: trace commands sent from user space on the "echo" pipe
Date: Thu, 28 May 2009 18:12:06 -0700
Message-ID: <44b849d11bf6801a642dd1aa9a70e470d046d273.1243559425.git.inaky@linux.intel.com>
References: <cover.1243559425.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:41659 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753764AbZE2EL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 00:11:59 -0400
In-Reply-To: <cover.1243559425.git.inaky@linux.intel.com>
In-Reply-To: <cover.1243559425.git.inaky@linux.intel.com>
References: <cover.1243559425.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When commands are sent from user space, trace both the command sent
and the answer received over the "echo" pipe instead of over the
"trace" pipe when command tracing is enabled. As well, when the device
sends a reports/indications, send it over the "echo" pipe.

The "trace" pipe is used by the device to send firmware traces;
gets confusing. Another named pipe makes it easier to split debug
information.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   13 ++++++++++---
 drivers/net/wimax/i2400m/rx.c     |    3 +++
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index a21318b..d33389f 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -231,13 +231,20 @@ int i2400m_op_msg_from_user(struct wimax_dev *wimax_dev,
 	d_fnstart(4, dev, "(wimax_dev %p [i2400m %p] msg_buf %p "
 		  "msg_len %zu genl_info %p)\n", wimax_dev, i2400m,
 		  msg_buf, msg_len, genl_info);
+	if (unlikely(i2400m->trace_msg_from_user))
+		wimax_msg(&i2400m->wimax_dev, "echo",
+			  msg_buf, msg_len, GFP_KERNEL);
 	ack_skb = i2400m_msg_to_dev(i2400m, msg_buf, msg_len);
 	result = PTR_ERR(ack_skb);
 	if (IS_ERR(ack_skb))
 		goto error_msg_to_dev;
-	if (unlikely(i2400m->trace_msg_from_user))
-		wimax_msg(&i2400m->wimax_dev, "trace",
-			  msg_buf, msg_len, GFP_KERNEL);
+	if (unlikely(i2400m->trace_msg_from_user)) {
+		const void *ack_data;
+		size_t ack_len;
+		ack_data = wimax_msg_data_len(ack_skb, &ack_len);
+		wimax_msg(&i2400m->wimax_dev, "echo",
+			  ack_data, ack_len, GFP_KERNEL);
+	}
 	result = wimax_msg_send(&i2400m->wimax_dev, ack_skb);
 error_msg_to_dev:
 	d_fnend(4, dev, "(wimax_dev %p [i2400m %p] msg_buf %p msg_len %zu "
diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index f9fc389..a4adc78 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -309,6 +309,9 @@ void i2400m_rx_ctl(struct i2400m *i2400m, struct sk_buff *skb_rx,
 		skb_get(skb_rx);
 		i2400m_queue_work(i2400m, i2400m_report_hook_work,
 				  GFP_KERNEL, &args, sizeof(args));
+		if (unlikely(i2400m->trace_msg_from_user))
+			wimax_msg(&i2400m->wimax_dev, "echo",
+				  l3l4_hdr, size, GFP_KERNEL);
 		result = wimax_msg(&i2400m->wimax_dev, NULL, l3l4_hdr, size,
 				   GFP_KERNEL);
 		if (result < 0)
-- 
1.6.2.3

