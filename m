From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Fri, 08 Apr 2011 17:07:03 +0200
Message-ID: <1302275223.4409.36.camel@edumazet-laptop>
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
	 <1302267400.4409.22.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63939 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757204Ab1DHPHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 11:07:08 -0400
Received: by wwa36 with SMTP id 36so4361350wwa.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 08:07:07 -0700 (PDT)
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 08 avril 2011 =C3=A0 22:10 +0800, Wei Gu a =C3=A9crit :
> Hi,
> Got you mean.
> But as I decribed before, I start the eth10 with 8 rx queues and 8 tx
> queues, and then I binding these 8 tx&rx queue each to CPU core 24-32
> (NUMA3), which I think could gain the best performance in my case
> (It's true on Linux 2.6.32)
> single queue ->single CPU

Try with other cpus ? Maybe a mix.

Maybe your thinking is not good, and you chose the cpus that were not
the best candidates. This was OK in 2.6.32 because you were lucky.

Using cpus from an unique NUMA node is not very good, since only one
NUMA node is going to be used, and other NUMA nodes are idle.


NUMA binding is tricky. Linux try to use local node, hoping that all
cpus are running and use local memory. In the end, global throughput is
better.

But if your workload use cpus from one single node, then it means you
lose part of the memory bandwidth.


> Then I can descibe a little bit with packet generator, I config the
> IXIA to continues increase the dest ip address towards the test
> server, so the packet was evenly distributed to each receving queues
> of the eth10. And according the IXIA tools the transmit sharp was
> really good, no too much peaks
>=20
> What I observed on Linux 2.6.38 during the test, there is no softqd
> was stressed (< 03% on SI for each core(24-31)) while the packet lost
> happens, so we are not really stress the CPU:), It looks like we are
> limited  on some memory bandwidth (DMA) on this release

That would mean you chose the wrong cpus to handle this load.


>=20
> And with same test case on 2.6.32, no such problem at all. It running
> pretty stable > 2Mpps without rx_missing_error. There is no HW
> limitation on this DL580
>=20
>=20
> BTW what is these "swapper"
> +      0.80%          swapper  [ixgbe]                    [k]
> ixgbe_poll
> +      0.79%             perf  [ixgbe]                    [k]
> ixgbe_poll
> Why the ixgbe_poll was on swapper/perf?
>=20

softirq are run behalf the current interrupted thread, unless you enter
ksoftirqd if load is high.

It can be "idle task" or the "perf" task, or another ones...



