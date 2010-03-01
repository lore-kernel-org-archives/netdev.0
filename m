From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sparse checking prevented by "net: fix kmemcheck annotations"
Date: Mon, 01 Mar 2010 14:09:26 +0100
Message-ID: <1267448966.3039.22.camel@edumazet-laptop>
References: <4B8BAE79.9000609@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:35552 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab0CANJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 08:09:34 -0500
In-Reply-To: <4B8BAE79.9000609@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 mars 2010 =C3=A0 13:09 +0100, Stefan Richter a =C3=A9crit :
> Hi all,
>=20
> the post 2.6.32-rc5, pre 2.6.32-rc6 commit 14d18a81 causes a serious
> regression for sparse checks:  make C=3D1 CF=3D"-D__CHECK_ENDIAN__" n=
ow
> causes sparse to log
>=20
>     include/linux/skbuff.h:357:41: error: invalid bitfield specifier =
for
>     type restricted __be16.
>=20
>=20
> I reported this already shortly after this hit the mainline.  But bac=
k
> then I didn't notice that this sparse error causes sparse to remain
> silent on all subsequent warnings in a file!
>=20
> We need to either change sparse to accept this bogus bit field that
> occurs in skbuff.h (__be16 protocol:16;), silently or with a warning,=
 or
> revert this kmemcheck annotation.
>=20
> ("We" =3D=3D preferably Eric :-)
>=20
> skbuff.h is included by lots of drivers, even ones that are not even
> networking drivers, notably DVB drivers.  None of these drivers can b=
e
> checked with sparse's __CHECK_ENDIAN__ at the moment.

Hi Stefan

I believe kmemcheck side effects were solved by commit e992cd9b72a18122
(kmemcheck: make bitfield annotations truly no-ops when disabled),
so there is no problem to partially revert the patch and fix this
problem.

Thanks !

[PATCH] net: fix protocol sk_buff field

Commit e992cd9b72a18 (kmemcheck: make bitfield annotations truly no-ops
when disabled) allows us to revert a workaround we did in the past to
not add holes in sk_buff structure.

This patch partially reverts commit 14d18a81b5171
(net: fix kmemcheck annotations) so that sparse doesnt complain:

include/linux/skbuff.h:357:41: error: invalid bitfield specifier for
type restricted __be16.

Reported-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ae836fd..b40f56b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -354,8 +354,8 @@ struct sk_buff {
 				ipvs_property:1,
 				peeked:1,
 				nf_trace:1;
-	__be16			protocol:16;
 	kmemcheck_bitfield_end(flags1);
+	__be16			protocol;
=20
 	void			(*destructor)(struct sk_buff *skb);
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)


