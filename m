From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] bonding: remove sysfs before removing devices
Date: Wed,  3 Apr 2013 17:46:33 +0200
Message-ID: <1365003993-13181-1-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	nikolay@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22790 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761567Ab3DCPq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Apr 2013 11:46:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a race condition if we try to rmmod bonding and simultaneously add
a bond master through sysfs. In bonding_exit() we first remove the devices
(through rtnl_link_unregister() ) and only after that we remove the sysfs.
If we manage to add a device through sysfs after that the devices were
removed - we'll end up with that device/sysfs structure and with the module
unloaded.

Fix this by first removing the sysfs and only after that calling
rtnl_link_unregister().

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 11a8cb3..dadeffc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4902,8 +4902,8 @@ static void __exit bonding_exit(void)
 
 	bond_destroy_debugfs();
 
-	rtnl_link_unregister(&bond_link_ops);
 	unregister_pernet_subsys(&bond_net_ops);
+	rtnl_link_unregister(&bond_link_ops);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	/*
-- 
1.7.1
