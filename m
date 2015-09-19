From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net] openvswitch: Zero flows on allocation.
Date: Fri, 18 Sep 2015 19:06:14 -0700
Message-ID: <1442628374-57025-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33561 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbbISCGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 22:06:20 -0400
Received: by pacex6 with SMTP id ex6so65317062pac.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 19:06:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS tries to be clever about not touching the parts of a flow that
aren't used. This can include leaving pieces of memory uninitialized
if the mask is zero and therefore the value would be ignored anyways.

While this works fine for the purposes of matching (which must always
look at the mask), serialization to netlink can be problematic. Since
the flow and the mask are serialized separately, the uninitialized
portions of the flow can be encoded with whatever values happen to be
present.

In terms of functionality, this has little effect since these fields
will be masked out by definition. However, it leaks kernel memory to
userspace, which is a potential security vulnerability.

This zeros the flows as they are allocated and installed. This was
always intended to be the case as the memory optimizations were only
supposed to apply to per-packet flow operations.

Fixes: 07148121 ("openvswitch: Eliminate memset() from flow_extract.")
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/flow_table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index d22d8e9..5248322 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -80,7 +80,7 @@ struct sw_flow *ovs_flow_alloc(void)
 	struct flow_stats *stats;
 	int node;
 
-	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
+	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL | __GFP_ZERO);
 	if (!flow)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.1.4
