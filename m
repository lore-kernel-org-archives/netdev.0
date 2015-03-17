From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 nf-next 1/6] net: untangle ip_fragment and bridge
 netfilter
Date: Tue, 17 Mar 2015 11:11:52 +0100
Message-ID: <20150317101152.GB26394@breakpoint.cc>
References: <1426179925-18220-1-git-send-email-fw@strlen.de>
 <1426179925-18220-2-git-send-email-fw@strlen.de>
 <20150316225545.GA4454@salvia>
 <20150317.004224.595812379252826772.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, fw@strlen.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, azhou@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150317.004224.595812379252826772.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> Specifically it needs to stop pretending it can do full on IP
> operations like fragmentation without the full necessary context.
> 
> That full necessary context being a physical destination device,
> and a proper IP route.
> 
> It means that all of the MTU calculations miss everything done
> by the ipv4 routing layer, all of the settings made by the user
> via sysctl_ip_fwd_use_pmtu, etc.

Perhaps, but I have a hard time defining wheter a bridge should
use something like sysctl_ip_fwd_use_pmtu or not.

And doing route lookups will break things for some people, we have zero
guarantee that a bridge has the needed routing information,
its valid to not even configure a default gateway on a bridge.

We could alter defragmentation to provide the size of the largest
fragment seen unconditionally, and use that.

But I honestly think this patch is the best we can do to at least
don't have the IP stack deal with this crap.

> So I think bridge netfilter needs to seriously look up a real
> route and do things properly like the rest of the networking
> stack does when it wants to fragment ipv4 packets.

Sure, I can investigate doing this.

However, I don't believe that this is fixable given that we might not
have any routing tables; also; we allowed things like transparent PPPOE
and VLAN header stripping.

ip_fragment shouldn't have to deal with increased LL space, as it does now,
and I don't see any way to fix that except adding that extra ll size argument
and having br_netfilter set it.

If you disagree, whats your suggested solution to get rid
of the br_netfilter inline helpers?

Kill support for vlan/pppoe header stripping?
Add route lookup but keep current behaviour as fallback in case we don't
find route?

I wouldn't object to doing that, but I'm reasonably sure it will break
existing setups.

Thanks!
