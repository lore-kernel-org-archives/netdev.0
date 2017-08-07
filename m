From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] net: vrf: Add extack messages for newlink failures
Date: Mon,  7 Aug 2017 10:08:10 -0700
Message-ID: <1502125690-2212-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:37958 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751513AbdHGRIQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 13:08:16 -0400
Received: by mail-pf0-f193.google.com with SMTP id h75so915842pfh.5
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 10:08:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add extack error messages for failure paths creating vrf devices. Once
extack support is added to iproute2, we go from the unhelpful:
    $  ip li add foobar type vrf
    RTNETLINK answers: Invalid argument

to:
    $ ip li add foobar type vrf
    Error: VRF table id is missing

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 drivers/net/vrf.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 8a1eaf3c302a..abd2010c48ae 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -1371,10 +1371,14 @@ static int vrf_validate(struct nlattr *tb[], struct nlattr *data[],
 			struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
-		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
+			NL_SET_ERR_MSG(extack, "Invalid hardware address");
 			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+		}
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS]))) {
+			NL_SET_ERR_MSG(extack, "Invalid hardware address");
 			return -EADDRNOTAVAIL;
+		}
 	}
 	return 0;
 }
@@ -1399,12 +1403,17 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 	struct net *net;
 	int err;
 
-	if (!data || !data[IFLA_VRF_TABLE])
+	if (!data || !data[IFLA_VRF_TABLE]) {
+		NL_SET_ERR_MSG(extack, "VRF table id is missing");
 		return -EINVAL;
+	}
 
 	vrf->tb_id = nla_get_u32(data[IFLA_VRF_TABLE]);
-	if (vrf->tb_id == RT_TABLE_UNSPEC)
+	if (vrf->tb_id == RT_TABLE_UNSPEC) {
+		NL_SET_ERR_MSG_ATTR(extack, data[IFLA_VRF_TABLE],
+				    "Invalid VRF table id");
 		return -EINVAL;
+	}
 
 	dev->priv_flags |= IFF_L3MDEV_MASTER;
 
-- 
2.1.4
