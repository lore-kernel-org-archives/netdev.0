From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 1/2] vxlan: correctly handle ipv6.disable module parameter
Date: Thu, 27 Apr 2017 21:24:35 +0200
Message-ID: <f945777f0c12a21bc996dea596b9c940f6c12a17.1493320999.git.jbenc@redhat.com>
References: <cover.1493320999.git.jbenc@redhat.com>
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41436 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034816AbdD0T1h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 15:27:37 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5D48C93312
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 19:27:36 +0000 (UTC)
In-Reply-To: <cover.1493320999.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When IPv6 is compiled but disabled at runtime, __vxlan_sock_add returns
-EAFNOSUPPORT. For metadata based tunnels, this causes failure of the whole
operation of bringing up the tunnel.

Ignore failure of IPv6 socket creation for metadata based tunnels caused by
IPv6 not being available.

Fixes: b1be00a6c39f ("vxlan: support both IPv4 and IPv6 sockets in a single vxlan device")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bdb6ae16d4a8..118e508f1889 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2818,17 +2818,21 @@ static int __vxlan_sock_add(struct vxlan_dev *vxlan, bool ipv6)
 
 static int vxlan_sock_add(struct vxlan_dev *vxlan)
 {
-	bool ipv6 = vxlan->flags & VXLAN_F_IPV6;
 	bool metadata = vxlan->flags & VXLAN_F_COLLECT_METADATA;
+	bool ipv6 = vxlan->flags & VXLAN_F_IPV6 || metadata;
+	bool ipv4 = !ipv6 || metadata;
 	int ret = 0;
 
 	RCU_INIT_POINTER(vxlan->vn4_sock, NULL);
 #if IS_ENABLED(CONFIG_IPV6)
 	RCU_INIT_POINTER(vxlan->vn6_sock, NULL);
-	if (ipv6 || metadata)
+	if (ipv6) {
 		ret = __vxlan_sock_add(vxlan, true);
+		if (ret < 0 && ret != -EAFNOSUPPORT)
+			ipv4 = false;
+	}
 #endif
-	if (!ret && (!ipv6 || metadata))
+	if (ipv4)
 		ret = __vxlan_sock_add(vxlan, false);
 	if (ret < 0)
 		vxlan_sock_release(vxlan);
-- 
1.8.3.1
