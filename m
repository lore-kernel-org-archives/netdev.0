From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 1/2] net: Add layer 2 hardware acceleration
 operations for macvlan devices
Date: Wed, 2 Oct 2013 08:53:47 -0400
Message-ID: <20131002125347.GA6795@neilslaptop.think-freely.org>
References: <20130911184441.26914.10336.stgit@nitbit.x32>
 <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
 <1380140209-24587-2-git-send-email-nhorman@tuxdriver.com>
 <524BC65B.4080803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, john.fastabend@intel.com,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43674 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729Ab3JBMyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 08:54:02 -0400
Content-Disposition: inline
In-Reply-To: <524BC65B.4080803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 02, 2013 at 12:08:11AM -0700, John Fastabend wrote:
> On 09/25/2013 01:16 PM, Neil Horman wrote:
> >Add a operations structure that allows a network interface to export the fact
> >that it supports package forwarding in hardware between physical interfaces and
> >other mac layer devices assigned to it (such as macvlans).  this operaions
> >structure can be used by virtual mac devices to bypass software switching so
> >that forwarding can be done in hardware more efficiently.
> 
> Some additional nits below which maybe you have already thought of.
> 
Its ok, you can say it, theyre more than nits :), gaping holes is more like it.
This pass was completely untested, I'm still ironing out bits, but I think for
the most part we're in agreement on the items below.  Comments inline.

> >
> >Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >CC: john.fastabend@intel.com
> >CC: "David S. Miller" <davem@davemloft.net>
> >---
> >  drivers/net/macvlan.c      | 37 +++++++++++++++++++++++++++++++++++++
> >  include/linux/if_macvlan.h |  1 +
> >  include/linux/netdevice.h  | 10 ++++++++++
> >  net/core/dev.c             |  3 +++
> >  4 files changed, 51 insertions(+)
> >
> >diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> >index 9bf46bd..0c37b30 100644
> >--- a/drivers/net/macvlan.c
> >+++ b/drivers/net/macvlan.c
> >@@ -296,8 +296,16 @@ netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
> >  	unsigned int len = skb->len;
> >  	int ret;
> >  	const struct macvlan_dev *vlan = netdev_priv(dev);
> >+	const struct l2_forwarding_accel_ops *l2a_ops = vlan->lowerdev->l2a_ops;
> >+
> >+	if (l2a_ops->l2_accel_xmit) {
> >+		ret = l2a_ops->l2_accel_xmit(skb, vlan->l2a_priv);
> >+		if (likely(ret == NETDEV_TX_OK))
> 
> maybe dev_xmit_complete() would be more appropriate?
> 
Yup, I've currently modified this to dev_queue_xmit, but _complete might be a
better option.

> >+			goto update_stats;
> >+	}
> >
> >  	ret = macvlan_queue_xmit(skb, dev);
> >+update_stats:
> >  	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
> >  		struct macvlan_pcpu_stats *pcpu_stats;
> >
> >@@ -336,6 +344,7 @@ static int macvlan_open(struct net_device *dev)
> >  {
> >  	struct macvlan_dev *vlan = netdev_priv(dev);
> >  	struct net_device *lowerdev = vlan->lowerdev;
> >+	const struct l2_forwarding_accel_ops *l2a_ops = lowerdev->l2a_ops;
> >  	int err;
> >
> >  	if (vlan->port->passthru) {
> >@@ -347,6 +356,19 @@ static int macvlan_open(struct net_device *dev)
> >  		goto hash_add;
> 
> Looks like this might break in the passthru case? If you don't call
> l2_accel_add_dev here but still use the l2_accel_xmit.
> 
Yeah, I need to clean this up.

> >  	}
> >
> >+	if (l2a_ops->l2_accel_add_dev) {
> 
> In the error cases it might be preferred to fallback to the
> non-offloaded software path. For example hardware may have a limit
> to the number of VSIs that can be created but we wouldn't want to
> push that up the stack.
> 
Hadn't thought of that, but yes, I agree, falling back to software switching is
definately desireable here

> >+		/* The lowerdev supports l2 switching
> >+		 * try to add this macvlan to it
> >+		 */
> >+		vlan->l2a_priv = kzalloc(l2a_ops->priv_size, GFP_KERNEL);
> >+		if (!vlan->l2a_priv)
> >+			return -ENOMEM;
> >+		err = l2a_ops->l2_accel_add_dev(vlan->lowerdev,
> >+						dev, vlan->l2a_priv);
> >+		if (err < 0)
> >+			return err;
> >+	}
> >+
> >  	err = -EBUSY;
> >  	if (macvlan_addr_busy(vlan->port, dev->dev_addr))
> >  		goto out;
> >@@ -367,6 +389,13 @@ hash_add:
> >  del_unicast:
> >  	dev_uc_del(lowerdev, dev->dev_addr);
> >  out:
> >+	if (vlan->l2a_priv) {
> 
> Add a feature flag here so it can be disabled.
> 
Makes sense.

I'm still working out kinks, but I hope to have a next version later this
week/early next.  I'll make sure to incorporate these changes. 

Thanks!
Neil

> >+		if (l2a_ops->l2_accel_del_dev)
> >+			l2a_ops->l2_accel_del_dev(vlan->lowerdev,
> >+						  vlan->l2a_priv);
> >+		kfree(vlan->l2a_priv);
> >+		vlan->l2a_priv = NULL;
> >+	}
> >  	return err;
> >  }
> 
> [...]
> 
> Thanks,
> John
> 
> 
> -- 
> John Fastabend         Intel Corporation
> 
