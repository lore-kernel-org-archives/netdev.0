From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Date: Thu, 17 Sep 2015 10:18:29 -0400
Message-ID: <1442499509.2865.16.camel@primarydata.com>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
	 <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150911143347.GQ21084@n2100.arm.linux.org.uk>
	 <20150911150613.GR21084@n2100.arm.linux.org.uk>
	 <1441984723.4619.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150911162416.GV21084@n2100.arm.linux.org.uk>
	 <20150911164937.GW21084@n2100.arm.linux.org.uk>
	 <20150917135705.GQ21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	AnnaSchumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150917135705.GQ21084-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Russell,

On Thu, 2015-09-17 at 14:57 +0100, Russell King - ARM Linux wrote:
> On Fri, Sep 11, 2015 at 05:49:38PM +0100, Russell King - ARM Linux
> wrote:
> > Following that idea, I just tried the patch below, and it seems to
> > work.
> > I don't know whether it handles all cases after a call to
> > kernel_connect(),
> > but it stops the multiple connection attempts:
> >=20
> >   1   0.000000 armada388 -> n2100 TCP 1009=E2=86=92nfs [SYN] Seq=3D=
3794066539
> > Win=3D28560 Len=3D0 MSS=3D1440 SACK_PERM=3D1 TSval=3D15712 TSecr=3D=
870317691
> > WS=3D128
> >   2   0.000414 n2100 -> armada388 TCP nfs=E2=86=921009 [SYN, ACK]
> > Seq=3D1884476522 Ack=3D3794066540 Win=3D28560 Len=3D0 MSS=3D1440 SA=
CK_PERM=3D1
> > TSval=3D870318939 TSecr=3D15712 WS=3D64
> >   3   0.000787 armada388 -> n2100 TCP 1009=E2=86=92nfs [ACK] Seq=3D=
3794066540
> > Ack=3D1884476523 Win=3D28672 Len=3D0 TSval=3D15712 TSecr=3D87031893=
9
> >   4   0.001304 armada388 -> n2100 NFS V3 ACCESS Call, FH:
> > 0x905379cc, [Check: RD LU MD XT DL]
> >   5   0.001566 n2100 -> armada388 TCP nfs=E2=86=921009 [ACK] Seq=3D=
1884476523
> > Ack=3D3794066660 Win=3D28608 Len=3D0 TSval=3D870318939 TSecr=3D1571=
2
> >   6   0.001640 armada388 -> n2100 NFS V3 ACCESS Call, FH:
> > 0x905379cc, [Check: RD LU MD XT DL]
> >   7   0.001866 n2100 -> armada388 TCP nfs=E2=86=921009 [ACK] Seq=3D=
1884476523
> > Ack=3D3794066780 Win=3D28608 Len=3D0 TSval=3D870318939 TSecr=3D1571=
2
> >   8   0.003070 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 4),
> > [Allowed: RD LU MD XT DL]
> >   9   0.003415 armada388 -> n2100 TCP 1009=E2=86=92nfs [ACK] Seq=3D=
3794066780
> > Ack=3D1884476647 Win=3D28672 Len=3D0 TSval=3D15712 TSecr=3D87031893=
9
> >  10   0.003592 armada388 -> n2100 NFS V3 ACCESS Call, FH:
> > 0xe15fc9c9, [Check: RD LU MD XT DL]
> >  11   0.004354 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 6),
> > [Allowed: RD LU MD XT DL]
> >  12   0.004682 armada388 -> n2100 NFS V3 ACCESS Call, FH:
> > 0xe15fc9c9, [Check: RD LU MD XT DL]
> >  13   0.005365 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 10),
> > [Allowed: RD LU MD XT DL]
> >  14   0.005701 armada388 -> n2100 NFS V3 GETATTR Call, FH:
> > 0xe15fc9c9
> > ...
>=20
> NFS people - any comments on this patch?  Is it the correct way to
> solve
> this problem (please see the first message in this thread for the
> problem.)
> Without this patch, NFS is unusable as it tries to launch multiple
> new
> connections from the same port to the NFS server without giving the
> NFS
> server time to respond and establish the TCP connection.

I agree that it addresses a real problem here, however there are a
couple of issues with the patch itself:

AFAICS, the 2 possible next states for SYN_SENT are TCP_ESTABLISHED and
TCP_CLOSE, so if the connection attempt fails, this patch leaves the
XPRT_CONNECTING flag set.
There is also the issue that clearing XPRT_CONNECTING in TCP_FIN_WAIT1,
TCP_CLOSE_WAIT and TCP_CLOSING could interfere with another connection
attempt by canceling the XPRT_CONNECTING state.

How about the following? It is based on your patch, but adds a check to
ensure that xs_tcp_state_change() doesn't clear the 'connecting' state
more than once (which could otherwise still happen in the TCP_CLOSE
case).

8<-------------------------------------------------------------------
=46rom 4dbfdebbc09982a9248866f8256549456e2b2efd Mon Sep 17 00:00:00 200=
1
=46rom: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Date: Wed, 16 Sep 2015 23:43:17 -0400
Subject: [PATCH] SUNRPC: Ensure that we wait for connections to complet=
e
 before retrying

Commit 718ba5b87343, moved the responsibility for unlocking the socket =
to
xs_tcp_setup_socket, meaning that the socket will be unlocked before we
know that it has finished trying to connect. The following patch is bas=
ed on
an initial patch by Russell King to ensure that we delay clearing the
XPRT_SOCK_CONNECTING flag until we either know that we failed to initia=
te
a connection attempt, or the connection attempt itself failed.

=46ixes: 718ba5b87343 ("SUNRPC: Add helpers to prevent socket create fr=
om racing")
Reported-by: Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Signed-off-by: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
---
 include/linux/sunrpc/xprtsock.h |  3 +++
 net/sunrpc/xprtsock.c           | 11 ++++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xpr=
tsock.h
index 7591788e9fbf..357e44c1a46b 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -42,6 +42,7 @@ struct sock_xprt {
 	/*
 	 * Connection of transports
 	 */
+	unsigned long		sock_state;
 	struct delayed_work	connect_worker;
 	struct sockaddr_storage	srcaddr;
 	unsigned short		srcport;
@@ -76,6 +77,8 @@ struct sock_xprt {
  */
 #define TCP_RPC_REPLY		(1UL << 6)
=20
+#define XPRT_SOCK_CONNECTING	1U
+
 #endif /* __KERNEL__ */
=20
 #endif /* _LINUX_SUNRPC_XPRTSOCK_H */
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7be90bc1a7c2..5bac27983e2a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1435,6 +1435,7 @@ out:
 static void xs_tcp_state_change(struct sock *sk)
 {
 	struct rpc_xprt *xprt;
+	struct sock_xprt *transport;
=20
 	read_lock_bh(&sk->sk_callback_lock);
 	if (!(xprt =3D xprt_from_sock(sk)))
@@ -1446,13 +1447,12 @@ static void xs_tcp_state_change(struct sock *sk=
)
 			sock_flag(sk, SOCK_ZAPPED),
 			sk->sk_shutdown);
=20
+	transport =3D container_of(xprt, struct sock_xprt, xprt);
 	trace_rpc_socket_state_change(xprt, sk->sk_socket);
 	switch (sk->sk_state) {
 	case TCP_ESTABLISHED:
 		spin_lock(&xprt->transport_lock);
 		if (!xprt_test_and_set_connected(xprt)) {
-			struct sock_xprt *transport =3D container_of(xprt,
-					struct sock_xprt, xprt);
=20
 			/* Reset TCP record info */
 			transport->tcp_offset =3D 0;
@@ -1461,6 +1461,8 @@ static void xs_tcp_state_change(struct sock *sk)
 			transport->tcp_flags =3D
 				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
 			xprt->connect_cookie++;
+			clear_bit(XPRT_SOCK_CONNECTING, &transport->sock_state);
+			xprt_clear_connecting(xprt);
=20
 			xprt_wake_pending_tasks(xprt, -EAGAIN);
 		}
@@ -1496,6 +1498,9 @@ static void xs_tcp_state_change(struct sock *sk)
 		smp_mb__after_atomic();
 		break;
 	case TCP_CLOSE:
+		if (test_and_clear_bit(XPRT_SOCK_CONNECTING,
+					&transport->sock_state))
+			xprt_clear_connecting(xprt);
 		xs_sock_mark_closed(xprt);
 	}
  out:
@@ -2179,6 +2184,7 @@ static int xs_tcp_finish_connecting(struct rpc_xp=
rt *xprt, struct socket *sock)
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start =3D jiffies;
+	set_bit(XPRT_SOCK_CONNECTING, &transport->sock_state);
 	ret =3D kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK=
);
 	switch (ret) {
 	case 0:
@@ -2240,7 +2246,6 @@ static void xs_tcp_setup_socket(struct work_struc=
t *work)
 	case -EINPROGRESS:
 	case -EALREADY:
 		xprt_unlock_connect(xprt, transport);
-		xprt_clear_connecting(xprt);
 		return;
 	case -EINVAL:
 		/* Happens, for instance, if the user specified a link
--=20
2.4.3

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
