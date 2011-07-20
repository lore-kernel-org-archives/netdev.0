From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: [PATCH] ethtool: fix ethtool_get_regs() to work with zero length
	registers
Date: Wed, 20 Jul 2011 12:18:50 +0300
Message-ID: <20110720091850.32210.2059.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

cfg80211 exports zero length register size as it currently only uses
struct ethtool_regs.version to export struct wiphy.hw_version. But the
problem is that ethtool_get_regs() assumes that the driver (cfg80211 in this
case) always has non-zero length for registers. With cfg80211
it would always fail and return -ENOMEM to user space.

Fix this by checking the register length from the driver and exporting
struct ethtool_regs to user space if the length is zero.

With this patch it's possible to get the hardware id from wireless drivers.
Tested with wl12xx and ath6kl.

Tested-by: Gery Kahn <geryk-l0cyMroinI0@public.gmane.org>
Signed-off-by: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
---
 net/core/ethtool.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index fd14116..6f073f4 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1213,7 +1213,7 @@ static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_regs regs;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
-	void *regbuf;
+	void *regbuf = NULL;
 	int reglen, ret;
 
 	if (!ops->get_regs || !ops->get_regs_len)
@@ -1226,18 +1226,24 @@ static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 	if (regs.len > reglen)
 		regs.len = reglen;
 
-	regbuf = vzalloc(reglen);
-	if (!regbuf)
-		return -ENOMEM;
+	if (reglen > 0) {
+		regbuf = vzalloc(reglen);
+		if (!regbuf)
+			return -ENOMEM;
+	}
 
 	ops->get_regs(dev, &regs, regbuf);
 
 	ret = -EFAULT;
 	if (copy_to_user(useraddr, &regs, sizeof(regs)))
 		goto out;
-	useraddr += offsetof(struct ethtool_regs, data);
-	if (copy_to_user(useraddr, regbuf, regs.len))
-		goto out;
+
+	if (regs.len > 0) {
+		useraddr += offsetof(struct ethtool_regs, data);
+		if (copy_to_user(useraddr, regbuf, regs.len))
+			goto out;
+	}
+
 	ret = 0;
 
  out:

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
