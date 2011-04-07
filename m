From: Wei Gu <wei.gu@ericsson.com>
Subject: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 7 Apr 2011 15:22:50 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
 <1302157012.2701.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:42926 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210Ab1DGHXp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 03:23:45 -0400
In-Reply-To: <1302157012.2701.73.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,
As I talked with Eric, that I get a very low performance on Linux 2.6.3=
8 kernel with intel ixgbe-3.2.10 driver.
I test different rx buff size on the Intel 10G NIC, by setting ethtool =
-G rx 4096.
I get the lowest performance(~50Kpps Rx&Tx) by setting the rx=3D=3D4096=
=2E
Once I decrease the Rx to 512 (default) then I can get Max 250Kpps Rx&T=
x on 1 NIC.

I was runing this test with HP DL580 4 Sock CPUs, and full memeory conf=
iguration.
modprobe ixgbe RSS=3D8,8,8,8,8,8,8,8 FdirMode=3D0,0,0,0,0,0,0,0 Node=3D=
0,0,1,1,2,2,3,3
Numactrl --hardware
available: 4 nodes (0-3)
node 0 cpus: 0 1 2 3 4 5 6 7 32 33 34 35 36 37 38 39
node 0 size: 65525 MB
node 0 free: 63053 MB
node 1 cpus: 8 9 10 11 12 13 14 15 40 41 42 43 44 45 46 47
node 1 size: 65536 MB
node 1 free: 63388 MB
node 2 cpus: 16 17 18 19 20 21 22 23 48 49 50 51 52 53 54 55
node 2 size: 65536 MB
node 2 free: 63344 MB
node 3 cpus: 24 25 26 27 28 29 30 31 56 57 58 59 60 61 62 63
node 3 size: 65535 MB
node 3 free: 63376 MB

Then I binding the eth10's rx and tx's IRQs to core "24 25 26 27 28 29 =
30 31", one by one, which means 1 rx and 1 tx was share 1 core.


I did the same test on 2.6.32 kernel, I can get >2.5M tx&rx with the sa=
me setup on RHEL6(2.6.32) Linux. But never reach 10.000.000 rx&tx on a =
single NIC:)

I also test the 2.6.38 shipped intel ixgbe driver It has the same probl=
em.

This is a perf record with linux shipped ixgbe driver, looks it has a v=
ery high irq/s rate. And the softirq was busy on alloc_iova


PerfTop:  512417 irqs/sec  kernel:91.3%  exact:  0.0% [1000Hz cpu-clock=
-msecs],  (all, 64 CPUs)
-----------------------------------------------------------------------=
-----------------------------------------------------------------------=
--------
-      0.82%     ksoftirqd/24  [kernel.kallsyms]          [k] _raw_spin=
_unlock_irqrestore
\u2592   - _raw_spin_unlock_irqrestore
\u2592      - 44.27% alloc_iova
\u2592           intel_alloc_iova
\u2592           __intel_map_single
\u2592           intel_map_page
\u2592         - ixgbe_init_interrupt_scheme
\u2592            - 59.97% ixgbe_alloc_rx_buffers
\u2592                 ixgbe_clean_rx_irq
\u2592                 0xffffffffa033a5
\u2592                 net_rx_action
u2592                 __do_softirq
\u2592               + call_softirq
\u2592            - 40.03% ixgbe_change_mtu
\u2592                 ixgbe_change_mtu
\u2592                 dev_hard_start_xmit
\u2592                 sch_direct_xmit
\u2592                 dev_queue_xmit
\u2592                 vlan_dev_hard_start_xmit
\u2592                 hook_func
\u2592                 nf_iterate
\u2592                nf_hook_slow
\u2592                 NF_HOOK.clone.1
\u2592                 ip_rcv
\u2592                 __netif_receive_skb
\u2592                 __netif_receive_skb
\u2592                 netif_receive_skb
\u2592                 napi_skb_finish
\u2592                 napi_gro_receive
\u2592                 ixgbe_clean_rx_irq
\u2592                 0xffffffffa033a5
\u2592                 net_rx_action
\u2592                 __do_softirq
\u2592               + call_softirq
\u2592      + 35.85% find_iova
\u2592      + 19.44% add_unmap


Thanks
WeiGu


-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]
Sent: Thursday, April 07, 2011 2:17 PM
To: Wei Gu
Cc: netdev; Alexander Duyck; Jeff Kirsher
Subject: RE: Question on "net: allocate skbs on local node"

Le jeudi 07 avril 2011 =E0 07:16 +0200, Eric Dumazet a =E9crit :
> Le jeudi 07 avril 2011 =E0 06:58 +0200, Eric Dumazet a =E9crit :
> > Le jeudi 07 avril 2011 =E0 10:16 +0800, Wei Gu a =E9crit :
> > > Hi Eric,
> > > Testing with ixgbe Linux 2.6.38 driver:
> > > We have a little better thruput figure with this driver, but it
> > > looks not scalling at all, I always stressed one CPU core/24.
> > > And when look the perf report for ksoftirqd/24, the most cost
> > > function is still "_raw_spin_unlock_irqstore" and the IRQ/s is
> > > huge, it's somehow conflicts with desgin of NAPI. On linux 2.6.32
> > > while the CPU was stressed the IRQ will descreased while the NAPI
> > > will running much on the polling mode. I don't know why on 2.6.38
> > > the IRQ was keep increasing.
> >
> >
> > CC netdev and Intel guys, since they said it should not happen (TM)
> >
> > IF you dont use DCA (make sure ioatdma module is not loaded), how
> > comes
> > alloc_iova() is called at all ?
> >
> > IF you use DCA, how comes its called, since the same CPU serves a
> > given interrupt ?
> >
> >
>
> But then, maybe you forgot to cpu affine IRQS ?
>
> High performance routing setup is tricky, since you probably want to
> disable many features that are ON by default : Most machines act as a
> end host.
>
>

Please dont send me anymore private mails, I do think the issue you hav=
e is on a setup, not a particular optimization done in network stack.


Copy of your private mail :

> On 2.6.38, I got a lot of "rx_missed_errors" on NIC, which means the
> rx loop was really busy to get packet from the receiving ring. Usuall=
y
> in this case it shouldn't exit the softirqs and keep polling in order
> to decrease the initrs.
>
> On 2.6.32, I can Rx and Tx 2.3Mpps with no packet lost(error on NIC),
> but on 2.6.38 I can only reach 50kpps with a lot of
> "rx_missed_errors", and all the binding cpu core was 100% in SI. I
> don't think there was any optimizations on it.

I hope you understand there is something wrong with your setup ?

50.000 pps on a 64 cpu machine is a bad joke.

We can reach +10.000.000 on a 16 cpus one.



