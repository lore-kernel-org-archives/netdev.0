From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Create and use fib_compute_spec_dst() helper.
Date: Wed, 04 Jul 2012 17:21:07 +0200
Message-ID: <1341415267.2583.2120.camel@edumazet-glaptop>
References: <20120628.035946.1026666621448892198.davem@davemloft.net>
	 <alpine.LFD.2.00.1206282309340.1722@ja.ssi.bg>
	 <20120628.184500.114483408843364230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53597 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841Ab2GDPVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 11:21:13 -0400
Received: by eeit10 with SMTP id t10so2933635eei.19
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2012 08:21:12 -0700 (PDT)
In-Reply-To: <20120628.184500.114483408843364230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-28 at 18:45 -0700, David Miller wrote:
> From: Julian Anastasov <ja@ssi.bg>
> Date: Fri, 29 Jun 2012 02:16:25 +0300 (EEST)
> 
> > 	This is bad for looped m/b-cast: ip_mc_output calls
> > ip_dev_loopback_xmit where pkt_type is set to PACKET_LOOPBACK.
> > May be we have to check skb_dst as below.
> 
> Agreed, for many reasons the pkt_type check is bogus.
> 
> > 	It is not clear to me why ip_route_input_mc and
> > ip_route_input_slow (brd_input) call fib_validate_source()
> > with arg oif=0. How would fib_rule_match match flowi_iif
> > for such traffic then?
> > 
> > 	May be iif should be always set just like in
> > ip_route_output_slow because now we do output lookup to
> > unicast target?:
> > 
> > 	fl4.flowi4_iif = net->loopback_dev->ifindex;
> 
> Ok.  I am not brave enough to adjust what broadcast and
> multicast code do in route.c :-)
> 
> > 	Here only 0 is allowed for m/b-cast daddr, we are not
> > going to use ip_hdr(skb)->daddr, so no need to provide it:
> > 
> > 	fl4.saddr = 0;
> 
> Agreed.
> 
> > 	What about providing ip_hdr(skb)->saddr as
> > 2nd argument here (it is validated by input routing
> > to be unicast or 0.0.0.0):
>  ...
> > 	By this way we will prefer local address from the
> > same subnet as iph->saddr. Also, we should not call
> > fib_lookup if ipv4_is_zeronet(ip_hdr(skb)->saddr), we
> > should use RT_SCOPE_LINK for inet_select_addr in this case.
> > By this way we will prefer addresses with scope link for
> > target 0.0.0.0. There is such logic that uses RT_SCOPE_LINK in
> > ip_route_input_mc() and ip_route_input_slow().
> 
> Also agreed.
> 
> > 	If we use rt_flags above I'm not sure whether
> > ip_options_compile is called with valid rt_flags from the
> > bridging code.
> 
> It will not be the first time we need to fix bridging from
> sending up garbage.
> 
> Here's what I committed based upon your feedback, thanks!
> 
> ====================
> ipv4: Fix bugs in fib_compute_spec_dst().
> 
> Based upon feedback from Julian Anastasov.
> 
> 1) Use route flags to determine multicast/broadcast, not the
>    packet flags.
> 
> 2) Leave saddr unspecified in flow key.
> 
> 3) Adjust how we invoke inet_select_addr().  Pass ip_hdr(skb)->saddr as
>    second arg, and if it was zeronet use link scope.
> 
> 4) Use loopback as input interface in flow key.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/fib_frontend.c |   34 +++++++++++++++++++++-------------
>  1 file changed, 21 insertions(+), 13 deletions(-)
> 
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 63b11ca..1d13217 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -185,28 +185,36 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
>  	struct net_device *dev = skb->dev;
>  	struct in_device *in_dev;
>  	struct fib_result res;
> +	struct rtable *rt;
>  	struct flowi4 fl4;
>  	struct net *net;
> +	int scope;
>  
> -	if (skb->pkt_type != PACKET_BROADCAST &&
> -	    skb->pkt_type != PACKET_MULTICAST)
> +	rt = skb_rtable(skb);
> +	if (!(rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST)))
>  		return ip_hdr(skb)->daddr;
>  

David I tried to setup a bridge to investigate problems reported on
another thread and got immediate crash because of this patch.

Crash in fib_compute_spec_dst() if skb_rtable(skb) is NULL

brctl addbr br0
brctl addif br0 eth0
ifconfig br0 up
ip addr del 172.30.42.23/27 dev eth0
ip addr add 172.30.42.23/27 dev br0
...
<crash>

[  166.706951] Modules linked in: ip6table_filter ip6_tables ebtable_nat ebtables fuse ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT iptable_mangle iptable_filter bridge stp rt61pci crc_itu_t rt2x00pci rt2x00lib eeprom_93cx6 tg3 ixgbe mdio igb
[  166.706955] Pid: 0, comm: swapper/0 Not tainted 3.5.0-rc4+ #494
[  166.706956] Call Trace:
[  166.706965]  <IRQ>  [<ffffffff81039c5f>] warn_slowpath_common+0x7f/0xc0
[  166.706969]  [<ffffffff81039cba>] warn_slowpath_null+0x1a/0x20
[  166.706973]  [<ffffffff815baade>] fib_compute_spec_dst+0x12e/0x1c0
[  166.706979]  [<ffffffff81581d71>] ip_options_compile+0x31/0x5b0
[  166.706985]  [<ffffffff8125ddf6>] ? security_sock_rcv_skb+0x16/0x20
[  166.706991]  [<ffffffff816b8245>] ? _raw_read_unlock_bh+0x25/0x30
[  166.706996]  [<ffffffffa0119465>] ? ebt_do_table+0x6a5/0x770 [ebtables]
[  166.707004]  [<ffffffffa00b8ce5>] br_parse_ip_options+0x105/0x210 [bridge]
[  166.707010]  [<ffffffffa00b9ef8>] br_nf_pre_routing+0x398/0x6a0 [bridge]
[  166.707015]  [<ffffffff81573534>] nf_iterate+0x84/0xd0
[  166.707021]  [<ffffffffa00b3ba0>] ? br_handle_local_finish+0x50/0x50 [bridge]
[  166.707024]  [<ffffffff81573605>] nf_hook_slow+0x85/0x130
[  166.707029]  [<ffffffffa00b3ba0>] ? br_handle_local_finish+0x50/0x50 [bridge]
[  166.707035]  [<ffffffff816201c7>] ? packet_rcv_spkt+0x47/0x190
[  166.707041]  [<ffffffffa00b3f40>] br_handle_frame+0x1c0/0x260 [bridge]
[  166.707044]  [<ffffffff816201c7>] ? packet_rcv_spkt+0x47/0x190
[  166.707050]  [<ffffffffa00b3d80>] ? br_handle_frame_finish+0x1e0/0x1e0 [bridge]
[  166.707054]  [<ffffffff8154538b>] __netif_receive_skb+0x1bb/0x5f0
[  166.707058]  [<ffffffff81545955>] netif_receive_skb+0x25/0xc0
[  166.707061]  [<ffffffff81545ced>] ? dev_gro_receive+0x1dd/0x2f0
[  166.707065]  [<ffffffff81546450>] napi_skb_finish+0x70/0xa0
[  166.707068]  [<ffffffff815483e5>] napi_gro_receive+0xf5/0x140
[  166.707075]  [<ffffffffa00720f2>] tg3_poll_work+0xc42/0xde0 [tg3]
[  166.707080]  [<ffffffff816647c7>] ? ieee80211_rx+0x357/0x890
[  166.707086]  [<ffffffffa007976c>] tg3_poll+0x8c/0x3c0 [tg3]
[  166.707091]  [<ffffffffa009093f>] ? rt2x00lib_rxdone+0x28f/0x450 [rt2x00lib]
[  166.707095]  [<ffffffff81547a2b>] net_rx_action+0x12b/0x250
