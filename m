From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [patch net-next 02/19] net: bridge: Add support for offloading
 port attributes
Date: Tue, 6 Jun 2017 16:08:56 +0300
Message-ID: <8625cccf-c274-9ffd-eeb2-85b2c4336c65@mellanox.com>
References: <20170605092043.3523-1-jiri@resnulli.us>
 <20170605092043.3523-3-jiri@resnulli.us>
 <fc8c1046-d567-e668-ef14-618814af36db@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, stephen@networkplumber.org,
        ivecera@redhat.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50088.outbound.protection.outlook.com ([40.107.5.88]:61024
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751305AbdFFNJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 09:09:27 -0400
In-Reply-To: <fc8c1046-d567-e668-ef14-618814af36db@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/05/2017 04:29 PM, Nikolay Aleksandrov wrote:
> On 05/06/17 12:20, Jiri Pirko wrote:
>> From: Arkadi Sharshevsky <arkadis@mellanox.com>
>>
>> Currently the flood, learning and learning_sync port attributes are
>> offloaded by setting the SELF flag. Add support for offloading the
>> flood and learning attribute through the bridge code. In case of
>> setting an unsupported flag on a offloded port the operation will
>> fail.
>>
>> The learning_sync attribute doesn't have any software representation
>> and cannot be offloaded through the bridge code.
>>
>> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  net/bridge/br_netlink.c | 112 +++++++++++++++++++++++++++++++++++++++---------
>>  net/bridge/br_private.h |   4 ++
>>  2 files changed, 96 insertions(+), 20 deletions(-)
>>
> 
> Hi Arkadi,
> A few comments below
> 

Hi Nikolay,
Thank you very much for the review, will fix.

>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index 1e63ec4..1afafb7 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -17,6 +17,7 @@
>>  #include <net/net_namespace.h>
>>  #include <net/sock.h>
>>  #include <uapi/linux/if_bridge.h>
>> +#include <net/switchdev.h>
>>  
>>  #include "br_private.h"
>>  #include "br_private_stp.h"
>> @@ -662,16 +663,52 @@ static int br_set_port_state(struct net_bridge_port *p, u8 state)
>>  }
>>  
>>  /* Set/clear or port flags based on attribute */
>> -static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
>> -			   int attrtype, unsigned long mask)
>> +static int br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
>> +			    int attrtype, unsigned long mask)
>>  {
>> -	if (tb[attrtype]) {
>> -		u8 flag = nla_get_u8(tb[attrtype]);
>> -		if (flag)
>> -			p->flags |= mask;
>> -		else
>> -			p->flags &= ~mask;
>> +	struct switchdev_attr attr = {
>> +		.orig_dev = p->dev,
>> +		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT,
>> +	};
>> +	unsigned long flags;
>> +	int err;
>> +
>> +	if (!tb[attrtype])
>> +		return 0;
>> +
>> +	if (nla_get_u8(tb[attrtype]))
>> +		flags = p->flags | mask;
>> +	else
>> +		flags = p->flags & ~mask;
>> +
>> +	if (mask & ~BR_PORT_FLAGS_HW_OFFLOAD)
>> +		goto out;
>> +
>> +	err = switchdev_port_attr_get(p->dev, &attr);
>> +	if (err == -EOPNOTSUPP)
>> +		goto out;
>> +	if (err)
>> +		return err;
>> +
>> +	/* Check if specific bridge flag attribute offload is supported */
>> +	if (!(attr.u.brport_flags_support & mask)) {
>> +		br_warn(p->br, "bridge flag offload is not supported %u(%s)\n",
>> +			(unsigned int)p->port_no, p->dev->name);
>> +		return -EOPNOTSUPP;
>> +	}
>> +
>> +	attr.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS;
>> +	attr.flags = SWITCHDEV_F_DEFER;
>> +	attr.u.brport_flags = flags;
>> +	err = switchdev_port_attr_set(p->dev, &attr);
>> +	if (err) {
>> +		br_warn(p->br, "error setting offload FLAG on port %u(%s)\n",
> 
> Why all caps (FLAG) ?
> 
>> +			(unsigned int)p->port_no, p->dev->name);
>> +		return err;
>>  	}
> 
> I think all of this switchdev-specific code should be contained into br_switchdev.c and
> exported via some function. Anyone changing only the bridge can easily get confused.
> 
>> +out:
>> +	p->flags = flags;
>> +	return 0;
>>  }
>>  
>>  /* Process bridge protocol info on port */
>> @@ -681,20 +718,55 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
>>  	bool br_vlan_tunnel_old = false;
>>  	int err;
>>  
>> -	br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
>> -	br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
>> -	br_set_port_flag(p, tb, IFLA_BRPORT_FAST_LEAVE, BR_MULTICAST_FAST_LEAVE);
>> -	br_set_port_flag(p, tb, IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK);
>> -	br_set_port_flag(p, tb, IFLA_BRPORT_LEARNING, BR_LEARNING);
>> -	br_set_port_flag(p, tb, IFLA_BRPORT_UNICAST_FLOOD, BR_FLOOD);
>> -	br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_FLOOD, BR_MCAST_FLOOD);
>> -	br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_TO_UCAST, BR_MULTICAST_TO_UNICAST);
>> -	br_set_port_flag(p, tb, IFLA_BRPORT_BCAST_FLOOD, BR_BCAST_FLOOD);
>> -	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP, BR_PROXYARP);
>> -	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP_WIFI, BR_PROXYARP_WIFI);
>> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
>> +	if (err)
>> +		return err;
>> +
>> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
>> +	if (err)
>> +		return err;
>> +
>> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_FAST_LEAVE, BR_MULTICAST_FAST_LEAVE);
>> +	if (err)
>> +		return err;
>> +
>> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK);
>> +	if (err)
>> +		return err;
>> +
>> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_LEARNING, BR_LEARNING);
>> +	if (err)
>> +		return err;
>> +
>> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_UNICAST_FLOOD, BR_FLOOD);
>> +	if (err)
>> +		return err;
>> +
>> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_FLOOD, BR_MCAST_FLOOD);
>> +	if (err)
>> +		return err;
>> +
>> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_MCAST_TO_UCAST, BR_MULTICAST_TO_UNICAST);
>> +	if (err)
>> +		return err;
>> +
>> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_BCAST_FLOOD, BR_BCAST_FLOOD);
>> +	if (err)
>> +		return err;
>> +
>> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP, BR_PROXYARP);
>> +	if (err)
>> +		return err;
>> +
>> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP_WIFI, BR_PROXYARP_WIFI);
>> +	if (err)
>> +		return err;
>>  
>>  	br_vlan_tunnel_old = (p->flags & BR_VLAN_TUNNEL) ? true : false;
>> -	br_set_port_flag(p, tb, IFLA_BRPORT_VLAN_TUNNEL, BR_VLAN_TUNNEL);
>> +	err = br_set_port_flag(p, tb, IFLA_BRPORT_VLAN_TUNNEL, BR_VLAN_TUNNEL);
>> +	if (err)
>> +		return err;
>> +
>>  	if (br_vlan_tunnel_old && !(p->flags & BR_VLAN_TUNNEL))
>>  		nbp_vlan_tunnel_info_flush(p);
>>  
>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>> index 2062692..5dc30ed 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -42,6 +42,10 @@
>>  /* Path to usermode spanning tree program */
>>  #define BR_STP_PROG	"/sbin/bridge-stp"
>>  
>> +/* Flags that can be offloaded to hardware */
>> +#define BR_PORT_FLAGS_HW_OFFLOAD (BR_LEARNING | BR_FLOOD | \
>> +				  BR_MCAST_FLOOD | BR_BCAST_FLOOD)
>> +
>>  typedef struct bridge_id bridge_id;
>>  typedef struct mac_addr mac_addr;
>>  typedef __u16 port_id;
>>
> 
