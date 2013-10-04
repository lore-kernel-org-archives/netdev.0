From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: do not forget FIN in tcp_shifted_skb()
Date: Fri, 04 Oct 2013 11:25:46 -0700
Message-ID: <1380911146.3564.27.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380907901.3564.24.camel@edumazet-glaptop.roam.corp.google.com>
	 <alpine.DEB.2.02.1310042101040.32153@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34194 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899Ab3JDSZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 14:25:51 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so4400905pdi.27
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 11:25:50 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1310042101040.32153@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-04 at 21:03 +0300, Ilpo J=C3=A4rvinen wrote:

> Nice that it was finally found. For some reason my memory tries to sa=
y=20
> that it wouldn't have not even tried to merge skbs with FIN but eithe=
r
> I changed that at some point while deving or I just remember wrong.
>=20
> Acked-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
>=20

Thanks for reviewing.

It looks like I chose the opposite strategy in tcp_try_coalesce() :

Not allowing a merge if the FIN was set of the skb.

But really it seems we could have the merge.

I'll test the following before official submission.

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fa6cf1f..90cf0b3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4119,9 +4119,6 @@ static bool tcp_try_coalesce(struct sock *sk,
=20
 	*fragstolen =3D false;
=20
-	if (tcp_hdr(from)->fin)
-		return false;
-
 	/* Its possible this segment overlaps with prior segment in queue */
 	if (TCP_SKB_CB(from)->seq !=3D TCP_SKB_CB(to)->end_seq)
 		return false;
@@ -4134,6 +4131,10 @@ static bool tcp_try_coalesce(struct sock *sk,
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
 	TCP_SKB_CB(to)->end_seq =3D TCP_SKB_CB(from)->end_seq;
 	TCP_SKB_CB(to)->ack_seq =3D TCP_SKB_CB(from)->ack_seq;
+
+	if (tcp_hdr(from)->fin)
+		tcp_hdr(to)->fin =3D 1;
+
 	return true;
 }
=20
