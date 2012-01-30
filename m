From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression in skge that started around acb42a3 (so past
 v3.3-rc1)
Date: Mon, 30 Jan 2012 18:22:28 +0100
Message-ID: <1327944148.3303.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120130155816.GA1400@phenom.dumpdata.com>
	 <20120130083843.160ffe5e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120130083843.160ffe5e@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 30 janvier 2012 =C3=A0 08:38 -0800, Stephen Hemminger a =C3=A9=
crit :
> On Mon, 30 Jan 2012 10:58:16 -0500
> Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote:
>=20
> > I hadn't done any git bisection yet, but with acb42a3 I started get=
ting this:
> >=20
> > (and only on i686 - x86_64 does not show these):
> >=20
> > (This is with Xen, the other one is without)
> > [   28.602121] eth2: no IPv6 routers present
> > [   70.457712] eth2: hw csum failure.
> > [   70.458695] Pid: 0, comm: swapper/0 Not tainted 3.3.0-rc1-00287-=
gacb42a3 #1
> > [   70.
> > [   70.458695]  [<c140942b>] __skb_checksum_complete+0xb/0x10
> > [   70.458695]  [<c148e3b0>] nf_ip_checksum+0x60/0x120
> > [   70.458695]  [<c143ee6b>] udp_error+0xbb/0x1f0
> > [   70.458695]  [<c103c1e4>] ? check_events+0x8/0xc
> > [   70.458695]  [<c103c1db>] ? xen_restore_fl_direct_reloc+0x4/0x4
> > [   70.458695]  [<c11497ee>] ? put_cpu_partial+0x9e/0xb0
> > [   70.458695]  [<c143edb0>] ? udp_pkt_to_tuple+0x60/0x60
> > [   70.458695]  [<c143a2b6>] nf_conntrack_in+0xc6/0x5c0
> > [   70.458695]  [<c14751f8>] ? __udp4_lib_rcv+0x428/0x630
> > [   70.458695]  [<c1149dd0>] ? kfree+0xf0/0x120
> > [   70.458695]  [<c1405b60>] ? skb_release_data+0x90/0xb0
> > [   70.458695]  [<c1405b60>] ? skb_release_data+0x90/0xb0
> > [   70.458695]  [<c14057d8>] ? __kfree_skb+0x38/0x90
> > [   70.458695]  [<c144d510>] ? inet_del_protocol+0x30/0x30
> > [   70.458695]  [<c148f41e>] ipv4_conntrack_in+0x1e/0x30
> > [   70.458695]  [<c14360d3>] nf_iterate+0x63/0x90
> > [   70.458695]  [<c144d510>] ? inet_del_protocol+0x30/0x30
> > [   70.458695]  [<c1436292>] nf_hook_slow+0x62/0x140
> > [   70.458695]  [<c144d510>] ? inet_del_protocol+0x30/0x30
> > [   70.458695]  [<c144dbb5>] ip_rcv+0x235/0x310
> > [   70.458695]  [<c144d510>] ? inet_del_protocol+0x30/0x30
> > [   70.458695]  [<c1412c36>] __netif_receive_skb+0x1d6/0x550
> > [   70.458695]  [<c147c6a9>] ? inet_gro_receive+0x59/0x1f0
> > [   70.458695]  [<c1413312>] netif_receive_skb+0x22/0x90
> > [   70.458695]  [<c1413487>] napi_skb_finish+0x37/0x50
> > [   70.458695]  [<c14139e3>] napi_gro_receive+0xe3/0xf0
> > [   70.458695]  [<c12ff4c0>] ? xen_swiotlb_map_sg+0x20/0x20
> > [   70.458695]  [<c12ff4d9>] ? xen_swiotlb_unmap_page+0x19/0x20
> > [   70.458695]  [<f7983d6c>] skge_poll+0x34c/0x6f4 [skge]
> > [   70.458695]  [<c141431a>] net_rx_action+0xfa/0x2a0
> > [   70.458695]  [<c107cecf>] __do_softirq+0x9f/0x210
> > [   70.458695]  [<c107ce30>] ? irq_exit+0xd0/0xd0
> > [   70.458695]  <IRQ>  [<c107ce15>] ? irq_exit+0xb5/0xd0
>=20
> The skge driver uses hardware receive checksum where it computes the =
sum
> of the packet (but does not check it). This kind of problem happens w=
hen some
> part of the call chain above it updates the packet but does not updat=
e the checksum.
> A fix like the following is presumably needed for some part of this p=
ath.
>=20
> commit fa2da8cdae1dd64f78fc915ca1d1a4a93c71e7cb
> Author: stephen hemminger <shemminger@vyatta.com>
> Date:   Tue Nov 15 08:09:14 2011 +0000
>=20
>     bridge: correct IPv6 checksum after pull
>    =20
>     Bridge multicast snooping of ICMPv6 would incorrectly report a ch=
ecksum prob
>     when used with Ethernet devices like sky2 that use CHECKSUM_COMPL=
ETE.
>     When bytes are removed from skb, the computed checksum needs to b=
e adjusted.
>    =20
>     Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>     Tested-by: Martin Volf <martin.volf.42@gmail.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
>=20
> --

I wonder if we receive an skb with extra padding, and we lack a
pskb_trim_rcsum() in udp_error() (net/netfilter/nf_conntrack_proto_udp.=
c
)
