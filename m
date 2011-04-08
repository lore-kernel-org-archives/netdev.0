From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Fri, 08 Apr 2011 14:56:40 +0200
Message-ID: <1302267400.4409.22.camel@edumazet-laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	 <1302163650.3357.8.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	 <1302167168.3357.12.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>
	 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
	 <1302253651.4409.2.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36509 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234Ab1DHM4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 08:56:46 -0400
Received: by wwa36 with SMTP id 36so4210363wwa.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 05:56:45 -0700 (PDT)
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 08 avril 2011 =C3=A0 20:19 +0800, Wei Gu a =C3=A9crit :
> Hi again,
> I tried more testing with by disable this CONFIG_DMAR with shipped
> 2.6.38 ixgbe and Intel released 3.2.10/3.1.15.
> All these test looks we can get >1Mpps 400bype packtes but not stable
> at all, there will huge number missing errors with 100% CPU IDLE:
> ethtool -S eth10 |grep rx_missed_errors
>=20
>         rx_missed_errors: 76832040
>=20
> SUM: 1102212 ETH8: 0  ETH10: 1102212 ETH6: 0 ETH4: 0
> SUM: 521841 ETH8: 0  ETH10: 521841 ETH6: 0 ETH4: 0
> SUM: 426776 ETH8: 0  ETH10: 426776 ETH6: 0 ETH4: 0
> SUM: 927520 ETH8: 0  ETH10: 927520 ETH6: 0 ETH4: 0
> SUM: 1171995 ETH8: 0  ETH10: 1171995 ETH6: 0 ETH4: 0
> SUM: 855980 ETH8: 0  ETH10: 855980 ETH6: 0 ETH4: 0
>=20
>=20
> Do you know if there is other options in the kernel will cause high
> rate rx_missed_errors with low CPU usage. (No problem on 2.6.32 with
> same test case)
>=20
> perf  record:
> +     69.74%          swapper  [kernel.kallsyms]          [k] poll_id=
le
> +     11.62%          swapper  [kernel.kallsyms]          [k] intel_i=
dle
> +      0.80%          swapper  [ixgbe]                    [k] ixgbe_p=
oll
> +      0.79%             perf  [ixgbe]                    [k] ixgbe_p=
oll
> +      0.77%             perf  [kernel.kallsyms]          [k] skb_cop=
y_bits
> +      0.64%          swapper  [kernel.kallsyms]          [k] skb_cop=
y_bits
> +      0.48%             perf  [kernel.kallsyms]          [k] __kmall=
oc_node_track_caller
> +      0.44%          swapper  [kernel.kallsyms]          [k] __kmall=
oc_node_track_caller
> +      0.36%          swapper  [kernel.kallsyms]          [k] kmem_ca=
che_alloc_node
> +      0.35%          swapper  [kernel.kallsyms]          [k] kfree
> +      0.35%             perf  [kernel.kallsyms]          [k] kmem_ca=
che_alloc_node
>=20


Make sure enough cpus serves interrupts, _before_ even starting your
stress test.

Then, make sure trafic is distributed to many different queues.
If a single flow is used, it probably uses a single queue ->single CPU.

Say you have irq affinities set to fffffffffffff  (all cpus able to
serve IRQ X,Y,Z,T,...)

Then you have a network burst (because you start your packet generator
at full rate), spreaded on many queues.

CPU0 takes hard interrupt for queue 0, eth8, and queues NAPI mode.
CPU0 takes hard interrupt for queue 0, eth10, and queues NAPI mode.
CPU0 takes hard interrupt for queue 1, eth8, and queues NAPI mode.
CPU0 takes hard interrupt for queue 1, eth10, and queues NAPI mode.
CPU0 takes hard interrupt for queue 2, eth8, and queues NAPI mode.
CPU0 takes hard interrupt for queue 2, eth10, and queues NAPI mode.
=2E..
CPU0 takes hard interrupt for queue X, eth8, and queues NAPI mode.
=2E..

Then softirq can start, and only CPU0 is able to handle NAPI for all th=
e
queued devices. You are stuck, with CPU0 never leaving ksoftirqd.

NAPI handling is always performed on the CPU that received the hardware
interrupt, until we exit NAPI (and rearm interrupt delivery).
It cannot migrate to an "idle cpu"


