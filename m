From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 4/7] openvswitch: Reset upper layer
	protocol info on internal devices.
Date: Fri, 20 Jul 2012 15:26:47 -0700
Message-ID: <1342823210-3308-5-git-send-email-jesse@nicira.com>
References: <1342823210-3308-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1342823210-3308-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

It's possible that packets that are sent on internal devices (from
the OVS perspective) have already traversed the local IP stack.
After they go through the internal device, they will again travel
through the IP stack which may get confused by the presence of
existing information in the skb. The problem can be observed
when switching between namespaces. This clears out that information
to avoid problems but deliberately leaves other metadata alone.
This is to provide maximum flexibility in chaining together OVS
and other Linux components.

Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/vport-internal_dev.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index de509d3..4061b9e 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -24,6 +24,9 @@
 #include <linux/ethtool.h>
 #include <linux/skbuff.h>
 
+#include <net/dst.h>
+#include <net/xfrm.h>
+
 #include "datapath.h"
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
@@ -209,6 +212,11 @@ static int internal_dev_recv(struct vport *vport, struct sk_buff *skb)
 	int len;
 
 	len = skb->len;
+
+	skb_dst_drop(skb);
+	nf_reset(skb);
+	secpath_reset(skb);
+
 	skb->dev = netdev;
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, netdev);
-- 
1.7.9.5
