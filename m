From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net] tunnels: Don't require remote endpoint or ID during creation.
Date: Fri, 16 Oct 2015 16:36:00 -0700
Message-ID: <1445038560-85471-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34550 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbbJPXgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 19:36:05 -0400
Received: by pabws5 with SMTP id ws5so2982342pab.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 16:36:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before lightweight tunnels existed, it really didn't make sense to
create a tunnel that was not fully specified, such as without a
destination IP address - the resulting packets would go nowhere.
However, with lightweight tunnels, the opposite is true - it doesn't
make sense to require this information when it will be provided later
on by the route. This loosens the requirements for this information.

An alternative would be to allow the relaxed version only when
COLLECT_METADATA is enabled. However, since there are several
variations on this theme (such as NBMA tunnels in GRE), just dropping
the restrictions seems the most consistent across tunnels and with
the existing configuration.

CC: John Linville <linville@tuxdriver.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 drivers/net/geneve.c | 12 ++++++------
 drivers/net/vxlan.c  |  7 +++----
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 8f5c02e..cde29f8 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -870,14 +870,14 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	__be16 dst_port = htons(GENEVE_UDP_PORT);
 	__u8 ttl = 0, tos = 0;
 	bool metadata = false;
-	__be32 rem_addr;
-	__u32 vni;
+	__be32 rem_addr = 0;
+	__u32 vni = 0;
 
-	if (!data[IFLA_GENEVE_ID] || !data[IFLA_GENEVE_REMOTE])
-		return -EINVAL;
+	if (data[IFLA_GENEVE_ID])
+		vni = nla_get_u32(data[IFLA_GENEVE_ID]);
 
-	vni = nla_get_u32(data[IFLA_GENEVE_ID]);
-	rem_addr = nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
+	if (data[IFLA_GENEVE_REMOTE])
+		rem_addr = nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
 
 	if (data[IFLA_GENEVE_TTL])
 		ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bbac1d3..afdc65f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2745,11 +2745,10 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	struct vxlan_config conf;
 	int err;
 
-	if (!data[IFLA_VXLAN_ID])
-		return -EINVAL;
-
 	memset(&conf, 0, sizeof(conf));
-	conf.vni = nla_get_u32(data[IFLA_VXLAN_ID]);
+
+	if (data[IFLA_VXLAN_ID])
+		conf.vni = nla_get_u32(data[IFLA_VXLAN_ID]);
 
 	if (data[IFLA_VXLAN_GROUP]) {
 		conf.remote_ip.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_GROUP]);
-- 
2.1.4
