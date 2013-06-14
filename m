From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 7/8] openvswitch: make skb->csum
	consistent with rest of networking stack.
Date: Fri, 14 Jun 2013 15:28:56 -0700
Message-ID: <1371248937-35614-8-git-send-email-jesse@nicira.com>
References: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1371248937-35614-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Following patch keeps skb->csum correct across ovs.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/actions.c            | 4 ++++
 net/openvswitch/flow.c               | 3 +++
 net/openvswitch/vport-internal_dev.c | 1 +
 net/openvswitch/vport-netdev.c       | 2 ++
 net/openvswitch/vport.h              | 7 +++++++
 5 files changed, 17 insertions(+)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 894b6cb..596d637 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -130,9 +130,13 @@ static int set_eth_addr(struct sk_buff *skb,
 	if (unlikely(err))
 		return err;
 
+	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_ALEN * 2);
+
 	memcpy(eth_hdr(skb)->h_source, eth_key->eth_src, ETH_ALEN);
 	memcpy(eth_hdr(skb)->h_dest, eth_key->eth_dst, ETH_ALEN);
 
+	ovs_skb_postpush_rcsum(skb, eth_hdr(skb), ETH_ALEN * 2);
+
 	return 0;
 }
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 33df091..fca4833 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -618,6 +618,9 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 	memcpy(key->eth.dst, eth->h_dest, ETH_ALEN);
 
 	__skb_pull(skb, 2 * ETH_ALEN);
+	/* We are going to push all headers that we pull, so no need to
+	 * update skb->csum here.
+	 */
 
 	if (vlan_tx_tag_present(skb))
 		key->eth.tci = htons(skb->vlan_tci);
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 84e0a03..e284c7e 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -221,6 +221,7 @@ static int internal_dev_recv(struct vport *vport, struct sk_buff *skb)
 	skb->dev = netdev;
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, netdev);
+	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 
 	netif_rx(skb);
 
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4371221..40de815 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -49,6 +49,8 @@ static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 		return;
 
 	skb_push(skb, ETH_HLEN);
+	ovs_skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
+
 	ovs_vport_receive(vport, skb);
 	return;
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 1cef5cd..293278c 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -192,4 +192,11 @@ void ovs_vport_record_error(struct vport *, enum vport_err_type err_type);
 extern const struct vport_ops ovs_netdev_vport_ops;
 extern const struct vport_ops ovs_internal_vport_ops;
 
+static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
+				      const void *start, unsigned int len)
+{
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_add(skb->csum, csum_partial(start, len, 0));
+}
+
 #endif /* vport.h */
-- 
1.8.1.2
