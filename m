From: William Tu <u9012063@gmail.com>
Subject: [PATCH net-next] bpf: fix the printing of ifindex
Date: Wed,  2 Aug 2017 08:43:52 -0700
Message-ID: <1501688632-2709-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34489 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdHBPoC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 11:44:02 -0400
Received: by mail-pg0-f66.google.com with SMTP id y192so6859244pgd.1
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 08:44:02 -0700 (PDT)
Received: from sc9-mailhost1.vmware.com ([208.91.1.34])
        by smtp.gmail.com with ESMTPSA id v128sm54851255pgv.49.2017.08.02.08.43.59
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 08:43:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save the ifindex before it gets zeroed so the invalid
ifindex can be printed out.

Signed-off-by: William Tu <u9012063@gmail.com>
---
 net/core/filter.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 7e9708653c6f..78d00933dbe7 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2509,15 +2509,16 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 	struct net_device *fwd;
+	u32 index = ri->ifindex;
 
 	if (ri->map)
 		return xdp_do_redirect_map(dev, xdp, xdp_prog);
 
-	fwd = dev_get_by_index_rcu(dev_net(dev), ri->ifindex);
+	fwd = dev_get_by_index_rcu(dev_net(dev), index);
 	ri->ifindex = 0;
 	ri->map = NULL;
 	if (unlikely(!fwd)) {
-		bpf_warn_invalid_xdp_redirect(ri->ifindex);
+		bpf_warn_invalid_xdp_redirect(index);
 		return -EINVAL;
 	}
 
@@ -2531,11 +2532,12 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 	unsigned int len;
+	u32 index = ri->ifindex;
 
-	dev = dev_get_by_index_rcu(dev_net(dev), ri->ifindex);
+	dev = dev_get_by_index_rcu(dev_net(dev), index);
 	ri->ifindex = 0;
 	if (unlikely(!dev)) {
-		bpf_warn_invalid_xdp_redirect(ri->ifindex);
+		bpf_warn_invalid_xdp_redirect(index);
 		goto err;
 	}
 
-- 
2.7.4
