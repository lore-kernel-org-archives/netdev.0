From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2 v2 nf-next] net: bridge: don't register netfilter
 call_iptables hooks by default
Date: Thu, 18 Sep 2014 20:39:56 +0200
Message-ID: <20140918183956.GA3989@salvia>
References: <1410969137-11885-1-git-send-email-fw@strlen.de>
 <20140918133511.GA8740@salvia>
 <20140918143108.GB8484@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140918143108.GB8484@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 18, 2014 at 04:31:08PM +0200, Florian Westphal wrote:
> > I also guess most distributors will use CONFIG_BRIDGE_NETFILTER=m.
> > Then, users will get a warning message to let them know that they will
> > have to modprobe br_netfilter in the future if they need it, so we can
> > remove the deferred request_module from the br init path.
> 
> Hmm, not sure if its safe to do this, e.g. with bridge=y,
> br_netfilter=m, module might not yet be present in such cases?
> 
> Also, what about this:
> iptables-restore < rules.txt
> modprobe bridge
> brctl addbr ...
> brctl addif ...
> 
> at this point, any packet forwarded by bridge is filtered
> via iptables.
> 
> After your patch, this might no longer be the case, if the modprobe
> call is delayed (maybe this is far-fetched and not an issue in practice)?

Agreed, I think we can use your static key approach to drop traffic
from br_handle_frame after the work has called request_module.

> 2nd hypothetical issue:
> modprobe bridge
> sysctl net.bridge.bridge-nf-call-iptables=0
> 
> The sysctl could fail when br_nf_core is not yet present.

Indeed.

We can keep those sysctls there in bridge.ko and deprecated them in
favour of br_netlink. I think we can add some IFLA_BRPORT_NF for the
setlink command to replace the existing global proc nf-call-thing.
We'll have to enhance the 'bridge' tool in iproute2 to support this.
I can see this is packaged in testing already by debian at least.

> Then, in two years or so, we would remove the autoload hook
> in the packet procesing path.

Agreed. By that time, we can kill the bridge.ko <-> br_netfilter.ko
dependency and the /proc call-nf-bridge stuff in favour of br_netlink.

Let me know if you still have any concern. Thanks.
