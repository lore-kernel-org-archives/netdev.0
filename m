From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4_en: add UFO support
Date: Fri, 3 Aug 2012 10:34:07 -0300
Message-ID: <20120803133407.GA5736@oc1711230544.ibm.com>
References: <1343940824-4720-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <953B660C027164448AE903364AC447D2871F0CCC@MTLDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:53209 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303Ab2HCNeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 09:34:14 -0400
Received: from /spool/local
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Fri, 3 Aug 2012 10:34:12 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id B34531DC0050
	for <netdev@vger.kernel.org>; Fri,  3 Aug 2012 09:34:09 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay03.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q73DXJQC27918574
	for <netdev@vger.kernel.org>; Fri, 3 Aug 2012 10:33:19 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q73BXvGj002086
	for <netdev@vger.kernel.org>; Fri, 3 Aug 2012 08:33:58 -0300
Content-Disposition: inline
In-Reply-To: <953B660C027164448AE903364AC447D2871F0CCC@MTLDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 03, 2012 at 08:29:26AM +0000, Yevgeny Petrilin wrote:
> > 
> > Mellanox Ethernet adapters support Large Segmentation Offload for UDP
> > packets. The only change needed is using the proper header size when the
> > packet is UDP instead of TCP.
> > 
> > This significantly increases performance for large UDP packets on platforms
> > which have an expensive dma_map call, like pseries.
> > 
> > On a simple test with 64000 payload size, throughput has increased from
> > about 6Gbps to 9.5Gbps, while CPU use dropped from about 600% to about
> > 80% or less, on a 8-core Power7 machine.
> > 
> Hi Thadeu,
> Can you please send the info regarding the adapter you are testing with? What test are you running?
> I just tried this patch with netperf on my x86_64, and it doesn't work. Packets are not fragmented properly (fragment offsets are not calculated).
> It is true that the TX side doesn't work as hard (OS doesn't need to do the fragmentation), but traffic is not sent properly on the wire.
> 
> I'll do further investigation and get back with more details.
> 
> Yevgeny
> 

Hi, Yevgeny.

At first, I only added the UFO feature. When testing that, I got lots of
errors on the receiving end, like:

UDP: short packet: From 10.0.0.2:0 0/1480 to 10.0.0.3:0

After finding out what the driver was writing to the LSO descriptor, it
was obvious why this happened. The driver was using as the header size
the TCP header size, which would use a value from the UDP packet
payload.

After the other change, however, everything should work fine. I ran a
uperf test with 64000-sized payload packets and everything seemed to
work fine.

The card I have in here is:

0001:01:00.0 Ethernet controller: Mellanox Technologies MT26448 [ConnectX EN 10GigE, PCIe 2.0 5GT/s] (rev b0)
        Subsystem: Mellanox Technologies Device 0016
        Flags: bus master, fast devsel, latency 0, IRQ 17
        Memory at 3da0fbe00000 (64-bit, non-prefetchable) [size=1M]
        Memory at 3da0fc000000 (64-bit, prefetchable) [size=32M]
        Expansion ROM at 3da0fbf00000 [disabled] [size=1M]
        Capabilities: [40] Power Management version 3
        Capabilities: [48] Vital Product Data
        Capabilities: [9c] MSI-X: Enable+ Count=128 Masked-
        Capabilities: [60] Express Endpoint, MSI 00
        Capabilities: [100] Alternative Routing-ID Interpretation (ARI)
        Capabilities: [148] Device Serial Number 00-02-c9-03-00-4b-97-c4
        Kernel driver in use: mlx4_core
        Kernel modules: mlx4_core

I will try some other tests in here and report my results.

Regards.
Cascardo.
