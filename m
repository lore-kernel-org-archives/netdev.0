From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] macvlan: handle fragmented multicast frames
Date: Thu, 06 Oct 2011 22:28:31 +0200
Message-ID: <1317932911.3457.31.camel@edumazet-laptop>
References: <4E8C89EE.3090600@candelatech.com>
	 <1317844449.3457.3.camel@edumazet-laptop>
	 <4E8CB990.1010406@candelatech.com>
	 <1317845835.3457.5.camel@edumazet-laptop>
	 <4E8CBBD6.3080500@candelatech.com>
	 <1317846693.3457.11.camel@edumazet-laptop>
	 <4E8CC474.7050803@candelatech.com>
	 <1317850603.3457.21.camel@edumazet-laptop>
	 <4E8CD180.5010905@candelatech.com>  <4E8CDB9B.6010900@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34985 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757235Ab1JFU2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 16:28:35 -0400
Received: by wyg34 with SMTP id 34so3235795wyg.19
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 13:28:34 -0700 (PDT)
In-Reply-To: <4E8CDB9B.6010900@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 octobre 2011 =C3=A0 15:35 -0700, Ben Greear a =C3=A9crit=
 :

> If someone wants to cook up macvlan-ip-defrag patch I'll be happy
> to test it.  But, as far as I can tell, this problem can happen on
> any two interfaces.  The reason that some of mine work (.1q vlans)
> and macvlan didn't is probably because those were separated by
> some virtual network links that imparted extra delay...so the
> vlan consumed all its fragments and passed the complete pkt up
> the stack before the mac-vlan ever saw the initial frame.
>=20
> With this in mind, it seems that using multiple udp multicast
> sockets bound to specific devices is fundamentally broken for
> fragmented packets.
>=20
> I have no pressing need for this feature, so now that I better unders=
tand
> the problem I can just document it and move on to other things.
>=20
> Thanks for all the help.
>=20

Please test following patch (note I had no time to test it, sorry !)

Based on net-next tree, might apply on 3.0 kernel...

[PATCH net-next] macvlan: handle fragmented multicast frames

=46ragmented multicast frames are delivered to a single macvlan port,
because ip defrag logic considers other samples are redundant.

Implement a defrag step before trying to send the multicast frame.

Reported-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/macvlan.c  |    3 +++
 include/net/ip.h       |    9 +++++++++
 net/ipv4/ip_fragment.c |   36 ++++++++++++++++++++++++++++++++++++
 net/packet/af_packet.c |   39 +--------------------------------------

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index b100c90..40366eb 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -169,6 +169,9 @@ static rx_handler_result_t macvlan_handle_frame(str=
uct sk_buff **pskb)
=20
 	port =3D macvlan_port_get_rcu(skb->dev);
 	if (is_multicast_ether_addr(eth->h_dest)) {
+		skb =3D ip_check_defrag(skb, IP_DEFRAG_MACVLAN);
+		if (!skb)
+			return RX_HANDLER_CONSUMED;
 		src =3D macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
 			/* frame comes from an external address */
diff --git a/include/net/ip.h b/include/net/ip.h
index aa76c7a..c7e066a 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -406,9 +406,18 @@ enum ip_defrag_users {
 	IP_DEFRAG_VS_OUT,
 	IP_DEFRAG_VS_FWD,
 	IP_DEFRAG_AF_PACKET,
+	IP_DEFRAG_MACVLAN,
 };
=20
 int ip_defrag(struct sk_buff *skb, u32 user);
+#ifdef CONFIG_INET
+struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user);
+#else
+static inline struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32=
 user)
+{
+	return skb;
+}
+#endif
 int ip_frag_mem(struct net *net);
 int ip_frag_nqueues(struct net *net);
=20
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 0e0ab98..763589a 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -682,6 +682,42 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 }
 EXPORT_SYMBOL(ip_defrag);
=20
+struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
+{
+	const struct iphdr *iph;
+	u32 len;
+
+	if (skb->protocol !=3D htons(ETH_P_IP))
+		return skb;
+
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		return skb;
+
+	iph =3D ip_hdr(skb);
+	if (iph->ihl < 5 || iph->version !=3D 4)
+		return skb;
+	if (!pskb_may_pull(skb, iph->ihl*4))
+		return skb;
+	iph =3D ip_hdr(skb);
+	len =3D ntohs(iph->tot_len);
+	if (skb->len < len || len < (iph->ihl * 4))
+		return skb;
+
+	if (ip_is_fragment(ip_hdr(skb))) {
+		skb =3D skb_share_check(skb, GFP_ATOMIC);
+		if (skb) {
+			if (pskb_trim_rcsum(skb, len))
+				return skb;
+			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+			if (ip_defrag(skb, user))
+				return NULL;
+			skb->rxhash =3D 0;
+		}
+	}
+	return skb;
+}
+EXPORT_SYMBOL(ip_check_defrag);
+
 #ifdef CONFIG_SYSCTL
 static int zero;
=20
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 25e68f5..ff9eed7 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1213,43 +1213,6 @@ static struct sock *fanout_demux_cpu(struct pack=
et_fanout *f, struct sk_buff *sk
 	return f->arr[cpu % num];
 }
=20
-static struct sk_buff *fanout_check_defrag(struct sk_buff *skb)
-{
-#ifdef CONFIG_INET
-	const struct iphdr *iph;
-	u32 len;
-
-	if (skb->protocol !=3D htons(ETH_P_IP))
-		return skb;
-
-	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
-		return skb;
-
-	iph =3D ip_hdr(skb);
-	if (iph->ihl < 5 || iph->version !=3D 4)
-		return skb;
-	if (!pskb_may_pull(skb, iph->ihl*4))
-		return skb;
-	iph =3D ip_hdr(skb);
-	len =3D ntohs(iph->tot_len);
-	if (skb->len < len || len < (iph->ihl * 4))
-		return skb;
-
-	if (ip_is_fragment(ip_hdr(skb))) {
-		skb =3D skb_share_check(skb, GFP_ATOMIC);
-		if (skb) {
-			if (pskb_trim_rcsum(skb, len))
-				return skb;
-			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-			if (ip_defrag(skb, IP_DEFRAG_AF_PACKET))
-				return NULL;
-			skb->rxhash =3D 0;
-		}
-	}
-#endif
-	return skb;
-}
-
 static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *d=
ev,
 			     struct packet_type *pt, struct net_device *orig_dev)
 {
@@ -1268,7 +1231,7 @@ static int packet_rcv_fanout(struct sk_buff *skb,=
 struct net_device *dev,
 	case PACKET_FANOUT_HASH:
 	default:
 		if (f->defrag) {
-			skb =3D fanout_check_defrag(skb);
+			skb =3D ip_check_defrag(skb, IP_DEFRAG_AF_PACKET);
 			if (!skb)
 				return 0;
 		}
