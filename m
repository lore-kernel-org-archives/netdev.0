From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix RCU race in
 nf_conntrack_find_get
Date: Thu, 9 Jan 2014 22:26:47 +0100
Message-ID: <20140109212647.GB29458@breakpoint.cc>
References: <1389090711-15843-1-git-send-email-avagin@openvz.org>
 <1389107305.26646.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140107152520.GF9894@breakpoint.cc>
 <20140109203206.GA26348@paralelels.com>
 <20140109205622.GA29458@breakpoint.cc>
 <20140109210749.GA29440@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrey Vagin <avagin@openvz.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vvs@openvz.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:37131 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754979AbaAIV0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 16:26:53 -0500
Content-Disposition: inline
In-Reply-To: <20140109210749.GA29440@paralelels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Vagin <avagin@parallels.com> wrote:
> On Thu, Jan 09, 2014 at 09:56:22PM +0100, Florian Westphal wrote:
> > Andrew Vagin <avagin@parallels.com> wrote:
> > > Can we allocate conntrack with zero ct_general.use and increment it at
> > > the first time before inserting the conntrack into the hash table?
> > > When conntrack is allocated it is attached exclusively to one skb.
> > > It must be destroyed with skb, if it has not been confirmed, so we
> > > don't need refcnt on this stage.
> > > 
> > > I found only one place, where a reference counter of unconfirmed
> > > conntract can incremented. It's ctnetlink_dump_table().
> > 
> > What about skb_clone, etc?  They will also increment the refcnt
> > if a conntrack entry is attached to the skb.
> 
> We can not attach an unconfirmed conntrack to a few skb, because

s/few/new/?

> nf_nat_setup_info can be executed concurrently for the same conntrack.
> 
> How do we avoid this race condition for cloned skb-s?

Simple, the assumption is that only one cpu owns the nfct, so it does
not matter if the skb is cloned in between, as there are no parallel
users.

The only possibility (that I know of) to violate this is to create
a bridge, enable call-iptables sysctl, add -j NFQUEUE rules and then
wait for packets that need to be forwarded to several recipients,
e.g. multicast traffic.

see
http://marc.info/?l=netfilter-devel&m=131471083501656&w=2

or search 'netfilter: nat: work around shared nfct struct in bridge
case'
