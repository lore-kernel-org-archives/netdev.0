From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v2 2/5] vxlan: remove net arg from
	vxlan[6]_xmit_skb()
Date: Mon,  2 Sep 2013 15:34:55 +0200
Message-ID: <1378128898-15136-3-git-send-email-nicolas.dichtel@6wind.com>
References: <CALnjE+pKi=p0y2ot2qWG1w=pxEUcPUKY+_UUi0RXbnGqVk9poA@mail.gmail.com>
	<1378128898-15136-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1378128898-15136-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This argument is not used, let's remove it.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/vxlan.c           | 8 ++++----
 include/net/vxlan.h           | 2 +-
 net/openvswitch/vport-vxlan.c | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 18165c02d614..5f46d2f3222f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1380,7 +1380,7 @@ static int handle_offloads(struct sk_buff *skb)
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static int vxlan6_xmit_skb(struct net *net, struct vxlan_sock *vs,
+static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 			   struct dst_entry *dst, struct sk_buff *skb,
 			   struct net_device *dev, struct in6_addr *saddr,
 			   struct in6_addr *daddr, __u8 prio, __u8 ttl,
@@ -1475,7 +1475,7 @@ static int vxlan6_xmit_skb(struct net *net, struct vxlan_sock *vs,
 }
 #endif
 
-int vxlan_xmit_skb(struct net *net, struct vxlan_sock *vs,
+int vxlan_xmit_skb(struct vxlan_sock *vs,
 		   struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
 		   __be16 src_port, __be16 dst_port, __be32 vni)
@@ -1651,7 +1651,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 
-		err = vxlan_xmit_skb(dev_net(dev), vxlan->vn_sock, rt, skb,
+		err = vxlan_xmit_skb(vxlan->vn_sock, rt, skb,
 				     fl4.saddr, dst->sin.sin_addr.s_addr,
 				     tos, ttl, df, src_port, dst_port,
 				     htonl(vni << 8));
@@ -1703,7 +1703,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
 
-		err = vxlan6_xmit_skb(dev_net(dev), vxlan->vn_sock, ndst, skb,
+		err = vxlan6_xmit_skb(vxlan->vn_sock, ndst, skb,
 				      dev, &fl6.saddr, &fl6.daddr, 0, ttl,
 				      src_port, dst_port, htonl(vni << 8));
 #endif
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index d2b88cafa7a2..e09c40b68027 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -29,7 +29,7 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 
 void vxlan_sock_release(struct vxlan_sock *vs);
 
-int vxlan_xmit_skb(struct net *net, struct vxlan_sock *vs,
+int vxlan_xmit_skb(struct vxlan_sock *vs,
 		   struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
 		   __be16 src_port, __be16 dst_port, __be32 vni);
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index a0060245b4e1..a481c03e2861 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -176,7 +176,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	inet_get_local_port_range(&port_min, &port_max);
 	src_port = vxlan_src_port(port_min, port_max, skb);
 
-	err = vxlan_xmit_skb(net, vxlan_port->vs, rt, skb,
+	err = vxlan_xmit_skb(vxlan_port->vs, rt, skb,
 			     fl.saddr, OVS_CB(skb)->tun_key->ipv4_dst,
 			     OVS_CB(skb)->tun_key->ipv4_tos,
 			     OVS_CB(skb)->tun_key->ipv4_ttl, df,
-- 
1.8.2.1
