From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v2 2/6] skbuff: add "missed_flow" flag
Date: Wed, 26 Mar 2014 17:31:08 +0100
Message-ID: <1395851472-10524-3-git-send-email-jiri@resnulli.us>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:38983 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755593AbaCZQbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 12:31:25 -0400
Received: by mail-ee0-f42.google.com with SMTP id d17so1879160eek.1
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 09:31:24 -0700 (PDT)
In-Reply-To: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This flag sets incoming switch device in order to let know that the flow
which the skb is part of is missed. Listener may react to it
appropriately,

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/filter.h |  1 +
 include/linux/skbuff.h | 13 +++++++++++++
 net/core/filter.c      |  3 +++
 3 files changed, 17 insertions(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index e568c8e..38c7c04 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -154,6 +154,7 @@ enum {
 	BPF_S_ANC_VLAN_TAG,
 	BPF_S_ANC_VLAN_TAG_PRESENT,
 	BPF_S_ANC_PAY_OFFSET,
+	BPF_S_ANC_MISSED_FLOW,
 };
 
 #endif /* __LINUX_FILTER_H__ */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 03db95a..0100c2f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -567,6 +567,7 @@ struct sk_buff {
 	 * headers if needed
 	 */
 	__u8			encapsulation:1;
+	__u8			missed_flow:1;
 	/* 6/8 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
@@ -2993,5 +2994,17 @@ static inline unsigned int skb_gso_network_seglen(const struct sk_buff *skb)
 			       skb_network_header(skb);
 	return hdr_len + skb_gso_transport_seglen(skb);
 }
+
+/**
+ * skb_mark_missed_flow - marks skb as a part of missed flow
+ * @skb: buffer
+ *
+ * Marks skb as a part of missed flow.
+ */
+static inline void skb_mark_missed_flow(struct sk_buff *skb)
+{
+	skb->missed_flow = 1;
+}
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/net/core/filter.c b/net/core/filter.c
index ad30d62..048f11a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -350,6 +350,9 @@ load_b:
 		case BPF_S_ANC_PAY_OFFSET:
 			A = __skb_get_poff(skb);
 			continue;
+		case BPF_S_ANC_MISSED_FLOW:
+			A = !!skb->missed_flow;
+			continue;
 		case BPF_S_ANC_NLATTR: {
 			struct nlattr *nla;
 
-- 
1.8.5.3
