From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [patch net-next 2/7] ipv4: ipmr: Add the parent ID field to VIF
 struct
Date: Sun, 1 Oct 2017 09:22:12 +0300
Message-ID: <536634da-7934-ae41-6962-4c99cb52dd7c@mellanox.com>
References: <20170928173415.15551-1-jiri@resnulli.us>
 <20170928173415.15551-3-jiri@resnulli.us>
 <7618b2e8-e7f9-d2c6-b13c-53aef0f50de0@cumulusnetworks.com>
 <11d1be00-0bd4-3bcc-d63b-9419d5399602@cumulusnetworks.com>
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
Received: from mail-ve1eur01on0060.outbound.protection.outlook.com ([104.47.1.60]:23520
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750911AbdJAGW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 1 Oct 2017 02:22:27 -0400
In-Reply-To: <11d1be00-0bd4-3bcc-d63b-9419d5399602@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2017 12:45 PM, Nikolay Aleksandrov wrote:
> On 29/09/17 12:29, Nikolay Aleksandrov wrote:
>> On 28/09/17 20:34, Jiri Pirko wrote:
>>> From: Yotam Gigi <yotamg@mellanox.com>
>>>
>>> In order to allow the ipmr module to do partial multicast forwarding
>>> according to the device parent ID, add the device parent ID field to the
>>> VIF struct. This way, the forwarding path can use the parent ID field
>>> without invoking switchdev calls, which requires the RTNL lock.
>>>
>>> When a new VIF is added, set the device parent ID field in it by invoking
>>> the switchdev_port_attr_get call.
>>>
>>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>>  include/linux/mroute.h | 2 ++
>>>  net/ipv4/ipmr.c        | 9 +++++++++
>>>  2 files changed, 11 insertions(+)
>>>
>>> diff --git a/include/linux/mroute.h b/include/linux/mroute.h
>>> index b072a84..a46577f 100644
>>> --- a/include/linux/mroute.h
>>> +++ b/include/linux/mroute.h
>>> @@ -57,6 +57,8 @@ static inline bool ipmr_rule_default(const struct fib_rule *rule)
>>>  
>>>  struct vif_device {
>>>  	struct net_device 	*dev;			/* Device we are using */
>>> +	struct netdev_phys_item_id dev_parent_id;	/* Device parent ID    */
>>> +	bool		dev_parent_id_valid;
>>>  	unsigned long	bytes_in,bytes_out;
>>>  	unsigned long	pkt_in,pkt_out;		/* Statistics 			*/
>>>  	unsigned long	rate_limit;		/* Traffic shaping (NI) 	*/
>>> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
>>> index 292a8e8..4566c54 100644
>>> --- a/net/ipv4/ipmr.c
>>> +++ b/net/ipv4/ipmr.c
>>> @@ -67,6 +67,7 @@
>>>  #include <net/fib_rules.h>
>>>  #include <linux/netconf.h>
>>>  #include <net/nexthop.h>
>>> +#include <net/switchdev.h>
>>>  
>>>  struct ipmr_rule {
>>>  	struct fib_rule		common;
>>> @@ -868,6 +869,9 @@ static int vif_add(struct net *net, struct mr_table *mrt,
>>>  		   struct vifctl *vifc, int mrtsock)
>>>  {
>>>  	int vifi = vifc->vifc_vifi;
>>> +	struct switchdev_attr attr = {
>>> +		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
>>> +	};
>>>  	struct vif_device *v = &mrt->vif_table[vifi];
>>>  	struct net_device *dev;
>>>  	struct in_device *in_dev;
>>> @@ -942,6 +946,11 @@ static int vif_add(struct net *net, struct mr_table *mrt,
>>>  
>>>  	/* Fill in the VIF structures */
>>>  
>>> +	attr.orig_dev = dev;
>>> +	if (!switchdev_port_attr_get(dev, &attr)) {
>>> +		v->dev_parent_id_valid = true;
>>> +		memcpy(v->dev_parent_id.id, attr.u.ppid.id, attr.u.ppid.id_len);
>> Hmm, shouldn't you set dev_parent_id.id_len too ? It would seem netdev_phys_item_id_same()
>> uses it in the comparison and without the len it would always look like they're the same
>> because memcmp will simply return 0 with count = 0.
> Also maybe we can use the non-zero id_len as a signal that it was set and drop the dev_parent_id_valid
> field altogether, it would seem there's no valid reason to have id_len == 0 and yet expect a valid
> parent_id.


Yes, I agree to both. I will remove the parent_id_valid field and use the len to
indicate whether it is valid.

Thanks for spotting the bug - since we have only been testing it with a pimreg
device, the problem was not found in our tests. Multi-ASIC setups are a bit
hard to find these days :)


>>> +	}
>>>  	v->rate_limit = vifc->vifc_rate_limit;
>>>  	v->local = vifc->vifc_lcl_addr.s_addr;
>>>  	v->remote = vifc->vifc_rmt_addr.s_addr;
>>>
