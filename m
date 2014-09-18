From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/2 v2 nf-next] net: bridge: don't register netfilter
 call_iptables hooks by default
Date: Thu, 18 Sep 2014 16:31:08 +0200
Message-ID: <20140918143108.GB8484@breakpoint.cc>
References: <1410969137-11885-1-git-send-email-fw@strlen.de>
 <20140918133511.GA8740@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140918133511.GA8740@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Wed, Sep 17, 2014 at 05:52:16PM +0200, Florian Westphal wrote:
> > Jesper reports that kernels with CONFIG_BRIDGE_NETFILTER=n show significantly
> > better performance vs. CONFIG_BRIDGE_NETFILTER=y, even with
> > bridge-nf-call-iptables=0.
> >
> > This is because bridge registers some bridge netfilter hooks at
> > module load time, so the static key to bypass nf rule evaluation
> > via NF_HOOK() is false.
> 
> I'm attaching a patch to decouple bridge netfilter from the bridge
> core.  The idea is to encapsulate the hook registration and most of
> its code in a separated module: br_netfilter.

Right, thats better.

I did not do this since it means modprobe bridge.ko will no longer
register the needed sysctls, and I deemed autoloading pointless
since that means the hooks are registered on bridge.ko load.

Also, it seems to be that we will have to wait forever to eventually
get rid of the autoload...

> I also guess most distributors will use CONFIG_BRIDGE_NETFILTER=m.
> Then, users will get a warning message to let them know that they will
> have to modprobe br_netfilter in the future if they need it, so we can
> remove the deferred request_module from the br init path.

Hmm, not sure if its safe to do this, e.g. with bridge=y,
br_netfilter=m, module might not yet be present in such cases?

Also, what about this:
iptables-restore < rules.txt
modprobe bridge
brctl addbr ...
brctl addif ...

at this point, any packet forwarded by bridge is filtered
via iptables.

After your patch, this might no longer be the case, if the modprobe
call is delayed (maybe this is far-fetched and not an issue in practice)?

2nd hypothetical issue:
modprobe bridge
sysctl net.bridge.bridge-nf-call-iptables=0

The sysctl could fail when br_nf_core is not yet present.

> Unless I'm missing anything, I think br_netfilter should have been a
> separated module since the beginning. The hook registration in other
> netfilter modules is also ruled by rmmod/modprobe, so better if we
> recover that path in this code.

Agreed.

> Kconfig (bridge=y, br_netfilter=m) and so on, btw. I also may include
> part of your original patch description if you're OK with it.

Sure, go ahead.

> Please, let me know if I overlook anything. Thanks.

> This patch modularizes br_netfilter so it can be
> rmmod'ed, thus, the hooks can be unregistered.

I see.  Yes, that makes sense.

Another alternative would be to merge both approaches.
I.e, use my patch, but move all the hook registration to
your proposed br_nf_core module.

The sysctls would still be registered from bridge.ko.

Then, if call_iptables is set and iptables rules are active,
do the module autoload and print the warning from your patch, telling
people to modprobe br_nf_core if they want the filtering.

Unfortunately, we'd have to export (from bridge.ko) some hook
to allow br_nf_core to signal that the hooks have been registered.

Then, in two years or so, we would remove the autoload hook
in the packet procesing path.

The only other disadvantage that I see is that we'd still have
the bridge-nf-* sysctls in bridge.ko rather than the new glue module.
