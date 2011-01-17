From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] dummy: do not create a link (dummy0) at module init by default
Date: Sun, 16 Jan 2011 19:49:53 -0500
Message-ID: <1295225393-5779-1-git-send-email-david.ward@ll.mit.edu>
To: netdev@vger.kernel.org, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from DMZ-MAILSEC-SCANNER-4.MIT.EDU ([18.9.25.15]:56245 "EHLO
	dmz-mailsec-scanner-4.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751417Ab1AQAul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 19:50:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the dummy network driver is initialized with no parameters, a link
is automatically created (named 'dummy0'). This is inconsistent with
other virtual network drivers such as veth, macvlan, and macvtap, which
do not create a link upon initialization.

This also causes confusing behavior when sending an RTM_NEWLINK message
for a dummy link, because the kernel will load the dummy network driver
first if it has not already been loaded. When that occurs, the result
is that two new links are actually created (or if IFLA_IFNAME is set to
'dummy0', the error EEXIST is returned). The following iproute command
demonstrates this behavior:

  ip link add [ name dummy0 ] type dummy

With this change, users who still want to have a link created when the
dummy network driver is loaded (instead of using iproute to create the
link as shown above) just need to set the 'numdummies' parameter to 1:

  modprobe dummy numdummies=1

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 drivers/net/dummy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index ff2d29b..ac8815f 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -38,7 +38,7 @@
 #include <net/rtnetlink.h>
 #include <linux/u64_stats_sync.h>
 
-static int numdummies = 1;
+static int numdummies = 0;
 
 static int dummy_set_address(struct net_device *dev, void *p)
 {
-- 
1.7.3.4

