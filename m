From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH net-next 1/1] veth: tweak creation of veth device
Date: Tue, 10 Oct 2017 16:08:44 -0400
Message-ID: <1507666124-8780-1-git-send-email-mrv@mojatatu.com>
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
        Roman Mashak <mrv@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:56148 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935073AbdJJUIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 16:08:51 -0400
Received: by mail-it0-f65.google.com with SMTP id l196so126230itl.4
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 13:08:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating veth pair, at first rtnl_new_link() creates veth_dev, i.e.
one end of the veth pipe, but not registers it; then veth_newlink() gets
invoked, where peer dev is created _and_ registered, followed by veth_dev
registration, which may fail if peer information, that is VETH_INFO_PEER
attribute, has not been provided and the kernel will allocate unique veth
name.

So, we should ask the kernel to allocate unique name for veth_dev only
when peer info is not available.

Example:

% ip link dev veth0 type veth
RTNETLINK answers: File exists

After fix:
% ip link dev veth0 type veth
% ip link show dev veth0
5: veth0@veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether f6:ef:8b:96:f4:ec brd ff:ff:ff:ff:ff:ff
%

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 drivers/net/veth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f5438d0..00dce15 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -432,7 +432,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	if (tb[IFLA_ADDRESS] == NULL)
 		eth_hw_addr_random(dev);
 
-	if (tb[IFLA_IFNAME])
+	if (ifmp && tb[IFLA_IFNAME])
 		nla_strlcpy(dev->name, tb[IFLA_IFNAME], IFNAMSIZ);
 	else
 		snprintf(dev->name, IFNAMSIZ, DRV_NAME "%%d");
-- 
1.9.1
