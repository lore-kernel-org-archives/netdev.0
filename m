From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next] net: always pass struct netdev_notifier_info to
 netdevice notifiers
Date: Wed, 29 May 2013 07:58:41 +0200
Message-ID: <20130529055841.GA1518@minipsycho.orion>
References: <1369798250-25798-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:59618 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320Ab3E2F6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 01:58:45 -0400
Received: by mail-wg0-f42.google.com with SMTP id n12so3777653wgh.5
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 22:58:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1369798250-25798-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 29, 2013 at 05:30:50AM CEST, amwang@redhat.com wrote:
>From: Cong Wang <amwang@redhat.com>
>
>commit 351638e7deeed2ec8ce451b53d3 (net: pass info struct via netdevice notifier)
>breaks booting of my KVM guest, this is due to we still forget to pass
>struct netdev_notifier_info in several places. This patch completes it.

Oh, I completely missed these. I hope that there are no more hidden
places like these.

Thanks.

>
>Cc: Jiri Pirko <jiri@resnulli.us>
>Cc: David S. Miller <davem@davemloft.net>
>Signed-off-by: Cong Wang <amwang@redhat.com>
>
>---
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 8502718..8f967e3 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -1609,6 +1609,12 @@ struct netdev_notifier_change_info {
> 	unsigned int flags_changed;
> };
> 
>+static inline void netdev_notifier_info_init(struct netdev_notifier_info *info,
>+					     struct net_device *dev)
>+{
>+	info->dev = dev;
>+}
>+
> static inline struct net_device *
> netdev_notifier_info_to_dev(const struct netdev_notifier_info *info)
> {
>diff --git a/net/atm/clip.c b/net/atm/clip.c
>index cce241e..8215f7c 100644
>--- a/net/atm/clip.c
>+++ b/net/atm/clip.c
>@@ -575,6 +575,7 @@ static int clip_inet_event(struct notifier_block *this, unsigned long event,
> 			   void *ifa)
> {
> 	struct in_device *in_dev;
>+	struct netdev_notifier_info info;
> 
> 	in_dev = ((struct in_ifaddr *)ifa)->ifa_dev;
> 	/*
>@@ -583,7 +584,8 @@ static int clip_inet_event(struct notifier_block *this, unsigned long event,
> 	 */
> 	if (event != NETDEV_UP)
> 		return NOTIFY_DONE;
>-	return clip_device_event(this, NETDEV_CHANGE, in_dev->dev);
>+	netdev_notifier_info_init(&info, in_dev->dev);
>+	return clip_device_event(this, NETDEV_CHANGE, &info);
> }
> 
> static struct notifier_block clip_dev_notifier = {
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 6eb621c..b2e9057 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -1391,12 +1391,6 @@ void dev_disable_lro(struct net_device *dev)
> }
> EXPORT_SYMBOL(dev_disable_lro);
> 
>-static void netdev_notifier_info_init(struct netdev_notifier_info *info,
>-				      struct net_device *dev)
>-{
>-	info->dev = dev;
>-}
>-
> static int call_netdevice_notifier(struct notifier_block *nb, unsigned long val,
> 				   struct net_device *dev)
> {
>diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
>index dd5508b..30e4de9 100644
>--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
>+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
>@@ -129,7 +129,10 @@ static int masq_inet_event(struct notifier_block *this,
> 			   void *ptr)
> {
> 	struct net_device *dev = ((struct in_ifaddr *)ptr)->ifa_dev->dev;
>-	return masq_device_event(this, event, dev);
>+	struct netdev_notifier_info info;
>+
>+	netdev_notifier_info_init(&info, dev);
>+	return masq_device_event(this, event, &info);
> }
> 
> static struct notifier_block masq_dev_notifier = {
>diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>index bce073b..7b34f06 100644
>--- a/net/ipv6/addrconf.c
>+++ b/net/ipv6/addrconf.c
>@@ -4645,13 +4645,16 @@ int addrconf_sysctl_forward(ctl_table *ctl, int write,
> 
> static void dev_disable_change(struct inet6_dev *idev)
> {
>+	struct netdev_notifier_info info;
>+
> 	if (!idev || !idev->dev)
> 		return;
> 
>+	netdev_notifier_info_init(&info, idev->dev);
> 	if (idev->cnf.disable_ipv6)
>-		addrconf_notify(NULL, NETDEV_DOWN, idev->dev);
>+		addrconf_notify(NULL, NETDEV_DOWN, &info);
> 	else
>-		addrconf_notify(NULL, NETDEV_UP, idev->dev);
>+		addrconf_notify(NULL, NETDEV_UP, &info);
> }
> 
> static void addrconf_disable_change(struct net *net, __s32 newf)
>diff --git a/net/ipv6/netfilter/ip6t_MASQUERADE.c b/net/ipv6/netfilter/ip6t_MASQUERADE.c
>index b76257c..47bff61 100644
>--- a/net/ipv6/netfilter/ip6t_MASQUERADE.c
>+++ b/net/ipv6/netfilter/ip6t_MASQUERADE.c
>@@ -89,8 +89,10 @@ static int masq_inet_event(struct notifier_block *this,
> 			   unsigned long event, void *ptr)
> {
> 	struct inet6_ifaddr *ifa = ptr;
>+	struct netdev_notifier_info info;
> 
>-	return masq_device_event(this, event, ifa->idev->dev);
>+	netdev_notifier_info_init(&info, ifa->idev->dev);
>+	return masq_device_event(this, event, &info);
> }
> 
> static struct notifier_block masq_inet_notifier = {
