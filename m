From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: ping: dont call udp_ioctl()
Date: Sun, 15 May 2011 10:18:40 +0200
Message-ID: <1305447520.3120.88.camel@edumazet-laptop>
References: <20110510.121550.112583080.davem@davemloft.net>
	 <20110513200100.GA3875@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, solar@openwall.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	peak@argo.troja.mff.cuni.cz, kees.cook@canonical.com,
	dan.j.rosenberg@gmail.com, eugene@redhat.com, nelhage@ksplice.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110513200100.GA3875@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 14 mai 2011 =C3=A0 00:01 +0400, Vasiliy Kulikov a =C3=A9crit =
:

> +/*
> + *	IOCTL requests applicable to the UDP^H^H^HICMP protocol
> + */
> +
> +int ping_ioctl(struct sock *sk, int cmd, unsigned long arg)
> +{
> +	pr_debug("ping_ioctl(sk=3D%p,sk->num=3D%u,cmd=3D%d,arg=3D%lu)\n",
> +		inet_sk(sk), inet_sk(sk)->inet_num, cmd, arg);
> +	switch (cmd) {
> +	case SIOCOUTQ:
> +	case SIOCINQ:
> +		return udp_ioctl(sk, cmd, arg);
> +	default:
> +		return -ENOIOCTLCMD;
> +	}
> +}

Do we really need to support SIOCOUTQ and SIOCINQ ioctls for ping
sockets ?

I ask this because udp_ioctl() assumes it handles UDP frames, and can
change UDP_MIB_INERRORS in case first_packet_length() finds a frame wit=
h
bad checksum.

[ UDP let the checksum be completed and checked when it performs the
Kernel->User copy ]

I would just remove this legacy, please shout if you believe we really
should support ioctl...

[ I actually tested that ping was still working correctly, of course ]

BTW, link
(ftp://mirrors.kernel.org/openwall/Owl/current/sources/Owl/packages/ipu=
tils/iputils-ss020927.tar.gz ) provided in http://openwall.info/wiki/pe=
ople/segoon/ping is not working.

I had to manually patch iputils-s20101006.tar.bz2 instead.

Thanks

[PATCH net-next-2.6] net: ping: dont call udp_ioctl()

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
 net/ipv4/ping.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 7041d09..952505a 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -610,20 +610,15 @@ do_confirm:
 }
=20
 /*
- *	IOCTL requests applicable to the UDP^H^H^HICMP protocol
+ *	IOCTL requests applicable to PING sockets
  */
=20
 int ping_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
 	pr_debug("ping_ioctl(sk=3D%p,sk->num=3D%u,cmd=3D%d,arg=3D%lu)\n",
 		inet_sk(sk), inet_sk(sk)->inet_num, cmd, arg);
-	switch (cmd) {
-	case SIOCOUTQ:
-	case SIOCINQ:
-		return udp_ioctl(sk, cmd, arg);
-	default:
-		return -ENOIOCTLCMD;
-	}
+
+	return -ENOIOCTLCMD;
 }
=20
 int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m=
sg,
