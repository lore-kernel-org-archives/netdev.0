From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: IPF Montvale machine panic when running a network-relevent
	testing
Date: Wed, 18 Jun 2008 11:27:43 +0800
Message-ID: <1213759663.25608.33.camel@ymzhang>
References: <1213345160.25608.3.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux-IA64 <linux-ia64@vger.kernel.org>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <1213345160.25608.3.camel@ymzhang>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-06-13 at 16:19 +0800, Zhang, Yanmin wrote:
> With kernel 2.6.26-rc5 and a git kernel just between rc4 and rc5, my
> kernel panic on my Montvale machine when I did an initial specweb2005
> testing between 2 machines.
>=20
> Below is the log.
>=20
> LOGIN: Unable to handle kernel NULL pointer dereference (address 0000=
000000000000)
> Thread-7266[13494]: Oops 8804682956800 [1]
> Modules linked in:
>=20
> Pid: 13494, CPU 0, comm:          Thread-7266
> psr : 0000101008026018 ifs : 800000000000050e ip  : [<a00000010087a4b=
0>]    Not tainted (2.6.26-rc4git)
> ip is at tcp_rcv_established+0x1450/0x16e0
> unat: 0000000000000000 pfs : 000000000000050e rsc : 0000000000000003
> rnat: 0000000000000000 bsps: 0000000000000000 pr  : 000000000059656b
> ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
> csd : 0000000000000000 ssd : 0000000000000000
> b0  : a00000010087a410 b6  : a0000001004c7ac0 b7  : a0000001004c64e0
> f6  : 000000000000000000000 f7  : 1003e0000000000000b80
> f8  : 10000821f080500000000 f9  : 1003efffffffffffffa58
> f10 : 1003edbb7db5f6be58df8 f11 : 1003e0000000000000015
> r1  : a0000001010cce90 r2  : e0000003d4530c40 r3  : 0000000000000105
> r8  : e000000402533d68 r9  : e000000402533a80 r10 : e000000402533bfc
> r11 : 0000000000000004 r12 : e0000003d4537df0 r13 : e0000003d4530000
> r14 : 0000000000000000 r15 : e000000401fca180 r16 : e0000003d4530c68
> r17 : e000000402572238 r18 : 00000000000000ff r19 : a0000001012c6630
> r20 : e0000003d4530c68 r21 : e000000401fca480 r22 : e000000402572658
> r23 : e000000402572240 r24 : a0000001012c4e04 r25 : 0000000000000003
> r26 : e000000401fca4a8 r27 : e000000402572660 r28 : e00000040a2d2a00
> r29 : e00000040a6f83a8 r30 : e00000040a6f8300 r31 : 000000000000000a
>=20
> Call Trace:
>  [<a000000100014de0>] show_stack+0x40/0xa0
>                                 sp=3De0000003d45379c0 bsp=3De0000003d=
4531440
>  [<a0000001000156f0>] show_regs+0x850/0x8a0
>                                 sp=3De0000003d4537b90 bsp=3De0000003d=
45313e0
>  [<a000000100038d10>] die+0x230/0x360
>                                 sp=3De0000003d4537b90 bsp=3De0000003d=
4531398
>  [<a00000010005cec0>] ia64_do_page_fault+0x8e0/0xa40
>                                 sp=3De0000003d4537b90 bsp=3De0000003d=
4531348
>  [<a00000010000b120>] ia64_leave_kernel+0x0/0x280
>                                 sp=3De0000003d4537c20 bsp=3De0000003d=
4531348
>  [<a00000010087a4b0>] tcp_rcv_established+0x1450/0x16e0
>                                 sp=3De0000003d4537df0 bsp=3De0000003d=
45312d8
>  [<a000000100888370>] tcp_v4_do_rcv+0x70/0x500
>                                 sp=3De0000003d4537df0 bsp=3De0000003d=
4531298
>  [<a00000010088cd30>] tcp_v4_rcv+0xfb0/0x1060
>                                 sp=3De0000003d4537e00 bsp=3De0000003d=
4531248
>=20
>=20
>=20
> As a matter of fact, kernel paniced at statement
> "queue->rskq_accept_tail->dl_next =3D req" in function =EF=BB=BFreqsk=
_queue_add, because
> =EF=BB=BFqueue->rskq_accept_tail is NULL. The call chain is:
> =EF=BB=BF=EF=BB=BFtcp_rcv_established =3D> inet_csk_reqsk_queue_add =3D=
> reqsk_queue_add.
The call chain is:
=EF=BB=BFtcp_rcv_established =3D> tcp_defer_accept_check =3D> inet_csk_=
reqsk_queue_add =3D> reqsk_queue_add

>=20
> As I was running an initial specweb2005(configured 3500 sessions) tes=
ting between
> 2 machines, there were lots of failure and many network connections w=
ere
> reestablished during the testing.
>=20
> In function tcp_v4_rcv, bh_lock_sock_nested(sk) (a kind of spinlock) =
is used to
> avoid race. But inet_csk_accept uses lock_sock(sk) (a kind of sleeper=
). Although
> lock_sock also accesses sk->sk_lock.slock, it looks like there is a r=
ace.
This issue is caused by tcp defer accept. Mostly, process context calls=
 lock_sock
to apply a sleeping lock. BH (SoftIRQ) context calls bh_lock_sock(_nest=
ed) to just apply
for the sk->sk_lock.slock without sleeping, then do appropriate process=
ing based on
if sk->sk_lock.owned=3D=3D0. That works well if both process context an=
d BH context operate
the same sk at the same time. But with =EF=BB=BFtcp defer accept, it do=
esn't, because
process context(for example, in inet_csk_accept) locks the listen sk, w=
hile BH
context (in tcp_v4_rcv, for example) locks the child sk and calls
=EF=BB=BFtcp_defer_accept_check=EF=BB=BF =3D> inet_csk_reqsk_queue_add =
=3D> reqsk_queue_add, so there is a race
to access the listen sock.

Below patch against 2.6.26-rc6 fixes the issue.

=EF=BB=BF=EF=BB=BFSigned-off-by: Zhang Yanmin <yanmin.zhang@intel.com>

---

--- linux-2.6.26-rc6/net/ipv4/inet_connection_sock.c	2008-06-17 12:26:5=
0.000000000 +0800
+++ linux-2.6.26-rc6_tcp/net/ipv4/inet_connection_sock.c	2008-06-17 16:=
41:07.000000000 +0800
@@ -257,7 +257,10 @@ struct sock *inet_csk_accept(struct sock
 			goto out_err;
 	}
=20
+	lock_sock_bh(sk);
 	newsk =3D reqsk_queue_get_child(&icsk->icsk_accept_queue, sk);
+	unlock_sock_bh(sk);
+
 	BUG_TRAP(newsk->sk_state !=3D TCP_SYN_RECV);
 out:
 	release_sock(sk);
@@ -602,7 +605,9 @@ void inet_csk_listen_stop(struct sock *s
 	inet_csk_delete_keepalive_timer(sk);
=20
 	/* make all the listen_opt local to us */
+	lock_sock_bh(sk);
 	acc_req =3D reqsk_queue_yank_acceptq(&icsk->icsk_accept_queue);
+	unlock_sock_bh(sk);
=20
 	/* Following specs, it would be better either to send FIN
 	 * (and enter FIN-WAIT-1, it is normal close)
--- linux-2.6.26-rc6/net/ipv4/tcp_input.c	2008-06-17 12:26:50.000000000=
 +0800
+++ linux-2.6.26-rc6_tcp/net/ipv4/tcp_input.c	2008-06-17 16:43:35.00000=
0000 +0800
@@ -4554,6 +4554,8 @@ static int tcp_defer_accept_check(struct
 		if (queued_data && hasfin)
 			queued_data--;
=20
+		bh_lock_sock_nested(tp->defer_tcp_accept.listen_sk);
+
 		if (queued_data &&
 		    tp->defer_tcp_accept.listen_sk->sk_state =3D=3D TCP_LISTEN) {
 			if (sock_flag(sk, SOCK_KEEPOPEN)) {
@@ -4568,6 +4570,8 @@ static int tcp_defer_accept_check(struct
 				tp->defer_tcp_accept.request,
 				sk);
=20
+			bh_unlock_sock(tp->defer_tcp_accept.listen_sk);
+
 			tp->defer_tcp_accept.listen_sk->sk_data_ready(
 				tp->defer_tcp_accept.listen_sk, 0);
=20
@@ -4577,6 +4581,7 @@ static int tcp_defer_accept_check(struct
 			tp->defer_tcp_accept.request =3D NULL;
 		} else if (hasfin ||
 			   tp->defer_tcp_accept.listen_sk->sk_state !=3D TCP_LISTEN) {
+			bh_unlock_sock(tp->defer_tcp_accept.listen_sk);
 			tcp_reset(sk);
 			return -1;
 		}
--- linux-2.6.26-rc6/include/net/sock.h	2008-06-17 12:26:50.000000000 +=
0800
+++ linux-2.6.26-rc6_tcp/include/net/sock.h	2008-06-17 16:43:58.0000000=
00 +0800
@@ -827,6 +827,10 @@ static inline void lock_sock(struct sock
=20
 extern void release_sock(struct sock *sk);
=20
+/* process context need below 2 interfaces */
+#define lock_sock_bh(__sk)	spin_lock_bh(&((__sk)->sk_lock.slock))
+#define unlock_sock_bh(__sk)	spin_unlock_bh(&((__sk)->sk_lock.slock))
+
 /* BH context may only use the following locking interface. */
 #define bh_lock_sock(__sk)	spin_lock(&((__sk)->sk_lock.slock))
 #define bh_lock_sock_nested(__sk) \


--
To unsubscribe from this list: send the line "unsubscribe linux-ia64" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
