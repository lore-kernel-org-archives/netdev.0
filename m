From: David Ahern <dsahern@gmail.com>
Subject: Re: [Patch net] ipv6: reorder ip6_route_dev_notifier after
 ipv6_dev_notf
Date: Thu, 4 May 2017 08:00:20 -0600
Message-ID: <06a0c19e-1450-6a97-3bfc-35237d784507@gmail.com>
References: <1493874452-3050-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33196 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752850AbdEDOAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 10:00:23 -0400
Received: by mail-pf0-f195.google.com with SMTP id b23so2222750pfc.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 07:00:23 -0700 (PDT)
In-Reply-To: <1493874452-3050-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/17 11:07 PM, Cong Wang wrote:
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 2f11366..4dbf7e2 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -4024,7 +4024,7 @@ static struct pernet_operations ip6_route_net_late_ops = {
>  
>  static struct notifier_block ip6_route_dev_notifier = {
>  	.notifier_call = ip6_route_dev_notify,
> -	.priority = 0,
> +	.priority = -10, /* Must be called after addrconf_notify!! */
>  };
>  
>  void __init ip6_route_init_special_entries(void)
> 

That should be codified such that if someone changes the priority of the
addrconf notifier, it fixes up the route notifier as well. e.g.,

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 1aeb25dd42a7..6c0ee3ccbe0f 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -20,6 +20,8 @@
 #define ADDRCONF_TIMER_FUZZ            (HZ / 4)
 #define ADDRCONF_TIMER_FUZZ_MAX                (HZ)
+#define ADDRCONF_NOTIFY_PRIORITY       0
+
 #include <linux/in.h>
 #include <linux/in6.h>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a2a370b71249..7a4e6b2996a1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3548,6 +3548,7 @@ static int addrconf_notify(struct notifier_block
*this, unsigned long event,
  */
 static struct notifier_block ipv6_dev_notf = {
        .notifier_call = addrconf_notify,
+       .priority      = ADDRCONF_NOTIFY_PRIORITY,
 };

 static void addrconf_type_change(struct net_device *dev, unsigned long
event)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a1bf426c959b..e0d83f8bc01a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -4024,7 +4024,7 @@ static struct pernet_operations
ip6_route_net_late_ops = {

 static struct notifier_block ip6_route_dev_notifier = {
        .notifier_call = ip6_route_dev_notify,
-       .priority = 0,
+       .priority = ADDRCONF_NOTIFY_PRIORITY - 10,
 };


And you marked this as a patch for net; I think this should go into
net-next.
