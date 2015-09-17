From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 2/5] vxlan: reject IPv6 addresses if IPv6 is not configured
Date: Thu, 17 Sep 2015 16:11:11 +0200
Message-ID: <45992b922f7bd5d0290c3a67034953838e372f31.1442498316.git.jbenc@redhat.com>
References: <cover.1442498316.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42517 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbbIQOLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 10:11:25 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 5668E2ED158
	for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 14:11:25 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-25.brq.redhat.com [10.40.204.25])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t8HEBMd7023833
	for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 10:11:24 -0400
In-Reply-To: <cover.1442498316.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When IPv6 address is set without IPv6 configured, the vxlan socket is mostly
treated as an IPv4 one but various lookus in fdb etc. still take the
AF_INET6 into account. This creates incosistencies with weird consequences.

Just reject IPv6 addresses in such case.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6ebe562af04e..bbac1d35ed4e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2636,8 +2636,11 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		dst->remote_ip.sa.sa_family = AF_INET;
 
 	if (dst->remote_ip.sa.sa_family == AF_INET6 ||
-	    vxlan->cfg.saddr.sa.sa_family == AF_INET6)
+	    vxlan->cfg.saddr.sa.sa_family == AF_INET6) {
+		if (!IS_ENABLED(CONFIG_IPV6))
+			return -EPFNOSUPPORT;
 		use_ipv6 = true;
+	}
 
 	if (conf->remote_ifindex) {
 		struct net_device *lowerdev
-- 
1.8.3.1
