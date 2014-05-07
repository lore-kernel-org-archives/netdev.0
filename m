From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 net] bonding: Fix stacked device detection in arp monitoring
Date: Wed, 07 May 2014 13:08:09 -0400
Message-ID: <536A6879.8070303@redhat.com>
References: <1399470461-22213-1-git-send-email-vyasevic@redhat.com> <29645.1399481039@localhost.localdomain>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Patric McHardy <kaber@trash.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56909 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049AbaEGRIT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 13:08:19 -0400
In-Reply-To: <29645.1399481039@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2014 12:43 PM, Jay Vosburgh wrote:
> Vlad Yasevich <vyasevic@redhat.com> wrote:
> 
>> Prior to commit fbd929f2dce460456807a51e18d623db3db9f077
>> 	bonding: support QinQ for bond arp interval
>>
>> the arp monitoring code allowed for proper detection of devices
>> stacked on top of vlans.  Since the above commit, the
>> code can still detect a device stacked on top of single
>> vlan, but not a device stacked on top of Q-in-Q configuration.
>> The search will only set the inner vlan tag if the route
>> device is the vlan device.  However, this is not always the
>> case, as it is possible to extend the stacked configuration.
>>
>> With this patch it is possible to provision devices on
>> top Q-in-Q vlan configuration that should be used as
>> a source of ARP monitoring information.
>>
>> For example:
>> ip link add link bond0 vlan10 type vlan proto 802.1q id 10
>> ip link add link vlan10 vlan100 type vlan proto 802.1q id 100
>> ip link add link vlan100 type macvlan
>>
>> Note:  This patch limites the number of stacked VLANs to 2,
>> just like before.  The original, however had another issue
>> in that if we had more then 2 levels of VLANs, we would end
>> up generating incorrectly tagged traffic.  This is no longer
>> possible.
>>
>> Fixes: fbd929f2dce460456807a51e18d623db3db9f077 (bonding: support QinQ for bond arp interval)
>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>> CC: Veaceslav Falico <vfalico@redhat.com>
>> CC: Andy Gospodarek <andy@greyhouse.net>
>> CC: Ding Tianhong <dingtianhong@huawei.com>
>> CC: Patric McHardy <kaber@trash.net>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>> v2->v1:
>> * Changed the function name to better describe what the function is doing.
>>  We are not just finding the stack of vlan devices, we are also verifything
>>  the path between the bonding device and the route output device.
>> * Added some more commenets about what the function is doing.
>> * Fixed an issue with multiple peer vlans.
>> * Removed all occurances of 'inner' and 'outer' and replaced it with tag
>>  array.
> 
> 	I think you may have misunderstood my prior comment; I meant
> that I liked the "inner" and "outer" names better than "tag[0]" and
> "tag[1]".

Oh, sorry.  I misunderstood.  I can certainly maintain inner/outer
connotation, but it seem a bit silly.  We have a stack of vlan devices
so we'll apply them as as stack as well.

I actually debated about making it generic and not limiting us to a
max depth of 2 as there is nothing in the vlan implementation that
limits the user from configuring a stack of more then 2 deep.

Even 802.1ad spec doesn't explicitly limit the number of vlan headers to
2, and once you do that, the concept of inner/outer goes away.

> 
> 	I did notice that the inner and outer parameters could be
> removed from bond_arp_send as well, but, again, I found the "inner" and
> "outer" names more descriptive than tag[0] or tag[1]; perhaps a #define
> for the magic numbers (0 = "outer", 1 = "inner" and 2 = "max nesting"),
> or at least a comment that says straight up "tag[0] is the outer tag,
> tag[1] is the inner tag (if there are two tags)" is in order.
> 
>> drivers/net/bonding/bond_main.c | 114 ++++++++++++++++++----------------------
>> 1 file changed, 52 insertions(+), 62 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 9d08e00..f592f96 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2126,8 +2126,7 @@ static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
>>  */
>> static void bond_arp_send(struct net_device *slave_dev, int arp_op,
>> 			  __be32 dest_ip, __be32 src_ip,
>> -			  struct bond_vlan_tag *inner,
>> -			  struct bond_vlan_tag *outer)
>> +			  struct bond_vlan_tag *tags)
>> {
>> 	struct sk_buff *skb;
>>
>> @@ -2141,12 +2140,12 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
>> 		net_err_ratelimited("ARP packet allocation failed\n");
>> 		return;
>> 	}
>> -	if (outer->vlan_id) {
>> -		if (inner->vlan_id) {
>> +	if (tags[0].vlan_id) {
>> +		if (tags[1].vlan_id) {
>> 			pr_debug("inner tag: proto %X vid %X\n",
>> -				 ntohs(inner->vlan_proto), inner->vlan_id);
>> -			skb = __vlan_put_tag(skb, inner->vlan_proto,
>> -					     inner->vlan_id);
>> +				 ntohs(tags[1].vlan_proto), tags[1].vlan_id);
>> +			skb = __vlan_put_tag(skb, tags[1].vlan_proto,
>> +					     tags[1].vlan_id);
>> 			if (!skb) {
>> 				net_err_ratelimited("failed to insert inner VLAN tag\n");
>> 				return;
>> @@ -2154,8 +2153,8 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
>> 		}
>>
>> 		pr_debug("outer reg: proto %X vid %X\n",
>> -			 ntohs(outer->vlan_proto), outer->vlan_id);
>> -		skb = vlan_put_tag(skb, outer->vlan_proto, outer->vlan_id);
>> +			 ntohs(tags[0].vlan_proto), tags[0].vlan_id);
>> +		skb = vlan_put_tag(skb, tags[0].vlan_proto, tags[0].vlan_id);
>> 		if (!skb) {
>> 			net_err_ratelimited("failed to insert outer VLAN tag\n");
>> 			return;
>> @@ -2164,22 +2163,52 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
>> 	arp_xmit(skb);
>> }
>>
>> +/* Check to make sure that @end device is stacked on top of the @start
>> + * device.  Invofrmation about any intervening vlans are saved into
>> + * the @tag array.  @idx parametet specifies how many vlans deep we are
>> + * are currently looking. We currently only support 2 levels of vlan stacking.
>> + * Return true if we have a valid stacking configuration.  Otherwise false.
>> + */
> 
> 	Spelling nits: "Information" and "parameter".
> 
>> +static bool bond_check_path(struct net_device *start, struct net_device *end,
>> +			    struct bond_vlan_tag *tag, int idx)
>> +{
>> +	struct net_device *upper;
>> +	struct list_head  *iter;
>> +
>> +	/* We do not support more then 2 levels of VLAN nesting */
>> +	if (idx >= 2)
>> +		return false;
>> +
>> +	netdev_for_each_all_upper_dev_rcu(start, upper, iter) {
>> +		if (is_vlan_dev(upper)) {
>> +			tag[idx].vlan_proto = vlan_dev_vlan_proto(upper);
>> +			tag[idx].vlan_id = vlan_dev_vlan_id(upper);
>> +		}
>> +		if (upper == end)
>> +			return true;
>> +
>> +		/* Look at the devices list  of 'upper' only if it is a
>> +		 * vlan device.
>> +		 */
>> +		if (is_vlan_dev(upper) &&
>> +		    bond_check_path(upper, end, tag, idx+1))
>> +			return true;
> 
> 	This may or may not be a realistic configuration, but will this
> function traverse correctly if there is some other device type between
> the two vlans?  E.g., eth0 -> bond0 -> vlan100 -> bridge -> vlan200,
> where "vlan200" is the "end" device holding the IP address from the
> route lookup.  It need not be a bridge in there, but I think this would
> be a legal configuration.

Yes.  I verified that it works.  The reason is that we are traversing
the all_adj_list.upper list which contains all of the upper devices at
each level.  So, at vlan100 level, we will see vlan200 and all will be
well.

-vlad

> 
> 	-J
> 
>> +	}
>> +	return false;
>> +}
>> +
>>
>> static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
>> {
>> -	struct net_device *upper, *vlan_upper;
>> -	struct list_head *iter, *vlan_iter;
>> 	struct rtable *rt;
>> -	struct bond_vlan_tag inner, outer;
>> +	struct bond_vlan_tag tags[2];
>> 	__be32 *targets = bond->params.arp_targets, addr;
>> 	int i;
>> +	bool ret;
>>
>> 	for (i = 0; i < BOND_MAX_ARP_TARGETS && targets[i]; i++) {
>> 		pr_debug("basa: target %pI4\n", &targets[i]);
>> -		inner.vlan_proto = 0;
>> -		inner.vlan_id = 0;
>> -		outer.vlan_proto = 0;
>> -		outer.vlan_id = 0;
>> +		memset(tags, 0, sizeof(tags));
>>
>> 		/* Find out through which dev should the packet go */
>> 		rt = ip_route_output(dev_net(bond->dev), targets[i], 0,
>> @@ -2192,7 +2221,8 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
>> 				net_warn_ratelimited("%s: no route to arp_ip_target %pI4 and arp_validate is set\n",
>> 						     bond->dev->name,
>> 						     &targets[i]);
>> -			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], 0, &inner, &outer);
>> +			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
>> +				      0, tags);
>> 			continue;
>> 		}
>>
>> @@ -2201,52 +2231,12 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
>> 			goto found;
>>
>> 		rcu_read_lock();
>> -		/* first we search only for vlan devices. for every vlan
>> -		 * found we verify its upper dev list, searching for the
>> -		 * rt->dst.dev. If found we save the tag of the vlan and
>> -		 * proceed to send the packet.
>> -		 */
>> -		netdev_for_each_all_upper_dev_rcu(bond->dev, vlan_upper,
>> -						  vlan_iter) {
>> -			if (!is_vlan_dev(vlan_upper))
>> -				continue;
>> -
>> -			if (vlan_upper == rt->dst.dev) {
>> -				outer.vlan_proto = vlan_dev_vlan_proto(vlan_upper);
>> -				outer.vlan_id = vlan_dev_vlan_id(vlan_upper);
>> -				rcu_read_unlock();
>> -				goto found;
>> -			}
>> -			netdev_for_each_all_upper_dev_rcu(vlan_upper, upper,
>> -							  iter) {
>> -				if (upper == rt->dst.dev) {
>> -					/* If the upper dev is a vlan dev too,
>> -					 *  set the vlan tag to inner tag.
>> -					 */
>> -					if (is_vlan_dev(upper)) {
>> -						inner.vlan_proto = vlan_dev_vlan_proto(upper);
>> -						inner.vlan_id = vlan_dev_vlan_id(upper);
>> -					}
>> -					outer.vlan_proto = vlan_dev_vlan_proto(vlan_upper);
>> -					outer.vlan_id = vlan_dev_vlan_id(vlan_upper);
>> -					rcu_read_unlock();
>> -					goto found;
>> -				}
>> -			}
>> -		}
>> -
>> -		/* if the device we're looking for is not on top of any of
>> -		 * our upper vlans, then just search for any dev that
>> -		 * matches, and in case it's a vlan - save the id
>> -		 */
>> -		netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
>> -			if (upper == rt->dst.dev) {
>> -				rcu_read_unlock();
>> -				goto found;
>> -			}
>> -		}
>> +		ret = bond_check_path(bond->dev, rt->dst.dev, tags, 0);
>> 		rcu_read_unlock();
>>
>> +		if (ret)
>> +			goto found;
>> +
>> 		/* Not our device - skip */
>> 		pr_debug("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
>> 			 bond->dev->name, &targets[i],
>> @@ -2259,7 +2249,7 @@ found:
>> 		addr = bond_confirm_addr(rt->dst.dev, targets[i], 0);
>> 		ip_rt_put(rt);
>> 		bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
>> -			      addr, &inner, &outer);
>> +			      addr, tags);
>> 	}
>> }
>>
>> -- 
>> 1.9.0
>>
> 
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
> 
