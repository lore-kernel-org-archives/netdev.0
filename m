From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 07 Apr 2011 10:07:30 +0200
Message-ID: <1302163650.3357.8.camel@edumazet-laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55107 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755393Ab1DGIHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 04:07:35 -0400
Received: by wwa36 with SMTP id 36so2722177wwa.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2011 01:07:34 -0700 (PDT)
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 avril 2011 =C3=A0 15:22 +0800, Wei Gu a =C3=A9crit :
> Hi guys,
> As I talked with Eric, that I get a very low performance on Linux 2.6=
=2E38 kernel with intel ixgbe-3.2.10 driver.
> I test different rx buff size on the Intel 10G NIC, by setting ethtoo=
l -G rx 4096.
> I get the lowest performance(~50Kpps Rx&Tx) by setting the rx=3D=3D40=
96.
> Once I decrease the Rx to 512 (default) then I can get Max 250Kpps Rx=
&Tx on 1 NIC.
>=20
> I was runing this test with HP DL580 4 Sock CPUs, and full memeory co=
nfiguration.
> modprobe ixgbe RSS=3D8,8,8,8,8,8,8,8 FdirMode=3D0,0,0,0,0,0,0,0 Node=3D=
0,0,1,1,2,2,3,3
> Numactrl --hardware
> available: 4 nodes (0-3)
> node 0 cpus: 0 1 2 3 4 5 6 7 32 33 34 35 36 37 38 39
> node 0 size: 65525 MB
> node 0 free: 63053 MB
> node 1 cpus: 8 9 10 11 12 13 14 15 40 41 42 43 44 45 46 47
> node 1 size: 65536 MB
> node 1 free: 63388 MB
> node 2 cpus: 16 17 18 19 20 21 22 23 48 49 50 51 52 53 54 55
> node 2 size: 65536 MB
> node 2 free: 63344 MB
> node 3 cpus: 24 25 26 27 28 29 30 31 56 57 58 59 60 61 62 63
> node 3 size: 65535 MB
> node 3 free: 63376 MB
>=20
> Then I binding the eth10's rx and tx's IRQs to core "24 25 26 27 28 2=
9 30 31", one by one, which means 1 rx and 1 tx was share 1 core.
>=20
>=20
> I did the same test on 2.6.32 kernel, I can get >2.5M tx&rx with the =
same setup on RHEL6(2.6.32) Linux. But never reach 10.000.000 rx&tx on =
a single NIC:)
>=20
> I also test the 2.6.38 shipped intel ixgbe driver It has the same pro=
blem.
>=20
> This is a perf record with linux shipped ixgbe driver, looks it has a=
 very high irq/s rate. And the softirq was busy on alloc_iova
>=20
>=20
> PerfTop:  512417 irqs/sec  kernel:91.3%  exact:  0.0% [1000Hz cpu-clo=
ck-msecs],  (all, 64 CPUs)
> ---------------------------------------------------------------------=
-----------------------------------------------------------------------=
----------
> -      0.82%     ksoftirqd/24  [kernel.kallsyms]          [k] _raw_sp=
in_unlock_irqrestore
> \u2592   - _raw_spin_unlock_irqrestore
> \u2592      - 44.27% alloc_iova
> \u2592           intel_alloc_iova
> \u2592           __intel_map_single
> \u2592           intel_map_page
> \u2592         - ixgbe_init_interrupt_scheme
> \u2592            - 59.97% ixgbe_alloc_rx_buffers
> \u2592                 ixgbe_clean_rx_irq
> \u2592                 0xffffffffa033a5
> \u2592                 net_rx_action
> u2592                 __do_softirq
> \u2592               + call_softirq
> \u2592            - 40.03% ixgbe_change_mtu
> \u2592                 ixgbe_change_mtu
> \u2592                 dev_hard_start_xmit
> \u2592                 sch_direct_xmit
> \u2592                 dev_queue_xmit
> \u2592                 vlan_dev_hard_start_xmit
> \u2592                 hook_func
> \u2592                 nf_iterate
> \u2592                nf_hook_slow
> \u2592                 NF_HOOK.clone.1
> \u2592                 ip_rcv
> \u2592                 __netif_receive_skb
> \u2592                 __netif_receive_skb
> \u2592                 netif_receive_skb
> \u2592                 napi_skb_finish
> \u2592                 napi_gro_receive
> \u2592                 ixgbe_clean_rx_irq
> \u2592                 0xffffffffa033a5
> \u2592                 net_rx_action
> \u2592                 __do_softirq
> \u2592               + call_softirq
> \u2592      + 35.85% find_iova
> \u2592      + 19.44% add_unmap
>=20
>=20
> Thanks
> WeiGu

What about using the driver as provided in 2.6.38 ?

No custom module parameter, only play with irq affinities

Say you have 64 queues but want only 8 cpus (24 -> 31) receiving trafic

for i in `seq 0 7`
do
 echo 01000000 >/proc/irq/*/eth1-fp-$i/../smp_affinity
done

for i in `seq 8 15`
do
 echo 02000000 >/proc/irq/*/eth1-fp-$i/../smp_affinity
done

=2E..

for i in `seq 56 63`
do
 echo 80000000 >/proc/irq/*/eth1-fp-$i/../smp_affinity
done


Why is ixgbe_change_mtu() seen on your profile ?
Its damn expensive, since it must call ixgbe_reinit_locked()

Are you using a custom code in kernel ?



