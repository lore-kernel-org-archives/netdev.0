From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [patch net-next 2/7] ipv4: ipmr: Add the parent ID field to VIF
 struct
Date: Sun, 1 Oct 2017 09:33:48 +0300
Message-ID: <0dd2bcc2-281d-8a63-6f53-2b3df27461d6@mellanox.com>
References: <20170928173415.15551-1-jiri@resnulli.us>
 <20170928173415.15551-3-jiri@resnulli.us>
 <29b9104c-6ada-0c9a-ce84-df104fa0afba@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        andrew@lunn.ch, dsa@cumulusnetworks.com, edumazet@google.com,
        willemb@google.com, johannes.berg@intel.com, dcaratti@redhat.com,
        pabeni@redhat.com, daniel@iogearbox.net, f.fainelli@gmail.com,
        fw@strlen.de, gfree.wind@vip.163.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0040.outbound.protection.outlook.com ([104.47.2.40]:43520
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750869AbdJAGeD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 1 Oct 2017 02:34:03 -0400
In-Reply-To: <29b9104c-6ada-0c9a-ce84-df104fa0afba@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2017 12:50 PM, Nikolay Aleksandrov wrote:
> On 28/09/17 20:34, Jiri Pirko wrote:
>> From: Yotam Gigi <yotamg@mellanox.com>
>>
>> In order to allow the ipmr module to do partial multicast forwarding
>> according to the device parent ID, add the device parent ID field to the
>> VIF struct. This way, the forwarding path can use the parent ID field
>> without invoking switchdev calls, which requires the RTNL lock.
>>
>> When a new VIF is added, set the device parent ID field in it by invoking
>> the switchdev_port_attr_get call.
>>
>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/linux/mroute.h | 2 ++
>>  net/ipv4/ipmr.c        | 9 +++++++++
>>  2 files changed, 11 insertions(+)
>>
>> diff --git a/include/linux/mroute.h b/include/linux/mroute.h
>> index b072a84..a46577f 100644
>> --- a/include/linux/mroute.h
>> +++ b/include/linux/mroute.h
>> @@ -57,6 +57,8 @@ static inline bool ipmr_rule_default(const struct fib_rule *rule)
>>  
>>  struct vif_device {
>>  	struct net_device 	*dev;			/* Device we are using */
>> +	struct netdev_phys_item_id dev_parent_id;	/* Device parent ID    */
>> +	bool		dev_parent_id_valid;
>>  	unsigned long	bytes_in,bytes_out;
>>  	unsigned long	pkt_in,pkt_out;		/* Statistics 			*/
>>  	unsigned long	rate_limit;		/* Traffic shaping (NI) 	*/
>> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
>> index 292a8e8..4566c54 100644
>> --- a/net/ipv4/ipmr.c
>> +++ b/net/ipv4/ipmr.c
>> @@ -67,6 +67,7 @@
>>  #include <net/fib_rules.h>
>>  #include <linux/netconf.h>
>>  #include <net/nexthop.h>
>> +#include <net/switchdev.h>
>>  
>>  struct ipmr_rule {
>>  	struct fib_rule		common;
>> @@ -868,6 +869,9 @@ static int vif_add(struct net *net, struct mr_table *mrt,
>>  		   struct vifctl *vifc, int mrtsock)
>>  {
>>  	int vifi = vifc->vifc_vifi;
>> +	struct switchdev_attr attr = {
>> +		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
>> +	};
>>  	struct vif_device *v = &mrt->vif_table[vifi];
>>  	struct net_device *dev;
>>  	struct in_device *in_dev;
>> @@ -942,6 +946,11 @@ static int vif_add(struct net *net, struct mr_table *mrt,
>>  
>>  	/* Fill in the VIF structures */
>>  
>> +	attr.orig_dev = dev;
>> +	if (!switchdev_port_attr_get(dev, &attr)) {
>> +		v->dev_parent_id_valid = true;
>> +		memcpy(v->dev_parent_id.id, attr.u.ppid.id, attr.u.ppid.id_len);
>> +	}
>>  	v->rate_limit = vifc->vifc_rate_limit;
>>  	v->local = vifc->vifc_lcl_addr.s_addr;
>>  	v->remote = vifc->vifc_rmt_addr.s_addr;
>>
> One more thing - what happens on vif delete, then add with the same vif index of another
> device that doesn't have a parent id ? I think the vif will be stuck with its parent_id
> when it gets set.
>

Right. I will set the len to 0 if the device has no parent.

Thanks!
