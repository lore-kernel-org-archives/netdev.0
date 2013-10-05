From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH v2] net: secure_seq: Fix warning when CONFIG_IPV6 and CONFIG_INET are not selected
Date: Sat,  5 Oct 2013 17:56:59 -0300
Message-ID: <1381006619-17126-2-git-send-email-festevam@gmail.com>
References: <1381006619-17126-1-git-send-email-festevam@gmail.com>
Cc: edumazet@google.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, olof@lixom.net,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f182.google.com ([209.85.213.182]:33236 "EHLO
	mail-ye0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536Ab3JEVDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Oct 2013 17:03:32 -0400
Received: by mail-ye0-f182.google.com with SMTP id q7so591536yen.27
        for <netdev@vger.kernel.org>; Sat, 05 Oct 2013 14:03:32 -0700 (PDT)
In-Reply-To: <1381006619-17126-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

net_secret() is only used when CONFIG_IPV6 or CONFIG_INET are selected.

Building a defconfig with both of these symbols unselected (Using the ARM
at91sam9rl_defconfig, for example) leads to the following build warning:

$ make at91sam9rl_defconfig
#
# configuration written to .config
#

$ make net/core/secure_seq.o
scripts/kconfig/conf --silentoldconfig Kconfig
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
make[1]: `include/generated/mach-types.h' is up to date.
  CALL    scripts/checksyscalls.sh
  CC      net/core/secure_seq.o
net/core/secure_seq.c:17:13: warning: 'net_secret_init' defined but not used [-Wunused-function]

Fix this warning by protecting the definition of net_secret() with these
symbols.

Reported-by: Olof Johansson <olof@lixom.net>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changes since v1:
- Add #if IS_ENABLED(CONFIG_IPV6) || IS_ENABLED(CONFIG_INET)

 net/core/secure_seq.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 3f1ec15..8d9d05e 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -10,6 +10,7 @@
 
 #include <net/secure_seq.h>
 
+#if IS_ENABLED(CONFIG_IPV6) || IS_ENABLED(CONFIG_INET)
 #define NET_SECRET_SIZE (MD5_MESSAGE_BYTES / 4)
 
 static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
@@ -29,6 +30,7 @@ static void net_secret_init(void)
 		cmpxchg(&net_secret[--i], 0, tmp);
 	}
 }
+#endif
 
 #ifdef CONFIG_INET
 static u32 seq_scale(u32 seq)
-- 
1.8.1.2
