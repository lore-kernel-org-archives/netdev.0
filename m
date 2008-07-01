From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: V2 [PATCH] netdevice: Fix wrong string handle in kernel command line
 parsing
Date: Tue, 01 Jul 2008 08:56:40 +0800
Message-ID: <486980C8.80706@cn.fujitsu.com>
References: <48686D7A.9030200@cn.fujitsu.com> <20080630102502.GG4050@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55890 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755024AbYGABBK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2008 21:01:10 -0400
In-Reply-To: <20080630102502.GG4050@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings said the following on 2008-6-30 18:25:
>> -			strcpy(s[i].name, name);
>> +			strncpy(s[i].name, name, IFNAMSIZ);
> 
> I think that strncpy() should be strlcpy(), because strncpy() does not
> ensure null-termination.
> 

Of course. Thanks, Ben.

v1->v2: Use strlcpy() to ensure s[i].name be null-termination.

1. In netdev_boot_setup_add(), a long name will leak.
   ex. : dev=21,0x1234,0x1234,0x2345,eth123456789verylongname.........
2. In netdev_boot_setup_check(), mismatch will happen if s[i].name
   is a substring of dev->name.
   ex. : dev=...eth1 dev=...eth11

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index c421a1f..3360df6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -454,7 +454,7 @@ static int netdev_boot_setup_add(char *name, struct ifmap *map)
 	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++) {
 		if (s[i].name[0] == '\0' || s[i].name[0] == ' ') {
 			memset(s[i].name, 0, sizeof(s[i].name));
-			strcpy(s[i].name, name);
+			strlcpy(s[i].name, name, IFNAMSIZ);
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

