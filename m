From: Florian Westphal <fw@strlen.de>
Subject: Re: Problems with fragments since gso skb forwarding changes in
 virtual environment
Date: Tue, 8 Apr 2014 01:46:40 +0200
Message-ID: <20140407234640.GB31953@breakpoint.cc>
References: <5342CC9A.6040800@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
To: Tobias Brunner <tobias@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47267 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754044AbaDGXqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 19:46:45 -0400
Content-Disposition: inline
In-Reply-To: <5342CC9A.6040800@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Brunner <tobias@strongswan.org> wrote:
> We noticed a problem with fragmented packets in the KVM/libvirt-based
> strongSwan integration test environment [1] with guest kernels that
> include the following commit:
> 
> 	net: ip, ipv6: handle gso skbs in forwarding path
> 	fe6cc55f3a9a053482a76f5a6b2257cee51b4663
> 
> The network topology in test scenarios that trigger the problem is as
> follows:
> 
> 	Host A - br1 - Router R - br2 - Host B
> 
> Where the two hosts and the router are virtual guests connected via
> bridges all created via libvirt (see [2] for the XML config files).  The
> guest's network interfaces all use virtio.
> 
> If the router runs with a kernel that includes the commit above, packets
> sent from A to B that exceed the MTU (1500 in this case) will be split
> into fragments when leaving R.  These fragment skbs get defragmented by
> the host kernel's nf_defrag_ipv4 module while being forwarded on br2.

Thanks for the detailed bug report, much appreciated.

Do I interpret this correctly:

Host A - br1 - Router R - br2 - Host B
  Mtu >1500               Mtu 1500

1. host A sends GSO packet, DF not set
2. packet arrives at R, still GSO packet
3. forward on R fragments packet since it won't fit
   outgoing interface (which is normal virtio ethernet) mtu
4. fragmented packets leave R
5. fragmented packets arrive on host system (not pictured above) br2
interface

6. packets are being bridged on host system, call_iptables sysctl on
7. packets are defragmented by netfilter on host due to call_iptables
sysctl on
8. packets are tossed on host in br_dev_queue_push_xmit because
   is_skb_forwardable() returns false

Is that correct?

> Without the commit, and between A and R even with it (because it only
> affects forwarding), the skbs are GSO throughout and transmitted from A
> to B without ever actually being fragmented.

I see why this change makes it trip over GSO skbs, but I fail to
see why it would work with larger-than-1500-mtu-and-fragmentation-allowed
packets being sent from A to B. (or with fragments generated locally
on R).

To the host system it should make no difference at all if the fragments
came into existence in R's forwarding path, or being sent by A, or if
the fragments were generated locally on R (i.e. ping -s $bignum $hosta
on R with DF off).

> Any ideas how to fix this properly?  That is, without just reverting
> parts of your commit for our guest kernels.

Looking at br_nf_dev_queue_xmit() in br_netfilter.c I see that it has
a bug (not related 'gso skbs in forwarding path' change): it assumes
that if skb->nfct is NULL no reassembly has taken place.  Thats not
true (can load ipv4 defrag module without ipv4 conntrack one), or
netfilter defragmented the packet but then protocol tracker returned
error ('INVALID' conntrack state in netfilter speak).

I admit its rare condition, but afaics br_nf_dev_queue_xmit is
supposed to re-fragment packets that have been subject to defrag.

I'll look into this again tomorrow.
