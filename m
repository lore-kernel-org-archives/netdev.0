From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 00/10] We must use rcu_barrier() on module unload
Date: Tue, 23 Jun 2009 18:44:21 -0700
Message-ID: <20090624014421.GN6748@linux.vnet.ibm.com>
References: <20090623150330.22490.87327.stgit@localhost>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dougthompson-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	bluesmoke-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	christine.caulfield-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, adilger-xsfywfwIY+M@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090623150330.22490.87327.stgit@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 23, 2009 at 05:03:53PM +0200, Jesper Dangaard Brouer wrote:
> This patch series is an attempt to cleanup the entire tree, for
> potential oops'es during module unload, due to outstanding RCU
> callbacks. (My last rcu_barrier patch series only addressed net/).
> 
> If an unloadable module uses RCU callbacks, it need to use
> rcu_barrier() so that the module may be safely unloaded.
> 
> For documentation see:
> 
>  Paul E. McKenney's Blog
>  http://paulmck.livejournal.com/7314.html
> 
>  http://lwn.net/Articles/217484/
> 
>  Documentation/RCU/rcubarrier.txt
> 
> 
> Looking through the Linux kernel for call_rcu() users and unloadable
> modules I found 10 modules that didn't behave correctly.

These look good from an RCU viewpoint, but I am in no better position
than is Jesper to analyze the individual modules.  From an RCU
viewpoint:

Acked-by: Paul E. McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

> Please: MAINTAINERS needs to verify that the module exit code prevent
> any new RCU callbacks from being posted (before rcu_barrier() is
> called). (I have tried to do this verification, but most of these
> module are simply too large and complex for me to verify this within
> reasonable time)
> 
> [Overview description, following patch ordering]
> 
> The modules ext4, bridge, mac80211, sunrpc, nfs and ipv6 are fairly
> straight forward (maintainers still needs to check for prevent of new
> RCU callbacks).
> 
> The module decnet, has disabled its module_exit() (since ^1da177e) but
> it still seems relevant to keep the code updated.
> 
> The modules edac_core and cfq-iosched, has implemented their own
> open-coded wait_for_completion() scheme, in order to wait for
> call_rcu() calls.  Maintainers needs to look into removing this code
> and using rcu_barrier() instead.
> 
> The module nf_conntrack, has embedded some comments that I would like
> Patrick McHardy to look at.  As I'm not sure which is are most optimal
> place to call rcu_barrier().  The patch probably calls rcu_barrier()
> too much, but its a better safe than sorry approach.
> 
> 
> I have made a patch for each individual module, so objections can be
> made on a per module basis.  I have Cc'ed all of the patches to the
> maintainers of each module (according to the MAINTAINERS file).
> 
> 
> The patchset is made on top of Linus Torvalds tree (starting on top of
> commit f234012f52a3).
> 
> Who wants to pickup these patches? (I usually go through DaveM, but
> this also touches subsystems that are not (yet?) under DaveM's
> maintainer ship)
> 
> 
> ---
> Jesper Dangaard Brouer (10):
>       nf_conntrack: Use rcu_barrier().
>       cfq-iosched: Uses its own open-coded rcu_barrier.
>       edac_core: Uses call_rcu() and its own wait_for_completion scheme.
>       decnet: Use rcu_barrier() on module unload.
>       ipv6: Use rcu_barrier() on module unload.
>       nfs: Use rcu_barrier() on module unload.
>       sunrpc: Use rcu_barrier() on unload.
>       mac80211: Use rcu_barrier() on unload.
>       bridge: Use rcu_barrier() instead of syncronize_net() on unload.
>       ext4: Use rcu_barrier() on module unload.
> 
> 
>  block/cfq-iosched.c                     |    6 ++++++
>  drivers/edac/edac_device.c              |    5 +++++
>  drivers/edac/edac_mc.c                  |    5 +++++
>  drivers/edac/edac_pci.c                 |    5 +++++
>  fs/ext4/mballoc.c                       |    4 +++-
>  fs/nfs/inode.c                          |    1 +
>  net/bridge/br.c                         |    2 +-
>  net/decnet/af_decnet.c                  |    6 ++++++
>  net/ipv6/af_inet6.c                     |    2 ++
>  net/mac80211/main.c                     |    2 ++
>  net/netfilter/nf_conntrack_core.c       |    5 +++++
>  net/netfilter/nf_conntrack_standalone.c |    2 ++
>  net/sunrpc/sunrpc_syms.c                |    1 +
>  13 files changed, 44 insertions(+), 2 deletions(-)
> 
> 
> --
> Best regards,
>   Jesper Brouer
>   ComX Networks A/S
>   Linux Network developer
>   Cand. Scient Datalog / MSc.
>   Author of http://adsl-optimizer.dk
>   LinkedIn: http://www.linkedin.com/in/brouer
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
