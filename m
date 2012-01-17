From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net] openvswitch: Fix multipart datapath dumps.
Date: Tue, 17 Jan 2012 15:33:39 -0800
Message-ID: <1326843219-14664-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Ben Pfaff <blp@nicira.com>,
	Paul Ingram <paul@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37428 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756331Ab2AQXdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 18:33:45 -0500
Received: by iagf6 with SMTP id f6so4976600iag.19
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 15:33:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Pfaff <blp@nicira.com>

The logic to split up the list of datapaths into multiple Netlink messages
was simply wrong, causing the list to be terminated after the first part.
Only about the first 50 datapaths would be dumped.  This fixes the
problem.

Reported-by: Paul Ingram <paul@nicira.com>
Signed-off-by: Ben Pfaff <blp@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d9d01cb..ce64c18 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2012 Nicira Networks.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -1396,9 +1396,8 @@ static int ovs_dp_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int i = 0;
 
 	list_for_each_entry(dp, &dps, list_node) {
-		if (i < skip)
-			continue;
-		if (ovs_dp_cmd_fill_info(dp, skb, NETLINK_CB(cb->skb).pid,
+		if (i >= skip &&
+		    ovs_dp_cmd_fill_info(dp, skb, NETLINK_CB(cb->skb).pid,
 					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					 OVS_DP_CMD_NEW) < 0)
 			break;
-- 
1.7.5.4
