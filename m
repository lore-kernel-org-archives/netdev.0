From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] openvswitch: Move LRO check from transmit to
	receive.
Date: Wed,  6 Feb 2013 19:14:56 -0800
Message-ID: <1360206896-43022-2-git-send-email-jesse@nicira.com>
References: <1360206896-43022-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1360206896-43022-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

The check for LRO packets was incorrectly put in the transmit path
instead of on receive.  Since this check is supposed to protect OVS
(and other parts of the system) from packets that it cannot handle
it is obviously not useful on egress.  Therefore, this commit moves
it back to the receive side.

The primary problem that this caused is upcalls to userspace tried
to segment the packet even though no segmentation information is
available.  This would later cause NULL pointer dereferences when
skb_gso_segment() did nothing.

Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/vport-netdev.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index a9327e2..670cbc3 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -35,10 +35,11 @@
 /* Must be called with rcu_read_lock. */
 static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 {
-	if (unlikely(!vport)) {
-		kfree_skb(skb);
-		return;
-	}
+	if (unlikely(!vport))
+		goto error;
+
+	if (unlikely(skb_warn_if_lro(skb)))
+		goto error;
 
 	/* Make our own copy of the packet.  Otherwise we will mangle the
 	 * packet for anyone who came before us (e.g. tcpdump via AF_PACKET).
@@ -50,6 +51,10 @@ static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 
 	skb_push(skb, ETH_HLEN);
 	ovs_vport_receive(vport, skb);
+	return;
+
+error:
+	kfree_skb(skb);
 }
 
 /* Called with rcu_read_lock and bottom-halves disabled. */
@@ -169,9 +174,6 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
 		goto error;
 	}
 
-	if (unlikely(skb_warn_if_lro(skb)))
-		goto error;
-
 	skb->dev = netdev_vport->dev;
 	len = skb->len;
 	dev_queue_xmit(skb);
-- 
1.7.9.5
