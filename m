From: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Date: Fri, 11 Sep 2015 17:49:38 +0100
Message-ID: <20150911164937.GW21084@n2100.arm.linux.org.uk>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
 <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150911143347.GQ21084@n2100.arm.linux.org.uk>
 <20150911150613.GR21084@n2100.arm.linux.org.uk>
 <1441984723.4619.61.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150911162416.GV21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150911162416.GV21084-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 05:24:17PM +0100, Russell King - ARM Linux wrot=
e:
> On Fri, Sep 11, 2015 at 08:18:43AM -0700, Eric Dumazet wrote:
> > On Fri, 2015-09-11 at 16:06 +0100, Russell King - ARM Linux wrote:
> > > On Fri, Sep 11, 2015 at 03:33:47PM +0100, Russell King - ARM Linu=
x wrote:
> > > > It looks like 0c78789e3a030615c6650fde89546cadf40ec2cc might be=
 relevant
> > > > too, but I don't see that solving the multiple _concurrent_ con=
nection
> > > > attempts with the same port number - presumably it's somehow tr=
ying to
> > > > make the same socket repeatedly connect despite a previous conn=
ection
> > > > being in progress, which would have nothing to do with cleaning=
 up a
> > > > previous attempt.
> > >=20
> > > As I suspected, applying the above commit in addition does not so=
lve the
> > > problem, I still see the same behaviour: SYN SYNACK SYN RSTACK, S=
YN
> > > SYNACK SYN RSTACK, and eventual SYN storms.
> > >=20
> > > I do have this captured as well:
> > >=20
> > > 2558   0.834316 armada388 -> n2100 TCP [TCP Port numbers reused] =
rpasswd=E2=86=92nfs [SYN] Seq=3D1053655487 Win=3D28800 Len=3D0 MSS=3D14=
40 SACK_PERM=3D1 TSval=3D60001 TSecr=3D0 WS=3D128
> > > 2559   0.834572 n2100 -> armada388 TCP nfs=E2=86=92rpasswd [SYN, =
ACK] Seq=3D3076611574 Ack=3D1053655488 Win=3D28560 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D869622246 TSecr=3D60001 WS=3D64
> > > 2560   0.834666 armada388 -> n2100 TCP [TCP Port numbers reused] =
rpasswd=E2=86=92nfs [SYN] Seq=3D1054228544 Win=3D28800 Len=3D0 MSS=3D14=
40 SACK_PERM=3D1 TSval=3D60005 TSecr=3D0 WS=3D128
> > > 2561   0.834895 n2100 -> armada388 TCP nfs=E2=86=92rpasswd [ACK] =
Seq=3D3076611575 Ack=3D1053655488 Win=3D28560 Len=3D0 TSval=3D869622246=
 TSecr=3D60001
> > >=20
> > > The packet at 2561 looks wrong to me - this doesn't follow what I=
 know
> > > would be the standard TCP setup of syn, synack, ack, because that=
 final
> > > ack is in the wrong direction.
> > >=20
> >=20
> > This 2561 packet is an ACK packet, because n2100 has a SYN_RECV soc=
ket
> > created by packet 2558.
> >=20
> > It receives a SYN packet (2560) that it interprets as a packet slig=
htly
> > out of sequence (1054228544 being above 1053655487) for this SYN_RE=
CV
> >=20
> > The wrong packet is 2560, not 2561
>=20
> Ok.
>=20
> Looking deeper at the XPRT sunrpc code, I have to wonder about the
> sanity of this:
>=20
> void xprt_connect(struct rpc_task *task)
> {
> ...
>         if (!xprt_connected(xprt)) {
> ...
>                 if (test_bit(XPRT_CLOSING, &xprt->state))
>                         return;
>                 if (xprt_test_and_set_connecting(xprt))
>                         return;
>                 xprt->stat.connect_start =3D jiffies;
>                 xprt->ops->connect(xprt, task);
>=20
> That calls into xs_connect(), which schedules a workqueue to do the
> connection.  The workqueue will call xs_tcp_setup_socket().
>=20
> xs_tcp_setup_socket() creates a socket if one didn't exist, otherwise
> re-using the previously obtained socket (which'll be why its using th=
e
> same socket) and then goes on to call xs_tcp_finish_connecting().
>=20
> xs_tcp_finish_connecting() calls kernel_connect(), which will return
> -EINPROGRESS.  We seem to treat EINPROGRESS as if the connection was
> successful:
>=20
>         case 0:
>         case -EINPROGRESS:
>         case -EALREADY:
>                 xprt_unlock_connect(xprt, transport);
>                 xprt_clear_connecting(xprt);
>                 return;
>=20
> and the xprt_clear_connecting() results in this whole path being
> re-opened: the socket is not yet connected, so xprt_connected() will
> return false, and despite the socket connection still being mid-way
> through being connected, we clear the "connecting" status, causing
> xprt_test_and_set_connecting() to return false.
>=20
> That allows us to re-call xprt->ops->connect, re-queue the connect
> worker, and re-run the call to kernel_connect() for a socket which is
> already mid-way through being connected.
>=20
> Shouldn't the "connecting" status only be cleared when either the soc=
ket
> has _finished_ connecting, or when the connection has _failed_ to con=
nect,
> and not when it's mid-way through connecting?
>=20
> I've not been able to prove this: I've set rpc_debug to 129 to log
> just xprt and trans RPC facilities, and that's sufficient to change
> the timing such that this doesn't happen.

=46ollowing that idea, I just tried the patch below, and it seems to wo=
rk.
I don't know whether it handles all cases after a call to kernel_connec=
t(),
but it stops the multiple connection attempts:

  1   0.000000 armada388 -> n2100 TCP 1009=E2=86=92nfs [SYN] Seq=3D3794=
066539 Win=3D28560 Len=3D0 MSS=3D1440 SACK_PERM=3D1 TSval=3D15712 TSecr=
=3D870317691 WS=3D128
  2   0.000414 n2100 -> armada388 TCP nfs=E2=86=921009 [SYN, ACK] Seq=3D=
1884476522 Ack=3D3794066540 Win=3D28560 Len=3D0 MSS=3D1440 SACK_PERM=3D=
1 TSval=3D870318939 TSecr=3D15712 WS=3D64
  3   0.000787 armada388 -> n2100 TCP 1009=E2=86=92nfs [ACK] Seq=3D3794=
066540 Ack=3D1884476523 Win=3D28672 Len=3D0 TSval=3D15712 TSecr=3D87031=
8939
  4   0.001304 armada388 -> n2100 NFS V3 ACCESS Call, FH: 0x905379cc, [=
Check: RD LU MD XT DL]
  5   0.001566 n2100 -> armada388 TCP nfs=E2=86=921009 [ACK] Seq=3D1884=
476523 Ack=3D3794066660 Win=3D28608 Len=3D0 TSval=3D870318939 TSecr=3D1=
5712
  6   0.001640 armada388 -> n2100 NFS V3 ACCESS Call, FH: 0x905379cc, [=
Check: RD LU MD XT DL]
  7   0.001866 n2100 -> armada388 TCP nfs=E2=86=921009 [ACK] Seq=3D1884=
476523 Ack=3D3794066780 Win=3D28608 Len=3D0 TSval=3D870318939 TSecr=3D1=
5712
  8   0.003070 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 4), [All=
owed: RD LU MD XT DL]
  9   0.003415 armada388 -> n2100 TCP 1009=E2=86=92nfs [ACK] Seq=3D3794=
066780 Ack=3D1884476647 Win=3D28672 Len=3D0 TSval=3D15712 TSecr=3D87031=
8939
 10   0.003592 armada388 -> n2100 NFS V3 ACCESS Call, FH: 0xe15fc9c9, [=
Check: RD LU MD XT DL]
 11   0.004354 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 6), [All=
owed: RD LU MD XT DL]
 12   0.004682 armada388 -> n2100 NFS V3 ACCESS Call, FH: 0xe15fc9c9, [=
Check: RD LU MD XT DL]
 13   0.005365 n2100 -> armada388 NFS V3 ACCESS Reply (Call In 10), [Al=
lowed: RD LU MD XT DL]
 14   0.005701 armada388 -> n2100 NFS V3 GETATTR Call, FH: 0xe15fc9c9
=2E..

 net/sunrpc/xprtsock.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ff5b6a2e62c3..c456d6e51c56 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1450,6 +1450,7 @@ static void xs_tcp_state_change(struct sock *sk)
 	switch (sk->sk_state) {
 	case TCP_ESTABLISHED:
 		spin_lock(&xprt->transport_lock);
+		xprt_clear_connecting(xprt);
 		if (!xprt_test_and_set_connected(xprt)) {
 			struct sock_xprt *transport =3D container_of(xprt,
 					struct sock_xprt, xprt);
@@ -1474,12 +1475,14 @@ static void xs_tcp_state_change(struct sock *sk=
)
 		smp_mb__before_atomic();
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
+		clear_bit(XPRT_CONNECTING, &xprt->state);	=09
 		smp_mb__after_atomic();
 		break;
 	case TCP_CLOSE_WAIT:
 		/* The server initiated a shutdown of the socket */
 		xprt->connect_cookie++;
 		clear_bit(XPRT_CONNECTED, &xprt->state);
+		clear_bit(XPRT_CONNECTING, &xprt->state);
 		xs_tcp_force_close(xprt);
 	case TCP_CLOSING:
 		/*
@@ -1493,6 +1496,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		set_bit(XPRT_CLOSING, &xprt->state);
 		smp_mb__before_atomic();
 		clear_bit(XPRT_CONNECTED, &xprt->state);
+		clear_bit(XPRT_CONNECTING, &xprt->state);
 		smp_mb__after_atomic();
 		break;
 	case TCP_CLOSE:
@@ -2237,11 +2241,13 @@ static void xs_tcp_setup_socket(struct work_str=
uct *work)
 		xs_tcp_force_close(xprt);
 		break;
 	case 0:
-	case -EINPROGRESS:
 	case -EALREADY:
 		xprt_unlock_connect(xprt, transport);
 		xprt_clear_connecting(xprt);
 		return;
+	case -EINPROGRESS:
+		xprt_unlock_connect(xprt, transport);
+		return;
 	case -EINVAL:
 		/* Happens, for instance, if the user specified a link
 		 * local IPv6 address without a scope-id.


--=20
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
