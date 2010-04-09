From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH 1/2] netdev: Add tracepoint to dev_hard_start_xmit
Date: Fri, 09 Apr 2010 16:39:56 +0900
Message-ID: <4BBED9CC.2050709@jp.fujitsu.com>
References: <4BBED951.8040406@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com,
	davem@davemloft.net, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:44457 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806Ab0DIHj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 03:39:29 -0400
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o397dSxH024802
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Fri, 9 Apr 2010 16:39:28 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBF4545DE51
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 16:39:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA82545DE4E
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 16:39:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B59B1DB8040
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 16:39:27 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3041E1DB803C
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 16:39:27 +0900 (JST)
In-Reply-To: <4BBED951.8040406@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tracepoint to dev_hard_start_xmit.
It notices that xmit packet passes network/driver interface.
An output is below.

   sshd-2443  [001] 68238.415621: netdev_start_xmit: dev=eth3 skbaddr=f3db5138 len=114
   sshd-2443  [001] 68238.705459: netdev_start_xmit: dev=eth3 skbaddr=f3db5138 len=114
   sshd-2443  [001] 68238.880361: netdev_start_xmit: dev=eth3 skbaddr=f3db5138 len=114

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
  include/trace/events/skb.h |   28 ++++++++++++++++++++++++++++
  net/core/dev.c             |    3 +++
  2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 4b2be6d..425a062 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -9,6 +9,34 @@
  #include <linux/tracepoint.h>
  
  /*
+ *  netdev_start_xmit - invoked when skb is passed to the driver
+ *  @skb:		pointer to struct sk_buff
+ *  @dev:		pointer to struct net_device
+ */
+TRACE_EVENT(netdev_start_xmit,
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
index 2a9b7dd..4667a96 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -129,6 +129,7 @@
  #include <linux/jhash.h>
  #include <linux/random.h>
  #include <trace/events/napi.h>
+#include <trace/events/skb.h>
  #include <linux/pci.h>
  
  #include "net-sysfs.h"
@@ -1903,6 +1904,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
  		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
  			skb_dst_drop(skb);
  
+		trace_netdev_start_xmit(skb, dev);
  		rc = ops->ndo_start_xmit(skb, dev);
  		if (rc == NETDEV_TX_OK)
  			txq_trans_update(txq);
@@ -1937,6 +1939,7 @@ gso:
  		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
  			skb_dst_drop(nskb);
  
+		trace_netdev_start_xmit(nskb, dev);
  		rc = ops->ndo_start_xmit(nskb, dev);
  		if (unlikely(rc != NETDEV_TX_OK)) {
  			if (rc & ~NETDEV_TX_MASK)


