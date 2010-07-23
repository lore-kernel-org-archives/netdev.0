From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Fri, 23 Jul 2010 07:09:08 +0200
Message-ID: <1279861748.2482.13.camel@edumazet-laptop>
References: <20100722191234.GA832@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrea Shepard <andrea@persephoneslair.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61696 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357Ab0GWFJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 01:09:14 -0400
Received: by wyf19 with SMTP id 19so1220028wyf.19
        for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 22:09:12 -0700 (PDT)
In-Reply-To: <20100722191234.GA832@cronus.persephoneslair.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 juillet 2010 =C3=A0 12:12 -0700, Andrea Shepard a =C3=A9cri=
t :
> Make pskb_expand_head() check ip_summed to make sure csum_start is re=
ally
> csum_start and not csum before adjusting it.
>=20
> This fixes a bug I encountered using a Sun Quad-Fast Ethernet card an=
d VLANs.
> On my configuration, the sunhme driver produces skbs with differing a=
mounts
> of headroom on receive depending on the packet size.  See line 2030 o=
f
> drivers/net/sunhme.c; packets smaller than RX_COPY_THRESHOLD have 52 =
bytes
> of headroom but packets larger than that cutoff have only 20 bytes.
>=20
> When these packets reach the VLAN driver, vlan_check_reorder_header()
> calls skb_cow(), which, if the packet has less than NET_SKB_PAD (=3D=3D=
 32) bytes
> of headroom, uses pskb_expand_head() to make more.
>=20
> Then, pskb_expand_head() needs to adjust a lot of offsets into the sk=
b,
> including csum_start.  Since csum_start is a union with csum, if the =
packet
> has a valid csum value this will corrupt it, which was the effect I o=
bserved.
> The sunhme hardware computes receive checksums, so the skbs would be =
created
> by the driver with ip_summed =3D=3D CHECKSUM_COMPLETE and a valid csu=
m field, and
> then pskb_expand_head() would corrupt the csum field, leading to an "=
hw csum
> error" message later on, for example in icmp_rcv() for pings larger t=
han the
> sunhme RX_COPY_THRESHOLD.
>=20
> On the basis of the comment at the beginning of include/linux/skbuff.=
h,
> I believe that the csum_start skb field is only meaningful if ip_csum=
med is
> CSUM_PARTIAL, so this patch makes pskb_expand_head() adjust it only i=
n that
> case to avoid corrupting a valid csum value.
>=20
> Please see my more in-depth disucssion of tracking down this bug for
> more details if you like:
>=20
> http://puellavulnerata.livejournal.com/112186.html
> http://puellavulnerata.livejournal.com/112567.html
> http://puellavulnerata.livejournal.com/112891.html
> http://puellavulnerata.livejournal.com/113096.html
> http://puellavulnerata.livejournal.com/113591.html
>=20
> I am not subscribed to this list, so please CC me on replies.
>=20

Excellent Changelog Andrea, thanks !

Reviewing pskb_expand_head(), I see it copy the whole struct
skb_shared_info, even if source contains garbage (uninitialized data).

I wonder why it is not triggering kmemcheck alarms

[PATCH net-next-2.6] net: pskb_expand_head() optimization

Move frags[] at the end of struct skb_shared_info, and make
pskb_expand_head() copy only the used part of it instead of whole array=
=2E

This should avoid kmemcheck warnings and speedup pskb_expand_head() as
well, avoiding a lot of cache misses.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |    3 ++-
 net/core/skbuff.c      |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f5aa87e..d89876b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -202,10 +202,11 @@ struct skb_shared_info {
 	 */
 	atomic_t	dataref;
=20
-	skb_frag_t	frags[MAX_SKB_FRAGS];
 	/* Intermediate layers must ensure that destructor_arg
 	 * remains valid until skb destructor */
 	void *		destructor_arg;
+	/* must be last field, see pskb_expand_head() */
+	skb_frag_t	frags[MAX_SKB_FRAGS];
 };
=20
 /* We divide dataref into two halves.  The higher 16 bits hold referen=
ces
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 76d33ca..7da58a2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -817,7 +817,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead=
, int ntail,
 	memcpy(data + nhead, skb->head, skb->tail - skb->head);
 #endif
 	memcpy(data + size, skb_end_pointer(skb),
-	       sizeof(struct skb_shared_info));
+	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_fra=
gs]));
=20
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
 		get_page(skb_shinfo(skb)->frags[i].page);


