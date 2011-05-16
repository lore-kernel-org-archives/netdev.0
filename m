From: Kalle Valo <kvalo@adurom.com>
Subject: [PATCH v3 2/2] net: postpone net device uevent to fix a race
Date: Mon, 16 May 2011 17:46:47 +0300
Message-ID: <20110516144647.13838.40897.stgit@localhost6.localdomain6>
References: <20110516143913.13838.85357.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh05.mail.saunalahti.fi ([62.142.5.111]:57784 "EHLO
	emh05.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755870Ab1EPOqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 10:46:52 -0400
In-Reply-To: <20110516143913.13838.85357.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalle Valo <kalle.valo@atheros.com>

There's a race in register_netdevice() so that the udev event is sent before
the device is actually ready. This was visible with flimflam, chrome os
connection manager:

00:21:35 roska flimflamd[2598]: src/udev.c:add_net_device()
00:21:35 roska flimflamd[2598]: connman_inet_ifname: SIOCGIFNAME(index
   4): No such device

So the kobject is visible in udev before the device is ready.

The issue is reported here:

https://bugzilla.kernel.org/show_bug.cgi?id=15606

Fix this by postponing the uevent with device_add_noevent() and
calling device_uevent() once the device is really ready.

Thanks to Johannes Berg for the original idea.

Signed-off-by: Kalle Valo <kalle.valo@atheros.com>
---
 net/core/dev.c       |    3 +++
 net/core/net-sysfs.c |    2 +-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 856b6ee..80cfa23 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5454,6 +5454,9 @@ int register_netdevice(struct net_device *dev)
 		rollback_registered(dev);
 		dev->reg_state = NETREG_UNREGISTERED;
 	}
+
+	device_uevent(&(dev->dev));
+
 	/*
 	 *	Prevent userspace races by waiting until the network
 	 *	device is fully setup before sending notifications.
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5ceb257..c10b1d5 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1337,7 +1337,7 @@ int netdev_register_kobject(struct net_device *net)
 #endif
 #endif /* CONFIG_SYSFS */
 
-	error = device_add(dev);
+	error = device_add_noevent(dev);
 	if (error)
 		return error;
 

