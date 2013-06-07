From: Mike Galbraith <bitbucket@online.de>
Subject: Re: Scaling problem with a lot of AF_PACKET sockets on different
 interfaces
Date: Fri, 07 Jun 2013 14:41:11 +0200
Message-ID: <1370608871.5854.64.camel@marge.simpson.net>
References: <51B1CA50.30702@telenet.dn.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51B1CA50.30702@telenet.dn.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(CC's net-fu dojo)=20

On Fri, 2013-06-07 at 14:56 +0300, Vitaly V. Bursov wrote:=20
> Hello,
>=20
> I have a Linux router with a lot of interfaces (hundreds or
> thousands of VLANs) and an application that creates AF_PACKET
> socket per interface and bind()s sockets to interfaces.
>=20
> Each socket has attached BPF filter too.
>=20
> The problem is observed on linux-3.8.13, but as far I can see
> from the source the latest version has alike behavior.
>=20
> I noticed that box has strange performance problems with
> most of the CPU time spent in __netif_receive_skb:
>   86.15%  [k] __netif_receive_skb
>    1.41%  [k] _raw_spin_lock
>    1.09%  [k] fib_table_lookup
>    0.99%  [k] local_bh_enable_ip
>=20
> and this the assembly with the "hot spot":
>         =E2=94=82       shr    $0x8,%r15w
>         =E2=94=82       and    $0xf,%r15d
>    0.00 =E2=94=82       shl    $0x4,%r15
>         =E2=94=82       add    $0xffffffff8165ec80,%r15
>         =E2=94=82       mov    (%r15),%rax
>    0.09 =E2=94=82       mov    %rax,0x28(%rsp)
>         =E2=94=82       mov    0x28(%rsp),%rbp
>    0.01 =E2=94=82       sub    $0x28,%rbp
>         =E2=94=82       jmp    5c7
>    1.72 =E2=94=825b0:   mov    0x28(%rbp),%rax
>    0.05 =E2=94=82       mov    0x18(%rsp),%rbx
>    0.00 =E2=94=82       mov    %rax,0x28(%rsp)
>    0.03 =E2=94=82       mov    0x28(%rsp),%rbp
>    5.67 =E2=94=82       sub    $0x28,%rbp
>    1.71 =E2=94=825c7:   lea    0x28(%rbp),%rax
>    1.73 =E2=94=82       cmp    %r15,%rax
>         =E2=94=82       je     640
>    1.74 =E2=94=82       cmp    %r14w,0x0(%rbp)
>         =E2=94=82       jne    5b0
>   81.36 =E2=94=82       mov    0x8(%rbp),%rax
>    2.74 =E2=94=82       cmp    %rax,%r8
>         =E2=94=82       je     5eb
>    1.37 =E2=94=82       cmp    0x20(%rbx),%rax
>         =E2=94=82       je     5eb
>    1.39 =E2=94=82       cmp    %r13,%rax
>         =E2=94=82       jne    5b0
>    0.04 =E2=94=825eb:   test   %r12,%r12
>    0.04 =E2=94=82       je     6f4
>         =E2=94=82       mov    0xc0(%rbx),%eax
>         =E2=94=82       mov    0xc8(%rbx),%rdx
>         =E2=94=82       testb  $0x8,0x1(%rdx,%rax,1)
>         =E2=94=82       jne    6d5
>=20
> This corresponds to:
>=20
> net/core/dev.c:
>          type =3D skb->protocol;
>          list_for_each_entry_rcu(ptype,
>                          &ptype_base[ntohs(type) & PTYPE_HASH_MASK], =
list) {
>                  if (ptype->type =3D=3D type &&
>                      (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=
=3D skb->dev ||
>                       ptype->dev =3D=3D orig_dev)) {
>                          if (pt_prev)
>                                  ret =3D deliver_skb(skb, pt_prev, or=
ig_dev);
>                          pt_prev =3D ptype;
>                  }
>          }
>=20
> Which works perfectly OK until there are a lot of AF_PACKET sockets, =
since
> the socket adds a protocol to ptype list:
>=20
> # cat /proc/net/ptype
> Type Device      Function
> 0800 eth2.1989 packet_rcv+0x0/0x400
> 0800 eth2.1987 packet_rcv+0x0/0x400
> 0800 eth2.1986 packet_rcv+0x0/0x400
> 0800 eth2.1990 packet_rcv+0x0/0x400
> 0800 eth2.1995 packet_rcv+0x0/0x400
> 0800 eth2.1997 packet_rcv+0x0/0x400
> .......
> 0800 eth2.1004 packet_rcv+0x0/0x400
> 0800          ip_rcv+0x0/0x310
> 0011          llc_rcv+0x0/0x3a0
> 0004          llc_rcv+0x0/0x3a0
> 0806          arp_rcv+0x0/0x150
>=20
> And this obviously results in a huge performance penalty.
>=20
> ptype_all, by the looks, should be the same.
>=20
> Probably one way to fix this it to perform interface name matching in
> af_packet handler, but there could be other cases, other protocols.
>=20
> Ideas are welcome :)
>=20
