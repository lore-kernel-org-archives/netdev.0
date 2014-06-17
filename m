From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH V2 net-next] LISP: Locator/Identifier Separation Protocol
Date: Tue, 17 Jun 2014 13:52:46 -0700
Message-ID: <CA+mtBx9-iJjuCrL2J+jzcnztvVJsFjccs_FKO1z33HRkSw2PRg@mail.gmail.com>
References: <4D3092DF-BB04-4C50-88B9-EBBA349C7B17@logicalelegance.com>
	<CA+mtBx9OdgWad6WJvNoUWreoyef9sd0AbHAsNWTSHaD1z=Tj8A@mail.gmail.com>
	<5F3B797F-9DE9-43AC-91E1-C11B51DB2B2C@logicalelegance.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Vina Ermagan (vermagan)" <vermagan@cisco.com>,
	"Lorand Jakab -X (lojakab - M SQUARED CONSULTING INC. at Cisco)"
	<lojakab@cisco.com>
To: Christopher White <chris@logicalelegance.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:55910 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965065AbaFQUwr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 16:52:47 -0400
Received: by mail-ie0-f175.google.com with SMTP id tp5so6898999ieb.34
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 13:52:47 -0700 (PDT)
In-Reply-To: <5F3B797F-9DE9-43AC-91E1-C11B51DB2B2C@logicalelegance.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2014 at 1:41 PM, Christopher White
<chris@logicalelegance.com> wrote:
> Thanks Tom, some quick questions as I wrap this up=E2=80=A6.
>
> On Jun 5, 2014, at 3:12 PM, Tom Herbert <therbert@google.com> wrote:
>
>>
>>> +static inline struct rtable *find_route(struct net *net,
>>> +                                       __be32 *saddr, __be32 daddr=
,
>>> +                                       u8 ipproto, u8 tos, u32 skb=
_mark)
>>> +{
>>> +       struct rtable *rt;
>>> +
>>> +       /* Tunnel configuration keeps DSCP part of TOS bits, But Li=
nux
>>> +        * router expect RT_TOS bits only.
>>> +        */
>>> +       struct flowi4 fl =3D { .daddr             =3D daddr,
>>> +                            .saddr             =3D *saddr,
>>> +                            .flowi4_tos        =3D RT_TOS(tos),
>>> +                            .flowi4_mark       =3D skb_mark,
>>> +                            .flowi4_proto      =3D ipproto };
>>> +
>>> +       rt =3D ip_route_output_key(net, &fl);
>>> +       *saddr =3D fl.saddr;
>>> +       return rt;
>>> +}
>>> +
>> Looks like a function that should be in common header file?
>>
>
> I=E2=80=99m not certain where the right place would be for this. A ne=
w file perhaps?
>
It should be in include/net/route.h. There is already ip_route_output
and ip_route_output_gre which are very similar to this.

>>
>>> +static int create_v4_sock(struct net *net, __be16 port, struct soc=
ket **psock,
>>> +                         u32 flags)
>>> +{
>>> +       struct sock *sk;
>>> +       struct socket *sock;
>>> +       struct sockaddr_in lisp_addr =3D {
>>> +               .sin_family             =3D AF_INET,
>>> +               .sin_addr.s_addr        =3D htonl(INADDR_ANY),
>>> +               .sin_port               =3D port,
>>> +       };
>>> +       int rc;
>>> +
>>> +       /* Create UDP socket for encapsulation receive. */
>>> +       rc =3D sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &=
sock);
>>> +       if (rc < 0) {
>>> +               pr_debug("UDP socket create failed\n");
>>> +               return rc;
>>> +       }
>>> +
>>> +       /* Put in proper namespace */
>>> +       sk =3D sock->sk;
>>> +       sk_change_net(sk, net);
>>> +
>>> +       rc =3D kernel_bind(sock, (struct sockaddr *)&lisp_addr,
>>> +                        sizeof(lisp_addr));
>>> +       if (rc < 0) {
>>> +               pr_debug("bind for UDP socket %pI4:%u (%d)\n",
>>> +                        &lisp_addr.sin_addr, ntohs(lisp_addr.sin_p=
ort), rc);
>>> +               sk_release_kernel(sk);
>>> +               return rc;
>>> +       }
>>> +
>>> +       *psock =3D sock;
>>> +       /* Disable multicast loopback */
>>> +       inet_sk(sk)->mc_loop =3D 0;
>>> +
>>> +       if (!(flags & LISP_F_UDP_CSUM))
>>> +               sock->sk->sk_no_check_tx =3D 1;
>>> +       return 0;
>>> +}
>> Another function that is common among UDP tunneling protocols and
>> should be in common code.
>
> In udp.c perhaps? udp_tunnel_create_v4_sock()?
>
It might make sense for this to udp_offload.c (along with
skb_udp_tunnel_segment).

> Thanks!
> -Chris
>
