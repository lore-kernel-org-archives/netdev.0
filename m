From: Tobias Brunner <tobias@strongswan.org>
Subject: Problems with fragments since gso skb forwarding changes in virtual
 environment
Date: Mon, 07 Apr 2014 18:04:42 +0200
Message-ID: <5342CC9A.6040800@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sifsv-80046.hsr.ch ([152.96.80.46]:42830 "EHLO
	mail.strongswan.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbaDGQN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 12:13:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian et al,

We noticed a problem with fragmented packets in the KVM/libvirt-based
strongSwan integration test environment [1] with guest kernels that
include the following commit:

	net: ip, ipv6: handle gso skbs in forwarding path
	fe6cc55f3a9a053482a76f5a6b2257cee51b4663

The network topology in test scenarios that trigger the problem is as
follows:

	Host A - br1 - Router R - br2 - Host B

Where the two hosts and the router are virtual guests connected via
bridges all created via libvirt (see [2] for the XML config files).  The
guest's network interfaces all use virtio.

If the router runs with a kernel that includes the commit above, packets
sent from A to B that exceed the MTU (1500 in this case) will be split
into fragments when leaving R.  These fragment skbs get defragmented by
the host kernel's nf_defrag_ipv4 module while being forwarded on br2.

This poses a problem.  Because the fragment skbs are not GSO, neither is
the defragmented skb.  Hence the packets are dropped just before leaving
the bridge, as is_skb_forwardable() will return false unless a too large
skb is actually GSO (this is the same for older host kernels, where the
check is directly done in br_forward.c).

Without the commit, and between A and R even with it (because it only
affects forwarding), the skbs are GSO throughout and transmitted from A
to B without ever actually being fragmented.

Any ideas how to fix this properly?  That is, without just reverting
parts of your commit for our guest kernels.

Regards,
Tobias

[1] http://wiki.strongswan.org/projects/strongswan/wiki/TestingEnvironment
[2] http://git.strongswan.org/?p=strongswan.git;a=tree;f=testing/config/kvm
