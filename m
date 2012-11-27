From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 2/2] bridge: export multicast database via netlink
Date: Tue, 27 Nov 2012 11:59:05 +0000
Message-ID: <20121127115905.GA16701@casper.infradead.org>
References: <1354009785-20014-1-git-send-email-amwang@redhat.com>
 <1354009785-20014-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41459 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112Ab2K0L7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 06:59:13 -0500
Content-Disposition: inline
In-Reply-To: <1354009785-20014-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/12 at 05:49pm, Cong Wang wrote:
> +static int br_rports_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
> +			       u32 seq, struct net_device *dev)
> +{
> +	struct net_bridge *br = netdev_priv(dev);
> +	struct net_bridge_port *p;
> +	struct hlist_node *n;
> +	struct nlattr *nest, *nest2;
> +
> +	if (!br->multicast_router || hlist_empty(&br->router_list)) {
> +		printk(KERN_INFO "no router on bridge\n");
> +		return 0;
> +	}
> +
> +	nest = nla_nest_start(skb, MDBA_ROUTER);
> +	if (nest == NULL)
> +		return -EMSGSIZE;
> +	nest2 = nla_nest_start(skb, MDBA_MDB_BRPORT);
> +	if (nest2 == NULL)
> +		goto fail;
> +
> +	hlist_for_each_entry_rcu(p, n, &br->router_list, rlist) {
> +		if (p && nla_put_u16(skb, MDBA_BRPORT_NO, p->port_no)) {
> +			nla_nest_cancel(skb, nest2);
> +			goto fail;
> +		}
> +	}
> +
> +	nla_nest_end(skb, nest2);
> +	nla_nest_end(skb, nest);

I would simplify the MDBA_ROUTER attribute to a u16[len(br->router_list)]. If
we ever need something more complex we can retire the MDBA_ROUTER
attribute and replace it with something newer.

> +	nest = nla_nest_start(skb, MDBA_MDB);
> +	if (nest == NULL)
> +		return -EMSGSIZE;
> +
> +	for (i = 0; i < mdb->max; i++) {
> +		struct hlist_node *h;
> +		struct net_bridge_mdb_entry *mp;
> +		struct net_bridge_port_group *p, **pp;
> +		struct net_bridge_port *port;
> +
> +		hlist_for_each_entry_rcu(mp, h, &mdb->mhash[i], hlist[mdb->ver]) {
> +			if (nla_put_be32(skb, MDBA_MDB_MCADDR, mp->addr.u.ip4))
> +				goto fail;
> +
> +			nest2 = nla_nest_start(skb, MDBA_MDB_BRPORT);
> +			if (nest2 == NULL)
> +				goto fail;

What if you can't fit all theh hash entries into a single netlink
message? You need to allow splitting theh hash across multiple
messages. Therefore I suggest that you add a container attribute
for each mdb_entry like this:

MDBA_MDB = {
  1 = {
    MDBA_MDB_MCADDR = { ... },
    MDBA_MDB_BRPORT = { ... },
  },
  2 = {
    MDBA_MDB_MCADDR = { ... },
    MDBA_MDB_BR_PORT = { ... },
  },
  [...]
}

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
> +	cb->seq = net->dev_base_seq;

Using RCU read lock is OK but that means you must be prepared to
handle additions/removals to the table between dump iterations
and thus you must introduce a seq counter bumped on each table
change and add it to the dev_base_seq above.

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

As stated above I believe that you should allow for hashtable to be
split across multiple messages so you need to store the hash table
offset as well and properly finalize and send the message on error
here.
