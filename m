From: Eric Garver <e@erig.me>
Subject: [PATCH net] geneve: fix needed_headroom and max_mtu for collect_metadata
Date: Fri,  2 Jun 2017 14:54:10 -0400
Message-ID: <20170602185410.10971-1-e@erig.me>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55736 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751007AbdFBSyN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Jun 2017 14:54:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
when using COLLECT_METADATA geneve devices are created with too small of
a needed_headroom and too large of a max_mtu. This is because
ip_tunnel_info_af() is not valid with the device level info when using
COLLECT_METADATA and we mistakenly fall into the IPv4 case.

For COLLECT_METADATA, always use the worst case of ipv6 since both
sockets are created.

Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
Signed-off-by: Eric Garver <e@erig.me>
---
 drivers/net/geneve.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 959fd12d2e67..6ebb0f559a42 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1133,7 +1133,7 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 
 	/* make enough headroom for basic scenario */
 	encap_len = GENEVE_BASE_HLEN + ETH_HLEN;
-	if (ip_tunnel_info_af(info) == AF_INET) {
+	if (!metadata && ip_tunnel_info_af(info) == AF_INET) {
 		encap_len += sizeof(struct iphdr);
 		dev->max_mtu -= sizeof(struct iphdr);
 	} else {
-- 
2.12.0
