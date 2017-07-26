From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v2] team: use a larger struct for mac address
Date: Wed, 26 Jul 2017 15:22:07 -0700
Message-ID: <20170726222207.5922-2-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36266 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdGZWW1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 18:22:27 -0400
Received: by mail-pf0-f195.google.com with SMTP id m21so2122022pfj.3
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 15:22:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 tunnels use sizeof(struct in6_addr) as dev->addr_len,
but in many places especially bonding, we use struct sockaddr
to copy and set mac addr, this could lead to stack out-of-bounds
access.

Fix it by using a larger address storage like bonding.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/team/team.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 464570409796..ae53e899259f 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -60,11 +60,11 @@ static struct team_port *team_port_get_rtnl(const struct net_device *dev)
 static int __set_port_dev_addr(struct net_device *port_dev,
 			       const unsigned char *dev_addr)
 {
-	struct sockaddr addr;
+	struct sockaddr_storage addr;
 
-	memcpy(addr.sa_data, dev_addr, port_dev->addr_len);
-	addr.sa_family = port_dev->type;
-	return dev_set_mac_address(port_dev, &addr);
+	memcpy(addr.__data, dev_addr, port_dev->addr_len);
+	addr.ss_family = port_dev->type;
+	return dev_set_mac_address(port_dev, (struct sockaddr *)&addr);
 }
 
 static int team_port_set_orig_dev_addr(struct team_port *port)
-- 
2.13.0
