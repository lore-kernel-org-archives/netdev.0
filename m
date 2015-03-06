From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v4 5/8] switchdev: implement IPv4 fib ndo wrappers
Date: Fri, 6 Mar 2015 01:38:43 -0800
Message-ID: <CAE4R7bA=sh944g7S-+JTxechQca-7S3B0u9Z26B9fDZUTqk+1w@mail.gmail.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
	<1425619280-27492-6-git-send-email-sfeldma@gmail.com>
	<20150306072400.GB2011@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:42492 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932760AbbCFJio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 04:38:44 -0500
Received: by qgfi50 with SMTP id i50so11266675qgf.9
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 01:38:43 -0800 (PST)
In-Reply-To: <20150306072400.GB2011@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 5, 2015 at 11:24 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Mar 06, 2015 at 06:21:17AM CET, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>Flesh out ndo wrappers to call into device driver.  To call into device driver,
>>the wrapper must interate over route's nexthops to ensure all nexthop devs
>>belong to the same switch device.  Currently, there is no support for route's
>>nexthops spanning offloaded and non-offloaded devices, or spanning ports of
>>multiple offload devices.
>>
>>Since switch device ports may be stacked under virtual interfaces (bonds and/or
>>bridges), and the route's nexthop may be on the virtual interface, the wrapper
>>will traverse the nexthop dev down to the base dev.  It's the base dev that's
>>passed to the switchdev driver's ndo ops.
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>---
>> net/switchdev/switchdev.c |   98 ++++++++++++++++++++++++++++++++++++++++++++-
>> 1 file changed, 96 insertions(+), 2 deletions(-)
>>
>>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>>index 81c4c02..99907d8 100644
>>--- a/net/switchdev/switchdev.c
>>+++ b/net/switchdev/switchdev.c
>>@@ -227,6 +227,65 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
>> }
>> EXPORT_SYMBOL(ndo_dflt_netdev_switch_port_bridge_dellink);
>>
>>+static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
>>+{
>>+      const struct net_device_ops *ops = dev->netdev_ops;
>>+      struct net_device *lower_dev;
>>+      struct net_device *port_dev;
>>+      struct list_head *iter;
>>+
>>+      /* Recusively search down until we find a sw port dev.
>>+       * (A sw port dev supports ndo_switch_parent_id_get).
>>+       */
>>+
>>+      if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD &&
>>+          ops->ndo_switch_parent_id_get)
>>+              return dev;
>>+
>>+      netdev_for_each_lower_dev(dev, lower_dev, iter) {
>>+              port_dev = netdev_switch_get_lowest_dev(lower_dev);
>>+              if (port_dev)
>>+                      return port_dev;
>>+      }
>
>
> I think we should proparate through stacked devices properly as we do in
> case of netdev_switch_port_bridge_setlink and netdev_switch_port_bridge_dellink
> (and also with roopa's new patchset in case of
> netdev_switch_port_stp_update)

I think it's actually ndo_switch_parent_id_get you want to Roopa-fy
(new word, has a nice ring to it).  But yes, do-able.

> Other than this I like this patchset. Great work! Thanks.

Thanks for the early reviews.
