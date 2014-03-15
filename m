From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 1/5] at86rf230: fix unexpected
	state change
Date: Sat, 15 Mar 2014 09:29:03 +0100
Message-ID: <1394872147-3021-2-git-send-email-alex.aring@gmail.com>
References: <1394872147-3021-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1394872147-3021-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fix a unexpected state change for the at86rf231 chip.
We can't change into STATE_FORCE_TX_ON while the chip is in one of
SLEEP, P_ON, RESET, TRX_OFF, and all *_NOCLK states.

In this case we are in the TRX_OFF state. See datasheet [1] page 71 for
more information.

Without this patch you will get the following message on a at86rf231 device:

[   20.065218] unexpected state change: 8, asked for 4
[   20.070527] ------------[ cut here ]------------
[   20.075414] WARNING: CPU: 0 PID: 160 at net/mac802154/ieee802154_dev.c:43 mac802154_slave_open+0x70/0xb8()
[   20.085594] Modules linked in: autofs4
[   20.089667] CPU: 0 PID: 160 Comm: ifconfig Not tainted 3.14.0-20140108-1-00993-g905c192 #162
[   20.098612] [<c00127b8>] (unwind_backtrace) from [<c0010b1c>] (show_stack+0x10/0x14)
[   20.106819] [<c0010b1c>] (show_stack) from [<c0033838>] (warn_slowpath_common+0x60/0x80)
[   20.115311] [<c0033838>] (warn_slowpath_common) from [<c00338e8>] (warn_slowpath_null+0x18/0x20)
[   20.124590] [<c00338e8>] (warn_slowpath_null) from [<c057b7e8>] (mac802154_slave_open+0x70/0xb8)
[   20.133880] [<c057b7e8>] (mac802154_slave_open) from [<c0488a58>] (__dev_open+0xa8/0x108)
[   20.142553] [<c0488a58>] (__dev_open) from [<c0488cb0>] (__dev_change_flags+0x8c/0x148)
[   20.151051] [<c0488cb0>] (__dev_change_flags) from [<c0488d84>] (dev_change_flags+0x18/0x48)
[   20.159968] [<c0488d84>] (dev_change_flags) from [<c04e2e9c>] (devinet_ioctl+0x2b0/0x63c)
[   20.168623] [<c04e2e9c>] (devinet_ioctl) from [<c04712e4>] (sock_ioctl+0x23c/0x29c)
[   20.176727] [<c04712e4>] (sock_ioctl) from [<c00e3cb8>] (do_vfs_ioctl+0x4a8/0x578)
[   20.184671] [<c00e3cb8>] (do_vfs_ioctl) from [<c00e3dd4>] (SyS_ioctl+0x4c/0x78)
[   20.192402] [<c00e3dd4>] (SyS_ioctl) from [<c000da00>] (ret_fast_syscall+0x0/0x48)
[   20.200392] ---[ end trace 9a34542f4ea08e47 ]---

This patch was tested on at86rf231 and at86rf212.

[1] http://www.atmel.com/images/doc8111.pdf

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index ae38a98..ad296bc 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -574,7 +574,7 @@ at86rf230_start(struct ieee802154_dev *dev)
 	if (rc)
 		return rc;
 
-	rc = at86rf230_state(dev, STATE_FORCE_TX_ON);
+	rc = at86rf230_state(dev, STATE_TX_ON);
 	if (rc)
 		return rc;
 
-- 
1.9.0


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
