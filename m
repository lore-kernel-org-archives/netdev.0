From: Ben Greear <greearb@candelatech.com>
Subject: [ipmr] ipmr:  Don't leak memory if fib lookup fails.
Date: Thu, 15 Jul 2010 16:22:33 -0700
Message-ID: <1279236153-23699-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58554 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933661Ab0GOXWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 19:22:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was detected using two mcast router tables.  The
pimreg for the second interface did not have a specific
mrule, so packets received by it were handled by the
default table, which had nothing configured.

This caused the ipmr_fib_lookup to fail, causing
the memory leak.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 ed2f911... f112ad8... M	net/ipv4/ipmr.c
 net/ipv4/ipmr.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index ed2f911..f112ad8 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -442,8 +442,10 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 	int err;
 
 	err = ipmr_fib_lookup(net, &fl, &mrt);
-	if (err < 0)
+	if (err < 0) {
+		kfree_skb(skb);
 		return err;
+	}
 
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
@@ -1729,8 +1731,10 @@ int ip_mr_input(struct sk_buff *skb)
 		goto dont_forward;
 
 	err = ipmr_fib_lookup(net, &skb_rtable(skb)->fl, &mrt);
-	if (err < 0)
+	if (err < 0) {
+		kfree_skb(skb);
 		return err;
+	}
 
 	if (!local) {
 		    if (IPCB(skb)->opt.router_alert) {
-- 
1.6.2.5

