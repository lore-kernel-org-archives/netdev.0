From: greearb@candelatech.com
Subject: [PATCH 1/4] mac80211-hwsim: notify user-space about channel change.
Date: Fri,  3 Apr 2015 14:12:00 -0700
Message-ID: <1428095523-374-1-git-send-email-greearb@candelatech.com>
Cc: johannes@sipsolutions.net, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:34583 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbbDCVMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 17:12:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

The goal is to allow the user-space application to properly
filter packets before sending them down to the kernel.  This
should more closely mimic what a real piece of hardware would
do.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 drivers/net/wireless/mac80211_hwsim.c | 48 +++++++++++++++++++++++++++++++++++
 drivers/net/wireless/mac80211_hwsim.h |  6 +++++
 2 files changed, 54 insertions(+)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 8908be6..d0e88b2 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -871,6 +871,52 @@ static bool hwsim_ps_rx_ok(struct mac80211_hwsim_data *data,
 	return true;
 }
 
+static void mac80211_hwsim_check_nl_notify(struct mac80211_hwsim_data *data)
+{
+	struct sk_buff *skb;
+	u32 center_freq = 0;
+	u32 _portid;
+	void *msg_head;
+
+	/* wmediumd mode check */
+	_portid = ACCESS_ONCE(wmediumd_portid);
+
+	if (!_portid)
+		return;
+
+	skb = genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_ATOMIC);
+	if (skb == NULL)
+		goto err_print;
+
+	msg_head = genlmsg_put(skb, 0, 0, &hwsim_genl_family, 0,
+			       HWSIM_CMD_NOTIFY);
+	if (msg_head == NULL) {
+		printk(KERN_DEBUG "mac80211_hwsim: problem with msg_head, notify\n");
+		goto nla_put_failure;
+	}
+
+	if (nla_put(skb, HWSIM_ATTR_ADDR_TRANSMITTER,
+		    ETH_ALEN, data->addresses[1].addr))
+		goto nla_put_failure;
+
+	if (data->channel)
+		center_freq = data->channel->center_freq;
+
+	if (nla_put_u32(skb, HWSIM_ATTR_FREQ, center_freq))
+		goto nla_put_failure;
+
+	genlmsg_end(skb, msg_head);
+	if (genlmsg_unicast(&init_net, skb, _portid))
+		goto err_print;
+
+	return;
+
+nla_put_failure:
+	nlmsg_free(skb);
+err_print:
+	printk(KERN_DEBUG "mac80211_hwsim: error occurred in %s\n", __func__);
+}
+
 static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 				       struct sk_buff *my_skb,
 				       int dst_portid)
@@ -1465,6 +1511,8 @@ static int mac80211_hwsim_config(struct ieee80211_hw *hw, u32 changed)
 				      HRTIMER_MODE_REL);
 	}
 
+	mac80211_hwsim_check_nl_notify(data);
+
 	return 0;
 }
 
diff --git a/drivers/net/wireless/mac80211_hwsim.h b/drivers/net/wireless/mac80211_hwsim.h
index 66e1c73..f0fc495c 100644
--- a/drivers/net/wireless/mac80211_hwsim.h
+++ b/drivers/net/wireless/mac80211_hwsim.h
@@ -71,6 +71,11 @@ enum hwsim_tx_control_flags {
  * @HWSIM_CMD_DEL_RADIO: destroy a radio, reply is multicasted
  * @HWSIM_CMD_GET_RADIO: fetch information about existing radios, uses:
  *	%HWSIM_ATTR_RADIO_ID
+ * @HWSIM_CMD_NOTIFY: notify user-space about driver changes.  This is
+ * designed to help the user-space app better emulate radio hardware.
+ * This command uses:
+ *      %HWSIM_ATTR_FREQ # Notify current operating center frequency.
+ *      %HWSIM_ATTR_ADDR_TRANSMITTER # ID which radio we are notifying about.
  * @__HWSIM_CMD_MAX: enum limit
  */
 enum {
@@ -81,6 +86,7 @@ enum {
 	HWSIM_CMD_NEW_RADIO,
 	HWSIM_CMD_DEL_RADIO,
 	HWSIM_CMD_GET_RADIO,
+	HWSIM_CMD_NOTIFY,
 	__HWSIM_CMD_MAX,
 };
 #define HWSIM_CMD_MAX (_HWSIM_CMD_MAX - 1)
-- 
1.7.11.7
