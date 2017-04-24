From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] ipv6: move stub initialization after ipv6 setup completion
Date: Mon, 24 Apr 2017 14:18:28 +0200
Message-ID: <fd7c85f650661466a782a71485f227f0b84454a7.1493035843.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60686 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1169634AbdDXMTk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 08:19:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv6 stub pointer is currently initialized before the ipv6
routing subsystem: a 3rd party can access and use such stub
before the routing data is ready.
Moreover, such pointer is not cleared in case of initialization
error, possibly leading to dangling pointers usage.

This change addresses the above moving the stub initialization
at the end of ipv6 init code.

Fixes: 5f81bd2e5d80 ("ipv6: export a stub for IPv6 symbols used by vxlan")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/af_inet6.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a9a9553..e82e59f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -933,8 +933,6 @@ static int __init inet6_init(void)
 	if (err)
 		goto igmp_fail;
 
-	ipv6_stub = &ipv6_stub_impl;
-
 	err = ipv6_netfilter_init();
 	if (err)
 		goto netfilter_fail;
@@ -1010,6 +1008,10 @@ static int __init inet6_init(void)
 	if (err)
 		goto sysctl_fail;
 #endif
+
+	/* ensure that ipv6 stubs are visible only after ipv6 is ready */
+	wmb();
+	ipv6_stub = &ipv6_stub_impl;
 out:
 	return err;
 
-- 
2.9.3
