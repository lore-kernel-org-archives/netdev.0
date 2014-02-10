From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Mon, 10 Feb 2014 11:31:45 -0500
Message-ID: <52F8FEF1.60407@redhat.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17087 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752883AbaBJQcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 11:32:03 -0500
In-Reply-To: <52F79990.3000400@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/09/2014 10:06 AM, Jamal Hadi Salim wrote:
>
> This patch allows something equivalent to
> "brctl showmacs <bridge device>" with iproute2
> syntax "bridge link br <bridge device>"
> Filtering by bridge is done in the kernel.
> The current setup doesnt scale when you have many bridges each
> with large fdbs (preliminary fix with the kernel patch).
>
> iproute2 allows filtering by bridge port, example:
> "bridge link br br1234 dev port1234"
> but the filtering is done in user space.
> In a future patch i would like to do the port filtering
> in the kernel. As well, adding a MAC filter in the kernel
> makes sense.
>
> Kernel patch is against net-next.
>
> cheers,
> jamal
>
> bridge-fdb-filter1
>
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 393b1bc..507ea4e 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2423,26 +2423,50 @@ static int rtnl_fdb_dump(struct sk_buff *skb,
struct netlink_callback *cb)
>  {
>  	int idx = 0;
>  	struct net *net = sock_net(skb->sk);
> +	const struct net_device_ops *ops;
>  	struct net_device *dev;
> +	struct ndmsg *ndm;
>
> -	rcu_read_lock();
> -	for_each_netdev_rcu(net, dev) {
> -		if (dev->priv_flags & IFF_BRIDGE_PORT) {
> -			struct net_device *br_dev;
> -			const struct net_device_ops *ops;
> -
> -			br_dev = netdev_master_upper_dev_get(dev);
> -			ops = br_dev->netdev_ops;
> -			if (ops->ndo_fdb_dump)
> -				idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
> +	ndm = nlmsg_data(cb->nlh);
> +	if (ndm->ndm_ifindex) {

We get really lucky here that ndm_ifindex and ifi_index happen to map to
the same location.

> +		dev = __dev_get_by_index(net, ndm->ndm_ifindex);
> +		if (dev == NULL) {
> +			pr_info("PF_BRIDGE: RTM_GETNEIGH with unknown ifindex\n");
> +			return -ENODEV;
> +		}
> +	
> +		if (!(dev->priv_flags & IFF_EBRIDGE)) {
> +			pr_info("PF_BRIDGE: RTM_GETNEIGH %s not a bridge device\n",
> +				dev->name);
> +			return -EINVAL;
>  		}
> +		ops = dev->netdev_ops;
> +		if (ops->ndo_fdb_dump) {
> +			idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
> +		} else {
> +			pr_info("PF_BRIDGE: RTM_GETNEIGH %s no dumper\n",
> +				dev->name);
> +			return -EINVAL;
> +		}

I agree with both of Johns commens fro the above code.
I think you can use ndo_dflt_fdb_dump() here and remove the first check
for IFF_EBRIDGE.

The only odd thing is that it would permit syntax like:
 # bridge fbd show br eth0
or
 # bridge fdb show br macvlan0

but I think that's ok.

> +	} else {
> +		rcu_read_lock();
> +		for_each_netdev_rcu(net, dev) {
> +			if (dev->priv_flags & IFF_BRIDGE_PORT) {
> +				struct net_device *br_dev;
> +				br_dev = netdev_master_upper_dev_get(dev);
> +				ops = br_dev->netdev_ops;
> +				if (ops->ndo_fdb_dump)
> +					idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
> +			}
>
> -		if (dev->netdev_ops->ndo_fdb_dump)
> -			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, idx);
> -		else
> -			idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
> +			if (dev->netdev_ops->ndo_fdb_dump)
> +				idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev,
> +								    idx);
> +			else
> +				idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
> +		}
> +		rcu_read_unlock();
>  	}
> -	rcu_read_unlock();
>
>  	cb->args[0] = idx;
>  	return skb->len;
>
>
> iprt-fdb-brfilter1
>
>
> diff --git a/bridge/fdb.c b/bridge/fdb.c
> index e2e53f1..f3073d6 100644
> --- a/bridge/fdb.c
> +++ b/bridge/fdb.c
> @@ -33,7 +33,7 @@ static void usage(void)
>  	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace }
ADDR dev DEV {self|master} [ temp ]\n"
>  		        "              [router] [ dst IPADDR] [ vlan VID ]\n"
>  		        "              [ port PORT] [ vni VNI ] [via DEV]\n");
> -	fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
> +	fprintf(stderr, "       bridge fdb {show} [ br BRDEV ] [ dev DEV ]\n");

'port' option is now allowed in the show operation

-vlad

>  	exit(-1);
>  }
>
> @@ -152,18 +152,35 @@ int print_fdb(const struct sockaddr_nl *who,
struct nlmsghdr *n, void *arg)
>
>  static int fdb_show(int argc, char **argv)
>  {
> +	struct ndmsg ndm = { };
>  	char *filter_dev = NULL;
> +	char *br = NULL;
> +
> +	ndm.ndm_family = PF_BRIDGE;
> +	ndm.ndm_state = NUD_NOARP;
>
>  	while (argc > 0) {
> -		if (strcmp(*argv, "dev") == 0) {
> +		if ((strcmp(*argv, "port") == 0) || strcmp(*argv, "dev") == 0) {
>  			NEXT_ARG();
> -			if (filter_dev)
> -				duparg("dev", *argv);
>  			filter_dev = *argv;
> +		} else if (strcmp(*argv, "br") == 0) {
> +			NEXT_ARG();
> +			br = *argv;
> +		} else {
> +			if (matches(*argv, "help") == 0)
> +				usage();
>  		}
>  		argc--; argv++;
>  	}
>
> +	if (br) {
> +		ndm.ndm_ifindex = ll_name_to_index(br);
> +		if (ndm.ndm_ifindex == 0) {
> +			fprintf(stderr, "Cannot find bridge device \"%s\"\n", br);
> +			return -1;
> +		}
> +	}
> +
>  	if (filter_dev) {
>  		filter_index = if_nametoindex(filter_dev);
>  		if (filter_index == 0) {
> @@ -171,13 +188,15 @@ static int fdb_show(int argc, char **argv)
>  				filter_dev);
>  			return -1;
>  		}
> +
>  	}
>
> -	if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETNEIGH) < 0) {
> +	if (rtnl_dump_request(&rth, RTM_GETNEIGH, &ndm, sizeof(struct
ndmsg)) < 0) {
>  		perror("Cannot send dump request");
>  		exit(1);
>  	}
>
> +
>  	if (rtnl_dump_filter(&rth, print_fdb, stdout) < 0) {
>  		fprintf(stderr, "Dump terminated\n");
>  		exit(1);
>
