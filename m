From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] init_netdev missing locking
Date: Wed, 15 Oct 2003 11:05:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015110520.0206e327.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


It looks like the call to dev_alloc_name() in init_netdev()
isn't protected by the required locking.
This patch adds rtnl_lock/unlock around the call to dev_alloc_name().

Comments?  or please apply.

--
~Randy


description:	add required locking to init_netdev()'s call to
		dev_alloc_name()
patch_name:	netinit_alloc_lock.patch
product_versions: Linux 2.6.0-test7
maintainer:	davem@redhat.com
author:		Randy.Dunlap <rddunlap@osdl.org>
patch_version:	2003-10-15.10:55:51

diffstat:=
 drivers/net/net_init.c |    3 +++
 1 files changed, 3 insertions(+)

diff -Naurp ./drivers/net/net_init.c~dev_alloc_lock ./drivers/net/net_init.c
--- ./drivers/net/net_init.c~dev_alloc_lock	2003-10-15 10:53:02.000000000 -0700
+++ ./drivers/net/net_init.c	2003-10-15 10:53:34.000000000 -0700
@@ -148,11 +148,14 @@ static struct net_device *init_netdev(st
 	 
 	if (dev->name[0] == '\0' || dev->name[0] == ' ') {
 		strcpy(dev->name, mask);
+		rtnl_lock();
 		if (dev_alloc_name(dev, mask)<0) {
+			rtnl_unlock();
 			if (new_device)
 				kfree(dev);
 			return NULL;
 		}
+		rtnl_unlock();
 	}
 
 	netdev_boot_setup_check(dev);
