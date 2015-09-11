From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Date: Fri, 11 Sep 2015 06:04:51 -0700
Message-ID: <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150911113839.GO21084-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-09-11 at 12:38 +0100, Russell King - ARM Linux wrote:
> I have a recent Marvell Armada 388 board here which uses the mvneta
> driver.  I'm seeing some weird effects with NFS with it acting as a
> client.  Unfortunately, the board does not have a functional RTC.
>=20
> The NFS server is the same NFS server that I've used for years with
> multiple other clients (it's my main NFS server) and it continues to
> support all other clients without any ill effect.  The NFS server
> kernel is rather old now, being a 3.x kernel.
>=20
> The NFS client appears to connect using TCP/IPv6 and initially is
> accessible.  Everything appears to work normally, and then the NFS
> server appears to stop responding.
>=20
> Running tcpdump on the NFS server, and then dumping the captured
> packets
> with tshark (because tcpdump appears not to understand IPv6 SYNs on
> the
> NFS port) shows:
>=20
>   3   0.030036 armada388 -> n2100 TCP 843=E2=86=92nfs [SYN] Seq=3D936=
803106
> Win=3D28800 Len=3D0 MSS=3D1440 SACK_PERM=3D1 TSval=3D892366 TSecr=3D0=
 WS=3D128

>   4   0.030409 n2100 -> armada388 TCP nfs=E2=86=92843 [SYN, ACK] Seq=3D=
409465870
> Ack=3D936803107 Win=3D28560 Len=3D0 MSS=3D1440 SACK_PERM=3D1
>  TSval=3D818169117 TSecr=3D892366 WS=3D64

>   5   0.030493 armada388 -> n2100 TCP [TCP Port numbers reused]
> 843=E2=86=92nfs [SYN] Seq=3D936803633 Win=3D28800 Len=3D0 MSS=3D1440 =
SACK_PERM=3D1
> TSval=3D892366 TSecr=3D0 WS=3D128

Yes, this packet looks very wrong. Like two simultaneous connect with
same source port. It is not a retransmit (Seq numbers differ)

>   6   0.030699 n2100 -> armada388 TCP nfs=E2=86=92843 [RST, ACK] Seq=3D=
0
> Ack=3D936803634 Win=3D0 Len=3D0
>   7   0.030766 armada388 -> n2100 TCP 843=E2=86=92nfs [RST] Seq=3D936=
803107
> Win=3D0 Len=3D0

I suspect port reuse in NFS being broken.

Have you tried to apply

commit 099392048cd443349c50310f7fdc96070e40f4e7
Author: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Date:   Sat Aug 29 19:11:21 2015 -0700

    SUNRPC: Prevent SYN+SYNACK+RST storms
   =20
    Add a shutdown() call before we release the socket in order to ensu=
re the
    reset is sent before we try to reconnect.
   =20
    Signed-off-by: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 214ca9dfb14e..7be90bc1a7c2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -822,6 +822,8 @@ static void xs_reset_transport(struct sock_xprt *tr=
ansport)
        if (atomic_read(&transport->xprt.swapper))
                sk_clear_memalloc(sk);
=20
+       kernel_sock_shutdown(sock, SHUT_RDWR);
+
        write_lock_bh(&sk->sk_callback_lock);
        transport->inet =3D NULL;
        transport->sock =3D NULL;


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
