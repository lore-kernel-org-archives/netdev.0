From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Regression in skge that started around acb42a3 (so past
 v3.3-rc1)
Date: Mon, 30 Jan 2012 08:38:43 -0800
Message-ID: <20120130083843.160ffe5e@nehalam.linuxnetplumber.net>
References: <20120130155816.GA1400@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34375 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753272Ab2A3Qir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jan 2012 11:38:47 -0500
In-Reply-To: <20120130155816.GA1400@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jan 2012 10:58:16 -0500
Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote:

> I hadn't done any git bisection yet, but with acb42a3 I started getting this:
> 
> (and only on i686 - x86_64 does not show these):
> 
> (This is with Xen, the other one is without)
> [   28.602121] eth2: no IPv6 routers present
> [   70.457712] eth2: hw csum failure.
> [   70.458695] Pid: 0, comm: swapper/0 Not tainted 3.3.0-rc1-00287-gacb42a3 #1
> [   70.
> [   70.458695]  [<c140942b>] __skb_checksum_complete+0xb/0x10
> [   70.458695]  [<c148e3b0>] nf_ip_checksum+0x60/0x120
> [   70.458695]  [<c143ee6b>] udp_error+0xbb/0x1f0
> [   70.458695]  [<c103c1e4>] ? check_events+0x8/0xc
> [   70.458695]  [<c103c1db>] ? xen_restore_fl_direct_reloc+0x4/0x4
> [   70.458695]  [<c11497ee>] ? put_cpu_partial+0x9e/0xb0
> [   70.458695]  [<c143edb0>] ? udp_pkt_to_tuple+0x60/0x60
> [   70.458695]  [<c143a2b6>] nf_conntrack_in+0xc6/0x5c0
> [   70.458695]  [<c14751f8>] ? __udp4_lib_rcv+0x428/0x630
> [   70.458695]  [<c1149dd0>] ? kfree+0xf0/0x120
> [   70.458695]  [<c1405b60>] ? skb_release_data+0x90/0xb0
> [   70.458695]  [<c1405b60>] ? skb_release_data+0x90/0xb0
> [   70.458695]  [<c14057d8>] ? __kfree_skb+0x38/0x90
> [   70.458695]  [<c144d510>] ? inet_del_protocol+0x30/0x30
> [   70.458695]  [<c148f41e>] ipv4_conntrack_in+0x1e/0x30
> [   70.458695]  [<c14360d3>] nf_iterate+0x63/0x90
> [   70.458695]  [<c144d510>] ? inet_del_protocol+0x30/0x30
> [   70.458695]  [<c1436292>] nf_hook_slow+0x62/0x140
> [   70.458695]  [<c144d510>] ? inet_del_protocol+0x30/0x30
> [   70.458695]  [<c144dbb5>] ip_rcv+0x235/0x310
> [   70.458695]  [<c144d510>] ? inet_del_protocol+0x30/0x30
> [   70.458695]  [<c1412c36>] __netif_receive_skb+0x1d6/0x550
> [   70.458695]  [<c147c6a9>] ? inet_gro_receive+0x59/0x1f0
> [   70.458695]  [<c1413312>] netif_receive_skb+0x22/0x90
> [   70.458695]  [<c1413487>] napi_skb_finish+0x37/0x50
> [   70.458695]  [<c14139e3>] napi_gro_receive+0xe3/0xf0
> [   70.458695]  [<c12ff4c0>] ? xen_swiotlb_map_sg+0x20/0x20
> [   70.458695]  [<c12ff4d9>] ? xen_swiotlb_unmap_page+0x19/0x20
> [   70.458695]  [<f7983d6c>] skge_poll+0x34c/0x6f4 [skge]
> [   70.458695]  [<c141431a>] net_rx_action+0xfa/0x2a0
> [   70.458695]  [<c107cecf>] __do_softirq+0x9f/0x210
> [   70.458695]  [<c107ce30>] ? irq_exit+0xd0/0xd0
> [   70.458695]  <IRQ>  [<c107ce15>] ? irq_exit+0xb5/0xd0

The skge driver uses hardware receive checksum where it computes the sum
of the packet (but does not check it). This kind of problem happens when some
part of the call chain above it updates the packet but does not update the checksum.
A fix like the following is presumably needed for some part of this path.

commit fa2da8cdae1dd64f78fc915ca1d1a4a93c71e7cb
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Tue Nov 15 08:09:14 2011 +0000

    bridge: correct IPv6 checksum after pull
    
    Bridge multicast snooping of ICMPv6 would incorrectly report a checksum prob
    when used with Ethernet devices like sky2 that use CHECKSUM_COMPLETE.
    When bytes are removed from skb, the computed checksum needs to be adjusted.
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Tested-by: Martin Volf <martin.volf.42@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
