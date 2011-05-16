From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v2] net: ping: dont call udp_ioctl()
Date: Mon, 16 May 2011 09:26:31 +0200
Message-ID: <1305530791.3120.217.camel@edumazet-laptop>
References: <20110513200100.GA3875@albatros>
	 <1305447520.3120.88.camel@edumazet-laptop>
	 <20110515213018.GA26820@openwall.com>
	 <20110515.174430.1379973540554096232.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: solar@openwall.com, segoon@openwall.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	peak@argo.troja.mff.cuni.cz, kees.cook@canonical.com,
	dan.j.rosenberg@gmail.com, eugene@redhat.com, nelhage@ksplice.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110515.174430.1379973540554096232.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 15 mai 2011 =C3=A0 17:44 -0400, David Miller a =C3=A9crit :

> Just get rid of ping_ioctl() entirely, as that is the effect of
> this change since inet_ioctl() returns -ENOIOCTLCMD when
> sk_prot->ioctl is NULL.
>=20
> Also get rid of asm/ioctls.h since that will be no longer needed.

Sure, here is updated version, thanks.

[PATCH net-next-2.6 v2] net: ping: dont call udp_ioctl()

udp_ioctl() really handles UDP and UDPLite protocols.

1) It can increment UDP_MIB_INERRORS in case first_packet_length() find=
s
a frame with bad checksum.

2) It has a dependency on sizeof(struct udphdr), not applicable to
ICMP/PING

If ping sockets need to handle SIOCINQ/SIOCOUTQ ioctl, this should be
done differently.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Vasiliy Kulikov <segoon@openwall.com>
---
 net/ipv4/ping.c |   19 -------------------
 1 file changed, 19 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 7041d09..41836ab 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -22,7 +22,6 @@
=20
 #include <asm/system.h>
 #include <linux/uaccess.h>
-#include <asm/ioctls.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
 #include <linux/socket.h>
@@ -609,23 +608,6 @@ do_confirm:
 	goto out;
 }
=20
-/*
- *	IOCTL requests applicable to the UDP^H^H^HICMP protocol
- */
-
-int ping_ioctl(struct sock *sk, int cmd, unsigned long arg)
-{
-	pr_debug("ping_ioctl(sk=3D%p,sk->num=3D%u,cmd=3D%d,arg=3D%lu)\n",
-		inet_sk(sk), inet_sk(sk)->inet_num, cmd, arg);
-	switch (cmd) {
-	case SIOCOUTQ:
-	case SIOCINQ:
-		return udp_ioctl(sk, cmd, arg);
-	default:
-		return -ENOIOCTLCMD;
-	}
-}
-
 int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m=
sg,
 		 size_t len, int noblock, int flags, int *addr_len)
 {
@@ -735,7 +717,6 @@ struct proto ping_prot =3D {
 	.close =3D	ping_close,
 	.connect =3D	ip4_datagram_connect,
 	.disconnect =3D	udp_disconnect,
-	.ioctl =3D	ping_ioctl,
 	.setsockopt =3D	ip_setsockopt,
 	.getsockopt =3D	ip_getsockopt,
 	.sendmsg =3D	ping_sendmsg,
