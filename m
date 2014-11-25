From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for
 ndo_fdb_add/ndo_fdb_del
Date: Tue, 25 Nov 2014 10:13:12 -0500
Message-ID: <20141125151312.GC27416@gospo.rtplab.test>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37039 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaKYPNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 10:13:46 -0500
Content-Disposition: inline
In-Reply-To: <1416911328-10979-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 11:28:33AM +0100, Jiri Pirko wrote:
> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
> u16 vid to drivers from there.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Structurally this looks fine, just a misspelling noted below.

Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
> new in v3
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c      |  2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  4 +-
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  9 +++--
>  drivers/net/macvlan.c                            |  4 +-
>  drivers/net/vxlan.c                              |  4 +-
>  include/linux/netdevice.h                        |  8 ++--
>  include/linux/rtnetlink.h                        |  6 ++-
>  net/bridge/br_fdb.c                              | 39 ++----------------
>  net/bridge/br_private.h                          |  4 +-
>  net/core/rtnetlink.c                             | 50 ++++++++++++++++++++----
>  10 files changed, 70 insertions(+), 60 deletions(-)
> 
[...]
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index a688268..f2a4b38 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -36,6 +36,7 @@
>  #include <linux/mutex.h>
>  #include <linux/if_addr.h>
>  #include <linux/if_bridge.h>
> +#include <linux/if_vlan.h>
>  #include <linux/pci.h>
>  #include <linux/etherdevice.h>
>  
> @@ -2312,7 +2313,7 @@ errout:
>  int ndo_dflt_fdb_add(struct ndmsg *ndm,
>  		     struct nlattr *tb[],
>  		     struct net_device *dev,
> -		     const unsigned char *addr,
> +		     const unsigned char *addr, u16 vid,
>  		     u16 flags)
>  {
>  	int err = -EINVAL;
> @@ -2338,6 +2339,28 @@ int ndo_dflt_fdb_add(struct ndmsg *ndm,
>  }
>  EXPORT_SYMBOL(ndo_dflt_fdb_add);
>  
> +static int fbd_vid_parse(struct nlattr *vlan_attr, u16 *p_vid)
I presume this is a misspelling?

[...]
> @@ -2370,6 +2394,10 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
>  
>  	addr = nla_data(tb[NDA_LLADDR]);
>  
> +	err = fbd_vid_parse(tb[NDA_VLAN], &vid);
Same here....

> +	if (err)
> +		return err;
> +
>  	err = -EOPNOTSUPP;
>  
>  	/* Support fdb on master device the net/bridge default case */

[...]
> @@ -2465,6 +2496,10 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
>  
>  	addr = nla_data(tb[NDA_LLADDR]);
>  
> +	err = fbd_vid_parse(tb[NDA_VLAN], &vid);
...and here.

> +	if (err)
> +		return err;
> +
>  	err = -EOPNOTSUPP;
>  
>  	/* Support fdb on master device the net/bridge default case */
> @@ -2474,7 +2509,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
>  		const struct net_device_ops *ops = br_dev->netdev_ops;
>  
>  		if (ops->ndo_fdb_del)
> -			err = ops->ndo_fdb_del(ndm, tb, dev, addr);
> +			err = ops->ndo_fdb_del(ndm, tb, dev, addr, vid);
>  
>  		if (err)
>  			goto out;
> @@ -2485,9 +2520,10 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
>  	/* Embedded bridge, macvlan, and any other device support */
>  	if (ndm->ndm_flags & NTF_SELF) {
>  		if (dev->netdev_ops->ndo_fdb_del)
> -			err = dev->netdev_ops->ndo_fdb_del(ndm, tb, dev, addr);
> +			err = dev->netdev_ops->ndo_fdb_del(ndm, tb, dev, addr,
> +							   vid);
>  		else
> -			err = ndo_dflt_fdb_del(ndm, tb, dev, addr);
> +			err = ndo_dflt_fdb_del(ndm, tb, dev, addr, vid);
>  
>  		if (!err) {
>  			rtnl_fdb_notify(dev, addr, RTM_DELNEIGH);
> -- 
> 1.9.3
> 
