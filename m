From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][IPV6][NDISC] unify ipv6 output routine
Date: Sat, 07 Feb 2004 13:14:55 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040207.131455.27570445.yoshfuji@linux-ipv6.org>
References: <200402070232.33771.kazunori@miyazawa.org>
	<4023D6FB.9010909@kolumbus.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: kazunori@miyazawa.org, davem@redhat.com, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mika.penttila@kolumbus.fi
In-Reply-To: <4023D6FB.9010909@kolumbus.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <4023D6FB.9010909@kolumbus.fi> (at Fri, 06 Feb 2004 20:03:39 +=
0200), Mika Penttil=E4 <mika.penttila@kolumbus.fi> says:

> Kazunori Miyazawa wrote:
:
> >Yoshifuji-san and I send the patch which unifies IPv6 output routine a=
nd remove
> >RTF_NDISC again. It resolves an issue of IPv6 IPsec with neighbor disc=
overy
> >without a flag.
:
> You break multicast replies, see what ndisc_build_ll_hdr() does...

It doesn't "break."=20
The ip6_output2() resolves and inserts link-layer address appropriately.
If it did, we would have noticed (by conformance test or even by
usual operation). ;-)

BTW, Miyazawa-san, we do not need ndisc_build_ll_hdr() anymore.
Compiler warns it. Please remove it. Thanks.


Here's the description:

dst->neighbour owns the neighbour entry for the destination.=20

For multicast, we know its link-layer address=20
(filled in ndisc_constructor()).
For unicast, the link-layer address may be unknown.

ip6_output2() will call ip6_output_finish() and
it tries inserting the link-layer header.

The destination link-layer address is used if it is known (*).
(Note: you remember that we know link-layer address for multicast.)

If the link-layer address is not known or invalid,=20
we queue the packet and resolve the link-layer address for the destinatio=
n.
Here, since the neighbour entry is "invalid," *multicast* NS is sent.=20
The NS packet passes similar path.=20
We know the destination for the NS is multicast and=20
what the link-layer address is, and the packet is sent via (*).
We will send the queued packet when we got NA from that node.

Real story:
A node may send NS without source link-layer address option=20
while we do not know the link-layer address for the source of the NS.
We need to send NA in reply to this NS.
Original code cannot handle this case.  The new code path can.

--=20
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
