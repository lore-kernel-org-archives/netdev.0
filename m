From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] tehuti: using uninitialized data in bdx_ioctl_priv()
Date: Mon, 24 Jun 2013 19:05:03 +0300
Message-ID: <20130624160503.GC31984@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we "cmd == SIOCDEVPRIVATE" then we use data[] without initializing
it.  The most common case is that we would return -EOPNOTSUPP.  The
other case is that we'd end up reading and writing to randomish places.
This requires CAP_SYS_RAWIO so it's not very bad.

The fix is to not allow SIOCDEVPRIVATE because it doesn't work.  I
returned -EOPNOTSUPP instead of -ENOTTY because that's what is used in
the rest of the file.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This bug is several years old.

diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 571452e..5d08f38 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -647,14 +647,16 @@ static int bdx_ioctl_priv(struct net_device *ndev, struct ifreq *ifr, int cmd)
 	ENTER;
 
 	DBG("jiffies=%ld cmd=%d\n", jiffies, cmd);
-	if (cmd != SIOCDEVPRIVATE) {
-		error = copy_from_user(data, ifr->ifr_data, sizeof(data));
-		if (error) {
-			pr_err("can't copy from user\n");
-			RET(-EFAULT);
-		}
-		DBG("%d 0x%x 0x%x\n", data[0], data[1], data[2]);
+
+	if (cmd == SIOCDEVPRIVATE)
+		RET(-EOPNOTSUPP);
+
+	error = copy_from_user(data, ifr->ifr_data, sizeof(data));
+	if (error) {
+		pr_err("can't copy from user\n");
+		RET(-EFAULT);
 	}
+	DBG("%d 0x%x 0x%x\n", data[0], data[1], data[2]);
 
 	if (!capable(CAP_SYS_RAWIO))
 		return -EPERM;
