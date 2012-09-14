From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] gre: add GSO support
Date: Fri, 14 Sep 2012 19:45:25 +0200
Message-ID: <1347644725.26523.13.camel@edumazet-glaptop>
References: <1347607533.8555.269.camel@edumazet-glaptop>
	 <CANP3RGckqqPnmfLjfqxOKuxJEkvzN9-5v+BqVZ_9GuYyo+EDHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35381 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759567Ab2INRpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 13:45:32 -0400
Received: by bkwj10 with SMTP id j10so1368066bkw.19
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 10:45:31 -0700 (PDT)
In-Reply-To: <CANP3RGckqqPnmfLjfqxOKuxJEkvzN9-5v+BqVZ_9GuYyo+EDHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-14 at 10:12 -0700, Maciej =C5=BBenczykowski wrote:
> Thanks!
>=20
> So I'm guessing it should be easy to add support like this to IPIP an=
d
> SIT now as well
> (not sure if they're missing, but I'd assume so)?

Yes, absolutely.

I was also playing adding GRO support to tunnels.

Here the prototype patch I currently have, it gives very nice speedups

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index b062a98..ca6ab66 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -589,6 +589,65 @@ ipgre_ecn_encapsulate(u8 tos, const struct iphdr *=
old_iph, struct sk_buff *skb)
 	return INET_ECN_encapsulate(tos, inner);
 }
=20
+static void tunnel_prequeue(struct ip_tunnel *tunnel, struct sk_buff *=
skb)
+{
+	unsigned long flags;
+	const struct iphdr *iph;
+
+	if (skb_cloned(skb)) {
+		netif_rx(skb);
+		return;
+	}
+	if (!pskb_may_pull(skb, sizeof(*iph)) ||
+	    skb_queue_len(&tunnel->napi_skbs) > 1000) {
+drop:
+		atomic_long_inc(&tunnel->dev->rx_dropped);
+		kfree_skb(skb);
+		return;
+	}
+	iph =3D ip_hdr(skb);
+	if (*(u8 *)iph =3D=3D 0x45 &&
+	    iph->protocol =3D=3D IPPROTO_TCP &&
+	    skb->ip_summed =3D=3D CHECKSUM_NONE) {
+		__skb_pull(skb, sizeof(*iph));
+
+		skb->csum =3D csum_tcpudp_nofold(iph->saddr, iph->daddr,
+					       skb->len, IPPROTO_TCP, 0);
+		if (__skb_checksum_complete(skb))
+			goto drop;
+
+		__skb_push(skb, sizeof(*iph));
+	}
+
+	spin_lock_irqsave(&tunnel->napi_skbs.lock, flags);
+
+	__skb_queue_tail(&tunnel->napi_skbs, skb);
+	if (skb_queue_len(&tunnel->napi_skbs) =3D=3D 1)
+		napi_schedule(&tunnel->napi);
+
+	spin_unlock_irqrestore(&tunnel->napi_skbs.lock, flags);
+}
+
+static int tunnel_napi_poll(struct napi_struct *napi, int budget)
+{
+	struct ip_tunnel *tunnel =3D container_of(napi, struct ip_tunnel, nap=
i);
+	struct sk_buff *skb;
+	int work_done =3D 0;
+
+	while (work_done < budget) {
+		skb =3D skb_dequeue(&tunnel->napi_skbs);
+		if (!skb)
+			break;
+		skb->next =3D NULL;
+		napi_gro_receive(napi, skb);
+		work_done++;
+	}
+
+	if (work_done < budget)
+		napi_complete(napi);
+	return work_done;
+}
+
 static int ipgre_rcv(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
@@ -714,8 +773,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 		skb_reset_network_header(skb);
 		ipgre_ecn_decapsulate(iph, skb);
=20
-		netif_rx(skb);
-
+		tunnel_prequeue(tunnel, skb);
 		rcu_read_unlock();
 		return 0;
 	}
@@ -745,6 +803,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buf=
f *skb, struct net_device *dev
 	__be32 dst;
 	int    mtu;
=20
+	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL &&
+	    skb_checksum_help(skb))
+		goto tx_error;
+
 	if (dev->type =3D=3D ARPHRD_ETHER)
 		IPCB(skb)->flags =3D 0;
=20
@@ -1292,10 +1354,19 @@ static const struct net_device_ops ipgre_netdev=
_ops =3D {
=20
 static void ipgre_dev_free(struct net_device *dev)
 {
+	struct ip_tunnel *tunnel =3D netdev_priv(dev);
+
+	netif_napi_del(&tunnel->napi);
+	skb_queue_purge(&tunnel->napi_skbs);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
=20
+#define GRE_FEATURES (NETIF_F_SG |		\
+		      NETIF_F_FRAGLIST |	\
+		      NETIF_F_HIGHDMA |		\
+		      NETIF_F_HW_CSUM)
+
 static void ipgre_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		=3D &ipgre_netdev_ops;
@@ -1309,6 +1380,9 @@ static void ipgre_tunnel_setup(struct net_device =
*dev)
 	dev->addr_len		=3D 4;
 	dev->features		|=3D NETIF_F_NETNS_LOCAL;
 	dev->priv_flags		&=3D ~IFF_XMIT_DST_RELEASE;
+
+	dev->features		|=3D GRE_FEATURES;
+	dev->hw_features	|=3D GRE_FEATURES;
 }
=20
 static int ipgre_tunnel_init(struct net_device *dev)
@@ -1340,7 +1414,9 @@ static int ipgre_tunnel_init(struct net_device *d=
ev)
 	dev->tstats =3D alloc_percpu(struct pcpu_tstats);
 	if (!dev->tstats)
 		return -ENOMEM;
-
+	skb_queue_head_init(&tunnel->napi_skbs);
+	netif_napi_add(dev, &tunnel->napi, tunnel_napi_poll, 64);
+	napi_enable(&tunnel->napi);
 	return 0;
 }
=20
