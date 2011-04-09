From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Sat, 9 Apr 2011 11:27:03 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se>
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
 <1302275223.4409.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:44553 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061Ab1DID2d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 23:28:33 -0400
In-Reply-To: <1302275223.4409.36.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI Eric,
If I try to bind the 8 tx&rx queue to different NUMA Node to (core 3,7,=
11,15,19,23,27,31), looks doesn't help on the rx_missing_error anymore.

I still think the best performance would be binding NIC to one sock of =
CPU with it's local memory node.
I did a lot of combination on 2.6.32 kernel, by bind the eth10 to NODE2=
/3 could gain 20% more performance compare to NODE0/1.
So I guess the CPU Socket 2&3 was locally with the eth10.

Thanks
WeiGu

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]
Sent: Friday, April 08, 2011 11:07 PM
To: Wei Gu
Cc: Alexander Duyck; netdev; Kirsher, Jeffrey T
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

Le vendredi 08 avril 2011 =E0 22:10 +0800, Wei Gu a =E9crit :
> Hi,
> Got you mean.
> But as I decribed before, I start the eth10 with 8 rx queues and 8 tx
> queues, and then I binding these 8 tx&rx queue each to CPU core 24-32
> (NUMA3), which I think could gain the best performance in my case
> (It's true on Linux 2.6.32) single queue ->single CPU

Try with other cpus ? Maybe a mix.

Maybe your thinking is not good, and you chose the cpus that were not t=
he best candidates. This was OK in 2.6.32 because you were lucky.

Using cpus from an unique NUMA node is not very good, since only one NU=
MA node is going to be used, and other NUMA nodes are idle.


NUMA binding is tricky. Linux try to use local node, hoping that all cp=
us are running and use local memory. In the end, global throughput is b=
etter.

But if your workload use cpus from one single node, then it means you l=
ose part of the memory bandwidth.


> Then I can descibe a little bit with packet generator, I config the
> IXIA to continues increase the dest ip address towards the test
> server, so the packet was evenly distributed to each receving queues
> of the eth10. And according the IXIA tools the transmit sharp was
> really good, no too much peaks
>
> What I observed on Linux 2.6.38 during the test, there is no softqd
> was stressed (< 03% on SI for each core(24-31)) while the packet lost
> happens, so we are not really stress the CPU:), It looks like we are
> limited  on some memory bandwidth (DMA) on this release

That would mean you chose the wrong cpus to handle this load.


>
> And with same test case on 2.6.32, no such problem at all. It running
> pretty stable > 2Mpps without rx_missing_error. There is no HW
> limitation on this DL580
>
>
> BTW what is these "swapper"
> +      0.80%          swapper  [ixgbe]                    [k]
> ixgbe_poll
> +      0.79%             perf  [ixgbe]                    [k]
> ixgbe_poll
> Why the ixgbe_poll was on swapper/perf?
>

softirq are run behalf the current interrupted thread, unless you enter=
 ksoftirqd if load is high.

It can be "idle task" or the "perf" task, or another ones...



