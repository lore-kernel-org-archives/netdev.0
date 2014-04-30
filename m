From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Question regarding bond delete notifications
Date: Wed, 30 Apr 2014 08:31:36 +0200
Message-ID: <20140430063136.GA2917@minipsycho.orion>
References: <535CA0BB.1010504@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>, j.vosburgh@gmail.com,
	vfalico@gmail.com, andy@greyhouse.net
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:41371 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbaD3Gbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 02:31:42 -0400
Received: by mail-la0-f52.google.com with SMTP id mc6so886066lab.39
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 23:31:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <535CA0BB.1010504@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Apr 27, 2014 at 08:16:27AM CEST, roopa@cumulusnetworks.com wrote:
>Hello,
>
>I am seeing a problem with the order of rtnl link notifications
>during bond deletes.
>If i delete a bond without deleting its slaves, kernel sends a
>RTM_DELLINK during unregister_netdevice
>(in rollback_registered_many) and then calls bond_uninit (ndo_uninit).
>bond_uninit inturn cleans up the slaves and generates a few
>RTM_NEWLINK rtnl notifications for NETDEV_CHANGEADDR and
>NETDEV_FEAT_CHANGE for the bond device.
>
>This is confusing to userspace listening for rtnl LINK Notifications.
>For example, libnl gets confused with RTM_NEWLINK arriving after
>RTM_DELLINK.
>The RTM_NEWLINK makes libnl believe that this is a new bond link. But
>kernel has already deleted the bond device.
>
>It seems like the kernel should  generate RTM_DELLINK notification
>after ndo_uninit. something like below.
>But am not sure if this change is safe for other netdevices.
>
>Is this a known problem ?. Any suggestions ?
>
>Thanks,
>Roopa
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index b1b0c8d..85cb73a 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -5568,33 +5568,33 @@ static void rollback_registered_many(struct
>list_head *head)
>    list_for_each_entry(dev, head, unreg_list) {
>        /* Shutdown queueing discipline. */
>        dev_shutdown(dev);
>
>
>        /* Notify protocols, that we are about to destroy
>           this device. They should clean all the things.
>        */
>        call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
>
>-       if (!dev->rtnl_link_ops ||
>-           dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
>-           rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
>-
>        /*
>         *  Flush the unicast and multicast chains
>         */
>        dev_uc_flush(dev);
>        dev_mc_flush(dev);
>
>        if (dev->netdev_ops->ndo_uninit)
>            dev->netdev_ops->ndo_uninit(dev);
>
>+       if (!dev->rtnl_link_ops ||
>+           dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
>+           rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
>+
>        /* Notifier chain MUST detach us all upper devices. */
>        WARN_ON(netdev_has_any_upper_dev(dev));
>
>        /* Remove entries from kobject tree */
>        netdev_unregister_kobject(dev);
> #ifdef CONFIG_XPS
>        /* Remove XPS queueing entries */
>        netif_reset_xps_queues_gt(dev, 0);
> #endif
>    }
>


Now I cannot think about why this might troubles. But my feeling it this
might be problematic, just a feeling.

Your change seems logical though.
