From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Question regarding bond delete notifications
Date: Sat, 26 Apr 2014 23:16:27 -0700
Message-ID: <535CA0BB.1010504@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:56696 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744AbaD0GQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 02:16:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am seeing a problem with the order of rtnl link notifications during 
bond deletes.
If i delete a bond without deleting its slaves, kernel sends a 
RTM_DELLINK during unregister_netdevice
(in rollback_registered_many) and then calls bond_uninit (ndo_uninit).
bond_uninit inturn cleans up the slaves and generates a few RTM_NEWLINK 
rtnl notifications for NETDEV_CHANGEADDR and NETDEV_FEAT_CHANGE for the 
bond device.

This is confusing to userspace listening for rtnl LINK Notifications.
For example, libnl gets confused with RTM_NEWLINK arriving after 
RTM_DELLINK.
The RTM_NEWLINK makes libnl believe that this is a new bond link. But 
kernel has already deleted the bond device.

It seems like the kernel should  generate RTM_DELLINK notification after 
ndo_uninit. something like below.
But am not sure if this change is safe for other netdevices.

Is this a known problem ?. Any suggestions ?

Thanks,
Roopa

diff --git a/net/core/dev.c b/net/core/dev.c
index b1b0c8d..85cb73a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5568,33 +5568,33 @@ static void rollback_registered_many(struct 
list_head *head)
     list_for_each_entry(dev, head, unreg_list) {
         /* Shutdown queueing discipline. */
         dev_shutdown(dev);


         /* Notify protocols, that we are about to destroy
            this device. They should clean all the things.
         */
         call_netdevice_notifiers(NETDEV_UNREGISTER, dev);

-       if (!dev->rtnl_link_ops ||
-           dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
-           rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
-
         /*
          *  Flush the unicast and multicast chains
          */
         dev_uc_flush(dev);
         dev_mc_flush(dev);

         if (dev->netdev_ops->ndo_uninit)
             dev->netdev_ops->ndo_uninit(dev);

+       if (!dev->rtnl_link_ops ||
+           dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
+           rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
+
         /* Notifier chain MUST detach us all upper devices. */
         WARN_ON(netdev_has_any_upper_dev(dev));

         /* Remove entries from kobject tree */
         netdev_unregister_kobject(dev);
  #ifdef CONFIG_XPS
         /* Remove XPS queueing entries */
         netif_reset_xps_queues_gt(dev, 0);
  #endif
     }
