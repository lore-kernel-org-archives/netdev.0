From: Eduardo Panisset <eduardo.panisset@gmail.com>
Subject: [BUG] XFRM is not updating RTAX_ADVMSS metric
Date: Mon, 22 Mar 2010 22:35:28 -0300
Message-ID: <b7b22e81003221835j7e8a1609laa9a8d1dac4e1341@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:63436 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755845Ab0CWBfc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 21:35:32 -0400
Received: by wwe15 with SMTP id 15so3761432wwe.19
        for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 18:35:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I have been testing DSMIPv6 code which uses all kind of advanced
features of XFRM framework and I believe I have found a bug related to
update RTAX_ADVMSS route metric.
The XFRM code on net/xfrm/xfrm_policy.c by its functions
xfrm_init_pmtu and xfrm_bundle_ok updates RTAX_MTU route caching
metric however I believe it must update RTAX_ADVMSS as this later is
used by tcp connect function for adverting the MSS value on SYN
messages.

As MSS is not being updated by XFRM the TCP SYN messages (e.g.
originated from a internet browser)=A0 is erroneously informing its MSS
(without taking into account the overhead added to IP packet size by
XFRM transformations).=A0 One result of that is the browser gets
"frozen" after starts a TCP connection because TCP messages sent by
TCP server will never get to it (TCP server is sending too large
segments to browser).

Below I describe the changes I have done (on xfrm_init_pmtu and
xfrm_bundle_ok) and that seem to fix this problem:

xfrm_init_pmtu:
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 .
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 .
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 .

=A0=A0=A0 =A0=A0=A0 dst->metrics[RTAX_MTU-1] =3D pmtu; // original code=
, below my changes

=A0=A0=A0 =A0=A0=A0 if (dst->xfrm->props.mode =3D=3D XFRM_MODE_TUNNEL)
=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 switch (dst->xfrm->props=
=2Efamily)
=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 {
=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 case AF_INET:
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 dst->metrics[RTAX_ADVMSS-1=
] =3D max_t(unsigned int,
pmtu - sizeof(struct iphdr) - sizeof(struct tcphdr), 256);
=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 break;

=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 case AF_INET6:
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 dst->metrics[RTAX_ADVMSS-1=
] =3D max_t(unsigned int,
pmtu - sizeof(struct ipv6hdr) - sizeof(struct tcphdr),
=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 d=
ev_net(dst->dev)->ipv6.
sysctl.ip6_rt_min_advmss);
=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 break;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }

xfrm_bundle_ok:

=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 .
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 .
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 .

=A0=A0=A0 =A0=A0=A0 dst->metrics[RTAX_MTU-1] =3D mtu; // original code,=
 below my changes

=A0=A0=A0=A0=A0=A0=A0 if (dst->xfrm->props.mode =3D=3D XFRM_MODE_TUNNEL=
)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 switch (dst->xfrm->props.=
family)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 case AF_INET:
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 d=
st->metrics[RTAX_ADVMSS-1] =3D max_t(unsigned
int, mtu - sizeof(struct iphdr) - sizeof(struct tcphdr), 256);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 break;

=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 case AF_INET6:
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 d=
st->metrics[RTAX_ADVMSS-1] =3D max_t(unsigned
int, mtu - sizeof(struct ipv6hdr) - sizeof(struct tcphdr),

dev_net(dst->dev)->ipv6.sysctl.ip6_rt_min_advmss);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 break;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }

Regards,
Eduardo Panisset.
