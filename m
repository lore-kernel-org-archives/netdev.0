From: Vincent Bernat <vincent@bernat.im>
Subject: [net-next v1] vxlan: use appropriate family on L3 miss
Date: Fri, 10 Mar 2017 16:30:24 +0100
Message-ID: <20170310153024.30894-1-vincent@bernat.im>
Cc: Vincent Bernat <vincent@bernat.im>
To: "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:33042 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932482AbdCJPbG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Mar 2017 10:31:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending a L3 miss, the family is set to AF_INET even for IPv6. This
causes userland (eg "ip monitor") to be confused. Ensure we send the
appropriate family in this case. For L2 miss, keep using AF_INET.

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e375560cc74e..168257aa8ace 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -276,9 +276,9 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	send_eth = send_ip = true;
 
 	if (type == RTM_GETNEIGH) {
-		ndm->ndm_family	= AF_INET;
 		send_ip = !vxlan_addr_any(&rdst->remote_ip);
 		send_eth = !is_zero_ether_addr(fdb->eth_addr);
+		ndm->ndm_family = send_ip ? rdst->remote_ip.sa.sa_family : AF_INET;
 	} else
 		ndm->ndm_family	= AF_BRIDGE;
 	ndm->ndm_state = fdb->state;
-- 
2.11.0
