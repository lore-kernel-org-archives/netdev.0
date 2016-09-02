From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 1/2] vxlan: reject multicast destination without an interface
Date: Fri,  2 Sep 2016 13:37:11 +0200
Message-ID: <e6dcb4c793eda200142ae7834c1e342f994451cf.1472815982.git.jbenc@redhat.com>
References: <cover.1472815982.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33230 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752045AbcIBLh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 07:37:28 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1F133C05680F
        for <netdev@vger.kernel.org>; Fri,  2 Sep 2016 11:37:24 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-85.brq.redhat.com [10.40.204.85])
        by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u82BbMAk001359
        for <netdev@vger.kernel.org>; Fri, 2 Sep 2016 07:37:23 -0400
In-Reply-To: <cover.1472815982.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, kernel accepts configurations such as:

  ip l a type vxlan dstport 4789 id 1 group 239.192.0.1
  ip l a type vxlan dstport 4789 id 1 group ff0e::110

However, neither of those really works. In the IPv4 case, the interface
cannot be brought up ("RTNETLINK answers: No such device"). This is because
multicast join will be rejected without the interface being specified.

In the IPv6 case, multicast wil be joined on the first interface found. This
is not what the user wants as it depends on random factors (order of
interfaces).

Note that it's possible to add a local address but it doesn't solve
anything. For IPv4, it's not considered in the multicast join (thus the same
error as above is returned on ifup). This could be added but it wouldn't
help for IPv6 anyway. For IPv6, we do need the interface.

Just reject a configuration that sets multicast address and does not provide
an interface. Nobody can depend on the previous behavior as it never worked.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index c0dda6fc0921..6358e35d74b7 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2842,6 +2842,9 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 			dev->mtu = lowerdev->mtu - (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
 
 		needed_headroom = lowerdev->hard_header_len;
+	} else if (vxlan_addr_multicast(&dst->remote_ip)) {
+		pr_info("multicast destination requires interface to be specified\n");
+		return -EINVAL;
 	}
 
 	if (conf->mtu) {
-- 
1.8.3.1
