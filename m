From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix struct sock bitfield annotation
Date: Fri, 09 Oct 2009 03:46:09 +0200
Message-ID: <4ACE95E1.30301@gmail.com>
References: <4ACE023D.9030208@gmail.com> <19f34abd0910081454v51455ee0p30ad6715b5ee31c0@mail.gmail.com> <4ACE8CEC.3020905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vegard Nossum <vegard.nossum@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	Christoph Lameter <cl@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53471 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755970AbZJIBrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 21:47:06 -0400
In-Reply-To: <4ACE8CEC.3020905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
>=20
> I am currently writing a tool to re-organize 'struct sock' fields,
> for net-next-2.6 using offsetof() macro, this is how I spot the probl=
em.
>=20

=46or networking guys, here is the actual mess with "struct sock" on x8=
6_64,
related to UDP handling (critical latencies for some people). We basica=
lly touch
all cache lines, in every paths, bad effects on SMP...

- rx softirq reception
- rx recvmsg() time
- tx sendto() time
- tx completion time

sizeof(struct sk_buff)  =3D232 (0x e8)
sizeof(struct sock)     =3D528 (0x210)
sizeof(struct inet_sock)=3D680 (0x2a8)

=46ollowing offsets in hexadecimal

offsetof(struct sock, sk_refcnt)       =3D 10   (rw by reception of udp=
 frame, __udp4_lib_lookup())
 (unavoidable hot spot unfortunatly, but not anymore touched by sock_wf=
ree())

offsetof(struct sock, sk_hash)         =3D 14   (read  rx softirq )
offsetof(struct sock, sk_family)       =3D 18   (read   "     "   =20
offsetof(struct inet_sock, daddr)      =3D210   (read   "     "  =20
offsetof(struct inet_sock, rcv_saddr)  =3D214   (read   "     " =20
offsetof(struct inet_sock, dport)      =3D218   (read   "     "=20
offsetof(struct inet_sock, mc_list)    =3D240   (read   "       multica=
st reception
offsetof(struct sock, sk_bound_dev_if) =3D 1c   (read  rx softirq)

(First patch I'll submit is move daddr/rcv_saddr/dport to struct sock_c=
ommon,
 so that lookup() use one cache line instead of two per socket in hash =
chain)


offsetof(struct sock, sk_prot)         =3D 30   (read by sk_has_account=
())
offsetof(struct sock, sk_rcvbuf)       =3D 3c   (read)
offsetof(struct sock, sk_protocol)     =3D 39
offsetof(struct sock, sk_allocation)   =3D e0   (read at send() time)
offsetof(struct sock, sk_flags)        =3D f8   (read)
offsetof(struct sock, sk_lock)         =3D 40   (rw by udp_sendmsg())
offsetof(struct sock, sk_dst_lock)     =3D 90   (rw by udp_sendmsg() on=
 connected socks)
offsetof(struct sock, sk_dst_cache)    =3D 78   (read by udp_sendmsg() =
on connected socks)
offsetof(struct sock, sk_mark)         =3D1d8   (read at sendto() time)
offsetof(struct sock, sk_write_queue)  =3D c0   (rw by sendto())
offsetof(struct inet_sock, id)         =3D232   (rw by sendto() on conn=
ected socks)
offsetof(struct sock, sk_wmem_alloc)   =3D 98   (RW, both at sendto() a=
nd tx completion handler time)
offsetof(struct sock, sk_sndbuf)       =3D a0   (read at tx completion =
time and sendto())
offsetof(struct sock, sk_sndmsg_page)  =3D1b8   (rw by send())
offsetof(struct sock, sk_send_head)    =3D1c0   (rw by send(), tcp)

offsetof(struct sock, sk_rmem_alloc)   =3D 94   (RW, both when frame is=
 received by softirq and dequeued at recvmsg() time)
offsetof(struct sock, sk_receive_queue)=3D a8   (RW, both when frame is=
 received by softirq and dequeued at recvmsg() time)
offsetof(struct sock, sk_forward_alloc)=3D dc   (rw rx softirq and recv=
msg() time)
offsetof(struct sock, sk_drops)        =3D134   (read when udp frame is=
 received in softirq handler)
offsetof(struct sock, sk_stamp)        =3D1a0   (write at recvmsg() tim=
e)
offsetof(struct sock, sk_sleep)        =3D 70   (read by softirq handle=
rs (rx/tx))
offsetof(struct sock, sk_filter)       =3D160   (read when udp frame is=
 received in softirq handler)
offsetof(struct sock, sk_socket)       =3D1a8   (read)
offsetof(struct sock, sk_callback_lock)=3D128   (rw at softirq time
offsetof(struct sock, sk_data_ready)   =3D1e8   (read)
offsetof(struct sock, sk_write_space)  =3D1f0   (read at TX completion =
time)

used by TCP
offsetof(struct sock, sk_timer)        =3D170
offsetof(struct sock, sk_ack_backlog)  =3D138   (listen socks)

Almost never used
offsetof(struct sock, sk_lingertime)   =3D100
offsetof(struct sock, sk_write_pending)=3D1cc
offsetof(struct sock, sk_prot_creator )=3D120
