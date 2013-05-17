From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v8 10/11] vxlan: respect scope_id for ll addr
Date: Fri, 17 May 2013 08:21:38 +0800
Message-ID: <1368750099-14086-11-git-send-email-amwang@redhat.com>
References: <1368750099-14086-1-git-send-email-amwang@redhat.com>
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754913Ab3EQAWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 20:22:45 -0400
In-Reply-To: <1368750099-14086-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

As pointed out by David, we should take care of scope id for ll
addr, and use it for route lookup.

Cc: David Stevens <dlstevens@us.ibm.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f4d46bf..68ebfa4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1237,7 +1237,7 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct sock *sk = vn->sock6->sk;
 	struct ipv6hdr *ip6h;
 #endif
-	const union vxlan_addr *dst;
+	union vxlan_addr *dst;
 	struct dst_entry *ndst = NULL;
 	__be16 src_port = 0, dst_port;
         u32 vni;
@@ -1332,6 +1332,12 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		src_port = vxlan_src_port(vxlan, skb);
 
+		if (ipv6_addr_type(&dst->sin6.sin6_addr) & IPV6_ADDR_LINKLOCAL) {
+			dst->sin6.sin6_scope_id = ipv6_iface_scope_id(&dst->sin6.sin6_addr,
+								rdst->remote_ifindex);
+			rdst->remote_ifindex = dst->sin6.sin6_scope_id;
+		}
+
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_oif = rdst->remote_ifindex;
 		fl6.flowi6_tos = RT_TOS(tos);
-- 
1.7.7.6
