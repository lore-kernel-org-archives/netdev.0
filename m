From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 23/27] drivers/net/wireless/prism54: Use memdup_user
Date: Sat, 22 May 2010 10:25:44 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005221025200.13021@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Use memdup_user when user data is immediately copied into the
allocated region.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression from,to,size,flag;
position p;
identifier l1,l2;
@@

-  to = \(kmalloc@p\|kzalloc@p\)(size,flag);
+  to = memdup_user(from,size);
   if (
-      to==NULL
+      IS_ERR(to)
                 || ...) {
   <+... when != goto l1;
-  -ENOMEM
+  PTR_ERR(to)
   ...+>
   }
-  if (copy_from_user(to, from, size) != 0) {
-    <+... when != goto l2;
-    -EFAULT
-    ...+>
-  }
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/prism54/isl_ioctl.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 8d1190c..2a62c60 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -2751,14 +2751,9 @@ prism54_hostapd(struct net_device *ndev, struct iw_point *p)
            p->length > PRISM2_HOSTAPD_MAX_BUF_SIZE || !p->pointer)
                return -EINVAL;
 
-       param = kmalloc(p->length, GFP_KERNEL);
-       if (param == NULL)
-               return -ENOMEM;
-
-       if (copy_from_user(param, p->pointer, p->length)) {
-               kfree(param);
-               return -EFAULT;
-       }
+	param = memdup_user(p->pointer, p->length);
+	if (IS_ERR(param))
+		return PTR_ERR(param);
 
        switch (param->cmd) {
        case PRISM2_SET_ENCRYPTION:
