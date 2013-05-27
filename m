From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v9 10/11] vxlan: respect scope_id for ll addr
Date: Mon, 27 May 2013 12:16:32 +0800
Message-ID: <1369628193-14925-11-git-send-email-amwang@redhat.com>
References: <1369628193-14925-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54562 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135Ab3E0ER7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 00:17:59 -0400
In-Reply-To: <1369628193-14925-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

As pointed out by David, we should take care of scope id for ll
addr, so use it for route lookup.

Cc: David S. Miller <davem@davemloft.net>
Cc: David Stevens <dlstevens@us.ibm.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 4c9709e..bcb8a42 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1306,7 +1306,7 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct sock *sk = vxlan->vn_sock->sock->sk;
 	struct ipv6hdr *ip6h;
 #endif
-	const union vxlan_addr *dst;
+	union vxlan_addr *dst;
 	struct dst_entry *ndst = NULL;
 	__be16 src_port = 0, dst_port;
         u32 vni;
@@ -1401,6 +1401,12 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
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
