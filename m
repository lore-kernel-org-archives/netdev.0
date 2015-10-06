From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 6/8] bridge: netlink: export port's timer values
Date: Tue,  6 Oct 2015 14:12:00 +0200
Message-ID: <1444133522-16907-7-git-send-email-razor@blackwall.org>
References: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36463 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbbJFMMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 08:12:31 -0400
Received: by wicgb1 with SMTP id gb1so162357586wic.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 05:12:30 -0700 (PDT)
In-Reply-To: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add the following attributes in order to export port's timer values:
IFLA_BRPORT_MESSAGE_AGE_TIMER, IFLA_BRPORT_FORWARD_DELAY_TIMER and
IFLA_BRPORT_HOLD_TIMER.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  3 +++
 net/bridge/br_netlink.c      | 14 ++++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 1d6aeb1bbe95..9c17f605e013 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -300,6 +300,9 @@ enum {
 	IFLA_BRPORT_NO,
 	IFLA_BRPORT_TOPOLOGY_CHANGE_ACK,
 	IFLA_BRPORT_CONFIG_PENDING,
+	IFLA_BRPORT_MESSAGE_AGE_TIMER,
+	IFLA_BRPORT_FORWARD_DELAY_TIMER,
+	IFLA_BRPORT_HOLD_TIMER,
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 433d632ad7d0..04b0e5072686 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -135,6 +135,9 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_NO */
 		+ nla_total_size(sizeof(u8))	/* IFLA_BRPORT_TOPOLOGY_CHANGE_ACK */
 		+ nla_total_size(sizeof(u8))	/* IFLA_BRPORT_CONFIG_PENDING */
+		+ nla_total_size(sizeof(u64))	/* IFLA_BRPORT_MESSAGE_AGE_TIMER */
+		+ nla_total_size(sizeof(u64))	/* IFLA_BRPORT_FORWARD_DELAY_TIMER */
+		+ nla_total_size(sizeof(u64))	/* IFLA_BRPORT_HOLD_TIMER */
 		+ 0;
 }
 
@@ -156,6 +159,7 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 			      const struct net_bridge_port *p)
 {
 	u8 mode = !!(p->flags & BR_HAIRPIN_MODE);
+	u64 timerval;
 
 	if (nla_put_u8(skb, IFLA_BRPORT_STATE, p->state) ||
 	    nla_put_u16(skb, IFLA_BRPORT_PRIORITY, p->priority) ||
@@ -182,6 +186,16 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u8(skb, IFLA_BRPORT_CONFIG_PENDING, p->config_pending))
 		return -EMSGSIZE;
 
+	timerval = br_timer_value(&p->message_age_timer);
+	if (nla_put_u64(skb, IFLA_BRPORT_MESSAGE_AGE_TIMER, timerval))
+		return -EMSGSIZE;
+	timerval = br_timer_value(&p->forward_delay_timer);
+	if (nla_put_u64(skb, IFLA_BRPORT_FORWARD_DELAY_TIMER, timerval))
+		return -EMSGSIZE;
+	timerval = br_timer_value(&p->hold_timer);
+	if (nla_put_u64(skb, IFLA_BRPORT_HOLD_TIMER, timerval))
+		return -EMSGSIZE;
+
 	return 0;
 }
 
-- 
2.4.3
