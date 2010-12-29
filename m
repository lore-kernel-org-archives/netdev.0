From: Albert Pretorius <albertpretorius@yahoo.co.uk>
Subject: Re: IPV6 loopback bound socket succeeds connecting to remote host
Date: Wed, 29 Dec 2010 16:53:41 +0000 (GMT)
Message-ID: <650920.34739.qm@web29014.mail.ird.yahoo.com>
References: <4D11A370.9060901@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, pekkas@netcore.fi,
	jmorris@namei.org
To: David Miller <davem@davemloft.net>,
	Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm2-vm0.bullet.mail.ird.yahoo.com ([77.238.189.199]:23646 "HELO
	nm2-vm0.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753508Ab0L2Qxn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Dec 2010 11:53:43 -0500
In-Reply-To: <4D11A370.9060901@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
I tested this on 2.6.37-rc8 but unfortunately that does not address the=
 problem. I suspect the ip_forward.c change only addresses the routing =
of data when /proc/sys/net/ipv6/conf/all/forwarding is enabled.

The original patch is required to prevent the kernel from sending a pac=
ket on the network with a source address of loopback. The kernel should=
 not do that regardless of whether the packet will be dropped by the ne=
twork (not routed).

Also from an application point of view I believe the behaviour should b=
e the same for IPV4 and IPV6 when binding to loopback and connecting to=
 remote address (i.e. EINVAL).

A further change is required to avoid the kernel acting on the receptio=
n of a packet with source address of loopback. Currently it will genera=
te an ICMP6 dest unreachable, or pass the packet to an application list=
ening on that port.

This patch (which includes the previous) seems to addresses the above p=
roblems:

---8<---
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index a83e920..a374100 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -108,7 +108,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device=
 *dev, struct packet_type *pt
     * of loopback must be dropped.
     */
    if (!(dev->flags & IFF_LOOPBACK) &&
-       ipv6_addr_loopback(&hdr->daddr))
+       (ipv6_addr_loopback(&hdr->daddr) | ipv6_addr_loopback(&hdr->sad=
dr)))
        goto err;

    skb->transport_header =3D skb->network_header + sizeof(*hdr);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 94b5bf1..0257998 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -919,6 +919,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 {
    int err;
    struct net *net =3D sock_net(sk);
+   struct net_device *dev_out;

    if (*dst =3D=3D NULL)
        *dst =3D ip6_route_output(net, sk, fl);
@@ -926,6 +927,13 @@ static int ip6_dst_lookup_tail(struct sock *sk,
    if ((err =3D (*dst)->error))
        goto out_err_release;

+   dev_out =3D ip6_dst_idev(*dst)->dev;
+   if (dev_out && ipv6_addr_loopback(&fl->fl6_src) &&
+       !(dev_out->flags & IFF_LOOPBACK)) {
+       err =3D -EINVAL;
+       goto out_err_release;
+   }
+
    if (ipv6_addr_any(&fl->fl6_src)) {
        err =3D ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
                     &fl->fl6_dst,
--->8---

best regards,
Albert Pretorius


--- On Wed, 22/12/10, Shan Wei <shanwei@cn.fujitsu.com> wrote:

> From: Shan Wei <shanwei@cn.fujitsu.com>
> Subject: Re: IPV6 loopback bound socket succeeds connecting to remote=
 host
> To: "David Miller" <davem@davemloft.net>
> Cc: albertpretorius@yahoo.co.uk, netdev@vger.kernel.org, yoshfuji@lin=
ux-ipv6.org, pekkas@netcore.fi, jmorris@namei.org
> Date: Wednesday, 22 December, 2010, 7:06
> David Miller wrote, at 12/20/2010
> 02:43 PM:
> > From: Shan Wei <shanwei@cn.fujitsu.com>
> > Date: Mon, 20 Dec 2010 14:31:28 +0800
> >=20
> >> David Miller wrote, at 12/17/2010 04:18 AM:
> >>> Your approach will only modify socket based
> route handling, it will
> >>> not handle the ipv6 forwarding case which as
> per the quoted RFC
> >>> sections must be handled too.
> >>
> >> For the ipv6 forwarding case, we have done the
> check in ip6_forward().
> >>
> >>=C2=A0 493=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0
> =C2=A0 =C2=A0=C2=A0=C2=A0int addrtype =3D
> ipv6_addr_type(&hdr->saddr);
> >>=C2=A0 494=20
> >>=C2=A0 495=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0
> =C2=A0 =C2=A0=C2=A0=C2=A0/* This check is security critical.
> */
> >>=C2=A0 496=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0
> =C2=A0 =C2=A0=C2=A0=C2=A0if (addrtype =3D=3D IPV6_ADDR_ANY ||
> >>=C2=A0 497=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0=C2=A0addrtype &
> (IPV6_ADDR_MULTICAST | IPV6_ADDR_LOOPBACK))
> >>=C2=A0 498=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0=C2=A0goto
> error;
> >=20
> > Indeed, thanks for pointing this out.
>=20
> Notice that the state in patchwork is =E2=80=9CChanges
> Requested=E2=80=9D, what should i do=20
> now?=C2=A0 I have no idead which part of this patch should
> be changed.
>=20
> --=20
> Best Regards
> -----
> Shan Wei
>=20


     =20
