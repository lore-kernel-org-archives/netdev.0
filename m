From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] mpls: Send route delete notifications when router module is unloaded
Date: Fri, 10 Mar 2017 09:46:15 -0800
Message-ID: <1489167975-11729-1-git-send-email-dsa@cumulusnetworks.com>
Cc: ebiederm@xmission.com, roopa@cumulusnetworks.com,
        rshearma@brocade.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35786 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750897AbdCJRqW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 12:46:22 -0500
Received: by mail-pf0-f170.google.com with SMTP id j5so44356289pfb.2
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 09:46:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the mpls_router module is unloaded, mpls routes are deleted but
notifications are not sent to userspace leaving userspace caches
out of sync. Add the call to mpls_notify_route in mpls_net_exit as
routes are freed.

Fixes: 0189197f44160 ("mpls: Basic routing support")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 3818686182b2..a1477989ed0b 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -2028,6 +2028,7 @@ static void mpls_net_exit(struct net *net)
 	for (index = 0; index < platform_labels; index++) {
 		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
 		RCU_INIT_POINTER(platform_label[index], NULL);
+		mpls_notify_route(net, index, rt, NULL, NULL);
 		mpls_rt_free(rt);
 	}
 	rtnl_unlock();
-- 
2.1.4
