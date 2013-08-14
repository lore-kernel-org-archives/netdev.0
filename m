From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net-next 2/6] vlan: add __vlan_find_dev_next()
Date: Wed, 14 Aug 2013 17:28:03 +0200
Message-ID: <20130814152803.GB21262@redhat.com>
References: <1375981079-2936-1-git-send-email-vfalico@redhat.com>
 <1375981079-2936-3-git-send-email-vfalico@redhat.com>
 <5204CD73.9010309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3364 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929Ab3HNP3F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 11:29:05 -0400
Content-Disposition: inline
In-Reply-To: <5204CD73.9010309@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 09, 2013 at 01:07:31PM +0200, Nikolay Aleksandrov wrote:
...snip...
>We already discussed privately my comments about this new function, I'll leave
>them here just for the sake of having them documented:

As an almost top-posting - I'm currently on my vacation, so just a few
comments, without real code/patches. I'll come up with v3 at the next week,
hopefully.

>My proposition is to drop these changes altogether (the new function, and the
>vlan.h macro change) and instead add something like the following (I haven't
>tested it, it's only to illustrate the idea) in if_vlan.h so it'll be accessible
>to everyone:
>
>Version 1 (circular so you can simplify the bonding ALB code, I haven't left
>spaces because of auto-wrapping):
>
>#define dev_for_each_vlan_from(dev, vlandev, proto, from, i)
>	for (i=from+1, vlandev=__vlan_find_dev_deep(dev, proto, from); \
>	     i!=from; \
>	     i=(i+1)%VLAN_N_VID, vlandev=__vlan_find_dev_deep(dev, proto, i)) \
>		if (vlandev)
>
>#define dev_for_each_vlan(dev, vlandev, proto, i)
>	dev_for_each_vlan_from(dev, vlandev, proto, 0, i)

I like this idea, however it's an overkill in some places (and calling
8k times __vlan_find_dev_deep()->rcu_dereference, verify for vlan_info,
re-call itself 8k times if it's really a slave etc... not really good).
That was one of the main thoughts when I've chosen the other way -
	while (vlan = vlan_next(vlan))

They're also quite ugly (huge for, and an if () inside of a nested define)
- but that's more an IMO.

But, again, I like the dev_for_each_vlan() idea, and will look at it again,
trying to omit the __vlan_find_dev_deep() somehow and without that
monstrous for() :).

>
>Version 2 is the same but a little shorter, without the circular part.
>This way you reuse the already provided function __vlan_find_dev_deep and the
>churn is smaller, also __vlan_find_dev_deep takes care of the master issue (that
>is if dev doesn't have a vlan_info, then its master's vlan_info will be used).

Great ideas, thank you.

>Also the code will look much nicer IMO changing this:
>while ((vlan_dev = __vlan_find_dev_next))
>
>to
>
>dev_for_each_vlan(dev, vlan_dev, proto, i)

Yep, I agree, dev_for_each_vlan() looks a lot more readable. Maybe the
proto and i args can also be dropped somehow, I'll take a look...

>
>There're also 2 nice side-effects, first you'll only walk over 4096 entries (for
>the specified vlan proto only)

Not a big one, tbh, cause the current code looks for at most
vlan_id..8192(+0..vlan_id), so 8192. But the proto is indeed a good
side-effect. Another point - we're not working with QinQ at all...

>and the bonding ALB code will simplify from the
>ambiguous looking:
>			vlan_id = bond->alb_info.current_alb_vlan;
>			vlan_dev = __vlan_find_dev_deep(bond->dev,
>							htons(ETH_P_8021Q),
>							vlan_id);
>
>			/* search for the next one, if not found - for any */
>			if (vlan_dev)
>				vlan_dev = __vlan_find_dev_next(bond->dev,
>								vlan_dev);
>			if (!vlan_dev)
>				vlan_dev = __vlan_find_dev_next(bond->dev,
>								NULL);
>
>			if (vlan_dev) {
>				vlan_id = vlan_dev_vlan_id(vlan_dev);
>				bond->alb_info.current_alb_vlan = vlan_id;
>			} else {
>				bond->alb_info.current_alb_vlan = 0;
>				rcu_read_unlock();
>				kfree_skb(skb);
> 				continue;
> 			}
>
>to something like (again untested, sorry for the style - line wrapping):

Yep, that's why I really like the idea with dev_for_each_vlan(), with one
minor comment (which is fixable, I guess).

>
>			vlan_id = bond->alb_info.current_alb_vlan+1;
>			/* since from here is current+1, if there aren't any
>			 * vlans up to current, it'll get current again if it's
>			 * available
>			 */
>			dev_for_each_vlan_from(bond->dev, vlan_dev, htons(ETH_P_8021Q), vlan_id, i)
>			break;

			^^^^^ THIS. It makes a big "WHAT?" in my head. :)

>
>			if (vlan_dev) {
>				vlan_id = vlan_dev_vlan_id(vlan_dev);
>				bond->alb_info.current_alb_vlan = vlan_id;
>			} else {
>				bond->alb_info.current_alb_vlan = 0;
>				rcu_read_unlock();
>				kfree_skb(skb);
> 				continue;
> 			}
>
>Cheers,
> Nik

Thanks a lot for the feedback, really appreciated :).
