From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH] net: ipconfig: Fix more use after free
Date: Tue, 16 Aug 2016 16:45:38 +0200
Message-ID: <20160816144538.3181-1-thierry.reding@gmail.com>
Cc: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Geert Uytterhoeven <geert+renesas@glider.be>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

While commit 9c706a49d660 ("net: ipconfig: fix use after free") avoids
the use after free, the resulting code still ends up calling both the
ic_setup_if() and ic_setup_routes() after calling ic_close_devs(), and
access to the device is still required.

Move the call to ic_close_devs() to the very end of the function.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
This applies on top of next-20160816.

 net/ipv4/ipconfig.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 66c2fe602810..ba9cbeafbb2e 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1530,12 +1530,14 @@ static int __init ip_auto_config(void)
 	 * Close all network devices except the device we've
 	 * autoconfigured and set up routes.
 	 */
-	ic_close_devs();
 	if (ic_setup_if() < 0 || ic_setup_routes() < 0)
-		return -1;
+		err = -1;
+	else
+		err = 0;
 
+	ic_close_devs();
 
-	return 0;
+	return err;
 }
 
 late_initcall(ip_auto_config);
-- 
2.9.0
