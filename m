From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Tue, 24 Aug 2010 17:08:52 +0200
Message-ID: <1282662532.2477.248.camel@edumazet-laptop>
References: <20100820193835.GA6025@del.dom.local>
	 <20100821074742.GA2367@del.dom.local>
	 <1282377058.2636.12.camel@edumazet-laptop>
	 <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg>
	 <20100823124736.GA16966@ff.dom.local>
	 <1282568443.2486.34.camel@edumazet-laptop>
	 <20100823131056.GA19160@ff.dom.local> <4C727B06.2060002@fs.uni-ruse.bg>
	 <4C72802D.8090405@fs.uni-ruse.bg> <20100823141437.GA2282@del.dom.local>
	 <4C734FB5.1090702@fs.uni-ruse.bg>
	 <1282626102.2378.1351.camel@edumazet-laptop>
	 <4C738636.4000107@fs.uni-ruse.bg>  <4C73C8DF.4060601@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64392 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017Ab0HXPI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 11:08:58 -0400
Received: by wwe15 with SMTP id 15so2015935wwe.1
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 08:08:57 -0700 (PDT)
In-Reply-To: <4C73C8DF.4060601@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 ao=C3=BBt 2010 =C3=A0 16:27 +0300, Plamen Petrov a =C3=A9cr=
it :

> The current status: if I enable GRO on the tg3 - the kernel oopses.
> It just takes a different amount of time to trigger: somewhere from
> 30 seconds to 30 minutes.
>=20
> The oopses looks the same, and here are the latest:
>=20
> [picture 13]
> http://picpaste.com/c8dbda8f5c15d9ce3e050dd7f245f5d0.jpg
>=20
> [picture 14]
> http://picpaste.com/646cca586b704c5b72d3cf9fa54c7344.jpg
>=20
> I was wondering which debug options could help us track this down?
>=20

Thanks, here is an updated patch (against linux-2.6)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3721fbb..77c8eb7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1935,6 +1935,32 @@ static inline int skb_needs_linearize(struct sk_=
buff *skb,
 					      illegal_highdma(dev, skb))));
 }
=20
+int skb_csum_start_bug(const struct sk_buff *skb, int pos)
+{
+
+	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
+		long csstart;
+
+		csstart =3D skb->csum_start - skb_headroom(skb);
+		if (WARN_ON(csstart > skb_headlen(skb))) {
+			int i;
+
+			pr_err("%d: csum_start %u, offset %u, headroom %d, headlen %d, len =
%d\n",
+				   pos, skb->csum_start, skb->csum_offset, skb_headroom(skb),
+				   skb_headlen(skb), skb->len);
+			pr_err("nr_frags=3D%u gso_size=3D%u ",
+					skb_shinfo(skb)->nr_frags,
+					skb_shinfo(skb)->gso_size);
+			for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
+				pr_err("frag_size=3D%u ", skb_shinfo(skb)->frags[i].size);
+			}
+			pr_err("\n");
+			return 1;
+		}
+	}
+	return 0;
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
@@ -1959,11 +1985,15 @@ int dev_hard_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev,
 				goto out_kfree_skb;
 			if (skb->next)
 				goto gso;
+			if (skb_csum_start_bug(skb, 10))
+				goto out_kfree_skb;
 		} else {
 			if (skb_needs_linearize(skb, dev) &&
 			    __skb_linearize(skb))
 				goto out_kfree_skb;
=20
+			if (skb_csum_start_bug(skb, 20))
+				goto out_kfree_skb;
 			/* If packet is not checksummed and device does not
 			 * support checksumming for this protocol, complete
 			 * checksumming here.
@@ -1974,10 +2004,16 @@ int dev_hard_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev,
 				if (!dev_can_checksum(dev, skb) &&
 				     skb_checksum_help(skb))
 					goto out_kfree_skb;
+				if (skb_csum_start_bug(skb, 30))
+					goto out_kfree_skb;
 			}
 		}
=20
-		rc =3D ops->ndo_start_xmit(skb, dev);
+		if (skb_csum_start_bug(skb, 40)) {
+			kfree_skb(skb);
+			rc =3D NETDEV_TX_OK;
+		} else
+			rc =3D ops->ndo_start_xmit(skb, dev);
 		if (rc =3D=3D NETDEV_TX_OK)
 			txq_trans_update(txq);
 		return rc;
@@ -1997,7 +2033,12 @@ gso:
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(nskb);
=20
-		rc =3D ops->ndo_start_xmit(nskb, dev);
+		if (skb_csum_start_bug(skb, 50)) {
+			kfree_skb(skb);
+			rc =3D NETDEV_TX_OK;
+		} else
+			rc =3D ops->ndo_start_xmit(nskb, dev);
+
 		if (unlikely(rc !=3D NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
 				goto out_kfree_gso_skb;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3a2513f..3d54a1b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1824,13 +1824,15 @@ void skb_copy_and_csum_dev(const struct sk_buff=
 *skb, u8 *to)
 {
 	__wsum csum;
 	long csstart;
+	extern int skb_csum_start_bug(const struct sk_buff *skb, int pos);
=20
 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
 		csstart =3D skb->csum_start - skb_headroom(skb);
 	else
 		csstart =3D skb_headlen(skb);
=20
-	BUG_ON(csstart > skb_headlen(skb));
+	if (skb_csum_start_bug(skb, 100))
+		return;
=20
 	skb_copy_from_linear_data(skb, to, csstart);
=20


