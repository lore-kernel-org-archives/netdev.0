From: Tobias Brunner <tobias@strongswan.org>
Subject: Re: Problems with fragments since gso skb forwarding changes in virtual
 environment
Date: Tue, 08 Apr 2014 14:24:25 +0200
Message-ID: <5343EA79.8030104@strongswan.org>
References: <5342CC9A.6040800@strongswan.org> <20140407234640.GB31953@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sifsv-80046.hsr.ch ([152.96.80.46]:53237 "EHLO
	mail.strongswan.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1756141AbaDHMY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 08:24:27 -0400
In-Reply-To: <20140407234640.GB31953@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

> Do I interpret this correctly:
> 
> Host A - br1 - Router R - br2 - Host B
>   Mtu >1500               Mtu 1500
> 
> 1. host A sends GSO packet, DF not set
> 2. packet arrives at R, still GSO packet
> 3. forward on R fragments packet since it won't fit
>    outgoing interface (which is normal virtio ethernet) mtu
> 4. fragmented packets leave R
> 5. fragmented packets arrive on host system (not pictured above) br2
> interface
> 
> 6. packets are being bridged on host system, call_iptables sysctl on
> 7. packets are defragmented by netfilter on host due to call_iptables
> sysctl on
> 8. packets are tossed on host in br_dev_queue_push_xmit because
>    is_skb_forwardable() returns false
> 
> Is that correct?

Exactly.  The MTU is 1500 on all interfaces though.

>> Without the commit, and between A and R even with it (because it only
>> affects forwarding), the skbs are GSO throughout and transmitted from A
>> to B without ever actually being fragmented.
> 
> I see why this change makes it trip over GSO skbs, but I fail to
> see why it would work with larger-than-1500-mtu-and-fragmentation-allowed
> packets being sent from A to B. (or with fragments generated locally
> on R).
> 
> To the host system it should make no difference at all if the fragments
> came into existence in R's forwarding path, or being sent by A, or if
> the fragments were generated locally on R (i.e. ping -s $bignum $hosta
> on R with DF off).

In our test scenarios the packets are UDP and GSO and without the commit
(or between A and R) they travel unchanged between guest and host
kernels without ever touching a physical interface that would actually
cause them to get fragmented (I wasn't aware of this, until I looked
into this issue).

For ICMP it's interesting to note that 'ping -s $bignum $hostb' from A
works even with the commit.  The packet is already fragmented when it
leaves A and these fragments are forwarded properly by the host bridges.
 They are defragmented by the nf_defrag_ipv4 module, but are fragmented
again in br_nf_dev_queue_xmit() because skb->nfct is non-null as pointed
out by you and David.

I tried removing the skb->nfct check, and while that fixes the
forwarding issue on the host, for some reason the UDP socket on B does
not receive the packet (the guest kernel does, even defragments it and
queues it to the socket, but the userland program never receives the
datagram).

Regards,
Tobias
