From: Florian Westphal <fw@strlen.de>
Subject: Re: Problems with fragments since gso skb forwarding changes in
 virtual environment
Date: Tue, 8 Apr 2014 02:26:44 +0200
Message-ID: <20140408002644.GC31953@breakpoint.cc>
References: <5342CC9A.6040800@strongswan.org>
 <20140407234640.GB31953@breakpoint.cc>
 <20140407.200535.1263628364222611722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, tobias@strongswan.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, mleitner@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47353 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753162AbaDHA0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 20:26:48 -0400
Content-Disposition: inline
In-Reply-To: <20140407.200535.1263628364222611722.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Tue, 8 Apr 2014 01:46:40 +0200
> 
> > Looking at br_nf_dev_queue_xmit() in br_netfilter.c I see that it has
> > a bug (not related 'gso skbs in forwarding path' change): it assumes
> > that if skb->nfct is NULL no reassembly has taken place.  Thats not
> > true (can load ipv4 defrag module without ipv4 conntrack one), or
> > netfilter defragmented the packet but then protocol tracker returned
> > error ('INVALID' conntrack state in netfilter speak).
> > 
> > I admit its rare condition, but afaics br_nf_dev_queue_xmit is
> > supposed to re-fragment packets that have been subject to defrag.
> 
> In fact, judging by commits:
> 
> commit e179e6322ac334e21a3c6d669d95bc967e5d0a80
> Author: Bart De Schuymer <bdschuym@pandora.be>
> Date:   Thu Apr 15 12:26:39 2010 +0200
> 
>     netfilter: bridge-netfilter: Fix MAC header handling with IP DNAT
> 
> and subsequently:
> 
> commit c197facc8ea08062f8f949aade6a33649ee06771
> Author: hummerbliss@gmail.com <hummerbliss@gmail.com>
> Date:   Mon Apr 20 17:12:35 2009 +0200
> 
>     netfilter: bridge: allow fragmentation of VLAN packets traversing a bridge
> 
> I would say that we should simply remove the skb->nfct check
> altogether and everything will work fine.

I was thinking about tracking defrag-on-top-of-bridge in
skb->nf_bridge.  But after looking at the changes you're mentioning I
think you're right, I don't see how we can end up in
br_nf_dev_queue_xmit with packet-exceeding-MTU and said skb NOT being
a defragmented packet.

I am afraid IPv6 defrag also needs to be considered here 8-/

I'll look into it tomorrow.
