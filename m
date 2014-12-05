From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to switch
 asic if feature flag set
Date: Fri, 5 Dec 2014 08:38:40 +0100
Message-ID: <20141205073840.GA1866@nanopsycho.orion>
References: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, nhorman@tuxdriver.com,
	nicolas.dichtel@6wind.com, vyasevic@redhat.com,
	f.fainelli@gmail.com, buytenh@wantstofly.org, aviadr@mellanox.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:39216 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaLEHin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 02:38:43 -0500
Received: by mail-wg0-f43.google.com with SMTP id l18so182629wgh.2
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 23:38:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 05, 2014 at 03:26:40AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>This allows offloading to switch asic without having the user to set
>any flag. And this is done in the bridge driver to rollback kernel settings
>on hw offload failure if required in the future.
>
>With this, it also makes sure a notification goes out only after the
>attributes are set both in the kernel and hw.
>---
> net/bridge/br_netlink.c |   27 ++++++++++++++++++++++++++-
> 1 file changed, 26 insertions(+), 1 deletion(-)
>
>diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>index 9f5eb55..ce173f0 100644
>--- a/net/bridge/br_netlink.c
>+++ b/net/bridge/br_netlink.c
>@@ -407,9 +407,21 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
> 				afspec, RTM_SETLINK);
> 	}
> 
>+	if ((dev->features & NETIF_F_HW_SWITCH_OFFLOAD) &&
>+			dev->netdev_ops->ndo_bridge_setlink) {
>+		int ret = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);

	This (and I suspect other patches as well) has many issues which
	are pointed out by scripts/checkpatch.pl sctipts. For example
	here, there should be an empty line. Please run your patches by
	this script before you send them.

>+		if (ret && ret != -EOPNOTSUPP) {
>+			/* XXX Fix this in the future to rollback
>+			 * kernel settings and return error
>+			 */
>+			br_warn(p->br, "error offloading bridge attributes " 
>+					"on port %u(%s)\n", (unsigned int) p->port_no,
>+					p->dev->name);
>+		}
>+	}
>+
> 	if (err == 0)
> 		br_ifinfo_notify(RTM_NEWLINK, p);
>-
> out:
> 	return err;
> }
>@@ -433,6 +445,19 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh)
> 	err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
> 			afspec, RTM_DELLINK);
> 
>+	if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD
>+			&& dev->netdev_ops->ndo_bridge_setlink) {
>+		int ret = dev->netdev_ops->ndo_bridge_dellink(dev, nlh);

	c&p issue, there should be check for dellink here.

>+		if (ret && ret != -EOPNOTSUPP) {
>+			/* XXX Fix this in the future to rollback
>+			 * kernel settings and return error
>+			 */
>+			br_warn(p->br, "error offloading bridge attributes " 
>+					"on port %u(%s)\n", (unsigned int) p->port_no,
>+					p->dev->name);
>+		}
>+	}
>+


	I agree with Scott that this code should be moved to rtnetlink.c

> 	return err;
> }
> static int br_validate(struct nlattr *tb[], struct nlattr *data[])
>-- 
>1.7.10.4
>
