From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC v3 0/12] vti4: prepare namespace and interfamily
 support.
Date: Thu, 30 Jan 2014 10:56:10 +0100
Message-ID: <20140130095610.GR31491@secunet.com>
References: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
 <52E8DE2C.7060706@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42198 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbaA3J4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jan 2014 04:56:13 -0500
Content-Disposition: inline
In-Reply-To: <52E8DE2C.7060706@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 29, 2014 at 11:55:40AM +0100, Christophe Gouault wrote:
> 
> Hi Steffen,
> 
> I did some tests, and it seems there is no inbound policy check against
> a vti SP after the ipsec decryption:

Thanks for testing!

> 
> To confirm the problem, I added some logs in the kernel to track the
> outbound SPD lookup and inbound policy check.
> 
> I tested a ping from HostL(10.22.1.1) to HostR(10.24.1.201), that must
> be encapsulated via a vti interface (vti1, mark 1, ifindex 8) between
> IPsecVTI(10.23.1.101) and HostR(10.23.1.201).
> 
> . 10.22.1.0/24 10.23.1.0/24 10.24.1.0/24
> . (HostL) ------------(IPsecVTI)============(HostR)------------
> . .1 .101 .201
> 
> Here is the trace:
> 
> (1) xfrm_lookup: oif=8 mark=0 saddr=10.22.1.1 daddr=10.24.1.201
> (2) xfrm_lookup: oif=8 mark=1 saddr=10.22.1.1 daddr=10.24.1.201
> (3) vti_rcv: found tunnel vti1
> (4) __xfrm_policy_check: dir=0 iif=0 mark=0 saddr=10.23.1.201
> daddr=10.23.1.101 skb->sp->len=0
> (5) __xfrm_policy_check: dir=2 iif=0 mark=0 saddr=10.24.1.201
> daddr=10.22.1.1 skb->sp->len=0
> 
> And the analysis:
> 
> - A first SPD lookup is done before entering vti1 in (1), seeking for
> a "global SP".
> - A second SPD lookup is done after entering vti1 in (2), with mark 1,
> seeking for a "vti SP"
> - the icmp request is encapsulated and sent to HostR
> - the esp-encrypted icmp reply is received, the packet enters vti1
> and an inbound policy check is performed on the ESP packet itself in
> (4), with mark 0, seeking for a "global SP".
> - the packet is decrypted and its mark set to 1, but no vti inbound
> policy check is done. Then the skb mark and secpath are reset by
> skb_scrub_params (called by vti_rcv_cb).
> - Then only an inbound policy check is performed on the icmp
> reply in (5), seeking for a "global SP". It is considered a plaintext
> packet, with no mark or secpath.
> 
> => there is no check that the forward vti security policy was
> enforced.
> 

Yes, that's true and this is a real problem. If we want to support
namespace transitions with vti, we can't know if a packet is going
to be forwarded or locally received in the other namespace. This means
that we don't know if we should enforce a input or a forward policy.

All we can do here, is to enforce a input policy before we do the
namespace transition in the receive path. The patch below (on top
of the vti patchset) should do this.

But this has the implication that forward policies do not make
much sense in combination with vti. This is a bit contrary to
traditional xfrm processing. But on the other hand, we receive
plaintext packets from the vti device so we should not check
for any IPsec processing that happened before we received the
packets via the vti device.


---
 include/net/xfrm.h        |   10 +++++-----
 net/ipv4/ip_vti.c         |    5 ++++-
 net/ipv4/xfrm4_protocol.c |    9 ++++++---
 net/xfrm/xfrm_input.c     |    4 +++-
 4 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index b7740ce..cac9c46 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1519,7 +1519,7 @@ int xfrm4_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm4_output(struct sk_buff *skb);
 int xfrm4_output_finish(struct sk_buff *skb);
-void xfrm4_rcv_cb(struct sk_buff *skb, u8 protocol, int err);
+int xfrm4_rcv_cb(struct sk_buff *skb, u8 protocol, int err);
 int xfrm4_protocol_register(struct xfrm4_protocol *handler, unsigned char protocol);
 int xfrm4_protocol_deregister(struct xfrm4_protocol *handler, unsigned char protocol);
 int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
@@ -1753,14 +1753,14 @@ static inline int xfrm_mark_put(struct sk_buff *skb, const struct xfrm_mark *m)
 	return ret;
 }
 
-static inline void xfrm_rcv_cb(struct sk_buff *skb, unsigned int family,
-			       u8 protocol, int err)
+static inline int xfrm_rcv_cb(struct sk_buff *skb, unsigned int family,
+			      u8 protocol, int err)
 {
 	switch(family) {
 	case AF_INET:
-		xfrm4_rcv_cb(skb, protocol, err);
-		break;
+		return xfrm4_rcv_cb(skb, protocol, err);
 	}
+	return 0;
 }
 
 #endif	/* _NET_XFRM_H */
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 7b1542c..5beb260 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -82,7 +82,7 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
 	struct ip_tunnel *tunnel = XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4;
 
 	if (!tunnel)
-		return -1;
+		return 1;
 
 	dev = tunnel->dev;
 
@@ -93,6 +93,9 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
 		return 0;
 	}
 
+	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
+		return -EPERM;
+
 	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(skb->dev)));
 	skb->dev = dev;
 
diff --git a/net/ipv4/xfrm4_protocol.c b/net/ipv4/xfrm4_protocol.c
index 993ab39..5ab5527 100644
--- a/net/ipv4/xfrm4_protocol.c
+++ b/net/ipv4/xfrm4_protocol.c
@@ -46,13 +46,16 @@ static inline struct xfrm4_protocol __rcu **proto_handlers(u8 protocol)
 	     handler != NULL;				\
 	     handler = rcu_dereference(handler->next))	\
 
-void xfrm4_rcv_cb(struct sk_buff *skb, u8 protocol, int err)
+int xfrm4_rcv_cb(struct sk_buff *skb, u8 protocol, int err)
 {
+	int ret;
 	struct xfrm4_protocol *handler;
 
 	for_each_protocol_rcu(*proto_handlers(protocol), handler)
-		if (!handler->cb_handler(skb, err))
-			return;
+		if ((ret = handler->cb_handler(skb, err)) <= 0)
+			return ret;
+
+	return 0;
 }
 EXPORT_SYMBOL(xfrm4_rcv_cb);
 
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index fb64b4a..99e3a9e 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -263,7 +263,9 @@ resume:
 		}
 	} while (!err);
 
-	xfrm_rcv_cb(skb, family, x->type->proto, 0);
+	err = xfrm_rcv_cb(skb, family, x->type->proto, 0);
+	if (err)
+		goto drop;
 
 	nf_reset(skb);
 
-- 
1.7.9.5
