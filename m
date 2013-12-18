From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [RFC PATCH] net, rps: bypass enqueue_to_backlog()
Date: Wed, 18 Dec 2013 21:03:36 +0800
Message-ID: <1387371816-32476-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:44653 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092Ab3LRNDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 08:03:49 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Wed, 18 Dec 2013 06:03:48 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id BD3823E40045
	for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:03:46 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBID3kOa9830714
	for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 14:03:46 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBID3kN4020181
	for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:03:46 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

When local cpu is just target cpu which will handle network soft irq,
the packet should be directly injected to network stack, by bypassing
enqueue_to_backlog(), it can speed up the packet processing.

HI, guys

I checked the first several versions of RPS patch which seemed to have
this condition determination, but why was it removed later? Do i miss
anything? if yes, please correct me, thanks.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c482fe8..d29d61f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3693,7 +3693,7 @@ int netif_receive_skb(struct sk_buff *skb)
 
 		cpu = get_rps_cpu(skb->dev, skb, &rflow);
 
-		if (cpu >= 0) {
+		if ((cpu >= 0) && (cpu != raw_smp_processor_id())) {
 			ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
 			rcu_read_unlock();
 			return ret;
-- 
1.7.6.5
