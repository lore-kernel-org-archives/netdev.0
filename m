From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: rlb mode of bond should not alter ARP originating via bridge
Date: Tue, 27 Nov 2012 16:05:47 -0800
Message-ID: <25503.1354061147@death.nxdomain>
References: <1352972861-17577-1-git-send-email-zheng.x.li@oracle.com> <30871.1353373354@death.nxdomain> <50AB447E.3010904@oracle.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com
To: "zheng.li" <zheng.x.li@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <50AB447E.3010904@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

zheng.li <zheng.x.li@oracle.com> wrote:

>After i applied my prior patch to the latest kernel and tested ,i change
>the patch as this. The prior patch is running ok on 2.6.32,but after
>2.6.32 it runs no effect ,it still cause domu(which arp through bridge
>via bonding) network intermittently unreachable. I found the reason is
>that the alb_monitor of bonding(after 2.6.32) send unicast arp reply
>which using rlb_client_info's assigned slave's MAC,so cause peer host
>update arp cache of domu with wrong MAC to cause domu unreachable again.
>The rlb_client_info is created when rlb_arp_xmit sending ARP request.
>rlb_client_info contain local IP with assigned
>slave,it will cause all local ip's ARP use slave's mac by
>rlb_update_client function.
>
>Bug reproduced rate: 100%.
>
>So i change the patch also affect the ARP request to don't through rlb
>to no create rlb_client_info. Applied the new patch on the latest
>version,it runs ok.
>
>So,the patch should affect ARP request and reply to work well.

	Ok, I think this is a reasonable change, but the patch should
have a commit description and comment in the code that accurately
reflects the final change.

	Currently, the new comment in the code reads as follows:

> +	/* Only modify ARP's MAC if it originates locally;
> +	 * don't change ARPs arriving via a bridge.
> +	 */
> +	if (!bond_slave_has_mac(bond, arp->mac_src))
> +		return NULL;

	I'd change the comment to say something like "Don't modify or
load balance ARPs that do not originate locally (e.g., arrive via a
bridge)" and put some details in the commit message, for example:

	Do not modify or load balance ARP packets passing through
balance-alb mode (wherein the ARP did not originate locally, and arrived
via a bridge).

	Modifying pass-through ARP replies causes an incorrect MAC
address to be placed into the ARP packet, rendering peers unable to
communicate with the actual destination from which the ARP reply
originated.

	Load balancing pass-through ARP requests causes an entry to be
created for the peer in the rlb table, and bond_alb_monitor will
occasionally issue ARP updates to all peers in the table instrucing them
as to which MAC address they should communicate with; this occurs when
some event sets rx_ntt.  In the bridged case, however, the MAC address
used for the update would be the MAC of the slave, not the actual source
MAC of the originating destination.  This would render peers unable to
communicate with the destinations beyond the bridge.

	-J

>bond_alb_monitor -> rlb_update_rx_clients --> rlb_update_client
>
>rlb_update_client(struct rlb_client_info *client_info)
>{
>   for (i = 0; i < RLB_ARP_BURST_SIZE; i++) {
>		struct sk_buff *skb;
>
>		skb = arp_create(ARPOP_REPLY, ETH_P_ARP,
>                                //peer host's IP
>				 client_info->ip_dst,
>				 client_info->slave->dev,
>                                //Domu 's IP
>				 client_info->ip_src,
>                          //peer host's MAC which be set in rlb_arp_recv
>				 client_info->mac_dst,
>//use slave's MAC to send unicast arp reply to peer ,so cause peer host
>//update MAC of domu with wrong mac address.
>				 client_info->slave->dev->dev_addr,
>				 client_info->mac_dst);
>.......
>}
>
>Thanks
>Zheng Li
>
>
>> Zheng Li <zheng.x.li@oracle.com> wrote:
>> 
>>> ARP traffic passing through a bridge and out via the bond (when the bond is a 
>>> port of the bridge) should not have its source MAC address adjusted by the 
>>> receive load balance code in rlb_arp_xmit.
>> 
>> 	This patch differs from prior versions in that it does more than
>> what's described here; it also disables the receive load balance logic
>> for any ARPs (request or reply) that are passing through the bond (not
>> of local origin).  For ARP replies, that's mostly harmless, as the ARPs
>> passing through will simply always be sent from one particular slave
>> (the active slave) instead of being balanced.
>> 
>> 	For ARP requests, though, they are already always sent via the
>> active slave, but there is also some logic in rlb_arp_xmit to limit the
>> side effects from the broadcast ARP, in particular this part:
>> 
>> 		/* The ARP reply packets must be delayed so that
>> 		 * they can cancel out the influence of the ARP request.
>> 		 */
>> 		bond->alb_info.rlb_update_delay_counter = RLB_UPDATE_DELAY;
>> 
>> 		/* arp requests are broadcast and are sent on the primary
>> 		 * the arp request will collapse all clients on the subnet to
>> 		 * the primary slave. We must register these clients to be
>> 		 * updated with their assigned mac.
>> 		 */
>> 		rlb_req_update_subnet_clients(bond, arp->ip_src);
>> 
>> 	that arranges for clients to be given ARP updates for their
>> slave assignments (which may change to the active slave, due to the ARP
>> broadcast being sent via the active slave).
>> 
>> 	I think the ARP reply side of this is fine (and is what is
>> described in teh changelog), but the ARP request behavior change is new
>> with this version.
>> 
>> 	Since prior versions of the patch didn't cause this code to be
>> skipped, is this change intentional?
>> 
>> 	Did you check to see if the above logic is necessary for ARP
>> requests passing through via a bridge to prevent peers from "stacking"
>> (in terms of load balance assignment) on the active slave due to bridged
>> ARP traffic?
>> 
>> 	-J
>> 
>>> Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
>>> Cc: Jay Vosburgh <fubar@us.ibm.com>
>>> Cc: Andy Gospodarek <andy@greyhouse.net>
>>> Cc: "David S. Miller" <davem@davemloft.net>
>>>
>>> ---
>>> drivers/net/bonding/bond_alb.c |    6 ++++++
>>> drivers/net/bonding/bonding.h  |   13 +++++++++++++
>>> 2 files changed, 19 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>>> index e15cc11..75f6f0d 100644
>>> --- a/drivers/net/bonding/bond_alb.c
>>> +++ b/drivers/net/bonding/bond_alb.c
>>> @@ -694,6 +694,12 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
>>> 	struct arp_pkt *arp = arp_pkt(skb);
>>> 	struct slave *tx_slave = NULL;
>>>
>>> +	/* Only modify ARP's MAC if it originates locally;
>>> +	 * don't change ARPs arriving via a bridge.
>>> +	 */
>>> +	if (!bond_slave_has_mac(bond, arp->mac_src))
>>> +		return NULL;
>>> +
>>> 	if (arp->op_code == htons(ARPOP_REPLY)) {
>>> 		/* the arp must be sent on the selected
>>> 		* rx channel
>>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>>> index f8af2fc..6dded56 100644
>>> --- a/drivers/net/bonding/bonding.h
>>> +++ b/drivers/net/bonding/bonding.h
>>> @@ -22,6 +22,7 @@
>>> #include <linux/in6.h>
>>> #include <linux/netpoll.h>
>>> #include <linux/inetdevice.h>
>>> +#include <linux/etherdevice.h>
>>> #include "bond_3ad.h"
>>> #include "bond_alb.h"
>>>
>>> @@ -450,6 +451,18 @@ static inline void bond_destroy_proc_dir(struct bond_net *bn)
>>> }
>>> #endif
>>>
>>> +static inline struct slave *bond_slave_has_mac(struct bonding *bond,
>>> +					       const u8 *mac)
>>> +{
>>> +	int i = 0;
>>> +	struct slave *tmp;
>>> +
>>> +	bond_for_each_slave(bond, tmp, i)
>>> +		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
>>> +			return tmp;
>>> +
>>> +	return NULL;
>>> +}
>>>
>>> /* exported from bond_main.c */
>>> extern int bond_net_id;
>>> -- 
>>> 1.7.6.5

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
