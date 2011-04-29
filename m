From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] net: fix rtnl even race in register_netdevice()
Date: Fri, 29 Apr 2011 20:26:34 +0300
Message-ID: <20110429172634.27130.25375.stgit@x201>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kalle.valo-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>

There's a race in register_netdevice so that the rtnl event is sent before
the device is actually ready. This was visible with flimflam, chrome os
connection manager:

00:21:35 roska flimflamd[2598]: src/udev.c:add_net_device()
00:21:35 roska flimflamd[2598]: connman_inet_ifname: SIOCGIFNAME(index
   4): No such device
00:21:45 roska flimflamd[2598]: src/rtnl.c:rtnl_message() buf
   0xbfefda3c len 1004
00:21:45 roska flimflamd[2598]: src/rtnl.c:rtnl_message()
   NEWLINK len 1004 type 16 flags 0x0000 seq 0

So the kobject is visible in udev before the device is ready.

(ignore the 10 s delay, I added that to reproduce the issue easily)

The issue is reported here:

https://bugzilla.kernel.org/show_bug.cgi?id=15606

The fix is to call netdev_register_kobject() after the device is added
to the list.

Signed-off-by: Kalle Valo <kalle.valo-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
---
 net/core/dev.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 956d3b0..f2afbe6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5425,11 +5425,6 @@ int register_netdevice(struct net_device *dev)
 	if (ret)
 		goto err_uninit;
 
-	ret = netdev_register_kobject(dev);
-	if (ret)
-		goto err_uninit;
-	dev->reg_state = NETREG_REGISTERED;
