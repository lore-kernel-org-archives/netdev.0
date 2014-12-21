From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Bug: mv643xxx fails with highmem
Date: Sun, 21 Dec 2014 16:51:06 +0000
Message-ID: <20141221165106.GN11285@n2100.arm.linux.org.uk>
References: <20141211194920.GR11285@n2100.arm.linux.org.uk>
 <20141211.151055.817876561546126576.davem@davemloft.net>
 <20141211202507.GS11285@n2100.arm.linux.org.uk>
 <5491F342.5090301@free-electrons.com>
 <20141218000357.GX11285@n2100.arm.linux.org.uk>
 <5492D2EF.6050807@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nimrod Andy <B38611@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	netdev@vger.kernel.org, fugang.duan@freescale.com
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:44195 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751268AbaLUQvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 11:51:32 -0500
Content-Disposition: inline
In-Reply-To: <5492D2EF.6050807@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2014 at 10:13:19AM -0300, Ezequiel Garcia wrote:
> On 12/17/2014 09:03 PM, Russell King - ARM Linux wrote:
> > However, exactly how it occurs, I don't know.  My understanding from
> > reading the various feature flags was that NETIF_F_HIGHDMA was required
> > for highmem (see illegal_highdma()) so as this isn't set, we shouldn't
> > be seeing highmem fragments - which is why I asked the question in my
> > original email.
> > 
> > If you want me to revert my fix above, and reproduce again, I can
> > certainly try that - or put a WARN_ON_ONCE(PageHighMem(this_frag->page.p))
> > in there, but I seem to remember that it wasn't particularly useful as
> > the backtrace didn't show where the memory actually came from.
> > 
> 
> No, that's OK. Thanks a lot for all the details. I'll try to come up with a
> fix soon.

Well, I decided to add the WARN_ON_ONCE() and re-test.  This I provoked
by touching etna_viv/src/etnaviv/etna_bo.c, and re-running make (etnaviv
is on a shared NFS mount.)

WARNING: CPU: 0 PID: 0 at /home/rmk/git/linux-cubox/drivers/net/ethernet/marvell/mv643xx_eth.c:884 mv643xx_eth_xmit+0x850/0x8dc()
Modules linked in: bnep rfcomm bluetooth nfsd exportfs ext3 jbd ext2 etnaviv(C)
snd_soc_spdif_tx orion_wdt snd_soc_kirkwood dove vmeta bmm_dmabuf hwmon snd_soc_kirkwood_spdif
CPU: 0 PID: 0 Comm: swapper Tainted: G         C     3.18.0+ #1056
Backtrace:
[<c0011f54>] (dump_backtrace) from [<c0012228>] (show_stack+0x18/0x1c)
 r6:00000374 r5:00000009 r4:00000000 r3:00000000
[<c0012210>] (show_stack) from [<c04992d8>] (dump_stack+0x20/0x28)
[<c04992b8>] (dump_stack) from [<c0050be4>] (warn_slowpath_common+0x6c/0x8c)
[<c0050b78>] (warn_slowpath_common) from [<c0050c28>] (warn_slowpath_null+0x24/0x2c)
 r8:c064ea80 r7:e8a5d880 r6:d00d0d70 r5:e614877c r4:00000001
[<c0050c04>] (warn_slowpath_null) from [<c02fee9c>] (mv643xx_eth_xmit+0x850/0x8dc)
[<c02fe64c>] (mv643xx_eth_xmit) from [<c03b94fc>] (dev_hard_start_xmit+0x19c/0x328)
 r10:c0648054 r9:d0261f60 r8:e6148000 r7:d00ec1c0 r6:c0648040 r5:e623ec00
 r4:d013c580
[<c03b9360>] (dev_hard_start_xmit) from [<c03d2728>] (sch_direct_xmit+0x148/0x24c)
 r10:e623ec00 r9:e63a4580 r8:e6148000 r7:e61f4e00 r6:c063e000 r5:00000000
 r4:00000000
[<c03d25e0>] (sch_direct_xmit) from [<c03b985c>] (__dev_queue_xmit+0x1d4/0x590)
 r10:e623ec00 r9:00000000 r8:00000000 r7:e6148000 r6:c063e000 r5:e61f4e00
 r4:d0163e70
[<c03b9688>] (__dev_queue_xmit) from [<c03b9c40>] (dev_queue_xmit+0x14/0x18)
 r10:c063e000 r9:00000000 r8:00000000 r7:d0163e70 r6:0000000e r5:d00caa00
 r4:d00caa94
[<c03b9c2c>] (dev_queue_xmit) from [<c043c58c>] (ip6_finish_output2+0x1a0/0x524)[<c043c3ec>] (ip6_finish_output2) from [<c043e008>] (ip6_output+0xb4/0x174)
 r10:d0163e70 r9:c063e000 r8:c066f678 r7:00000000 r6:d0163e70 r5:00000000
 r4:000021c0
[<c043df54>] (ip6_output) from [<c043c114>] (ip6_xmit+0x278/0x550)
 r7:00000000 r6:00000001 r5:00000000 r4:001463b6
[<c043be9c>] (ip6_xmit) from [<c0466fbc>] (inet6_csk_xmit+0x74/0xa8)
 r10:d0163e70 r9:00000020 r8:d00d2080 r7:d00d25a0 r6:d0163e70 r5:00000000
 r4:d00d2080
[<c0466f48>] (inet6_csk_xmit) from [<c03f87ac>] (tcp_transmit_skb+0x494/0x990)
 r7:e6094100 r6:c0658910 r5:00000020 r4:ffff5165
[<c03f8318>] (tcp_transmit_skb) from [<c03f9970>] (tcp_write_xmit+0x138/0xc1c)
 r10:00002178 r9:00000000 r8:00002ca0 r7:00000006 r6:00000594 r5:d0163dc0
 r4:d00d2080
[<c03f9838>] (tcp_write_xmit) from [<c03fa4d4>] (__tcp_push_pending_frames+0x38/0x98)
 r10:00000002 r9:00000078 r8:d03d7600 r7:d00d25a0 r6:d02841c0 r5:e448f778
 r4:d00d2080
[<c03fa49c>] (__tcp_push_pending_frames) from [<c03f567c>] (tcp_rcv_established+0x15c/0x600)
 r4:d00d2080
[<c03f5520>] (tcp_rcv_established) from [<c0461918>] (tcp_v6_do_rcv+0x2bc/0x46c) r10:00000002 r9:00000078 r8:d03d7600 r7:d00d25a0 r6:00000000 r5:d00d2080
 r4:d02841c0
[<c046165c>] (tcp_v6_do_rcv) from [<c0462828>] (tcp_v6_rcv+0x7f8/0x810)
 r8:00000000 r7:d00d2080 r6:c063e000 r5:c066f678 r4:d02841c0
[<c0462030>] (tcp_v6_rcv) from [<c043e750>] (ip6_input+0xec/0x424)
 r10:c066f678 r9:c052a75c r8:d02841c0 r7:c0649720 r6:00000006 r5:e6168400
 r4:00000006
[<c043e664>] (ip6_input) from [<c043e100>] (ip6_rcv_finish+0x38/0xa4)
 r10:e6168400 r9:e6148000 r8:d02841c0 r7:00000001 r6:c066f678 r5:00000000
 r4:d02841c0 r3:c043e664
[<c043e0c8>] (ip6_rcv_finish) from [<c043e494>] (ipv6_rcv+0x328/0x4f8)
 r4:e448f750 r3:00000000
[<c043e16c>] (ipv6_rcv) from [<c03b43c0>] (__netif_receive_skb_core+0x2fc/0x5d0) r10:d02841c0 r9:c0649050 r8:c06480c4 r7:e6148000 r6:00000000 r5:0000dd86
 r4:c043e16c
[<c03b40c4>] (__netif_receive_skb_core) from [<c03b6bac>] (__netif_receive_skb+0x2c/0x88)
 r10:00000001 r9:d02841c0 r8:e61484e0 r7:e8a5b310 r6:2cc7fffe r5:00000003
 r4:d02841c0
[<c03b6b80>] (__netif_receive_skb) from [<c03b6d30>] (netif_receive_skb_internal+0x2c/0x68)
 r5:00000003 r4:d02841c0
[<c03b6d04>] (netif_receive_skb_internal) from [<c03b7690>] (napi_gro_receive+0x7c/0xa8)
 r4:d02841c0
[<c03b7614>] (napi_gro_receive) from [<c0300738>] (mv643xx_eth_poll+0x58c/0x6ac) r5:e6148000 r4:e614864c
[<c03001ac>] (mv643xx_eth_poll) from [<c03b7370>] (net_rx_action+0xa4/0x1a8)
 r10:c0658910 r9:c0675940 r8:c0675940 r7:0000012c r6:00000040 r5:e61485c0
 r4:c03001ac
[<c03b72cc>] (net_rx_action) from [<c00533c0>] (__do_softirq+0xf0/0x214)
 r10:00000003 r9:00000101 r8:c063e000 r7:00000003 r6:c0677480 r5:c067748c
 r4:00000000
[<c00532d0>] (__do_softirq) from [<c005377c>] (irq_exit+0xac/0xfc)
 r10:e6ffcd40 r9:560f5815 r8:00000000 r7:0000001e r6:00000000 r5:00000000
 r4:c063e000
[<c00536d0>] (irq_exit) from [<c0085330>] (__handle_domain_irq+0x7c/0xc0)
 r4:c065ef68 r3:00010001
[<c00852b4>] (__handle_domain_irq) from [<c000fb0c>] (handle_IRQ+0x24/0x28)
 r8:00000001 r7:c063ff74 r6:ffffffff r5:600f0013 r4:c0077408 r3:c063ff40
[<c000fae8>] (handle_IRQ) from [<c0008600>] (dove_legacy_handle_irq+0x34/0x5c)
[<c00085cc>] (dove_legacy_handle_irq) from [<c0012ce0>] (__irq_svc+0x40/0x74)
Exception stack(0xc063ff40 to 0xc063ff88)
ff40: 00000000 0001114c c0658324 c001d940 c063e000 c06470c8 c06759fe c06759fe
ff60: 00000001 560f5815 e6ffcd40 c063ff9c c063ff88 c063ff88 c000fc38 c0077408
ff80: 600f0013 ffffffff
[<c0077354>] (cpu_startup_entry) from [<c04952c4>] (rest_init+0x78/0x90)
 r7:ffffffff r3:c04b0554
[<c049524c>] (rest_init) from [<c0609ca8>] (start_kernel+0x34c/0x3b0)
 r4:c06479b0 r3:00000001
[<c060995c>] (start_kernel) from [<00008070>] (0x8070)

Obviously, the useful bit is only down to just above
__tcp_push_pending_frames(), since that's traces back to the TCP socket's
send queue.

If I had to guess where the highmem pages were coming from, I'd suggest
that it was via the page cache and NFS - maybe something like GCC opens
a new NFS file, writes to it.  Pages are allocated to it, which happen
to be allocated from highmem.  NFS eventually sends these pages to the
NFS server via TCP, which fragments the page and leaves pointers to the
highmem page in the TCP skbuff.  My NFS mounts are IPv6.

For Freescale iMX6 FEC, I haven't yet been able to reproduce this there.
The FEC has tx-checksum-ipv6 and rx-vlan-offload enabled, which the
mv643xxx driver doesn't have.  The FEC platform has twice the memory of
the Dove platform (so has much more highmem) so I would've thought it
would have been easier to reproduce there.  Slightly different kernels
too - Dove runs 3.18 plus additions, iMX6 is running Linus' tip from
two days ago plus very similar additions (but same GPU and X server
code.)

Other stuff... Dove memory is 0 - 0x3fffffff.  mv643xxx DMA mask
uninitialised (coherent DMA mask set to 0xffffffff).

iMX6 is 0x10000000 - 0x8fffffff, with the DMA mask defaulting to
point at the coherent mask (due to being DT based) which is
0xffffffff.

Here's the diff of the ethtool -k output:

--- eth0.dove       2014-12-21 16:38:39.000000000 +0000
+++ eth0.imx6       2014-12-21 16:38:50.792453703 +0000
@@ -3,7 +3,7 @@
 tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off [fixed]
-       tx-checksum-ipv6: off [fixed]
+       tx-checksum-ipv6: on
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
 scatter-gather: on
@@ -17,7 +17,7 @@
 generic-segmentation-offload: on
 generic-receive-offload: on
 large-receive-offload: off [fixed]
-rx-vlan-offload: off [fixed]
+rx-vlan-offload: on
 tx-vlan-offload: off [fixed]
 ntuple-filters: off [fixed]
 receive-hashing: off [fixed]
@@ -32,7 +32,6 @@
 tx-ipip-segmentation: off [fixed]
 tx-sit-segmentation: off [fixed]
 tx-udp_tnl-segmentation: off [fixed]
-tx-mpls-segmentation: off [fixed]
 fcoe-mtu: off [fixed]
 tx-nocache-copy: off
 loopback: off [fixed]

Hmm.  I'm now wondering about this:

static netdev_features_t harmonize_features(struct sk_buff *skb,
        netdev_features_t features)
{
...
        if (skb->ip_summed != CHECKSUM_NONE &&
            !can_checksum_protocol(features, type)) {
                features &= ~NETIF_F_ALL_CSUM;
        } else if (illegal_highdma(skb->dev, skb)) {
                features &= ~NETIF_F_SG;
        }

For Dove, can_checksum_protocol() would return false for IPv6, which
would allow the first "if" statement to succeed, hence clearing
NETIF_F_ALL_CSUM.

This would prevent the second if() being evaluated - which seems to
remove the check for any fragments in highmem.  David - shouldn't these
two checks be independent?

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
