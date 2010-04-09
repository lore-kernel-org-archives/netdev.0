From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH 2/2] netdev: Add tracepoint to netif_receive_skb
Date: Fri, 09 Apr 2010 16:41:27 +0900
Message-ID: <4BBEDA27.7000502@jp.fujitsu.com>
References: <4BBED951.8040406@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com,
	davem@davemloft.net, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:44521 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160Ab0DIHlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 03:41:01 -0400
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o397f0HF025345
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Fri, 9 Apr 2010 16:41:00 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E97A745DE52
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 16:40:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B5DA545DE4C
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 16:40:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C49E1DB801B
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 16:40:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 12E231DB8012
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 16:40:59 +0900 (JST)
In-Reply-To: <4BBED951.8040406@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tracepoint to netif_receive_skb.
It notices that receive packet passes network/driver interface.
An output is below.

<idle>-0     [001] 68238.417058: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=52
<idle>-0     [001] 68238.704363: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=100
<idle>-0     [001] 68238.706891: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=52
<idle>-0     [001] 68238.878736: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=100

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
  include/trace/events/skb.h |   28 ++++++++++++++++++++++++++++
  net/core/dev.c             |    1 +
  2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 425a062..ca78d49 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -37,6 +37,34 @@ TRACE_EVENT(netdev_start_xmit,
  );
  
  /*
+ * netdev_receive_skb - invoked when skb is received from the driver
+ * @skb:		pointer to struct sk_buff
+ * @dev:		pointer to struct net_device
+ */
+TRACE_EVENT(netdev_receive_skb,
+
+	TP_PROTO(struct sk_buff *skb,
+		 struct net_device *dev),
+
+	TP_ARGS(skb, dev),
+
+	TP_STRUCT__entry(
+		__field(	const void *, 	skbaddr		)
+		__field(	unsigned int, 	len		)
+		__string(	name, 		dev->name	)
+       ),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->len = skb->len;
+		__assign_str(name, dev->name);
+	),
+
+	TP_printk("dev=%s skbaddr=%p len=%u",
+		__get_str(name), __entry->skbaddr, __entry->len)
+);
+
+/*
   * Tracepoint for free an sk_buff:
   */
  TRACE_EVENT(kfree_skb,
diff --git a/net/core/dev.c b/net/core/dev.c
index 4667a96..7281286 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2683,6 +2683,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
  
  	__get_cpu_var(netdev_rx_stat).total++;
  
+	trace_netdev_receive_skb(skb, orig_dev);
  	skb_reset_network_header(skb);
  	skb_reset_transport_header(skb);
  	skb->mac_len = skb->network_header - skb->mac_header;

