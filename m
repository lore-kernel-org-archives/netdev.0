From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 3/3] team: use a larger struct for mac address
Date: Tue, 25 Apr 2017 22:03:23 -0700
Message-ID: <1493183003-884-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34175 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2993372AbdDZFDk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 01:03:40 -0400
Received: by mail-pf0-f194.google.com with SMTP id g23so13998257pfj.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 22:03:40 -0700 (PDT)
In-Reply-To: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 tunnels use sizeof(struct in6_addr) as dev->addr_len,
but in many places especially bonding, we use struct sockaddr
to copy and set mac addr, this could lead to stack out-of-bounds
access.

Fix it by using a larger address storage.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/team/team.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 85c0124..88878f1 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -60,10 +60,13 @@ static struct team_port *team_port_get_rtnl(const struct net_device *dev)
 static int __set_port_dev_addr(struct net_device *port_dev,
 			       const unsigned char *dev_addr)
 {
-	struct sockaddr addr;
+	struct {
+		unsigned short type;
+		unsigned char addr[MAX_ADDR_LEN];
+	} addr;
 
-	memcpy(addr.sa_data, dev_addr, port_dev->addr_len);
-	addr.sa_family = port_dev->type;
+	memcpy(addr.addr, dev_addr, port_dev->addr_len);
+	addr.type = port_dev->type;
 	return dev_set_mac_address(port_dev, &addr);
 }
 
-- 
2.5.5
