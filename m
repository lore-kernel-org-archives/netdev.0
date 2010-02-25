From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/6] cnic: Simplify route checking during iSCSI
 connection.
Date: Wed, 24 Feb 2010 16:42:07 -0800
Message-ID: <1267058529-18454-4-git-send-email-mchan@broadcom.com>
References: <1267058529-18454-1-git-send-email-mchan@broadcom.com>
 <1267058529-18454-2-git-send-email-mchan@broadcom.com>
 <1267058529-18454-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2534 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758589Ab0BYAcm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 19:32:42 -0500
In-Reply-To: <1267058529-18454-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a separate IP address for iSCSI, connections should proceed
whether or not we can get a route to the target from the network stack.
It is possible that the network IP address may not reach the iSCSI target.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Eddie Wai <waie@broadcom.com>
---
 drivers/net/cnic.c |   37 +++++++++++++------------------------
 1 files changed, 13 insertions(+), 24 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 4558444..0defe61 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2860,8 +2860,8 @@ static int cnic_get_route(struct cnic_sock *csk, struct cnic_sockaddr *saddr)
 {
 	struct cnic_dev *dev = csk->dev;
 	struct cnic_local *cp = dev->cnic_priv;
-	int is_v6, err, rc = -ENETUNREACH;
-	struct dst_entry *dst;
+	int is_v6, rc = 0;
+	struct dst_entry *dst = NULL;
 	struct net_device *realdev;
 	u32 local_port;
 
@@ -2877,39 +2877,31 @@ static int cnic_get_route(struct cnic_sock *csk, struct cnic_sockaddr *saddr)
 	clear_bit(SK_F_IPV6, &csk->flags);
 
 	if (is_v6) {
-#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
 		set_bit(SK_F_IPV6, &csk->flags);
-		err = cnic_get_v6_route(&saddr->remote.v6, &dst);
-		if (err)
-			return err;
-
-		if (!dst || dst->error || !dst->dev)
-			goto err_out;
+		cnic_get_v6_route(&saddr->remote.v6, &dst);
 
 		memcpy(&csk->dst_ip[0], &saddr->remote.v6.sin6_addr,
 		       sizeof(struct in6_addr));
 		csk->dst_port = saddr->remote.v6.sin6_port;
 		local_port = saddr->local.v6.sin6_port;
-#else
-		return rc;
-#endif
 
 	} else {
-		err = cnic_get_v4_route(&saddr->remote.v4, &dst);
-		if (err)
-			return err;
-
-		if (!dst || dst->error || !dst->dev)
-			goto err_out;
+		cnic_get_v4_route(&saddr->remote.v4, &dst);
 
 		csk->dst_ip[0] = saddr->remote.v4.sin_addr.s_addr;
 		csk->dst_port = saddr->remote.v4.sin_port;
 		local_port = saddr->local.v4.sin_port;
 	}
 
-	csk->vlan_id = cnic_get_vlan(dst->dev, &realdev);
-	if (realdev != dev->netdev)
-		goto err_out;
+	csk->vlan_id = 0;
+	csk->mtu = dev->netdev->mtu;
+	if (dst && dst->dev) {
+		u16 vlan = cnic_get_vlan(dst->dev, &realdev);
+		if (realdev == dev->netdev) {
+			csk->vlan_id = vlan;
+			csk->mtu = dst_mtu(dst);
+		}
+	}
 
 	if (local_port >= CNIC_LOCAL_PORT_MIN &&
 	    local_port < CNIC_LOCAL_PORT_MAX) {
@@ -2927,9 +2919,6 @@ static int cnic_get_route(struct cnic_sock *csk, struct cnic_sockaddr *saddr)
 	}
 	csk->src_port = local_port;
 
-	csk->mtu = dst_mtu(dst);
-	rc = 0;
-
 err_out:
 	dst_release(dst);
 	return rc;
-- 
1.6.4.GIT


