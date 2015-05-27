From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH] xfrm6: Do not use xfrm_local_error for path MTU issues in
 tunnels
Date: Wed, 27 May 2015 10:40:32 -0700
Message-ID: <20150527173823.1415.96248.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: steffen.klassert@secunet.com, davem@davemloft.net,
	herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change makes it so that we use icmpv6_send to report PMTU issues back
into tunnels in the case that the resulting packet is larger than the MTU
of the outgoing interface.  Previously xfrm_local_error was being used in
this case, however this was resulting in no changes, I suspect due to the
fact that the tunnel itself was being kept out of the loop.

This patch fixes PMTU problems seen on ip6_vti tunnels and is based on the
behavior seen if the socket was orphaned.  Instead of requiring the socket
to be orphaned this patch simply defaults to using icmpv6_send in the case
that the frame came though a tunnel.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv6/xfrm6_output.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 09c76a7b474d..6f9b514d0e38 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -72,6 +72,7 @@ static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 {
 	int mtu, ret = 0;
 	struct dst_entry *dst = skb_dst(skb);
+	struct xfrm_state *x = dst->xfrm;
 
 	mtu = dst_mtu(dst);
 	if (mtu < IPV6_MIN_MTU)
@@ -82,7 +83,7 @@ static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 
 		if (xfrm6_local_dontfrag(skb))
 			xfrm6_local_rxpmtu(skb, mtu);
-		else if (skb->sk)
+		else if (skb->sk && x->props.mode != XFRM_MODE_TUNNEL)
 			xfrm_local_error(skb, mtu);
 		else
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
@@ -149,11 +150,16 @@ static int __xfrm6_output(struct sock *sk, struct sk_buff *skb)
 	else
 		mtu = dst_mtu(skb_dst(skb));
 
-	if (skb->len > mtu && xfrm6_local_dontfrag(skb)) {
-		xfrm6_local_rxpmtu(skb, mtu);
-		return -EMSGSIZE;
-	} else if (!skb->ignore_df && skb->len > mtu && skb->sk) {
-		xfrm_local_error(skb, mtu);
+	if (!skb->ignore_df && skb->len > mtu) {
+		skb->dev = dst->dev;
+
+		if (xfrm6_local_dontfrag(skb))
+			xfrm6_local_rxpmtu(skb, mtu);
+		else if (skb->sk && x->props.mode != XFRM_MODE_TUNNEL)
+			xfrm_local_error(skb, mtu);
+		else
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+
 		return -EMSGSIZE;
 	}
 
