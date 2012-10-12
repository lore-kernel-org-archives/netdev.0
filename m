From: Joe Perches <joe@perches.com>
Subject: Re: [RFC v4 1/1] net/hsr: Support for the HSR protocol (IEC:2010 /
 HSR v0)
Date: Fri, 12 Oct 2012 14:39:35 -0700
Message-ID: <1350077975.26909.17.camel@joe-AO722>
References: <4FF38A5C.9000802@xdin.com>
	 <1341361824.1993.16.camel@joe2Laptop> <502D475C.9090208@xdin.com>
	 <20120816.133036.1422214989121265534.davem@davemloft.net>
	 <50784F2D.1060200@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"jboticario@gmail.com" <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:47315 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752100Ab2JLVjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2012 17:39:36 -0400
In-Reply-To: <50784F2D.1060200@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-12 at 17:11 +0000, Arvid Brodin wrote:
> This would add support for the High-availability Seamless Redundancy network
> protocol, version 0 (2010).
> 
> This RFC is NOT meant for mainline inclusion at the moment since we're trying
> to figure out how to handle a probable incompatibility with the newer
> HSR v1 (2012) standard.

just trivial comments, ignore as you choose.

> diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
[]
> +void hsr_set_operstate(struct net_device *hsr_dev, struct net_device *slave1,
> +		       struct net_device *slave2)
> +{
> +	if (!is_admin_up(hsr_dev)) {
> +		__hsr_set_operstate(hsr_dev, IF_OPER_DOWN);
> +		return;
> +	}
> +
> +	if (is_operstate_up(slave1) || is_operstate_up(slave2))
> +		__hsr_set_operstate(hsr_dev, IF_OPER_UP);
> +	else
> +		__hsr_set_operstate(hsr_dev, IF_OPER_LOWERLAYERDOWN);
> +}

sometimes it's better to have a single call like
{
	int type;

	if (!is_admin_up(hsr_dev))
		type = IF_OPER_DOWN;
	else if (is_operstate_up(slave1) || is_operstate_up(slave2))
		type = IF_OPER_UP;
	else
		type = IF_OPER_LOWERLAYERDOWN;

	__hsr_set_operstate(hsr_dev, type);
}

[]

> +static int hsr_dev_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct hsr_priv *hsr_priv;
> +	struct hsr_ethhdr *hsr_ethhdr;
> +	struct sk_buff *skb2;
> +	int res1, res2;
> +
> +	hsr_priv = netdev_priv(dev);
> +	hsr_ethhdr = (struct hsr_ethhdr *) skb->data;
> +
> +	if ((ntohs(skb->protocol) != ETH_P_HSR) ||
> +			(ntohs(hsr_ethhdr->ethhdr.h_proto) != ETH_P_HSR)) {

These ntohs calls are done at runtime.
The conversion could be done at compile time instead using

	if (skb->protocol != ntohs(ETH_P_HSR) ||
	    hsr_ethhdr->ethhdr.h_proto != ntohs(ETH_P_HSR)) {

[]

> +static void restore_slaves(struct net_device *hsr_dev)
> +{
[]
> +			netdev_info(hsr_dev, "HSR: Cannot restore slave "
> +						"promiscuity (%s, %d)\n",
> +						hsr_priv->slave[i]->name, res);

It's nicer to coalesce formats for easier grep

			netdev_info(hsr_dev, "HSR: Cannot restore slave promiscuity (%s, %d)\n",
				    hsr_priv->slave[i]->name, res);

or maybe use special wrappers for something like:
int hsr_info(hsr, slave, fmt, ...)
{
}

[]

> diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c

> +static struct node_entry *find_node_by_AddrB(struct list_head *node_db,
> +					     unsigned char addr[ETH_ALEN])
> +{
> +	struct node_entry *node;
> +
> +	list_for_each_entry_rcu(node, node_db, mac_list)
> +		if (!compare_ether_addr(node->MacAddressB, addr))
> +			return node;

please use braces when the list/for has an if
