From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH v2 net-next 2/6] vlan: add __vlan_find_dev_next()
Date: Fri, 09 Aug 2013 13:07:31 +0200
Message-ID: <5204CD73.9010309@redhat.com>
References: <1375981079-2936-1-git-send-email-vfalico@redhat.com> <1375981079-2936-3-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19688 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967445Ab3HILLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 07:11:17 -0400
In-Reply-To: <1375981079-2936-3-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2013 06:57 PM, Veaceslav Falico wrote:
> RFC -> v1: make the function accept/return vlan's net_device, this way we
> 	   won't have troubles with VLAN 0, and the user code will be
> 	   cleaner and faster.
> v1  -> v2: don't check for the master device - if we'll want in the future
> 	   to convert a slave device - it will fail, but now we don't
> 	   actually care.
> 
> Add a new exported function __vlan_find_dev_next(dev, vlan_dev), which
> returns the a vlan's net_device that is used by the dev and is its id is
> greater or equal to vlan_dev's vlan id. If vlan_dev is NULL, return first
> vlan, if nothing is found return NULL.
> 
> This function must be under rcu_read_lock(), is aware of master devices and
> doesn't guarantee that, once it returns, the vlan dev will still be used by
> dev as its vlan.
> 
> It's basically a helper for "for_each_vlan_in_dev(dev, vlan_dev)" logic,
> and is supposed to be used like this:
> 
> vlan_dev = NULL;
> 
> while ((vlan_dev = __vlan_find_dev_next(dev, vlan_dev))) {
> 	if (!vlan_dev)
> 		continue;
> 
> 	do_work(vlan_dev);
> }
> 
> In that case we're sure that vlan_dev at least was used as a vlan, and won't
> go away while we're holding rcu_read_lock().
> 
> However, if we don't hold rtnl_lock(), we can't be sure that that vlan_dev
> is still in dev's vlan_list.
> 
> CC: Patrick McHardy <kaber@trash.net>
> CC: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---

We already discussed privately my comments about this new function, I'll leave
them here just for the sake of having them documented:
My proposition is to drop these changes altogether (the new function, and the
vlan.h macro change) and instead add something like the following (I haven't
tested it, it's only to illustrate the idea) in if_vlan.h so it'll be accessible
to everyone:

Version 1 (circular so you can simplify the bonding ALB code, I haven't left
spaces because of auto-wrapping):

#define dev_for_each_vlan_from(dev, vlandev, proto, from, i)
	for (i=from+1, vlandev=__vlan_find_dev_deep(dev, proto, from); \
	     i!=from; \
	     i=(i+1)%VLAN_N_VID, vlandev=__vlan_find_dev_deep(dev, proto, i)) \
		if (vlandev)

#define dev_for_each_vlan(dev, vlandev, proto, i)
	dev_for_each_vlan_from(dev, vlandev, proto, 0, i)

Version 2 is the same but a little shorter, without the circular part.
This way you reuse the already provided function __vlan_find_dev_deep and the
churn is smaller, also __vlan_find_dev_deep takes care of the master issue (that
is if dev doesn't have a vlan_info, then its master's vlan_info will be used).
Also the code will look much nicer IMO changing this:
while ((vlan_dev = __vlan_find_dev_next))

to

dev_for_each_vlan(dev, vlan_dev, proto, i)

There're also 2 nice side-effects, first you'll only walk over 4096 entries (for
the specified vlan proto only) and the bonding ALB code will simplify from the
ambiguous looking:
			vlan_id = bond->alb_info.current_alb_vlan;
			vlan_dev = __vlan_find_dev_deep(bond->dev,
							htons(ETH_P_8021Q),
							vlan_id);

			/* search for the next one, if not found - for any */
			if (vlan_dev)
				vlan_dev = __vlan_find_dev_next(bond->dev,
								vlan_dev);
			if (!vlan_dev)
				vlan_dev = __vlan_find_dev_next(bond->dev,
								NULL);

			if (vlan_dev) {
				vlan_id = vlan_dev_vlan_id(vlan_dev);
				bond->alb_info.current_alb_vlan = vlan_id;
			} else {
				bond->alb_info.current_alb_vlan = 0;
				rcu_read_unlock();
				kfree_skb(skb);
 				continue;
 			}

to something like (again untested, sorry for the style - line wrapping):

			vlan_id = bond->alb_info.current_alb_vlan+1;
			/* since from here is current+1, if there aren't any
			 * vlans up to current, it'll get current again if it's
			 * available
			 */
			dev_for_each_vlan_from(bond->dev, vlan_dev, htons(ETH_P_8021Q), vlan_id, i)
			break;

			if (vlan_dev) {
				vlan_id = vlan_dev_vlan_id(vlan_dev);
				bond->alb_info.current_alb_vlan = vlan_id;
			} else {
				bond->alb_info.current_alb_vlan = 0;
				rcu_read_unlock();
				kfree_skb(skb);
 				continue;
 			}

Cheers,
 Nik
