From: Christopher White <chris@logicalelegance.com>
Subject: Re: [PATCH V2 net-next] LISP: Locator/Identifier Separation Protocol
Date: Tue, 17 Jun 2014 13:41:04 -0700
Message-ID: <5F3B797F-9DE9-43AC-91E1-C11B51DB2B2C@logicalelegance.com>
References: <4D3092DF-BB04-4C50-88B9-EBBA349C7B17@logicalelegance.com> <CA+mtBx9OdgWad6WJvNoUWreoyef9sd0AbHAsNWTSHaD1z=Tj8A@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Vina Ermagan (vermagan)" <vermagan@cisco.com>,
	"Lorand Jakab -X (lojakab - M SQUARED CONSULTING INC. at Cisco)"
	<lojakab@cisco.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.webfaction.com ([74.55.86.74]:51761 "EHLO
	smtp.webfaction.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933275AbaFQUlI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 16:41:08 -0400
In-Reply-To: <CA+mtBx9OdgWad6WJvNoUWreoyef9sd0AbHAsNWTSHaD1z=Tj8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Tom, some quick questions as I wrap this up=85.

On Jun 5, 2014, at 3:12 PM, Tom Herbert <therbert@google.com> wrote:

>=20
>> +static inline struct rtable *find_route(struct net *net,
>> +                                       __be32 *saddr, __be32 daddr,
>> +                                       u8 ipproto, u8 tos, u32 skb_=
mark)
>> +{
>> +       struct rtable *rt;
>> +
>> +       /* Tunnel configuration keeps DSCP part of TOS bits, But Lin=
ux
>> +        * router expect RT_TOS bits only.
>> +        */
>> +       struct flowi4 fl =3D { .daddr             =3D daddr,
>> +                            .saddr             =3D *saddr,
>> +                            .flowi4_tos        =3D RT_TOS(tos),
>> +                            .flowi4_mark       =3D skb_mark,
>> +                            .flowi4_proto      =3D ipproto };
>> +
>> +       rt =3D ip_route_output_key(net, &fl);
>> +       *saddr =3D fl.saddr;
>> +       return rt;
>> +}
>> +
> Looks like a function that should be in common header file?
>=20

I=92m not certain where the right place would be for this. A new file p=
erhaps?

>=20
>> +static int create_v4_sock(struct net *net, __be16 port, struct sock=
et **psock,
>> +                         u32 flags)
>> +{
>> +       struct sock *sk;
>> +       struct socket *sock;
>> +       struct sockaddr_in lisp_addr =3D {
>> +               .sin_family             =3D AF_INET,
>> +               .sin_addr.s_addr        =3D htonl(INADDR_ANY),
>> +               .sin_port               =3D port,
>> +       };
>> +       int rc;
>> +
>> +       /* Create UDP socket for encapsulation receive. */
>> +       rc =3D sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &s=
ock);
>> +       if (rc < 0) {
>> +               pr_debug("UDP socket create failed\n");
>> +               return rc;
>> +       }
>> +
>> +       /* Put in proper namespace */
>> +       sk =3D sock->sk;
>> +       sk_change_net(sk, net);
>> +
>> +       rc =3D kernel_bind(sock, (struct sockaddr *)&lisp_addr,
>> +                        sizeof(lisp_addr));
>> +       if (rc < 0) {
>> +               pr_debug("bind for UDP socket %pI4:%u (%d)\n",
>> +                        &lisp_addr.sin_addr, ntohs(lisp_addr.sin_po=
rt), rc);
>> +               sk_release_kernel(sk);
>> +               return rc;
>> +       }
>> +
>> +       *psock =3D sock;
>> +       /* Disable multicast loopback */
>> +       inet_sk(sk)->mc_loop =3D 0;
>> +
>> +       if (!(flags & LISP_F_UDP_CSUM))
>> +               sock->sk->sk_no_check_tx =3D 1;
>> +       return 0;
>> +}
> Another function that is common among UDP tunneling protocols and
> should be in common code.

In udp.c perhaps? udp_tunnel_create_v4_sock()?

Thanks!
-Chris
