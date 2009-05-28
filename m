From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 03/10] wimax/i2400m: allow kernel commands to device to be logged too
Date: Wed, 27 May 2009 18:05:08 -0700
Message-ID: <05962df1398ad316feb1e20160b7502731bebc97.1243472510.git.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com>
 <e9de4b9426eeeddf56110425cfd88e43828e7146.1243472510.git.inaky@linux.intel.com>
 <22d4458f609ba31f1382e25844125e421dcd4163.1243472510.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:3119 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756386AbZE1BFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 21:05:48 -0400
In-Reply-To: <22d4458f609ba31f1382e25844125e421dcd4163.1243472510.git.inaky@linux.intel.com>
In-Reply-To: <cover.1243472509.git.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By running 'echo 1 > /sys/kernel/debug/wimax:wmxX/i2400m/trace_msg_from_user',
the driver will echo to user space all the commands being sent to the
device from user space, along with the responses.

However, this only helps with the commands being sent from user space;
with this patch, the trace hook is moved to i2400m_msg_to_dev(), which
is the single access point for running commands to the device (both by
user space and the kernel driver). This allows better debugging by
having a complete stream of commands/acks and reports.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |    5 +++++
 drivers/net/wimax/i2400m/driver.c  |   10 ----------
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index b3cadb6..0f58418 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -721,6 +721,8 @@ struct sk_buff *i2400m_msg_to_dev(struct i2400m *i2400m,
 		ack_timeout = HZ;
 	};
 
+	if (unlikely(i2400m->trace_msg_from_user))
+		wimax_msg(&i2400m->wimax_dev, "echo", buf, buf_len, GFP_KERNEL);
 	/* The RX path in rx.c will put any response for this message
 	 * in i2400m->ack_skb and wake us up. If we cancel the wait,
 	 * we need to change the value of i2400m->ack_skb to something
@@ -755,6 +757,9 @@ struct sk_buff *i2400m_msg_to_dev(struct i2400m *i2400m,
 	ack_l3l4_hdr = wimax_msg_data_len(ack_skb, &ack_len);
 
 	/* Check the ack and deliver it if it is ok */
+	if (unlikely(i2400m->trace_msg_from_user))
+		wimax_msg(&i2400m->wimax_dev, "echo",
+			  ack_l3l4_hdr, ack_len, GFP_KERNEL);
 	result = i2400m_msg_size_check(i2400m, ack_l3l4_hdr, ack_len);
 	if (result < 0) {
 		dev_err(dev, "HW BUG? reply to message 0x%04x: %d\n",
diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index d33389f..ef16c57 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -231,20 +231,10 @@ int i2400m_op_msg_from_user(struct wimax_dev *wimax_dev,
 	d_fnstart(4, dev, "(wimax_dev %p [i2400m %p] msg_buf %p "
 		  "msg_len %zu genl_info %p)\n", wimax_dev, i2400m,
 		  msg_buf, msg_len, genl_info);
-	if (unlikely(i2400m->trace_msg_from_user))
-		wimax_msg(&i2400m->wimax_dev, "echo",
-			  msg_buf, msg_len, GFP_KERNEL);
 	ack_skb = i2400m_msg_to_dev(i2400m, msg_buf, msg_len);
 	result = PTR_ERR(ack_skb);
 	if (IS_ERR(ack_skb))
 		goto error_msg_to_dev;
-	if (unlikely(i2400m->trace_msg_from_user)) {
-		const void *ack_data;
-		size_t ack_len;
-		ack_data = wimax_msg_data_len(ack_skb, &ack_len);
-		wimax_msg(&i2400m->wimax_dev, "echo",
-			  ack_data, ack_len, GFP_KERNEL);
-	}
 	result = wimax_msg_send(&i2400m->wimax_dev, ack_skb);
 error_msg_to_dev:
 	d_fnend(4, dev, "(wimax_dev %p [i2400m %p] msg_buf %p msg_len %zu "
-- 
1.6.2.3

