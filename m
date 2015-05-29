From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH] vti6: Add pmtu handling to vti6_xmit.
Date: Fri, 29 May 2015 11:28:26 -0700
Message-ID: <20150529182709.2147.78230.stgit@ahduyck-vm-fedora22>
References: <5567695F.6070505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: steffen.klassert@secunet.com, davem@davemloft.net,
	herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <5567695F.6070505@gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steffen Klassert <steffen.klassert@secunet.com>

We currently rely on the PMTU discovery of xfrm.
However if a packet is localy sent, the PMTU mechanism
of xfrm tries to to local socket notification what
might not work for applications like ping that don't
check for this. So add pmtu handling to vti6_xmit to
report MTU changes immediately.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---

So this version is slightly modified to cover the IPv4 case in addition to
the IPv6 case.  With this patch I was able to run netperf over either an
IPv4 or IPv6 address routed over the ip6_vti tunnel.

 net/ipv6/ip6_vti.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index d25209657edc..3b5c1ea50d2f 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -435,6 +435,7 @@ vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
 	struct net_device *tdev;
 	struct xfrm_state *x;
 	int err = -1;
+	int mtu;
 
 	if (!dst)
 		goto tx_err_link_failure;
@@ -468,6 +469,19 @@ vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
 	skb_dst_set(skb, dst);
 	skb->dev = skb_dst(skb)->dev;
 
+	mtu = dst_mtu(dst);
+	if (!skb->ignore_df && skb->len > mtu) {
+		skb_dst(skb)->ops->update_pmtu(dst, NULL, skb, mtu);
+
+		if (skb->protocol == htons(ETH_P_IPV6))
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		else
+			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
+				  htonl(mtu));
+
+		return -EMSGSIZE;
+	}
+
 	err = dst_output(skb);
 	if (net_xmit_eval(err) == 0) {
 		struct pcpu_sw_netstats *tstats = this_cpu_ptr(dev->tstats);
