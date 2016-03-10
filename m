From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Thu, 10 Mar 2016 14:55:43 -0500 (EST)
Message-ID: <20160310.145543.990436948715023108.davem@davemloft.net>
References: <20160310150920.GC21154@uranus.lan>
	<20160310.130138.1302349043066531127.davem@davemloft.net>
	<CAM_iQpWWbj00H-cKvpeaKq6mVWK_D2CFuarXiE6YDQeQX5JupA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090AbcCJTzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 14:55:46 -0500
In-Reply-To: <CAM_iQpWWbj00H-cKvpeaKq6mVWK_D2CFuarXiE6YDQeQX5JupA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 10 Mar 2016 11:02:28 -0800

> On Thu, Mar 10, 2016 at 10:01 AM, David Miller <davem@davemloft.net> wrote:
>> I'm tempted to say that we should provide these notifier handlers with
>> the information they need, explicitly, to handle this case.
>>
>> Most intdev notifiers actually want to know the individual addresses
>> that get removed, one by one.  That's handled by the existing
>> NETDEV_DOWN event and the ifa we pass to that.
>>
>> But some, like this netfilter masq case, would be satisfied with a
>> single event that tells them the whole inetdev instance is being torn
>> down.  Which is the case we care about here.
>>
>> We currently don't use NETDEV_UNREGISTER for inetdev notifiers, so
>> maybe we could use that.
>>
>> And that is consistent with the core netdev notifier that triggers
>> this call chain in the first place.
>>
>> Roughly, something like this:
>>
>> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
>> index 8c3df2c..6eee5cb 100644
>> --- a/net/ipv4/devinet.c
>> +++ b/net/ipv4/devinet.c
>> @@ -292,6 +292,11 @@ static void inetdev_destroy(struct in_device *in_dev)
>>
>>         in_dev->dead = 1;
>>
>> +       if (in_dev->ifa_list)
>> +               blocking_notifier_call_chain(&inetaddr_chain,
>> +                                            NETDEV_UNREGISTER,
>> +                                            in_dev->ifa_list);
>> +
>>         ip_mc_destroy_dev(in_dev);
> 
> 
> Hmm, but inetdev_destroy() is only called when NETDEV_UNREGISTER
> is happening and masq already registers a netdev notifier...

Indeed, good catch.  Therefore:

1) Keep the masq netdev notifier.  That will flush the conntrack table
   for the inetdev_destroy event.

2) Make the inetdev notifier only do something if inetdev->dead is
   false.  (ie. we are flushing an individual address)

And then we don't need the NETDEV_UNREGISTER thing at all:

diff --git a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
index c6eb421..f71841a 100644
--- a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
@@ -108,10 +108,20 @@ static int masq_inet_event(struct notifier_block *this,
 			   unsigned long event,
 			   void *ptr)
 {
-	struct net_device *dev = ((struct in_ifaddr *)ptr)->ifa_dev->dev;
 	struct netdev_notifier_info info;
+	struct in_ifaddr *ifa = ptr;
+	struct in_device *idev;
 
-	netdev_notifier_info_init(&info, dev);
+	/* The masq_dev_notifier will catch the case of the device going
+	 * down.  So if the inetdev is dead and being destroyed we have
+	 * no work to do.  Otherwise this is an individual address removal
+	 * and we have to perform the flush.
+	 */
+	idev = ifa->ifa_dev;
+	if (idev->dead)
+		return NOTIFY_DONE;
+
+	netdev_notifier_info_init(&info, idev->dev);
 	return masq_device_event(this, event, &info);
 }
 
