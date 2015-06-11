From: sfeldma@gmail.com
Subject: [PATCH net-next] switchdev: fix handling for drivers not supporting IPv4 fib add/del ops
Date: Wed, 10 Jun 2015 17:04:49 -0700
Message-ID: <1433981089-51216-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, f.fainelli@gmail.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34070 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbbFKACv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 20:02:51 -0400
Received: by payr10 with SMTP id r10so43318131pay.1
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 17:02:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

If CONFIG_NET_SWITCHDEV is enabled, but port driver does not implement
support for IPv4 FIB add/del ops, don't fail route add/del offload
operations.  Route adds will not be marked as OFFLOAD.  Routes will be
installed in the kernel FIB, as usual.

This was report/fixed by Florian when testing DSA driver with net-next on
devices with L2 offload support but no L3 offload support. What he reported
was an initial route installed from DHCP client would fail (route not
installed to kernel FIB).  This was triggering the setting of
ipv4.fib_offload_disabled, which would disable route offloading after the
first failure.  So subsequent attempts to install the route would succeed.

There is follow-on work/discussion to address the handling of route install
failures, but for now, let's differentiate between no support and failed
support.

Reported-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/switchdev/switchdev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 99bced4..28637e9 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -853,7 +853,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	if (!err)
 		fi->fib_flags |= RTNH_F_OFFLOAD;
 
-	return err;
+	return err == -EOPNOTSUPP ? 0 : err;
 }
 EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_add);
 
@@ -898,7 +898,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	if (!err)
 		fi->fib_flags &= ~RTNH_F_OFFLOAD;
 
-	return err;
+	return err == -EOPNOTSUPP ? 0 : err;
 }
 EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_del);
 
-- 
1.7.10.4
