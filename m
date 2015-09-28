From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 2/6] net/dcb: make dcbnl.c explicitly non-modular
Date: Mon, 28 Sep 2015 15:51:26 -0400
Message-ID: <1443469890-19485-3-git-send-email-paul.gortmaker@windriver.com>
References: <1443469890-19485-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Anish Bhatt <anish@chelsio.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Shani Michaeli <shanim@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:40486 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbbI1TwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 15:52:16 -0400
In-Reply-To: <1443469890-19485-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Kconfig currently controlling compilation of this code is:

net/dcb/Kconfig:config DCB
net/dcb/Kconfig:        bool "Data Center Bridging support"

...meaning that it currently is not being built as a module by anyone.

Lets remove the modular code that is essentially orphaned, so that
when reading the driver there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.  We can
change to one of the other priority initcalls (subsys?) at any later
date, if desired.

We also delete the MODULE_LICENSE tag etc. since all that information
is (or is now) already contained at the top of the file in the comments.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Or Gerlitz <ogerlitz@mellanox.com>
Cc: Anish Bhatt <anish@chelsio.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Shani Michaeli <shanim@mellanox.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/dcb/dcbnl.c | 30 +++---------------------------
 1 file changed, 3 insertions(+), 27 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 5b21f6f88e97..4f6c1862dfd2 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -13,6 +13,7 @@
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, see <http://www.gnu.org/licenses/>.
  *
+ * Description: Data Center Bridging netlink interface
  * Author: Lucy Liu <lucy.liu@intel.com>
  */
 
@@ -24,7 +25,7 @@
 #include <linux/dcbnl.h>
 #include <net/dcbevent.h>
 #include <linux/rtnetlink.h>
-#include <linux/module.h>
+#include <linux/init.h>
 #include <net/sock.h>
 
 /* Data Center Bridging (DCB) is a collection of Ethernet enhancements
@@ -48,10 +49,6 @@
  * features for capable devices.
  */
 
-MODULE_AUTHOR("Lucy Liu, <lucy.liu@intel.com>");
-MODULE_DESCRIPTION("Data Center Bridging netlink interface");
-MODULE_LICENSE("GPL");
-
 /**************** DCB attribute policies *************************************/
 
 /* DCB netlink attributes policy */
@@ -1935,19 +1932,6 @@ int dcb_ieee_delapp(struct net_device *dev, struct dcb_app *del)
 }
 EXPORT_SYMBOL(dcb_ieee_delapp);
 
-static void dcb_flushapp(void)
-{
-	struct dcb_app_type *app;
-	struct dcb_app_type *tmp;
-
-	spin_lock_bh(&dcb_lock);
-	list_for_each_entry_safe(app, tmp, &dcb_app_list, list) {
-		list_del(&app->list);
-		kfree(app);
-	}
-	spin_unlock_bh(&dcb_lock);
-}
-
 static int __init dcbnl_init(void)
 {
 	INIT_LIST_HEAD(&dcb_app_list);
@@ -1957,12 +1941,4 @@ static int __init dcbnl_init(void)
 
 	return 0;
 }
-module_init(dcbnl_init);
-
-static void __exit dcbnl_exit(void)
-{
-	rtnl_unregister(PF_UNSPEC, RTM_GETDCB);
-	rtnl_unregister(PF_UNSPEC, RTM_SETDCB);
-	dcb_flushapp();
-}
-module_exit(dcbnl_exit);
+device_initcall(dcbnl_init);
-- 
2.6.0.rc3
