From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] netdevice: Fix wrong string handle in kernel command line
 parsing
Date: Mon, 30 Jun 2008 13:22:02 +0800
Message-ID: <48686D7A.9030200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50925 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752408AbYF3G3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2008 02:29:16 -0400
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id A747B17013D
	for <netdev@vger.kernel.org>; Mon, 30 Jun 2008 14:29:12 +0800 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. In netdev_boot_setup_add(), a long name will leak.
   ex. : dev=21,0x1234,0x1234,0x2345,eth123456789verylongname.........
2. In netdev_boot_setup_check(), mismatch will happen if s[i].name
   is a substring of dev->name.
   ex. : dev=...eth1 dev=...eth11

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index c421a1f..9ecb3db 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -454,7 +454,7 @@ static int netdev_boot_setup_add(char *name, struct ifmap *map)
 	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++) {
 		if (s[i].name[0] == '\0' || s[i].name[0] == ' ') {
 			memset(s[i].name, 0, sizeof(s[i].name));
-			strcpy(s[i].name, name);
+			strncpy(s[i].name, name, IFNAMSIZ);
 			memcpy(&s[i].map, map, sizeof(s[i].map));
 			break;
 		}
@@ -479,7 +479,7 @@ int netdev_boot_setup_check(struct net_device *dev)
 
 	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++) {
 		if (s[i].name[0] != '\0' && s[i].name[0] != ' ' &&
-		    !strncmp(dev->name, s[i].name, strlen(s[i].name))) {
+		    !strcmp(dev->name, s[i].name)) {
 			dev->irq 	= s[i].map.irq;
 			dev->base_addr 	= s[i].map.base_addr;
 			dev->mem_start 	= s[i].map.mem_start;

