From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] qlnic: dont set skb->truesize
Date: Mon, 20 Sep 2010 14:28:59 +0200
Message-ID: <1284985739.3420.284.camel@edumazet-laptop>
References: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
	 <1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
	 <1284717448.3391.75.camel@edumazet-laptop>
	 <99737F4847ED0A48AECC9F4A1974A4B80F86F8018D@MNEXMB2.qlogic.org>
	 <1284985118.3420.270.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	David Miller <davem@davemloft.net>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33031 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350Ab0ITM3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 08:29:05 -0400
Received: by wyf22 with SMTP id 22so4225648wyf.19
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 05:29:03 -0700 (PDT)
In-Reply-To: <1284985118.3420.270.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 septembre 2010 =C3=A0 14:18 +0200, Eric Dumazet a =C3=A9cri=
t :
> Le lundi 20 septembre 2010 =C3=A0 06:16 -0500, Amit Salecha a =C3=A9c=
rit :
>=20
> > This can be cleaned up.=20
> > Though I have one doubt. We are allocating larger packets than the =
actual data used.
> > Doesn't it will break accounting ?
>=20
> truesize accounts for the real size of buffers, not the used part in
> them.
>=20
> IMHO, a driver not dealing with fragments should not touch skb->trues=
ize
>=20
> # grep truesize drivers/net/tg3.c
> <nothing>
>=20
> If a driver deals with fragments, it probably should use "+=3D" opera=
tor
> only, not hardcoding sizeof(struct sk_buff) thing that only core netw=
ork
> has to deal with.
>=20
> $ find drivers/net/bnx2x|xargs grep truesize
> drivers/net/bnx2x/bnx2x_cmn.c:		skb->truesize +=3D frag_len;
>=20
> Almost all drivers are fine, they are some of them that should be
> changed.
>=20
>=20

I suspect following patch should be fine :

[PATCH net-next-2.6] qlnic: dont set skb->truesize

skb->truesize is set in core network.

Dont change it unless dealing with fragments.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/qlcnic/qlcnic_init.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcn=
ic_init.c
index e26fa95..16dd9eb 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1418,8 +1418,6 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter=
,
 	if (pkt_offset)
 		skb_pull(skb, pkt_offset);
=20
-	skb->truesize =3D skb->len + sizeof(struct sk_buff);
-
 	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
 		adapter->stats.rxdropped++;
 		dev_kfree_skb(skb);
@@ -1491,8 +1489,6 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter=
,
=20
 	skb_put(skb, lro_length + data_offset);
=20
-	skb->truesize =3D skb->len + sizeof(struct sk_buff) + skb_headroom(sk=
b);
-
 	skb_pull(skb, l2_hdr_offset);
=20
 	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
@@ -1732,8 +1728,6 @@ qlcnic_process_rcv_diag(struct qlcnic_adapter *ad=
apter,
 	if (pkt_offset)
 		skb_pull(skb, pkt_offset);
=20
-	skb->truesize =3D skb->len + sizeof(struct sk_buff);
-
 	if (!qlcnic_check_loopback_buff(skb->data))
 		adapter->diag_cnt++;
=20


