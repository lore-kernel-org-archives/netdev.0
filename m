From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH bridge 4/5] bridge: Add private ioctls to configure
 vlans on bridge ports
Date: Fri, 24 Aug 2012 14:19:50 -0400
Message-ID: <5037C5C6.4000908@redhat.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com> <1345750195-31598-5-git-send-email-vyasevic@redhat.com> <20120824175616.GL2472@linux.vnet.ibm.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48463 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759960Ab2HXSTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 14:19:53 -0400
In-Reply-To: <20120824175616.GL2472@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2012 01:56 PM, Paul E. McKenney wrote:
> On Thu, Aug 23, 2012 at 03:29:54PM -0400, Vlad Yasevich wrote:
>> Add a private ioctl to add and remove vlan configuration on bridge port.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>
> One question below...
>
> index 7222fe1..3a5b1f9 100644
>> --- a/net/bridge/br_ioctl.c
>> +++ b/net/bridge/br_ioctl.c
>> @@ -289,6 +289,37 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>>   	case BRCTL_GET_FDB_ENTRIES:
>>   		return get_fdb_entries(br, (void __user *)args[1],
>>   				       args[2], args[3]);
>> +	case BRCTL_ADD_VLAN:
>> +	{
>> +		struct net_bridge_port *p;
>> +
>> +		if (!capable(CAP_NET_ADMIN))
>> +			return -EPERM;
>> +
>> +		rcu_read_lock();
>> +		if ((p = br_get_port(br, args[1])) == NULL) {
>> +			rcu_read_unlock();
>> +			return -EINVAL;
>> +		}
>> +		rcu_read_unlock();
>
> Why is it safe to pass "p" out of the RCU read-side critical section?
> I don't see that br_get_port() does anything to make this safe, at least
> not in v3.5.
>

You right.  It not really safe.  As Stephen pointed out, it is 
accidentally protected by rtnl, so it will not go away.  However, that's 
not a good excuse and I've already fixed it in my tree.

thanks
-vlad
>> +		return br_set_port_vlan(p, args[2]);
>> +	}
>> +
>> +	case BRCTL_DEL_VLAN:
>> +	{
>> +		struct net_bridge_port *p;
>> +
>> +		if (!capable(CAP_NET_ADMIN))
>> +			return -EPERM;
>> +
>> +		rcu_read_lock();
>> +		if ((p = br_get_port(br, args[1])) == NULL) {
>> +			rcu_read_unlock();
>> +			return -EINVAL;
>> +		}
>> +		rcu_read_unlock();
>> +		br_set_port_vlan(p, args[2]);
>> +	}
>>   	}
>>
>>   	return -EOPNOTSUPP;
>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>> index b6c56ab..5639c1c 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -402,6 +402,8 @@ extern int br_del_if(struct net_bridge *br,
>>   extern int br_min_mtu(const struct net_bridge *br);
>>   extern netdev_features_t br_features_recompute(struct net_bridge *br,
>>   	netdev_features_t features);
>> +extern int br_set_port_vlan(struct net_bridge_port *p, unsigned long vid);
>> +extern int br_del_port_vlan(struct net_bridge_port *p, unsigned long vid);
>>
>>   /* br_input.c */
>>   extern int br_handle_frame_finish(struct sk_buff *skb);
>> --
>> 1.7.7.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
