From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 12:43:27 +0800
Message-ID: <CABa6K_Ge-Y1ne3iBcN1HSRN+G4bW6hSAHYFGKuA5QKW6CT3grQ@mail.gmail.com>
References: <20120618.194016.2282814982594761206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:38388 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab2FSEns convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:43:48 -0400
Received: by qcro28 with SMTP id o28so3292128qcr.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 21:43:48 -0700 (PDT)
In-Reply-To: <20120618.194016.2282814982594761206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 19, 2012 at 10:40 AM, David Miller <davem@davemloft.net> wr=
ote:
> @@ -324,19 +324,34 @@ static int ip_rcv_finish(struct sk_buff *skb)
> =A0 =A0 =A0 =A0 * =A0 =A0 =A0how the packet travels inside Linux netw=
orking.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (skb_dst(skb) =3D=3D NULL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int err =3D ip_route_input_noref(skb, i=
ph->daddr, iph->saddr,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0iph->tos, skb->dev);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(err)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err =3D=3D -EHOSTUN=
REACH)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IP_INC_=
STATS_BH(dev_net(skb->dev),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 IPSTATS_MIB_INADDRERRORS);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (err =3D=3D -EN=
ETUNREACH)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IP_INC_=
STATS_BH(dev_net(skb->dev),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 IPSTATS_MIB_INNOROUTES);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (err =3D=3D -EX=
DEV)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NET_INC=
_STATS_BH(dev_net(skb->dev),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0LINUX_MIB_IPRPFILTER);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct net_protocol *ipprot;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int protocol =3D iph->protocol;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int hash, err;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash =3D protocol & (MAX_INET_PROTOS - =
1);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ipprot =3D rcu_dereference(inet_protos[=
hash]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOENT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ipprot && ipprot->early_demux)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ipprot->early_d=
emux(skb);

I am afraid that this lookup with hurt the performance of the
forwarding path. A knob?

If this approach is acceptable, maybe we can use sockets to do finer RF=
S.

Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
