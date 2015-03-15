From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-netns: Notice about loose device when do 'del'
Date: Sun, 15 Mar 2015 12:57:24 +0200
Message-ID: <1426417044-6754-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:34898 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbbCOLJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 07:09:03 -0400
Received: by lbcgn8 with SMTP id gn8so4016565lbc.2
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 04:09:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-netns.8 | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index 28a9544..062564d 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -46,6 +46,9 @@ ip-netns \- process network namespace management
 A network namespace is logically another copy of the network stack,
 with its own routes, firewall rules, and network devices.
 
+By default process inherites network namespace from its parent. Initially all
+the processes shares the same default network namespace from the init process.
+
 By convention a named network namespace is an object at
 .BR "/var/run/netns/" NAME
 that can be opened.  The file descriptor resulting from opening
@@ -88,14 +91,30 @@ network namespace and assigns NAME.
 .sp
 If NAME is present in /var/run/netns it is umounted and the mount
 point is removed.  If this is the last user of the network namespace the
-network namespace will be freed, otherwise the network namespace
-persists until it has no more users.  ip netns delete may fail if
-the mount point is in use in another mount namespace.
+network namespace will be freed and all physical devices will be moved to the
+default one, otherwise the network namespace persists until it has no more
+users. ip netns delete may fail if the mount point is in use in another mount
+namespace.
 
 If
 .B -all
 option was specified then all the network namespace names will be removed.
 
+It is possible to "loose" the physical device when it was moved to netns and
+then this netns was deleted with a running process:
+
+    $ ip netns add net0
+    $ ip link set dev eth0 netns net0
+    $ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
+    $ ip netns del net0
+
+and eth0 will appear in the default netns only after SOME_PROCESS_IN_BACKGROUND
+will exit or will be killed. To prevent this the processes running in net0
+should be killed before deleting the netns:
+
+    $ ip netns pids net0 | xargs | kill
+    $ ip netns del net0
+
 .TP
 .B ip netns set NAME NETNSID - assign an id to a peer network namespace
 .sp
-- 
2.3.1
