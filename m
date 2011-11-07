From: Mikulas Patocka <mpatocka@redhat.com>
Subject: data corruption in skge hardware
Date: Mon, 7 Nov 2011 11:42:11 -0500 (EST)
Message-ID: <Pine.LNX.4.64.1111071109410.18030@hs20-bc2-1.build.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42654 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754911Ab1KGQmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 11:42:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I found a data corruption in skge network card.

The card is this: "03:06.0 Ethernet controller: 3Com Corporation 3c940 
10/100/1000Base-T [Marvell] (rev 10)"

The machine is two quad core Opterons with HT2000 north bridge and HT1000 
south bridge.

When "scatter-gather" and "generic-segmentation-offload" are enabled, the 
card sends out corrupted packets.

It normally manifests as a ssh connection drop once per few days, but I 
found a workload that triggers this bug quickly.

I ran tcpdump on both sending and receiving machine and caught the packet 
corruption:

correct packet (on the sending machine):
19:03:21.131836 IP hydra.ssh > phoebe.58913: Flags [P.], seq 53712:53808, 
ack 1, win 193, options [nop,nop,TS val 8677173 ecr 1211608], length 96
        0x0000:  4510 0094 c7bf 4000 4006 f12d c0a8 8007
        0x0010:  c0a8 800e 0016 e621 2d64 84e6 1fc2 3f5b
        0x0020:  8018 00c1 81ed 0000 0101 080a 0084 6735
        0x0030:  0012 7cd8 4301 4af9 87c9 d2b4 8ba6 aedb
        0x0040:  0572 1738 93db 789c 634b 4386 d013 db27
        0x0050:  258b 6fa6 743c d429 a5e1 162f 2721 19bf
        0x0060:  6669 a5c3 6bea 89ec a635 b8b4 8727 38c1
        0x0070:  139f 5989 781b 49dd 79f5 4dfe 78ac ecb0
        0x0080:  546c 33e0 0953 04bc 0647 a9d4 2fc4 cba0
        0x0090:  44b2 3b01

incorrect packet (on the receiving machine):
19:03:21.133174 IP hydra.ssh > phoebe.58913: Flags [P.], seq 53712:53808, 
ack 1, win 193, options [nop,nop,TS val 8677173 ecr 1211608], length 96
        0x0000:  4510 0094 c7bf 4000 4006 f12d c0a8 8007
        0x0010:  c0a8 800e 0016 e621 2d64 84e6 1fc2 3f5b
        0x0020:  8018 00c1 6aa4 0000 0101 080a 0084 6735
        0x0030:  0012 7cd8 0000 0000 0000 0000 0010 0000
        0x0040:  0000 0000 0000 0000 0000 0000 0000 0000
        0x0050:  0000 0000 0000 0000 0000 00c0 dc92 4702
        0x0060:  88ff ff00 0000 0000 0000 0000 0000 0000
        0x0070:  0000 0000 0000 0000 0000 0000 0000 0000
        0x0080:  0000 0000 0000 0000 0000 0000 0000 0000
        0x0090:  0000 00e0

Obviously, scatter-gather doesn't work, the header is correct, but the 
packet body was likely read from random memory.

I tried to use "clflush" instruction on the transmit descriptor and the 
packet body to test if it is a cache-coherency issue, but the corruption 
was still there.

I tried to limit memory to 2G to test if it was a problem with high 
memory, but the corruption was still there.

I tries olded kernels (as far as 2.6.34), the corruption was still there, 
but it took much more time to trigger it with old kernels.


Do you have other reports of data corruption with skge hardware? Shouldn't 
the driver set "scatter-gather" off by default because it is unreliable?

Mikulas
