From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] net/core: Fix potential memory leak in dev_set_alias()
Date: Wed,  8 Aug 2012 14:33:25 +0400
Message-ID: <1344422005-21993-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not leak memory by updating pointer with potentially NULL realloc return value.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 net/core/dev.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0cb3fe8..3bcc5da 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1055,6 +1055,8 @@ rollback:
  */
 int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
 {
+	char *new_ifalias;
+
 	ASSERT_RTNL();
 
 	if (len >= IFALIASZ)
@@ -1068,9 +1070,10 @@ int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
 		return 0;
 	}
 
-	dev->ifalias = krealloc(dev->ifalias, len + 1, GFP_KERNEL);
-	if (!dev->ifalias)
+	new_ifalias = krealloc(dev->ifalias, len + 1, GFP_KERNEL);
+	if (!new_ifalias)
 		return -ENOMEM;
+	dev->ifalias = new_ifalias;
 
 	strlcpy(dev->ifalias, alias, len+1);
 	return len;
-- 
1.7.9.5
