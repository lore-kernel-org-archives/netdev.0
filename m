From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 2/2] ixgbe: enable l2 forwarding acceleration for
 macvlans
Date: Tue, 5 Nov 2013 15:52:45 -0500
Message-ID: <20131105205245.GC14954@hmsreliant.think-freely.org>
References: <20131104185717.11802.69282.stgit@jf-dev1-dcblab>
 <20131104190154.11802.75724.stgit@jf-dev1-dcblab>
 <20131105142631.GB14954@hmsreliant.think-freely.org>
 <5279566E.6030807@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	andy@greyhouse.net, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34443 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754726Ab3KEUxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 15:53:11 -0500
Content-Disposition: inline
In-Reply-To: <5279566E.6030807@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 05, 2013 at 12:34:54PM -0800, John Fastabend wrote:
> On 11/5/2013 6:26 AM, Neil Horman wrote:
> >On Mon, Nov 04, 2013 at 11:01:55AM -0800, John Fastabend wrote:
> >>Now that l2 acceleration ops are in place from the prior patch,
> >>enable ixgbe to take advantage of these operations.  Allow it to
> >>allocate queues for a macvlan so that when we transmit a frame,
> >>we can do the switching in hardware inside the ixgbe card, rather
> >>than in software.
> >>
> >>For now this patch limits the hardware to 8 offloaded macvlan ports.
> >>A follow on patch will remove this limitation but to simplify
> >>review/validation of the new macvlan offload ops we leave it at 8
> >>for now.
> >>
> >>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >>CC: Andy Gospodarek <andy@greyhouse.net>
> >>CC: "David S. Miller" <davem@davemloft.net>
> >
> >A few Nits, since you're going to send a V3 anyway.  Comments inline.
> >
> >>---
> 
> 
> [...]
> 
> >Nit: You're using macvlan here, and vsi above.  Might be nice to give everything
> >a consistent suffix/prefix for clarity.  Perhaps dfwd since thats what the new
> >ndo_ops uses?
> >
> 
> using dfwd now.
> 
> >><snip>
> >
> >>  static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
> >>@@ -4317,6 +4521,8 @@ static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
> >>  static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
> >>  {
> >>  	struct ixgbe_hw *hw = &adapter->hw;
> >>+	struct net_device *upper;
> >>+	struct list_head *iter;
> >>  	int err;
> >>  	u32 ctrl_ext;
> >>
> >>@@ -4360,6 +4566,16 @@ static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
> >>  	/* enable transmits */
> >>  	netif_tx_start_all_queues(adapter->netdev);
> >>
> >>+	/* enable any upper devices */
> >>+	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
> >>+		if (netif_is_macvlan(upper)) {
> >>+			struct macvlan_dev *vlan = netdev_priv(upper);
> >>+
> >>+			if (vlan->fwd_priv)
> >>+				netif_tx_start_all_queues(upper);
> >>+		}
> >>+	}
> >>+
> >I don't think it matters much, but do we want to start the upper devs queues
> >here unilaterally?  Nominally a network interface starts its queues on dev_open.
> >Would it be better to only start those devices if (vlan->fwd_priv &&
> >(upper->flags & IFF_UP)?  We would then have to listen for NETDEV_UP events as
> >well to handle accelerated macvlans comming up after ixgbe does, which is more
> >work, but I wanted to mention this in case theres some disadvantage to starting
> >the queue early.
> >
> 
> vlan->fwd_priv is set in macvlan_open() and cleared in macvlan_close()
> and serialized with the rtnl lock. So I think anytime you get here and
> have vlan->fwd_priv non-null its the same as IFF_UP being set.
> 
> The only call sites I see changing the IFF_UP flag are dev_open() and
> dev_close() and derivatives.  Each calls ndo_open and ndo_close. So
> assuming I didn't miss some call sites the above seems correct.
> 
> >
> >Other than that I think it looks good though.  Nice work!
> >
> 
> Great thanks for looking it over. I should have v3 out here shortly
> doing a couple more tests for feature interop.
> 
Copy that, I'll sign off on that version
Neil

> >Regards
> >Neil
> >
> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
> 
