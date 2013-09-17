From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] vxlan: Avoid creating fdb entry with NULL destination
Date: Tue, 17 Sep 2013 12:12:40 -0700
Message-ID: <1379445160.21109.29.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	mike.rapoport@ravellosystems.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:50771 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752863Ab3IQTMr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 15:12:47 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Tue, 17 Sep 2013 15:12:46 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 9982FC9005A
	for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 15:12:43 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8HJChNa47644676
	for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 19:12:43 GMT
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8HJCgx9029904
	for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 15:12:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit afbd8bae9c798c5cdbe4439d3a50536b5438247c 
   vxlan: add implicit fdb entry for default destination
creates an implicit fdb entry for default destination. This results 
in an invalid fdb entry if default destination is not specified.
For ex: 
  ip link add vxlan1 type vxlan id 100
creates the following fdb entry
  00:00:00:00:00:00 dev vxlan1 dst 0.0.0.0 self permanent

This patch fixes this issue by creating an fdb entry only if a
valid default destination is specified.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
---

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bf64b41..ac25c2d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2492,15 +2492,19 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 
 	SET_ETHTOOL_OPS(dev, &vxlan_ethtool_ops);
 
-	/* create an fdb entry for default destination */
-	err = vxlan_fdb_create(vxlan, all_zeros_mac,
-			       &vxlan->default_dst.remote_ip,
-			       NUD_REACHABLE|NUD_PERMANENT,
-			       NLM_F_EXCL|NLM_F_CREATE,
-			       vxlan->dst_port, vxlan->default_dst.remote_vni,
-			       vxlan->default_dst.remote_ifindex, NTF_SELF);
-	if (err)
-		return err;
+	/* create an fdb entry for a valid default destination */
+	if (!vxlan_addr_any(&vxlan->default_dst.remote_ip)) {
+		err = vxlan_fdb_create(vxlan, all_zeros_mac,
+				       &vxlan->default_dst.remote_ip,
+				       NUD_REACHABLE|NUD_PERMANENT,
+				       NLM_F_EXCL|NLM_F_CREATE,
+				       vxlan->dst_port,
+				       vxlan->default_dst.remote_vni,
+				       vxlan->default_dst.remote_ifindex,
+				       NTF_SELF);
+		if (err)
+			return err;
+	}
 
 	err = register_netdevice(dev);
 	if (err) {
