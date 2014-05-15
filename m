From: Kirill Tkhai <ktkhai@parallels.com>
Subject: Re: net: unix: Align send data_len up to PAGE_SIZE
Date: Thu, 15 May 2014 18:27:56 +0400
Message-ID: <1400164076.3782.32.camel@tkhai>
References: <1399906332.31472.1.camel@tkhai>
	 <20140514.151504.1740922429122469259.davem@davemloft.net>
	 <1400144080.3782.23.camel@tkhai>
	 <1400160440.7973.135.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:52819 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754060AbaEOO17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 10:27:59 -0400
In-Reply-To: <1400160440.7973.135.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D0=A7=D1=82, 15/05/2014 =D0=B2 06:27 -0700, Eric Dumazet =D0=BF=
=D0=B8=D1=88=D0=B5=D1=82:
> On Thu, 2014-05-15 at 12:54 +0400, Kirill Tkhai wrote:
>=20
> >=20
> > And I assumed it's OK to allocate skbs with zero header size like t=
his:
> >=20
> > sock_alloc_send_pskb(sk, 0, data_len)
> >=20
> > Please say, if it's wrong.
> >=20
>=20
> Its OK
>=20

Thanks for the reply. So, new version is below.

[PATCH]net: unix: Align send data_len up to PAGE_SIZE
   =20
Using whole of allocated pages reduces requested skb->data size.
This is just a little more thriftily allocation.
   =20
netperf does not show difference with the current performance.
   =20
Signed-off-by: Kirill Tkhai <ktkhai@parallels.com>
---
 net/unix/af_unix.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 749f80c..65d67c2 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1492,10 +1492,12 @@ static int unix_dgram_sendmsg(struct kiocb *kio=
cb, struct socket *sock,
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
=20
-	if (len > SKB_MAX_ALLOC)
+	if (len > SKB_MAX_ALLOC) {
 		data_len =3D min_t(size_t,
 				 len - SKB_MAX_ALLOC,
 				 MAX_SKB_FRAGS * PAGE_SIZE);
+		data_len =3D PAGE_ALIGN(data_len);
+	}
=20
 	skb =3D sock_alloc_send_pskb(sk, len - data_len, data_len,
 				   msg->msg_flags & MSG_DONTWAIT, &err,
@@ -1670,6 +1672,8 @@ static int unix_stream_sendmsg(struct kiocb *kioc=
b, struct socket *sock,
=20
 		data_len =3D max_t(int, 0, size - SKB_MAX_HEAD(0));
=20
+		data_len =3D min_t(size_t, size, PAGE_ALIGN(data_len));
+
 		skb =3D sock_alloc_send_pskb(sk, size - data_len, data_len,
 					   msg->msg_flags & MSG_DONTWAIT, &err,
 					   get_order(UNIX_SKB_FRAGS_SZ));
