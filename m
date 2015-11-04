From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net v4] ipv6: clean up dev_snmp6 proc entry when we fail to initialize inet6_dev
Date: Wed,  4 Nov 2015 18:30:40 +0100
Message-ID: <1446658240-31423-1-git-send-email-sd@queasysnail.net>
Cc: eric.dumazet@gmail.com, dvyukov@google.com,
	hannes@stressinduktion.org, cwang@twopensource.com,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030296AbbKDRbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 12:31:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipv6_add_dev, when addrconf_sysctl_register fails, we do not clean up
the dev_snmp6 entry that we have already registered for this device.
Call snmp6_unregister_dev in this case.

Fixes: a317a2f19da7d ("ipv6: fail early when creating netdev named all or default")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
v4: v3 had a bad message-id and didn't get picked up by patchwork,
    sorry for the noise
v3: add Fixes: tag, thanks Eric.
v2: we cannot call snmp6_unregister_dev from addrconf_core.c, this
    breaks CONFIG_IPV6=m, instead do the clean up directly from
    ipv6_add_dev
    thanks Cong.

 net/ipv6/addrconf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 36b85bd05ac8..dd00828863a0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -417,6 +417,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	if (err) {
 		ipv6_mc_destroy_dev(ndev);
 		del_timer(&ndev->regen_timer);
+		snmp6_unregister_dev(ndev);
 		goto err_release;
 	}
 	/* protected by rtnl_lock */
-- 
2.6.2
