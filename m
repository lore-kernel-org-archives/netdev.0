From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix struct sock bitfield annotation
Date: Fri, 09 Oct 2009 10:50:25 +0200
Message-ID: <4ACEF951.7030104@gmail.com>
References: <4ACE023D.9030208@gmail.com>	<19f34abd0910081454v51455ee0p30ad6715b5ee31c0@mail.gmail.com>	<4ACE8CEC.3020905@gmail.com> <20091009.005408.151610125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vegard.nossum@gmail.com, netdev@vger.kernel.org, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52273 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbZJIIvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 04:51:12 -0400
In-Reply-To: <20091009.005408.151610125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :

>=20
> I think from a practical standpoint, you are right.
>=20
> But Vegard is right too, as we should be able to put the annotation
> right next to the ":" statements.
>=20
> So if you really want why don't you put the sk_protocol and
> sk_type into the ":" block as you mentioned.
>=20
> And then you can use Arnaldo's 'pahole' instead of the kludgy
> offsetof() which doesn't work with bitfields :-)
>=20
> I want the 8 bytes back just like you, but seperating the annotation
> from the real C bitfields looks definitely wrong to me.


Let's hope nobody wants to use &sk->sk_protocol, &sk->sk_type,
(or offsetof(..., sk_somefield) if that matters)

Only compile tested on 'allyesconfig' build on x86_64

[PATCH] net: Fix struct sock bitfield annotation

Since commit a98b65a3 (net: annotate struct sock bitfield), we lost
8 bytes in struct sock on 64bit arches because of=20
kmemcheck_bitfield_end(flags) misplacement.

=46ix this by putting together sk_shutdown, sk_no_check, sk_userlocks,
sk_protocol and sk_type in the 'flags' 32bits bitfield

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1621935..9f96394 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -226,12 +226,12 @@ struct sock {
 #define sk_prot			__sk_common.skc_prot
 #define sk_net			__sk_common.skc_net
 	kmemcheck_bitfield_begin(flags);
-	unsigned char		sk_shutdown : 2,
-				sk_no_check : 2,
-				sk_userlocks : 4;
+	unsigned int		sk_shutdown  : 2,
+				sk_no_check  : 2,
+				sk_userlocks : 4,
+				sk_protocol  : 8,
+				sk_type      : 16;
 	kmemcheck_bitfield_end(flags);
-	unsigned char		sk_protocol;
-	unsigned short		sk_type;
 	int			sk_rcvbuf;
 	socket_lock_t		sk_lock;
 	/*
