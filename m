From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC net-next 3/3] mpls: new ipmpls device for encapsulating IP packets as mpls
Date: Tue, 02 Jun 2015 13:26:43 -0500
Message-ID: <87a8wivue4.fsf@x220.int.ebiederm.org>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
	<1433177175-16775-4-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Thomas Graf <tgraf@suug.ch>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34677 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753980AbbFBSbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 14:31:47 -0400
In-Reply-To: <1433177175-16775-4-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Mon, 1 Jun 2015 17:46:15 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> Allow creating an mpls device for the purposes of encapsulating IP
> packets with:
>
>   ip link add type ipmpls
>
> This device defines its per-nexthop encapsulation data as a stack of
> labels, in the same format as for RTA_NEWST. It uses the encap data
> which will have been stored in the IP route to encapsulate the packet
> with that stack of labels, with the last label corresponding to a
> local label that defines how the packet will be sent out. The device
> sends packets over loopback to the local MPLS forwarding logic which
> performs all of the work.
>
> Stats are implemented, although any error in the sending via the real
> interface will be handled by the main mpls forwarding code and so not
> accounted by the interface.

Eeek stats!  Lots of unnecessary overhead.  If stats were ok we could
have simply reduced the cost of struct net_device to the point where it
would not matter.

This is really a bad hack for not getting in and being able to set
dst_output the way the xfrm infrastructure does.

What we really want here is xfrm-lite.  By lite I mean the tunnel
selection criteria is simple enough that it fits into the normal
routing table instead of having to do weird flow based magic that
is rarely needed.

I believe what we want are the xfrm stacking of dst entries.

Eric


> This implementation is based on an alternative earlier implementation
> by Eric W. Biederman.
>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  include/uapi/linux/if_arp.h |   1 +
>  net/mpls/Kconfig            |   5 +
>  net/mpls/Makefile           |   1 +
>  net/mpls/af_mpls.c          |   2 +
>  net/mpls/ipmpls.c           | 284 ++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 293 insertions(+)
>  create mode 100644 net/mpls/ipmpls.c
>
> diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
> index 4d024d75d64b..17d669fd1781 100644
> --- a/include/uapi/linux/if_arp.h
> +++ b/include/uapi/linux/if_arp.h
> @@ -88,6 +88,7 @@
>  #define ARPHRD_IEEE80211_RADIOTAP 803	/* IEEE 802.11 + radiotap header */
>  #define ARPHRD_IEEE802154	  804
>  #define ARPHRD_IEEE802154_MONITOR 805	/* IEEE 802.15.4 network monitor */
> +#define ARPHRD_MPLS	806		/* IP and IPv6 over MPLS tunnels */
>  
>  #define ARPHRD_PHONET	820		/* PhoNet media type		*/
>  #define ARPHRD_PHONET_PIPE 821		/* PhoNet pipe header		*/
> diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
> index 17bde799c854..5264da94733a 100644
> --- a/net/mpls/Kconfig
> +++ b/net/mpls/Kconfig
> @@ -27,4 +27,9 @@ config MPLS_ROUTING
>  	help
>  	 Add support for forwarding of mpls packets.
>  
> +config MPLS_IPTUNNEL
> +	tristate "MPLS: IP over MPLS tunnel support"
> +	help
> +	 A network device that encapsulates ip packets as mpls
> +
>  endif # MPLS
> diff --git a/net/mpls/Makefile b/net/mpls/Makefile
> index 65bbe68c72e6..3a93c14b23c5 100644
> --- a/net/mpls/Makefile
> +++ b/net/mpls/Makefile
> @@ -3,5 +3,6 @@
>  #
>  obj-$(CONFIG_NET_MPLS_GSO) += mpls_gso.o
>  obj-$(CONFIG_MPLS_ROUTING) += mpls_router.o
> +obj-$(CONFIG_MPLS_IPTUNNEL) += ipmpls.o
>  
>  mpls_router-y := af_mpls.o
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 7b3f732269e4..68bdfbdddfaf 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -615,6 +615,7 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,
>  
>  	return 0;
>  }
> +EXPORT_SYMBOL(nla_put_labels);
>  
>  int nla_get_labels(const struct nlattr *nla,
>  		   u32 max_labels, u32 *labels, u32 label[])
> @@ -660,6 +661,7 @@ int nla_get_labels(const struct nlattr *nla,
>  	*labels = nla_labels;
>  	return 0;
>  }
> +EXPORT_SYMBOL(nla_get_labels);
>  
>  static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>  			       struct mpls_route_config *cfg)
> diff --git a/net/mpls/ipmpls.c b/net/mpls/ipmpls.c
> new file mode 100644
> index 000000000000..cf6894ae0c61
> --- /dev/null
> +++ b/net/mpls/ipmpls.c
> @@ -0,0 +1,284 @@
> +#include <linux/types.h>
> +#include <linux/netdevice.h>
> +#include <linux/if_vlan.h>
> +#include <linux/if_arp.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <linux/module.h>
> +#include <linux/mpls.h>
> +#include "internal.h"
> +
> +static LIST_HEAD(ipmpls_dev_list);
> +
> +#define MAX_NEW_LABELS 2
> +
> +struct ipmpls_dev_priv {
> +	struct net_device *out_dev;
> +	struct list_head list;
> +	struct net_device *dev;
> +};
> +
> +static netdev_tx_t ipmpls_dev_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct ipmpls_dev_priv *priv = netdev_priv(dev);
> +	struct net_device *out_dev = priv->out_dev;
> +	struct mpls_shim_hdr *hdr;
> +	bool bottom_of_stack = true;
> +	int len = skb->len;
> +	const void *encap;
> +	int num_labels;
> +	unsigned ttl;
> +	const u32 *labels;
> +	int ret;
> +	int i;
> +
> +	num_labels = dst_get_encap(skb, &encap) / 4;
> +	if (!num_labels)
> +		goto drop;
> +
> +	labels = encap;
> +
> +	/* Obtain the ttl */
> +	if (skb->protocol == htons(ETH_P_IP)) {
> +		ttl = ip_hdr(skb)->ttl;
> +	} else if (skb->protocol == htons(ETH_P_IPV6)) {
> +		ttl = ipv6_hdr(skb)->hop_limit;
> +	} else if (skb->protocol == htons(ETH_P_MPLS_UC)) {
> +		ttl = mpls_entry_decode(mpls_hdr(skb)).ttl;
> +		bottom_of_stack = false;
> +	} else {
> +		goto drop;
> +	}
> +
> +	/* Now that the encap has been retrieved, there's no longer
> +	 * any need to keep the dst around so clear it out.
> +	 */
> +	skb_dst_drop(skb);
> +	skb_orphan(skb);
> +
> +	skb->inner_protocol = skb->protocol;
> +	skb->inner_network_header = skb->network_header;
> +
> +	skb_push(skb, num_labels * sizeof(*hdr));
> +	skb_reset_network_header(skb);
> +	hdr = mpls_hdr(skb);
> +
> +	for (i = num_labels - 1; i >= 0; i--) {
> +		hdr[i] = mpls_entry_encode(labels[i], ttl, 0, bottom_of_stack);
> +		bottom_of_stack = false;
> +	}
> +
> +	skb->dev = out_dev;
> +	skb->protocol = htons(ETH_P_MPLS_UC);
> +
> +	ret = dev_hard_header(skb, out_dev, ETH_P_MPLS_UC,
> +			      out_dev->dev_addr, NULL, len);
> +	if (ret >= 0)
> +		ret = dev_queue_xmit(skb);
> +	if (ret)
> +		goto drop;
> +
> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes += len;
> +
> +	return 0;
> +
> +drop:
> +	dev->stats.tx_dropped++;
> +	kfree_skb(skb);
> +	return NETDEV_TX_OK;
> +}
> +
> +static int ipmpls_dev_init(struct net_device *dev)
> +{
> +	struct ipmpls_dev_priv *priv = netdev_priv(dev);
> +
> +	list_add_tail(&priv->list, &ipmpls_dev_list);
> +
> +	return 0;
> +}
> +
> +static void ipmpls_dev_uninit(struct net_device *dev)
> +{
> +	struct ipmpls_dev_priv *priv = netdev_priv(dev);
> +
> +	list_del_init(&priv->list);
> +}
> +
> +static void ipmpls_dev_free(struct net_device *dev)
> +{
> +	free_netdev(dev);
> +}
> +
> +static const struct net_device_ops ipmpls_netdev_ops = {
> +	.ndo_init		= ipmpls_dev_init,
> +	.ndo_start_xmit		= ipmpls_dev_xmit,
> +	.ndo_uninit		= ipmpls_dev_uninit,
> +};
> +
> +#define IPMPLS_FEATURES (NETIF_F_SG |			\
> +			 NETIF_F_FRAGLIST |		\
> +			 NETIF_F_HIGHDMA |		\
> +			 NETIF_F_VLAN_CHALLENGED)
> +
> +static void ipmpls_dev_setup(struct net_device *dev)
> +{
> +	dev->netdev_ops		= &ipmpls_netdev_ops;
> +
> +	dev->type		= ARPHRD_MPLS;
> +	dev->flags		= IFF_NOARP;
> +	netif_keep_dst(dev);
> +	dev->addr_len		= 0;
> +	dev->features		|= NETIF_F_LLTX;
> +	dev->features		|= IPMPLS_FEATURES;
> +	dev->hw_features	|= IPMPLS_FEATURES;
> +	dev->vlan_features	= 0;
> +
> +	dev->destructor = ipmpls_dev_free;
> +}
> +
> +static int ipmpls_dev_validate(struct nlattr *tb[], struct nlattr *data[])
> +{
> +	return 0;
> +}
> +
> +static int ipmpls_dev_newlink(struct net *src_net, struct net_device *dev,
> +			      struct nlattr *tb[], struct nlattr *data[])
> +{
> +	struct ipmpls_dev_priv *priv = netdev_priv(dev);
> +
> +	priv->out_dev = src_net->loopback_dev;
> +	priv->dev = dev;
> +
> +	dev->hard_header_len =
> +		priv->out_dev->hard_header_len +
> +		sizeof(struct mpls_shim_hdr) * MAX_NEW_LABELS;
> +
> +	return register_netdevice(dev);
> +}
> +
> +static void ipmpls_dev_dellink(struct net_device *dev, struct list_head *head)
> +{
> +	unregister_netdevice_queue(dev, head);
> +}
> +
> +static int ipmpls_dev_parse_encap(const struct net_device *dev,
> +				  const struct nlattr *nla,
> +				  void *encap)
> +{
> +	u32 labels;
> +
> +	if (nla_len(nla) / 4 > MAX_NEW_LABELS)
> +		return -EINVAL;
> +
> +	if (encap && nla_get_labels(nla, MAX_NEW_LABELS, &labels, encap))
> +		return -EINVAL;
> +
> +	/* Stored encap size is the same as the rtnl encap len */
> +	return nla_len(nla);
> +}
> +
> +static int ipmpls_dev_fill_encap(const struct net_device *dev,
> +				 struct sk_buff *skb, int encap_len,
> +				 const void *encap)
> +{
> +	return nla_put_labels(skb, RTA_ENCAP, encap_len / 4, encap);
> +}
> +
> +static int ipmpls_dev_match_encap(const struct net_device *dev,
> +				  const struct nlattr *nla, int encap_len,
> +				  const void *encap)
> +{
> +	unsigned nla_labels;
> +	struct mpls_shim_hdr *nla_label;
> +	const u32 *stored_labels = encap;
> +	int i;
> +
> +	/* Stored encap size is the same as the rtnl encap len */
> +	if (nla_len(nla) != encap_len)
> +		return 1;
> +
> +	nla_labels = nla_len(nla) / 4;
> +	nla_label = nla_data(nla);
> +
> +	for (i = 0; i < nla_labels; i++) {
> +		struct mpls_entry_decoded dec;
> +
> +		dec = mpls_entry_decode(nla_label + i);
> +
> +		if (stored_labels[i] != dec.label)
> +			return 1;
> +	}
> +
> +	return 0;
> +}
> +
> +static struct rtnl_link_ops ipmpls_ops = {
> +	.kind		= "ipmpls",
> +	.priv_size	= sizeof(struct ipmpls_dev_priv),
> +	.setup		= ipmpls_dev_setup,
> +	.validate	= ipmpls_dev_validate,
> +	.newlink	= ipmpls_dev_newlink,
> +	.dellink	= ipmpls_dev_dellink,
> +	.parse_encap	= ipmpls_dev_parse_encap,
> +	.fill_encap	= ipmpls_dev_fill_encap,
> +	.match_encap	= ipmpls_dev_match_encap,
> +};
> +
> +static int ipmpls_dev_notify(struct notifier_block *this, unsigned long event,
> +			     void *ptr)
> +{
> +	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
> +
> +	if (event == NETDEV_UNREGISTER) {
> +		struct ipmpls_dev_priv *priv, *priv2;
> +		LIST_HEAD(list_kill);
> +
> +		/* Ignore netns device moves */
> +		if (dev->reg_state != NETREG_UNREGISTERING)
> +			goto done;
> +
> +		list_for_each_entry_safe(priv, priv2, &ipmpls_dev_list, list) {
> +			if (priv->out_dev != dev)
> +				continue;
> +
> +			ipmpls_dev_dellink(priv->dev, &list_kill);
> +		}
> +		unregister_netdevice_many(&list_kill);
> +	}
> +done:
> +	return NOTIFY_OK;
> +}
> +
> +static struct notifier_block ipmpls_dev_notifier = {
> +	.notifier_call = ipmpls_dev_notify,
> +};
> +
> +static int __init ipmpls_init(void)
> +{
> +	int err;
> +
> +	err = register_netdevice_notifier(&ipmpls_dev_notifier);
> +	if (err)
> +		goto out;
> +
> +	err = rtnl_link_register(&ipmpls_ops);
> +	if (err)
> +		goto out_unregister_notifier;
> +out:
> +	return err;
> +out_unregister_notifier:
> +	unregister_netdevice_notifier(&ipmpls_dev_notifier);
> +	goto out;
> +}
> +module_init(ipmpls_init);
> +
> +static void __exit ipmpls_exit(void)
> +{
> +	rtnl_link_unregister(&ipmpls_ops);
> +	unregister_netdevice_notifier(&ipmpls_dev_notifier);
> +}
> +module_exit(ipmpls_exit);
> +
> +MODULE_LICENSE("GPL v2");
> +MODULE_ALIAS_RTNL_LINK("ipmpls");
