From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v1 2/2] bridge: export multicast database via
 netlink
Date: Fri, 30 Nov 2012 11:26:18 +0000
Message-ID: <20121130112618.GF30697@casper.infradead.org>
References: <1354269514-1863-1-git-send-email-amwang@redhat.com>
 <1354269514-1863-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41930 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932820Ab2K3L0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 06:26:22 -0500
Content-Disposition: inline
In-Reply-To: <1354269514-1863-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/12 at 05:58pm, Cong Wang wrote:
> +enum {
> +	MDBA_UNSPEC,
> +	MDBA_MDB,
> +	MDBA_ROUTER,
> +	__MDBA_MAX,
> +};
> +#define MDBA_MAX (__MDBA_MAX - 1)
> +
> +enum {
> +	MDBA_MDB_UNSPEC,
> +	MDBA_MCADDR,
> +	MDBA_BRPORT_NO,
> +	__MDBA_MDB_MAX,
> +};
> +#define MDBA_MDB_MAX (__MDBA_MDB_MAX - 1)

So juse use these enums from iproute2 directly instead redefining
them.

> diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
> new file mode 100644
> index 0000000..3751f7d
> --- /dev/null
> +++ b/net/bridge/br_mdb.c
> @@ -0,0 +1,166 @@
> +#include <linux/err.h>
> +#include <linux/if_ether.h>
> +#include <linux/igmp.h>
> +#include <linux/kernel.h>
> +#include <linux/netdevice.h>
> +#include <linux/rculist.h>
> +#include <linux/skbuff.h>
> +#include <linux/slab.h>
> +#include <net/ip.h>
> +#if IS_ENABLED(CONFIG_IPV6)
> +#include <net/ipv6.h>
> +#include <net/mld.h>
> +#include <net/addrconf.h>
> +#include <net/ip6_checksum.h>
> +#endif
> +
> +#include "br_private.h"
> +
> +struct br_port_msg {
> +	int ifindex;
> +};

Make that __u32 ifindex and move the definition into if_bridge.h so
you can reuse it in iproute2.

> +static int br_rports_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
> +			       u32 seq, struct net_device *dev)
> +{
> +	struct net_bridge *br = netdev_priv(dev);
> +	struct net_bridge_port *p;
> +	struct hlist_node *n;
> +	struct nlattr *nest;
> +
> +	if (!br->multicast_router || hlist_empty(&br->router_list)) {
> +		printk(KERN_INFO "no router on bridge\n");
> +		return 0;
> +	}
> +
> +	nest = nla_nest_start(skb, MDBA_ROUTER);
> +	if (nest == NULL)
> +		return -EMSGSIZE;
> +
> +	hlist_for_each_entry_rcu(p, n, &br->router_list, rlist) {
> +		if (p && nla_put_u16(skb, MDBA_BRPORT_NO, p->port_no))
> +			goto fail;
> +	}

port_no 0 is reserved, right?

We can reduce message size here and make it easier to extend by
using p->port_no as the attribute id by doing something like this:

hlist_for_each_entry_rcu(p, n, &br->router_list, rlist)
	if (nla_put_flag(skb, p->port_no))
		goto fail;

This will result in an empty attribute body for now and if you ever
need to include more data you can simply start putting attributes
insde that empty body and old users will continue to function.

> +static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
> +			    u32 seq, struct net_device *dev)
> +{
> +	struct net_bridge *br = netdev_priv(dev);
> +	struct net_bridge_mdb_htable *mdb;
> +	struct nlattr *nest;
> +	unsigned int i;
> +	int s_idx;
> +
> +	if (br->multicast_disabled) {
> +		printk(KERN_INFO "multicast is disabled on bridge\n");
> +		return 0;
> +	}
> +
> +	mdb = rcu_dereference(br->mdb);
> +	if (!mdb) {
> +		printk(KERN_INFO "no mdb on bridge\n");
> +		return 0;
> +	}
> +
> +	cb->seq = mdb->seq;

I'm not sure how this is supposed to worl. cb->seq may not change
throughout the complete dump process or the dump will be interrupted
and the user is required to restart.

Each bridge will have its own mdb resulting in a differing seq.

> +	s_idx = cb->args[1];
> +	if (s_idx >= mdb->max)
> +		return 0;
> +
> +	nest = nla_nest_start(skb, MDBA_MDB);
> +	if (nest == NULL)
> +		return -EMSGSIZE;
> +
> +	for (i = s_idx; i < mdb->max; i++) {
> +		struct hlist_node *h;
> +		struct net_bridge_mdb_entry *mp;
> +		struct net_bridge_port_group *p, **pp;
> +		struct net_bridge_port *port;
> +
> +		hlist_for_each_entry_rcu(mp, h, &mdb->mhash[i], hlist[mdb->ver]) {
> +			for (pp = &mp->ports;
> +			     (p = rcu_dereference(*pp)) != NULL;
> +			      pp = &p->next) {
> +				port = p->port;
> +				if (port) {
> +					printk(KERN_INFO "port %u, mcaddr: %pI4\n", port->port_no, &mp->addr.u.ip4);
> +					if (nla_put_u16(skb, MDBA_BRPORT_NO, port->port_no) ||
> +					    nla_put_be32(skb, MDBA_MCADDR, p->addr.u.ip4))
> +						goto fail;
> +				}
> +			}
> +		}
> +	}
> +
> +	cb->args[1] = i;
> +	nla_nest_end(skb, nest);
> +	return 0;
> +fail:
> +	cb->args[1] = i;
> +	nla_nest_cancel(skb, nest);
> +	return -EMSGSIZE;

This still relies on the assumption that all of mdb->mhash[] will fit
into a single netlink message. Is that guaranteed? If so that would
simplify this a lot and you wouldn't have to worry about rehashes at
all.

As-is it looks broken, you store an offset into the hash but if you
run out of space you trim away the complete nested attribute again
and thus offseting will actually result in data loss because that
data has never been wired but you will skip over it next time.

You need something like this:
        for (i = 0; i < mdb->max; i++) {
                [...]
                hlist_for_each_entry_rcu(mp, h, &mdb->mhash[i], hlist[mdb->ver]) {
                        if (idx < s_idx)
                                goto skip;

                        hentry = nla_nest_start(...)
                        if (nla_put_u16(...) ||
                            nla_put_32(...)) {
                                nla_nest_cancel(skb, hentry);
				err = -EMSGSIZE;
                                goto out;
                        }
                        nla_nest_end(skb, hentry);
                skip:
                        idx++;
                }
        }

out:
	cb->args[1] = idx;
	nla_nest_end(skb, nest);
	return err;

> +}
> +
> +static int br_mdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
> +{
> +	struct net_device *dev;
> +	struct net *net = sock_net(skb->sk);
> +	struct nlmsghdr *nlh;
> +	u32 seq = cb->nlh->nlmsg_seq;
> +	int idx = 0, s_idx;
> +
> +	s_idx = cb->args[0];
> +
> +	rcu_read_lock();
> +
> +	for_each_netdev_rcu(net, dev) {
> +		if (dev->priv_flags & IFF_EBRIDGE) {
> +			struct br_port_msg *bpm;
> +
> +			if (idx < s_idx)
> +				goto cont;
> +
> +			nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid,
> +					seq, RTM_GETMDB,
> +					sizeof(*bpm), NLM_F_MULTI);
> +			if (nlh == NULL)
> +				break;
> +
> +			bpm = nlmsg_data(nlh);
> +			bpm->ifindex = dev->ifindex;
> +			if (br_mdb_fill_info(skb, cb, seq, dev) < 0) {
> +				printk(KERN_INFO "br_mdb_fill_info failed\n");
> +				goto fail;
> +			}
> +			if (br_rports_fill_info(skb, cb, seq, dev) < 0) {
> +				printk(KERN_INFO "br_rports_fill_info failed\n");
> +				goto fail;
> +			}
> +
> +			nlmsg_end(skb, nlh);
> +cont:
> +			idx++;
> +		}
> +	}
> +
> +	rcu_read_unlock();
> +	cb->args[0] = idx;
> +	return skb->len;
> +
> +fail:
> +	rcu_read_unlock();
> +	nlmsg_cancel(skb, nlh);
> +	return skb->len;

Assuming you implement partial messages as proposed above you don't
want to nlmsg_cancel() here. Instead you just want to nlmsg_end() and
send out the message with a partial MDB_MDBA and continue where you
left off.
