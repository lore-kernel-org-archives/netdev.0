From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC 3/7] netfilter: add NF_INET_LOCAL_SOCKET_IN chain type
Date: Wed, 30 Sep 2015 23:48:52 +0200
Message-ID: <20150930214852.GA8443@breakpoint.cc>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
 <1443525140-13493-4-git-send-email-daniel@zonque.org>
 <20150929211959.GF19923@breakpoint.cc>
 <560B8E25.7050801@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, pablo@netfilter.org,
	daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, balazs.scheidler@balabit.com
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46262 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754177AbbI3Vs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 17:48:57 -0400
Content-Disposition: inline
In-Reply-To: <560B8E25.7050801@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Mack <daniel@zonque.org> wrote:
> Of course you can drop certain packets at this point, depending on other
> details. Say, for instance, you want to match all packets that are
> received by a certain task and that are originated from IP addresses of
> a specific subnet, and drop the rest. Rather than adding matches to your
> global firewall configuration for all the ports that tasks may or may
> not listen on, you can just do it on a higher level, from the
> perspective of an administrator. If you decide to let your web server
> listen on another port as well, no firewall rule configuration change is
> needed at all.

We don't have per application configurations, not even with these
patches...?
The configuration is still global/per netns?

> Another use case is accounting. If you want to know how much traffic a
> certain service or application in your system has caused, you don't want
> to match all its ports to firewall rules just in order to get that
> information. Instead, you can now derive that information on a
> per-application base. With this patch set, this even works just fine for
> multicast listeners, which is something that is currently impossible to
> achieve otherwise.

> > So the only 'benefit' is that netcls id is available; but
> > a) why is that even needed and
> 
> It's currently the only way of realizing application-level firewalls,
> and it'd be an awesome feature if it actually worked.

Application level firewall makes me think of proxies.
What exactly are we talking about?
Can you provide examples?

> > b) is such a huge sledgehammer just for net cgroup accounting
> > worth it?
> 
> I really don't know if this approach is intrusive enough to make it
> qualify as sledgehammer. I'd like to see some real-world benchmarks and
> have proof there is a performance decrease for setups that don't use
> such chains.

We have static keys for nf hooks so there is no performance decrease if
no netfilter hooks are active.

HOWEVER, this discussion seems to hint at the opposite, namely that this
will turn into a mandatory or at least auto-enabled feature.

But regardless, I called it a sledgehammer not because of performance
concerns but because just to get this proposed socket matching facility we
now have to put hooks into all protocol handlers and commit to keeping them
there forever.

Also, some time ago Eric suggested to allow binding to tcp ports
from packet sockets to implement userspace-driven TCP stacks (i.e.
kernel would just queue raw frames for the given quadruple withput
caring about ordering etc).

If we allow this proposed change, we'd also have to extend that
with these hooks.

Next time someone mentions that we don't have application matching
but only sk/cgroup tests. Are we then going to consider doing task lookups?

> > For deterministic ingress filtering you can only rely on what
> > is contained in the packet.
> 
> Why so? For deterministic ingress filtering of traffic directed to a
> local socket, you can as well rely on information associated with that
> socket. And this is what application-level firewall rule sets are all about.

Application not running -> different behaviour.  I'm sure thats obvious
to you, but I'm not sure if its obvious to users that their
'match on net clsid 42' won't work anymore when that service isn't running.
