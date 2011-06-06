From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH] macvlan: add VLAN filters to lowerdev
Date: Mon, 06 Jun 2011 15:44:39 -0700
Message-ID: <4DED5857.2000408@intel.com>
References: <20110606142715.2692.6311.stgit@jf-dev1-dcblab> <20110606.150352.392614415181146213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33407 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758413Ab1FFWok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 18:44:40 -0400
In-Reply-To: <20110606.150352.392614415181146213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/6/2011 3:03 PM, David Miller wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Mon, 06 Jun 2011 07:27:16 -0700
> 
>> Stacking VLANs on top of the macvlan device does not
>> work if the lowerdev device is using vlan filters set
>> by NETIF_F_HW_VLAN_FILTER. Add ndo ops to pass vlan
>> calls to lowerdev.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> I think this might have unintended side-effects.
> 
> Much of the VLAN code makes decisions based upon whether these
> ops are NULL or not.
> 
> Now, no matter what is implemented in the lower device, the VLAN
> code will see them non-NULL in the macvlan device.

I would expect these decisions to be wrapped in the feature flag
like this,

        if (vlan_id && (real_dev->features & NETIF_F_HW_VLAN_FILTER))
                ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);

Although grep found two call sites not wrapped,

int register_vlan_dev(struct net_device *dev)
	[...]
        if (ngrp) {
                if (ops->ndo_vlan_rx_register)
                        ops->ndo_vlan_rx_register(real_dev, ngrp);
                rcu_assign_pointer(real_dev->vlgrp, ngrp);
        }


And,

void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
	[...]

        /* If the group is now empty, kill off the group. */
        if (grp->nr_vlans == 0) {
                vlan_gvrp_uninit_applicant(real_dev);

                rcu_assign_pointer(real_dev->vlgrp, NULL);
                if (ops->ndo_vlan_rx_register)
                        ops->ndo_vlan_rx_register(real_dev, NULL);

                /* Free the group, after all cpu's are done. */
                call_rcu(&grp->rcu, vlan_rcu_free);
        }


I could wrap these in feature flag checks as well but I see no harm
in letting these fall through to the macvlan driver and failing.

Thanks,
John.




