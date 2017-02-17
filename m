From: zhou zhengwu <zhouzhengwu@huawei.com>
Subject: Re: [BUG] LACP state machine will find nothing and do nothing when
 link is single passing
Date: Fri, 17 Feb 2017 16:46:10 +0800
Message-ID: <acaef657-0119-986b-d9d6-74db686a7ca8@huawei.com>
References: <fcacaf54-5f4e-fd6e-d00c-9de7e74d26f4@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <qianguoxin@huawei.com>,
        <chenhuan.chenhuan@huawei.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:10765 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754199AbdBQIq1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 03:46:27 -0500
In-Reply-To: <fcacaf54-5f4e-fd6e-d00c-9de7e74d26f4@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Obviously, in the case of single link, one end of port can receives 
lacpdu and the lacp configure parameters will not change, eg. port 
number, port priority and system priority and so on.  So lacp state 
machine will not check the link change and the failed link will not be 
unselected from the active aggregator.

I add an additional check for the port state when lacpdu is processed in 
rx state machine. The function is ad_rx_machine()->__update_selected(). 
Then everything work well.

Following is the detail modification:

diff -c5 bond_3ad.c bond_3ad.c

static void __update_selected(struct lacpdu *lacpdu, struct port *port)
{
		    ........
   		    ntohs(lacpdu->actor_port_priority) != partner->port_priority ||
   		    MAC_ADDRESS_COMPARE(&lacpdu->actor_system, &partner->system) ||
   		    ntohs(lacpdu->actor_system_priority) != partner->system_priority ||
   		    ntohs(lacpdu->actor_key) != partner->key ||
   		    (lacpdu->actor_state & AD_STATE_AGGREGATION) != 
(partner->port_state & AD_STATE_AGGREGATION)
+ || (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION) != 
(partner->port_state & AD_STATE_SYNCHRONIZATION)) {
   			// update the state machine Selected variable
   			port->sm_vars &= ~AD_PORT_SELECTED;
   		}
   	}
   }

***************
static void ad_port_selection_logic(struct port *port)
{
             ..........
   		     (aggregator->partner_system_priority == 
port->partner_oper.system_priority) &&
   		     (aggregator->partner_oper_aggregator_key == 
port->partner_oper.key)
   		    ) &&
   		    ((MAC_ADDRESS_COMPARE(&(port->partner_oper.system), 
&(null_mac_addr)) && // partner answers
   		      !aggregator->is_individual)  // but is not individual OR
+ 		    ) && (port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION)
   		   ) {
   			// attach to the founded aggregator
   			port->aggregator = aggregator;
   			port->actor_port_aggregator_identifier =
   				port->aggregator->aggregator_identifier;
		

On 2017/2/16 17:20, zhou zhengwu wrote:
> Hi
>
> [1]Problem description:
>    ServerA [bond] ----------- [bond] ServerB
>    I have two servers which connected with bonding interfaces LACP
> enabled. Two bonding interfaces are configured like following:
>    insmod ./bonding.ko mode=4 lacp_rate=1 all_slaves_active=1
>    echo +trunk1 > /sys/class/net/bonding_masters
>    echo +eth0 > /sys/class/net/trunk1/bonding/slaves
>    echo +eth1 > /sys/class/net/trunk1/bonding/slaves
>
>    Firstly, it works well.
>    Then, one port (for example, eth0) in serverB failed, it can just
> send but not receive packets, however it still is UP.
>    Result:
>    In serverB, lcap is work well.
>    While In serverA, eth0 connecting with eth0 in serverB is in the same
> lacp aggregator with eth1 and traffic is still sent through it.
>
> [2]From the lacp implementation, we can see:
>    In above condition, eth0 in server A will receive lacpdu which show
> that AD_STATE_SYNCHRONIZATION is unset in actor_state to indicate there
> is something wrong in eth0 of server B. However, our implementation of
> lacp will just check the port parameters and not check the port state.
> If the peer port state changes, local lacp state machine will not find
> which will cause the lacp state machine works wrong.
>
>
