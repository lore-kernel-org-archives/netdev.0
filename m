From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2 nf-next] net: bridge: don't register netfilter
 call_iptables hooks by default
Date: Wed, 17 Sep 2014 14:15:30 +0200
Message-ID: <20140917121530.GA3750@salvia>
References: <1410882457-16641-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410882457-16641-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Tue, Sep 16, 2014 at 05:47:36PM +0200, Florian Westphal wrote:
> Jesper reports that kernels with CONFIG_BRIDGE_NETFILTER=n show significantly
> better performance vs. CONFIG_BRIDGE_NETFILTER=y, even with
> bridge-nf-call-iptables=0.
> 
> This is because bridge registers some bridge netfilter hooks at
> module load time, so the static key to bypass nf rule evaluation
> via NF_HOOK() is false.
> 
> The hooks serve no purpose, unless iptables filtering for bridges is
> desired (i.e., bridge-nf-call-*=1 and active iptables rules present).
> 
> The proper solution would be to just change the bridge-nf-call-iptables sysctl
> default value to 0 and then register the hooks when user enables call-iptables
> sysctl.  We cannot do that though since it breaks existing setups.
>
> The next best solution is to delay registering of the hooks until
> we know that
> 
> a) call-iptables sysctl is enabled (this is the default)
> AND
> b) ip(6)tables rules are loaded.
> 
> This adds br_nf_check_call_iptables() helper in bridge input before
> bridge 'prerouting' (sic) hooks to perform this check.
> 
> IOW, if user does not turn off call-iptables sysctl on the bridge, hook
> registering is only done if NFPROTO_IPV4/IPV6 hooks are registered as
> well once the first packet arrives on a bridge port.
> 
> Doing this check for every packet is still faster than registering
> the hooks unconditionally.  To not add overhead for setups where
> the call-iptables hooks are required, a static key shortcut is provided.
> 
> As its not possible to register hooks from bh context (grabs mutex)
> its scheduled via workqueue.

My main concern with this approach is that we may let packets go
through unfiltered for some little time until the worker thread has
the chance to register the hooks.

Alternatives that I see for these are:

* pr_info to indicate the br_netfilter enable by default is
  deprecated. Similar to your small patch 2/2, but it will take quite
  some time until we can finally change this to zero.

* I think we can unregister the hooks when we notice that all
  bridge-nf-call-*tables are zero from the sysctl. We register them if
  any of them becomes 1 again.

Let me know, thanks.
