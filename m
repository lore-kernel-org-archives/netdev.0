From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: dst_release() cleanup
Date: Mon, 07 Dec 2009 19:12:03 +0100
Message-ID: <4B1D4573.9040605@gmail.com>
References: <4B1A4BC5.3050300@gmail.com> <20091207091746.51d8958a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48430 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964956AbZLGSMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 13:12:20 -0500
In-Reply-To: <20091207091746.51d8958a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
=20
> I don't like to put actual necessary code in WARN or BUG macro
> args because some embedded type developer is likely to build
> with
>=20
> #define WARN_ON(x)
>=20
> to get rid of all warnings.

Oops, I thought WARN_ON(X) must evaluate X once, my bad, since its not =
documented.

Thanks

[PATCH] net: dst_release() cleanup

atomic_dec_return() is a full memory barrier, we can omit
the smp_mb__before_atomic_dec() call.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dst.c b/net/core/dst.c
index 57bc4d5..c3d0cfa 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -263,11 +263,9 @@ again:
 void dst_release(struct dst_entry *dst)
 {
 	if (dst) {
-               int newrefcnt;
+		int newrefcnt =3D atomic_dec_return(&dst->__refcnt);
=20
-		smp_mb__before_atomic_dec();
-               newrefcnt =3D atomic_dec_return(&dst->__refcnt);
-               WARN_ON(newrefcnt < 0);
+		WARN_ON(newrefcnt < 0);
 	}
 }
 EXPORT_SYMBOL(dst_release);
