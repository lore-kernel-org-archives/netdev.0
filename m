From: Daniel Borkmann <danborkmann@googlemail.com>
Subject: Re: [PATCH] netpoll: allow execution of multiple rx_hooks per interface
Date: Wed, 13 Jan 2010 01:27:30 +0100
Message-ID: <4B4D1372.9060702@gmail.com>
References: <4B4630C0.6090206@gmail.com> <4B467A4D.9070708@gmail.com>	 <1263252108.29868.4774.camel@calx>	 <20100111.155912.68138954.davem@davemloft.net> <1263254625.29868.4777.camel@calx> <4B4BBDA5.8010808@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA0C8D4E1BD57FB96C653A6ED"
Cc: David Miller <davem@davemloft.net>, danborkmann@googlemail.com,
	linux-kernel@vger.kernel.org, jmoyer@redhat.com,
	netdev@vger.kernel.org, netdev@oss.sgi.com
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753772Ab0AMA15@vger.kernel.org>
In-Reply-To: <4B4BBDA5.8010808@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA0C8D4E1BD57FB96C653A6ED
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Daniel Borkmann wrote:
> Matt Mackall wrote:
>> On Mon, 2010-01-11 at 15:59 -0800, David Miller wrote:
>>> From: Matt Mackall <mpm@selenic.com>
>>> Date: Mon, 11 Jan 2010 17:21:48 -0600
>>>
>>>> Looks pretty good. Dave?
>>>>
>>>> Acked-by: Matt Mackall <mpm@selenic.com>
>>> I don't like the loop for RX ARP processing.
>>>
>>> The packet contents aren't going to change, so doing basic
>>> packet validation inside of the "for each RX client" loop
>>> of arp_reply() doesn't make any sense.
>> True. Dan, please help our poor compilers with some manual loop
>> invariant motion.
>=20
> Okay, true. I'll fix this by tomorrow and resend the patch.

Here the fix of the RX ARP processing routine. Content that isn't
going to change is out-of-loop.
Successfully tested on my machines.

Signed-off-by: Daniel Borkmann <danborkmann@googlemail.com>

diff -Nur a/include/linux/netpoll.h b/include/linux/netpoll.h
--- a/include/linux/netpoll.h	2010-01-05 23:52:58.000000000 +0100
+++ b/include/linux/netpoll.h	2010-01-07 23:19:25.000000000 +0100
@@ -21,15 +21,20 @@
 	__be32 local_ip, remote_ip;
 	u16 local_port, remote_port;
 	u8 remote_mac[ETH_ALEN];
+
+	struct list_head rx; /* rx_np list element */
 };

 struct netpoll_info {
 	atomic_t refcnt;
+
 	int rx_flags;
 	spinlock_t rx_lock;
-	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
+	struct list_head rx_np; /* netpolls that registered an rx_hook */
+
 	struct sk_buff_head arp_tx; /* list of arp requests to reply to */
 	struct sk_buff_head txq;
+
 	struct delayed_work tx_work;
 };

@@ -51,7 +56,7 @@
 	unsigned long flags;
 	int ret =3D 0;

-	if (!npinfo || (!npinfo->rx_np && !npinfo->rx_flags))
+	if (!npinfo || (list_empty(&npinfo->rx_np) && !npinfo->rx_flags))
 		return 0;

 	spin_lock_irqsave(&npinfo->rx_lock, flags);
@@ -67,7 +72,7 @@
 {
 	struct netpoll_info *npinfo =3D skb->dev->npinfo;

-	return npinfo && (npinfo->rx_np || npinfo->rx_flags);
+	return npinfo && (!list_empty(&npinfo->rx_np) || npinfo->rx_flags);
 }

 static inline int netpoll_receive_skb(struct sk_buff *skb)
diff -Nur a/net/core/netpoll.c b/net/core/netpoll.c
--- a/net/core/netpoll.c	2010-01-05 23:53:07.000000000 +0100
+++ b/net/core/netpoll.c	2010-01-12 23:36:48.000000000 +0100
@@ -407,11 +407,24 @@
 	__be32 sip, tip;
 	unsigned char *sha;
 	struct sk_buff *send_skb;
-	struct netpoll *np =3D NULL;
+	struct netpoll *np, *tmp;
+	unsigned long flags;
+	int hits =3D 0;
+
+	if (list_empty(&npinfo->rx_np))
+		return;
+
+	/* Before checking the packet, we do some early
+	   inspection whether this is interesting at all */
+	spin_lock_irqsave(&npinfo->rx_lock, flags);
+	list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
+		if (np->dev =3D=3D skb->dev)
+			hits++;
+	}
+	spin_unlock_irqrestore(&npinfo->rx_lock, flags);

-	if (npinfo->rx_np && npinfo->rx_np->dev =3D=3D skb->dev)
-		np =3D npinfo->rx_np;
-	if (!np)
+	/* No netpoll struct is using this dev */
+	if (!hits)
 		return;

 	/* No arp on this interface */
@@ -437,77 +450,91 @@
 	arp_ptr +=3D skb->dev->addr_len;
 	memcpy(&sip, arp_ptr, 4);
 	arp_ptr +=3D 4;
-	/* if we actually cared about dst hw addr, it would get copied here */
+	/* If we actually cared about dst hw addr,
+	   it would get copied here */
 	arp_ptr +=3D skb->dev->addr_len;
 	memcpy(&tip, arp_ptr, 4);

 	/* Should we ignore arp? */
-	if (tip !=3D np->local_ip ||
-	    ipv4_is_loopback(tip) || ipv4_is_multicast(tip))
+	if (ipv4_is_loopback(tip) || ipv4_is_multicast(tip))
 		return;

 	size =3D arp_hdr_len(skb->dev);
-	send_skb =3D find_skb(np, size + LL_ALLOCATED_SPACE(np->dev),
-			    LL_RESERVED_SPACE(np->dev));
-
-	if (!send_skb)
-		return;
-
-	skb_reset_network_header(send_skb);
-	arp =3D (struct arphdr *) skb_put(send_skb, size);
-	send_skb->dev =3D skb->dev;
-	send_skb->protocol =3D htons(ETH_P_ARP);
-
-	/* Fill the device header for the ARP frame */
-	if (dev_hard_header(send_skb, skb->dev, ptype,
-			    sha, np->dev->dev_addr,
-			    send_skb->len) < 0) {
-		kfree_skb(send_skb);
-		return;
-	}

-	/*
-	 * Fill out the arp protocol part.
-	 *
-	 * we only support ethernet device type,
-	 * which (according to RFC 1390) should always equal 1 (Ethernet).
-	 */
+	spin_lock_irqsave(&npinfo->rx_lock, flags);
+	list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
+		if (tip !=3D np->local_ip)
+			continue;
+
+		send_skb =3D find_skb(np, size + LL_ALLOCATED_SPACE(np->dev),
+				    LL_RESERVED_SPACE(np->dev));
+		if (!send_skb)
+			continue;
+
+		skb_reset_network_header(send_skb);
+		arp =3D (struct arphdr *) skb_put(send_skb, size);
+		send_skb->dev =3D skb->dev;
+		send_skb->protocol =3D htons(ETH_P_ARP);
+
+		/* Fill the device header for the ARP frame */
+		if (dev_hard_header(send_skb, skb->dev, ptype,
+				    sha, np->dev->dev_addr,
+				    send_skb->len) < 0) {
+			kfree_skb(send_skb);
+			continue;
+		}

-	arp->ar_hrd =3D htons(np->dev->type);
-	arp->ar_pro =3D htons(ETH_P_IP);
-	arp->ar_hln =3D np->dev->addr_len;
-	arp->ar_pln =3D 4;
-	arp->ar_op =3D htons(type);
-
-	arp_ptr=3D(unsigned char *)(arp + 1);
-	memcpy(arp_ptr, np->dev->dev_addr, np->dev->addr_len);
-	arp_ptr +=3D np->dev->addr_len;
-	memcpy(arp_ptr, &tip, 4);
-	arp_ptr +=3D 4;
-	memcpy(arp_ptr, sha, np->dev->addr_len);
-	arp_ptr +=3D np->dev->addr_len;
-	memcpy(arp_ptr, &sip, 4);
+		/*
+		 * Fill out the arp protocol part.
+		 *
+		 * we only support ethernet device type,
+		 * which (according to RFC 1390) should
+		 * always equal 1 (Ethernet).
+		 */

-	netpoll_send_skb(np, send_skb);
+		arp->ar_hrd =3D htons(np->dev->type);
+		arp->ar_pro =3D htons(ETH_P_IP);
+		arp->ar_hln =3D np->dev->addr_len;
+		arp->ar_pln =3D 4;
+		arp->ar_op =3D htons(type);
+
+		arp_ptr =3D (unsigned char *)(arp + 1);
+		memcpy(arp_ptr, np->dev->dev_addr, np->dev->addr_len);
+		arp_ptr +=3D np->dev->addr_len;
+		memcpy(arp_ptr, &tip, 4);
+		arp_ptr +=3D 4;
+		memcpy(arp_ptr, sha, np->dev->addr_len);
+		arp_ptr +=3D np->dev->addr_len;
+		memcpy(arp_ptr, &sip, 4);
+
+		netpoll_send_skb(np, send_skb);
+
+		/* If there are several rx_hooks for the same address,
+		   we're fine by sending a single reply */
+		break;
+	}
+	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 }

 int __netpoll_rx(struct sk_buff *skb)
 {
 	int proto, len, ulen;
+	int hits =3D 0;
 	struct iphdr *iph;
 	struct udphdr *uh;
-	struct netpoll_info *npi =3D skb->dev->npinfo;
-	struct netpoll *np =3D npi->rx_np;
+	struct netpoll_info *npinfo =3D skb->dev->npinfo;
+	struct netpoll *np, *tmp;

-	if (!np)
+	if (list_empty(&npinfo->rx_np))
 		goto out;
+
 	if (skb->dev->type !=3D ARPHRD_ETHER)
 		goto out;

 	/* check if netpoll clients need ARP */
 	if (skb->protocol =3D=3D htons(ETH_P_ARP) &&
 	    atomic_read(&trapped)) {
-		skb_queue_tail(&npi->arp_tx, skb);
+		skb_queue_tail(&npinfo->arp_tx, skb);
 		return 1;
 	}

@@ -551,16 +578,23 @@
 		goto out;
 	if (checksum_udp(skb, uh, ulen, iph->saddr, iph->daddr))
 		goto out;
-	if (np->local_ip && np->local_ip !=3D iph->daddr)
-		goto out;
-	if (np->remote_ip && np->remote_ip !=3D iph->saddr)
-		goto out;
-	if (np->local_port && np->local_port !=3D ntohs(uh->dest))
-		goto out;

-	np->rx_hook(np, ntohs(uh->source),
-		    (char *)(uh+1),
-		    ulen - sizeof(struct udphdr));
+	list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
+		if (np->local_ip && np->local_ip !=3D iph->daddr)
+			continue;
+		if (np->remote_ip && np->remote_ip !=3D iph->saddr)
+			continue;
+		if (np->local_port && np->local_port !=3D ntohs(uh->dest))
+			continue;
+
+		np->rx_hook(np, ntohs(uh->source),
+			       (char *)(uh+1),
+			       ulen - sizeof(struct udphdr));
+		hits++;
+	}
+
+	if (!hits)
+		goto out;

 	kfree_skb(skb);
 	return 1;
@@ -684,6 +718,7 @@
 	struct net_device *ndev =3D NULL;
 	struct in_device *in_dev;
 	struct netpoll_info *npinfo;
+	struct netpoll *npe, *tmp;
 	unsigned long flags;
 	int err;

@@ -704,7 +739,7 @@
 		}

 		npinfo->rx_flags =3D 0;
-		npinfo->rx_np =3D NULL;
+		INIT_LIST_HEAD(&npinfo->rx_np);

 		spin_lock_init(&npinfo->rx_lock);
 		skb_queue_head_init(&npinfo->arp_tx);
@@ -785,7 +820,7 @@
 	if (np->rx_hook) {
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		npinfo->rx_flags |=3D NETPOLL_RX_ENABLED;
-		npinfo->rx_np =3D np;
+		list_add_tail(&np->rx, &npinfo->rx_np);
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}

@@ -801,9 +836,16 @@
 	return 0;

  release:
-	if (!ndev->npinfo)
+	if (!ndev->npinfo) {
+		spin_lock_irqsave(&npinfo->rx_lock, flags);
+		list_for_each_entry_safe(npe, tmp, &npinfo->rx_np, rx) {
+			npe->dev =3D NULL;
+		}
+		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+
 		kfree(npinfo);
-	np->dev =3D NULL;
+	}
+
 	dev_put(ndev);
 	return err;
 }
@@ -823,10 +865,11 @@
 	if (np->dev) {
 		npinfo =3D np->dev->npinfo;
 		if (npinfo) {
-			if (npinfo->rx_np =3D=3D np) {
+			if (!list_empty(&npinfo->rx_np)) {
 				spin_lock_irqsave(&npinfo->rx_lock, flags);
-				npinfo->rx_np =3D NULL;
-				npinfo->rx_flags &=3D ~NETPOLL_RX_ENABLED;
+				list_del(&np->rx);
+				if (list_empty(&npinfo->rx_np))
+					npinfo->rx_flags &=3D ~NETPOLL_RX_ENABLED;
 				spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 			}



--------------enigA0C8D4E1BD57FB96C653A6ED
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAktNE3IACgkQ5AxJm1m3CC8JUACfZYu+KMNmoi1wggcgZzugfjqF
jHcAn19IOYG/HadXh23FMHCUrDSg2PaV
=I1xP
-----END PGP SIGNATURE-----

--------------enigA0C8D4E1BD57FB96C653A6ED--
