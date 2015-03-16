From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: [PATCH net-next v4 3/3] Validate all netlink attributes and return error if any of the validation fails.
Date: Tue, 17 Mar 2015 04:32:44 +0530
Message-ID: <5269ddae1a0a164a488703654c9bb6e24845c637.1426509272.git.siva.mannem.lnx@gmail.com>
References: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
Cc: davem@davemloft.net, sfeldma@gmail.com,
	Siva Mannem <siva.mannem.lnx@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34907 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964797AbbCPXD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 19:03:29 -0400
Received: by pabyw6 with SMTP id yw6so78244361pab.2
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 16:03:28 -0700 (PDT)
In-Reply-To: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
In-Reply-To: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
References: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch validates all netlink attributes and return error if any of the
validation fails.

Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
Suggested-by: David Miller <davem@davemloft.net>
---
 net/bridge/br_netlink.c | 39 ++++++++++++++++++++++++++++++++++++++-
 1 file changed, 38 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index d80e802..0b18c0d 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -740,12 +740,49 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 			 struct nlattr *data[])
 {
 	struct net_bridge *br = netdev_priv(brdev);
-	int err;
+	unsigned long forward_delay;
+	unsigned long hello_time;
+	unsigned long max_age;
+	unsigned long ageing_time;
+	u32 t;
+	int err = -ERANGE;
 
 	if (!data)
 		return 0;
 
 	if (data[IFLA_BR_FORWARD_DELAY]) {
+		t = nla_get_u32(data[IFLA_BR_FORWARD_DELAY]);
+		forward_delay = clock_t_to_jiffies(t);
+		if (forward_delay < BR_MIN_FORWARD_DELAY ||
+		    forward_delay > BR_MAX_FORWARD_DELAY)
+			return err;
+	}
+
+	if (data[IFLA_BR_HELLO_TIME]) {
+		t = nla_get_u32(data[IFLA_BR_HELLO_TIME]);
+		hello_time = clock_t_to_jiffies(t);
+		if (hello_time < BR_MIN_HELLO_TIME ||
+		    hello_time > BR_MAX_HELLO_TIME)
+			return err;
+	}
+
+	if (data[IFLA_BR_MAX_AGE]) {
+		t = nla_get_u32(data[IFLA_BR_MAX_AGE]);
+		max_age = clock_t_to_jiffies(t);
+		if (max_age < BR_MIN_MAX_AGE ||
+		    max_age > BR_MAX_MAX_AGE)
+			return err;
+	}
+
+	if (data[IFLA_BR_AGEING_TIME]) {
+		t = nla_get_u32(data[IFLA_BR_AGEING_TIME]);
+		ageing_time = clock_t_to_jiffies(t);
+		if (ageing_time < BR_MIN_AGEING_TIME ||
+		    ageing_time > BR_MAX_AGEING_TIME)
+			return err;
+	}
+
+	if (data[IFLA_BR_FORWARD_DELAY]) {
 		err = br_set_forward_delay(br, nla_get_u32(data[IFLA_BR_FORWARD_DELAY]));
 		if (err)
 			return err;
-- 
2.1.0
