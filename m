From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [patch net-next 03/12] ipmr: Add FIB notification access
 functions
Date: Fri, 22 Sep 2017 09:35:52 +0300
Message-ID: <ca295917-5a65-b9de-a818-ca446e1655b5@mellanox.com>
References: <20170921064338.1282-1-jiri@resnulli.us>
 <20170921064338.1282-4-jiri@resnulli.us>
 <24470459-704b-89a2-648a-bbd4d3a1aebb@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40082.outbound.protection.outlook.com ([40.107.4.82]:9568
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751637AbdIVGgB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 02:36:01 -0400
In-Reply-To: <24470459-704b-89a2-648a-bbd4d3a1aebb@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/2017 02:19 PM, Nikolay Aleksandrov wrote:
> On 21/09/17 09:43, Jiri Pirko wrote:
>> From: Yotam Gigi <yotamg@mellanox.com>
>>
>> Make the ipmr module register as a FIB notifier. To do that, implement both
>> the ipmr_seq_read and ipmr_dump ops.
>>
>> The ipmr_seq_read op returns a sequence counter that is incremented on
>> every notification related operation done by the ipmr. To implement that,
>> add a sequence counter in the netns_ipv4 struct and increment it whenever a
>> new MFC route or VIF are added or deleted. The sequence operations are
>> protected by the RTNL lock.
>>
>> The ipmr_dump iterates the list of MFC routes and the list of VIF entries
>> and sends notifications about them. The entries dump is done under RCU.
>>
>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/linux/mroute.h   |  15 ++++++
>>  include/net/netns/ipv4.h |   3 ++
>>  net/ipv4/ipmr.c          | 135 ++++++++++++++++++++++++++++++++++++++++++++++-
>>  3 files changed, 151 insertions(+), 2 deletions(-)
>>
> [snip]
>> +
>> +static int ipmr_dump(struct net *net, struct notifier_block *nb)
>> +{
>> +	struct mr_table *mrt;
>> +	int err;
>> +
>> +	err = ipmr_rules_dump(net, nb);
>> +	if (err)
>> +		return err;
>> +
>> +	ipmr_for_each_table(mrt, net) {
>> +		struct vif_device *v = &mrt->vif_table[0];
>> +		struct mfc_cache *mfc;
>> +		int vifi;
>> +
>> +		/* Notifiy on table VIF entries */
>> +		for (vifi = 0; vifi < mrt->maxvif; vifi++, v++) {
>> +			if (!v->dev)
>> +				continue;
>> +
>> +			call_ipmr_vif_entry_notifier(nb, net, FIB_EVENT_VIF_ADD,
>> +						     v, vifi, mrt->id);
>> +		}
> The VIF table is protected by mrt_lock (rwlock), here with RCU only
> you're not guaranteed to keep v->dev. It can become NULL after the check above.
> For details you can see vif_delete() in net/ipv4/ipmr.c. You need at least
> mrt_lock for reading.

Hmm, that's interesting. That situation would lead the dump to be inconsistent,
thus eventually discarded, right? So I can also just make sure that the driver
ignores dev=NULL notifications and that would be enough to solve it.

I have to think about it a bit more, but anyway, maybe taking the mrt_lock for
the VIF dump is the right solution here.

Anyway, thanks for the review!


>> +
>> +		/* Notify on table MFC entries */
>> +		list_for_each_entry_rcu(mfc, &mrt->mfc_cache_list, list)
>> +			call_ipmr_mfc_entry_notifier(nb, net,
>> +						     FIB_EVENT_ENTRY_ADD, mfc,
>> +						     mrt->id);
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static const struct fib_notifier_ops ipmr_notifier_ops_template = {
>> +	.family		= RTNL_FAMILY_IPMR,
>> +	.fib_seq_read	= ipmr_seq_read,
>> +	.fib_dump	= ipmr_dump,
>> +	.owner		= THIS_MODULE,
>> +};
>> +
>> +int __net_init ipmr_notifier_init(struct net *net)
>> +{
>> +	struct fib_notifier_ops *ops;
>> +
>> +	net->ipv4.ipmr_seq = 0;
>> +
>> +	ops = fib_notifier_ops_register(&ipmr_notifier_ops_template, net);
>> +	if (IS_ERR(ops))
>> +		return PTR_ERR(ops);
>> +	net->ipv4.ipmr_notifier_ops = ops;
>> +
>> +	return 0;
>> +}
>> +
>> +static void __net_exit ipmr_notifier_exit(struct net *net)
>> +{
>> +	fib_notifier_ops_unregister(net->ipv4.ipmr_notifier_ops);
>> +	net->ipv4.ipmr_notifier_ops = NULL;
>> +}
>> +
>>  /* Setup for IP multicast routing */
>>  static int __net_init ipmr_net_init(struct net *net)
>>  {
>>  	int err;
>>  
>> +	err = ipmr_notifier_init(net);
>> +	if (err)
>> +		goto ipmr_notifier_fail;
>> +
>>  	err = ipmr_rules_init(net);
>>  	if (err < 0)
>> -		goto fail;
>> +		goto ipmr_rules_fail;
>>  
>>  #ifdef CONFIG_PROC_FS
>>  	err = -ENOMEM;
>> @@ -3074,7 +3202,9 @@ static int __net_init ipmr_net_init(struct net *net)
>>  proc_vif_fail:
>>  	ipmr_rules_exit(net);
>>  #endif
>> -fail:
>> +ipmr_rules_fail:
>> +	ipmr_notifier_exit(net);
>> +ipmr_notifier_fail:
>>  	return err;
>>  }
>>  
>> @@ -3084,6 +3214,7 @@ static void __net_exit ipmr_net_exit(struct net *net)
>>  	remove_proc_entry("ip_mr_cache", net->proc_net);
>>  	remove_proc_entry("ip_mr_vif", net->proc_net);
>>  #endif
>> +	ipmr_notifier_exit(net);
>>  	ipmr_rules_exit(net);
>>  }
>>  
>>
