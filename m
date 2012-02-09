From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Wed, 8 Feb 2012 20:36:27 -0800
Message-ID: <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 08 Feb 2012 19:22:06 -0800
John Fastabend <john.r.fastabend@intel.com> wrote:

> Propagate software FDB table into hardware uc, mc lists when
> the NETIF_F_HW_FDB is set.
> 
> This resolves the case below where an embedded switch is used
> in hardware to do inter-VF or VF-PF switching. This patch
> pushes the FDB entry (specifically the MAC address) into the
> embedded switch with dev_add_uc and dev_add_mc so the switch
> "learns" about the software bridge.
> 
> 
>           veth0  veth2
>             |      |
>           ------------
>           |  bridge0 |   <---- software bridging
>           ------------
>                /
>                /
>   ethx.y      ethx
>     VF         PF
>      \         \          <---- propagate FDB entries to HW
>      \         \
>   --------------------
>   |  Embedded Bridge |    <---- hardware offloaded switching
>   --------------------
> 
> This is only an RFC couple more changes are needed.
> 
> (1) Optimize HW FDB set/del to only walk list if an FDB offloaded
>     device is attached. Or decide it doesn't matter from unlikely()
>     path.
> 
> (2) Is it good enough to just call dev_uc_{add|del} or
>     dev_mc_{add|del}? Or do some devices really need a new netdev
>     callback to do this operation correctly. I think it should be
>     good enough as is.
> 
> (3) wrapped list walk in rcu_read_lock() just in case maybe every
>     case is already inside rcu_read_lock()/unlock().
> 
> Also this is in response to this thread regarding the macvlan and
> exposing rx filters posting now to see if folks think this is the
> right idea and if it will resolve at least the bridge case.
> 
> http://lists.openwall.net/netdev/2011/11/08/135
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  include/linux/netdev_features.h |    2 ++
>  net/bridge/br_fdb.c             |   34 ++++++++++++++++++++++++++++++++++
>  2 files changed, 36 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
> index 77f5202..5936fae 100644

Rather than yet another device feature, I would rather use netlink_notifier
callback. The notifier is more general and generic without messing with internals
of bridge.

