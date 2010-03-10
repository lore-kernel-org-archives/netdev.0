From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [net-next-2.6 PATCH 3/3] net: forbid underlaying devices to change its type
Date: Wed, 10 Mar 2010 13:04:10 -0800
Message-ID: <23664.1268255050@death.nxdomain.ibm.com>
References: <20100310202804.GC2834@psychotron.redhat.com> <20100310203019.GF2834@psychotron.redhat.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:46979 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757113Ab0CJVER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 16:04:17 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2AKwXHx031558
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 13:58:33 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2AL4Ea3114042
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 14:04:14 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2AL4CDr003309
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 14:04:14 -0700
In-reply-to: <20100310203019.GF2834@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>It's not desired for underlaying devices to change type. At the time, there is
>for example possible to have bond with changed type from Ethernet to Infiniband
>as a port of a bridge. This patch fixes this.

	Do the current initscripts / sysconfig packages do things such
that this restriction won't break things?  I.e., do those packages have
a dependency on being able to change the type after setting up, e.g., a
VLAN over bonding on Infiniband?

	This isn't to suggest that this change should be rejected if the
above is true; rather, I'm curious as to how this came up as a problem,
and whether initscripts / sysconfig require concurrent changes.

	In any event, it all seems reasonable to me, so, at least for
the bonding bits:

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J


>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>---
> drivers/net/macvlan.c  |    3 +++
> net/8021q/vlan.c       |    4 ++++
> net/bridge/br_notify.c |    4 ++++
> 3 files changed, 11 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>index 40faa36..445e73c 100644
>--- a/drivers/net/macvlan.c
>+++ b/drivers/net/macvlan.c
>@@ -748,6 +748,9 @@ static int macvlan_device_event(struct notifier_block *unused,
> 		list_for_each_entry_safe(vlan, next, &port->vlans, list)
> 			vlan->dev->rtnl_link_ops->dellink(vlan->dev, NULL);
> 		break;
>+	case NETDEV_PRE_TYPE_CHANGE:
>+		/* Forbid underlaying device to change its type. */
>+		return NOTIFY_BAD;
> 	}
> 	return NOTIFY_DONE;
> }
>diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
>index 4535122..c39a5f4 100644
>--- a/net/8021q/vlan.c
>+++ b/net/8021q/vlan.c
>@@ -530,6 +530,10 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
> 		}
> 		unregister_netdevice_many(&list);
> 		break;
>+
>+	case NETDEV_PRE_TYPE_CHANGE:
>+		/* Forbid underlaying device to change its type. */
>+		return NOTIFY_BAD;
> 	}
>
> out:
>diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
>index 763a3ec..1413b72 100644
>--- a/net/bridge/br_notify.c
>+++ b/net/bridge/br_notify.c
>@@ -82,6 +82,10 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
> 	case NETDEV_UNREGISTER:
> 		br_del_if(br, dev);
> 		break;
>+
>+	case NETDEV_PRE_TYPE_CHANGE:
>+		/* Forbid underlaying device to change its type. */
>+		return NOTIFY_BAD;
> 	}
>
> 	/* Events that may cause spanning tree to refresh */
>-- 
>1.6.6.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
