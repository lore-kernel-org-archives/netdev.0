From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] net: add NETDEV_PRECHANGEMTU to notify
 before mtu change happens
Date: Thu, 16 Jan 2014 08:18:03 +0100
Message-ID: <20140116071803.GB2815@minipsycho.orion>
References: <1389826939-20691-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <amwang@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:61850 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaAPHSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 02:18:07 -0500
Received: by mail-ea0-f169.google.com with SMTP id l9so798067eaj.14
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 23:18:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1389826939-20691-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 16, 2014 at 12:02:18AM CET, vfalico@redhat.com wrote:
>Currently, if a device changes its mtu, first the change happens (invloving
>all the side effects), and after that the NETDEV_CHANGEMTU is sent so that
>other devices can catch up with the new mtu. However, if they return
>NOTIFY_BAD, then the change is reverted and error returned.
>
>This is a really long and costy operation (sometimes). To fix this, add
>NETDEV_PRECHANGEMTU notification which is called prior to any change
>actually happening, and if any callee returns NOTIFY_BAD - the change is
>aborted. This way we're skipping all the playing with apply/revert the mtu.
>
>CC: "David S. Miller" <davem@davemloft.net>
>CC: Jiri Pirko <jiri@resnulli.us>
>CC: Eric Dumazet <edumazet@google.com>
>CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>CC: Cong Wang <amwang@redhat.com>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
> include/linux/netdevice.h | 3 ++-
> net/core/dev.c            | 5 +++++
> 2 files changed, 7 insertions(+), 1 deletion(-)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 5c88ab1..6fa2c91 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -1718,7 +1718,7 @@ struct pcpu_sw_netstats {
> #define NETDEV_CHANGE	0x0004	/* Notify device state change */
> #define NETDEV_REGISTER 0x0005
> #define NETDEV_UNREGISTER	0x0006
>-#define NETDEV_CHANGEMTU	0x0007
>+#define NETDEV_CHANGEMTU	0x0007 /* notify after mtu change happened */
> #define NETDEV_CHANGEADDR	0x0008
> #define NETDEV_GOING_DOWN	0x0009
> #define NETDEV_CHANGENAME	0x000A
>@@ -1734,6 +1734,7 @@ struct pcpu_sw_netstats {
> #define NETDEV_JOIN		0x0014
> #define NETDEV_CHANGEUPPER	0x0015
> #define NETDEV_RESEND_IGMP	0x0016
>+#define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
> 
> int register_netdevice_notifier(struct notifier_block *nb);
> int unregister_netdevice_notifier(struct notifier_block *nb);
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 20c834e..cb78923 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -5360,6 +5360,11 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
> 	if (!netif_device_present(dev))
> 		return -ENODEV;
> 
>+	err = call_netdevice_notifiers(NETDEV_PRECHANGEMTU, dev);
>+	err = notifier_to_errno(err);
>+	if (err)
>+		return err;
>+
> 	orig_mtu = dev->mtu;
> 	err = __dev_set_mtu(dev, new_mtu);
> 
>-- 
>1.8.4
>

I like this 

Acked-by: Jiri Pirko <jiri@resnulli.us>
