From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v5] net/hsr: Add support for the High-availability
 Seamless Redundancy protocol (HSRv0)
Date: Wed, 23 Oct 2013 09:52:22 -0700
Message-ID: <1382547142.22433.18.camel@joe-AO722>
References: <5267F4BD.70409@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>,
	=?ISO-8859-1?Q?El=EDas?= Molina =?ISO-8859-1?Q?Mu=F1oz?=
	<elias.molina@ehu.es>
To: Arvid Brodin <arvid.brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0092.hostedemail.com ([216.40.44.92]:45978 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751275Ab3JWQw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:52:26 -0400
In-Reply-To: <5267F4BD.70409@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-23 at 18:09 +0200, Arvid Brodin wrote:
> High-availability Seamless Redundancy ("HSR") provides instant failover
> redundancy for Ethernet networks. It requires a special network topology where
> all nodes are connected in a ring (each node having two physical network
> interfaces). It is suited for applications that demand high availability and
> very short reaction time.

trivia: (can be ignored/fixed later)

> +static void restore_slaves(struct net_device *hsr_dev)
> +{
> +	struct hsr_priv *hsr_priv;
> +	int i;
> +	int res;
> +
> +	hsr_priv = netdev_priv(hsr_dev);
> +
> +	rtnl_lock();
> +
> +	/* Restore promiscuity */
> +	for (i = 0; i < 2; i++) {

I presume all of these for slave loops that use
for (i = 0; i < 2; i++) should be i < HSR_MAX_SLAVE

Maybe it'd be useful to add a foreach_slave() helper.

> +static struct node_entry *find_node_by_AddrA(struct list_head *node_db,
> +					     const unsigned char addr[ETH_ALEN])
> +{
> +	struct node_entry *node;
> +
> +	list_for_each_entry_rcu(node, node_db, mac_list) {
> +		if (!compare_ether_addr(node->MacAddressA, addr))

Please use ether_addr_equal instead for all these uses.
compare_ether_addr should be removed one day.

> +static struct node_entry *find_node_by_AddrB(struct list_head *node_db,
> +					     const unsigned char addr[ETH_ALEN])
[]
> +		if (!compare_ether_addr(node->MacAddressB, addr))
[]
> +struct node_entry *hsr_find_node(struct list_head *node_db, struct sk_buff *skb)
[]
> +		if (!compare_ether_addr(node->MacAddressA, ethhdr->h_source))
> +			return node;
> +		if (!compare_ether_addr(node->MacAddressB, ethhdr->h_source))
> +			return node;

> +struct node_entry *hsr_merge_node(struct hsr_priv *hsr_priv,
> +				  struct node_entry *node,
> +				  struct sk_buff *skb,
> +				  enum hsr_dev_idx dev_idx)
[]
> +	if (node && compare_ether_addr(node->MacAddressA, hsr_sp->MacAddressA)) {
[]
> +	if (node && (dev_idx == node->AddrB_if) &&
> +	    compare_ether_addr(node->MacAddressB, hsr_ethsup->ethhdr.h_source)) {
[]
> +	if (node && (dev_idx != node->AddrB_if) &&
> +	    (node->AddrB_if != HSR_DEV_NONE) &&
> +	    compare_ether_addr(node->MacAddressA, hsr_ethsup->ethhdr.h_source)) {
[]
> +	if (compare_ether_addr(hsr_sp->MacAddressA, hsr_ethsup->ethhdr.h_source))

[]

> +/* above(a, b) - return 1 if a > b, 0 otherwise.
> + */
> +static bool above(u16 a, u16 b)
> +{
> +	/* Remove inconsistency where above(a, b) == below(a, b) */
> +	if ((int) b - a == 32768)
> +		return 0;
> +
> +	return (((s16) (b - a)) < 0);
> +}
> +#define below(a, b)		above((b), (a))
> +#define above_or_eq(a, b)	(!below((a), (b)))
> +#define below_or_eq(a, b)	(!above((a), (b)))

This looks odd.  Perhaps

static bool above(u16 a, u16 b)
{
	return a > b;
}
#define below(a, b) above(b, a)

static bool above_or_eq(u16 a, u16 b)
{
	return a >= b;
}
#define below_or_eq(a, b) above_or_eq(b, a)
