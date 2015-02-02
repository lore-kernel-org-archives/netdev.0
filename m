From: Fan Du <fengyuleidian0615@gmail.com>
Subject: [PATCHv2 net] net: restore lro after device detached from bridge
Date: Mon, 02 Feb 2015 10:20:12 +0800
Message-ID: <54CEDEDC.7060507@gmail.com>
References: <1422621209-23222-1-git-send-email-fan.du@intel.com> <54CBEE24.8000603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, bhutchings@solarflare.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:57316 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbbBBCYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2015 21:24:25 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so76174817pad.1
        for <netdev@vger.kernel.org>; Sun, 01 Feb 2015 18:24:25 -0800 (PST)
In-Reply-To: <54CBEE24.8000603@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B401=E6=9C=8831=E6=97=A5 04:48, Alexander Duyck =E5=
=86=99=E9=81=93:
> On 01/30/2015 04:33 AM, Fan Du wrote:
>> Either detaching a device from bridge or switching a device
>> out of FORWARDING state, the original lro feature should
>> possibly be enabled for good reason, e.g. hw feature like
>> receive side coalescing could come into play.
>>
>> BEFORE:
>> echo 1 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k e=
ns806f0 | grep large
>> large-receive-offload: off
>>
>> echo 0 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k e=
ns806f0 | grep large
>> large-receive-offload: off
>>
>> AFTER:
>> echo 1 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k e=
ns806f0 | grep large
>> large-receive-offload: off
>>
>> echo 0 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k e=
ns806f0 | grep large
>> large-receive-offload: on
>>
>> Signed-off-by: Fan Du <fan.du@intel.com>
>> Fixes: 0187bdfb0567 ("net: Disable LRO on devices that are forwardin=
g")
>

> First off this isn't a "fix".  This is going to likely break more tha=
n
> it fixes.  The main reason why LRO is disabled is because it can caus=
e
> more harm then it helps.  Since GRO is available we should err on the
> side of caution since enabling LRO/RSC can have undesirable side effe=
cts
> in a number of cases.

I think you are talking about bad scenarios when net device is attached=
 to a bridge.
Then what's the good reason user has to pay extra cpu power for using G=
RO, instead
of using hw capable LRO/RSC when this net device is detached from bridg=
e acting as
a standalone NIC?

Note, SRC is defaulted to *ON* in practice for ALL ixgbe NICs, as same =
other RSC capable
NICs. Attaching net device to a bridge _once_ should not changed its de=
fault configuration,
moreover it's a subtle change without any message that user won't notic=
ed at all.


 From 1e76b2625b3e6aa239b5ef8399fe441a587c6646 Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@intel.com>
Date: Mon, 2 Feb 2015 05:02:11 -0500
Subject: [PATCH] net: restore lro after device detached from bridge

When detached net device from a bridge, the original lro
feature should possibly be enabled for good reason, e.g.
hw feature like receive side coalescing could come into play.

Signed-off-by: Fan Du <fan.du@intel.com>
=46ixes: 0187bdfb0567 ("net: Disable LRO on devices that are forwarding=
")
---
ChangeLog:
v2:
   - Restore lro only when device detached from bridge
---
  include/linux/netdevice.h |  1 +
  net/bridge/br_if.c        |  1 +
  net/core/dev.c            | 23 +++++++++++++++++++++++
  3 files changed, 25 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 642d426..904b1a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2153,6 +2153,7 @@ int dev_alloc_name(struct net_device *dev, const =
char *name);
  int dev_open(struct net_device *dev);
  int dev_close(struct net_device *dev);
  void dev_disable_lro(struct net_device *dev);
+void dev_enable_lro(struct net_device *dev);
  int dev_loopback_xmit(struct sk_buff *newskb);
  int dev_queue_xmit(struct sk_buff *skb);
  int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 81e49fb..4236f3a 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -565,6 +565,7 @@ int br_del_if(struct net_bridge *br, struct net_dev=
ice *dev)
  		call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);

  	netdev_update_features(br->dev);
+	dev_enable_lro(dev);

  	return 0;
  }
diff --git a/net/core/dev.c b/net/core/dev.c
index 1e325ad..76f2ed7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1451,6 +1451,29 @@ void dev_disable_lro(struct net_device *dev)
  }
  EXPORT_SYMBOL(dev_disable_lro);

+/**
+ *	dev_enable_lro - enable Large Receive Offload on a device
+ *	@dev: device
+ *
+ *	Enable Large Receive Offload (LRO) on a net device.
+ *	This is needed if device is not attached to a bridge.
+ */
+void dev_enable_lro(struct net_device *dev)
+{
+	struct net_device *lower_dev;
+	struct list_head *iter;
+
+	dev->wanted_features |=3D NETIF_F_LRO;
+	netdev_update_features(dev);
+
+	if (unlikely(!(dev->features & NETIF_F_LRO)))
+		netdev_WARN(dev, "failed to enable LRO!\n");
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter)
+		dev_enable_lro(lower_dev);
+}
+EXPORT_SYMBOL(dev_enable_lro);
+
  static int call_netdevice_notifier(struct notifier_block *nb, unsigne=
d long val,
  				   struct net_device *dev)
  {
--=20
1.8.3.1


> As far as the rest of the patch I have serious misgivings as this is
> going to be switching on LRO in multiple cases so if the user disable=
s
> it they will find it was re-enabled when they likely weren't expectin=
g
> it.  LRO/RSC has a history of causing issues in a number of different
> cases.  I'd say if it is off leave it off.  If the user really wants =
to
> enable it they can do so via the ethtool interface that is already
> provided in the kernel after they have removed the interface from the
> bridge, or disabled IP routing.
>
> Leaving it disabled would be consistent with how it is handled in
> ixgbe_fix_features when Rx checksum offload is disabled.  We just
> disable the feature and expect the user to re-enable it when they
> re-enable Rx checksum offload.  The same logic should apply here. The
> user put the hardware in this state, it is the responsibility of the
> user to sort out the side effects of disabled features after they rev=
ert
> to their original state.

>> ---
>>   include/linux/netdevice.h |  1 +
>>   net/bridge/br_if.c        |  1 +
>>   net/core/dev.c            | 24 ++++++++++++++++++++++++
>>   net/ipv4/devinet.c        |  4 ++++
>>   net/ipv6/addrconf.c       |  2 ++
>>   5 files changed, 32 insertions(+)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 642d426..904b1a4 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -2153,6 +2153,7 @@ int dev_alloc_name(struct net_device *dev, con=
st char *name);
>>   int dev_open(struct net_device *dev);
>>   int dev_close(struct net_device *dev);
>>   void dev_disable_lro(struct net_device *dev);
>> +void dev_enable_lro(struct net_device *dev);
>>   int dev_loopback_xmit(struct sk_buff *newskb);
>>   int dev_queue_xmit(struct sk_buff *skb);
>>   int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv);
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index 81e49fb..4236f3a 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -565,6 +565,7 @@ int br_del_if(struct net_bridge *br, struct net_=
device *dev)
>>           call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
>>       netdev_update_features(br->dev);
>> +    dev_enable_lro(dev);
>>       return 0;
>>   }
>
> Removing an interface from a bridge should not be grounds for turning=
 on LRO/RSC.
>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 1e325ad..938d7f6 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1451,6 +1451,30 @@ void dev_disable_lro(struct net_device *dev)
>>   }
>>   EXPORT_SYMBOL(dev_disable_lro);
>> +/**
>> + *    dev_enable_lro - enable Large Receive Offload on a device
>> + *    @dev: device
>> + *
>> + *    Enable Large Receive Offload (LRO) on a net device.  Must be
>> + *    called under RTNL. This is needed if device is not attached
>> + *    to a bridge, or user change the forwarding state.
>> + */
>> +void dev_enable_lro(struct net_device *dev)
>> +{
>> +    struct net_device *lower_dev;
>> +    struct list_head *iter;
>> +
>> +    dev->wanted_features |=3D NETIF_F_LRO;
>> +    netdev_update_features(dev);
>> +
>> +    if (unlikely(!(dev->features & NETIF_F_LRO)))
>> +        netdev_WARN(dev, "failed to enable LRO!\n");
>> +
>> +    netdev_for_each_lower_dev(dev, lower_dev, iter)
>> +        dev_enable_lro(lower_dev);
>> +}
>> +EXPORT_SYMBOL(dev_enable_lro);
>> +
>>   static int call_netdevice_notifier(struct notifier_block *nb, unsi=
gned long val,
>>                      struct net_device *dev)
>>   {
>> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
>> index 214882e..3307196 100644
>> --- a/net/ipv4/devinet.c
>> +++ b/net/ipv4/devinet.c
>> @@ -1956,6 +1956,8 @@ static void inet_forward_change(struct net *ne=
t)
>>           struct in_device *in_dev;
>>           if (on)
>>               dev_disable_lro(dev);
>> +        else
>> +            dev_enable_lro(dev);
>>           rcu_read_lock();
>>           in_dev =3D __in_dev_get_rcu(dev);
>>           if (in_dev) {
>
> Disabling it due to a feature conflict makes sense.  Enabling it afte=
r disabling forwarding not so much.  If the user disabled it prior to e=
nabling forwarding it should stay disabled, not be enabled.
>
>> @@ -2047,6 +2049,8 @@ static int devinet_sysctl_forward(struct ctl_t=
able *ctl, int write,
>>                       container_of(cnf, struct in_device, cnf);
>>                   if (*valp)
>>                       dev_disable_lro(idev->dev);
>> +                else
>> +                    dev_enable_lro(idev->dev);
>>                   inet_netconf_notify_devconf(net,
>>                                   NETCONFA_FORWARDING,
>>                                   idev->dev->ifindex,
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index f7c8bbe..4c3b54c 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -669,6 +669,8 @@ static void dev_forward_change(struct inet6_dev =
*idev)
>>       dev =3D idev->dev;
>>       if (idev->cnf.forwarding)
>>           dev_disable_lro(dev);
>> +    else
>> +        dev_enable_lro(dev);
>>       if (dev->flags & IFF_MULTICAST) {
>>           if (idev->cnf.forwarding) {
>>               ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
>
> Same applies here.
>
> If anything this patch seems like more of a feature request then a fi=
x. It would likely create a desirable effect for some, but have some un=
desirable side-effects for other users.
>
> - Alex
