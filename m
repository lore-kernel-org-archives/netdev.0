From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/7] CAN: Add raw protocol
Date: Wed, 19 Sep 2007 10:34:58 +0200
Message-ID: <46F0DF32.9020707@trash.net>
References: <20070917100321.18347.0@janus.isnogud.escape.de>	<20070917100439.18347.3@janus.isnogud.escape.de>	<46EFDCF5.3020609@trash.net> <ygfbqbzzls5.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57896 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964AbXISIly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 04:41:54 -0400
In-Reply-To: <ygfbqbzzls5.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
> 
>>>+config CAN_RAW_USER
>>>+	bool "Allow non-root users to access Raw CAN Protocol sockets"
>>>+	depends on CAN_RAW
>>
>>Would it be much more trouble for userspace to use capabilities for
>>this? This would allow userspace to always know what to expect, I
>>don't think distributions will enable this option (which might again
>>not matter since they're probably rarely used in cars :)).
> 
> 
> First, it's not only used in cars but also in other embedded and
> automation contexts :-)
> 
> In fact, we already check capabilities in af_can.c:can_create() like
> this
> 
>         if (cp->capability >= 0 && !capable(cp->capability))
>                 return -EPERM;
> 
> Each protocol implementation can set cp->capability to -1 so that all
> users can open sockets without any restriction or to some capability,
> typically CAP_NET_RAW.  In raw.c it is done so
> 
> 	#ifdef CONFIG_CAN_RAW_USER
> 	#define RAW_CAP (-1)
> 	#else
> 	#define RAW_CAP CAP_NET_RAW
> 	#endif
> 
> I also didn't love this configure option very much when we added it.
> But in embedded systems it is often not much of a problem to let
> anybody access raw sockets, since there are no "normal" users.  This
> is the reason for the configure option.  I haven't yet looked into
> capabilities and their inheritance between process in detail.	Would
> it be easy to let all user space run with CAP_NET_RAW?  What if some
> process calls setuid() or execve()s a set-uid program?  Will
> capabilities be retained?


If its in the inheritable set, I believe it is retained. I mainly
don't like it because I believe permission checks shouldn't depend
on config option, this makes it harder for userspace to know what
to expect. But keep it if you must.

>>>+static int raw_notifier(struct notifier_block *nb,
>>>+			unsigned long msg, void *data)
>>>+{
>>>+	struct net_device *dev = (struct net_device *)data;
>>>+	struct raw_sock *ro = container_of(nb, struct raw_sock, notifier);
>>>+	struct sock *sk = &ro->sk;
>>>+
>>>+	DBG("msg %ld for dev %p (%s idx %d) sk %p ro->ifindex %d\n",
>>>+	    msg, dev, dev->name, dev->ifindex, sk, ro->ifindex);
>>>+
>>>+	if (dev->nd_net != &init_net)
>>>+		return NOTIFY_DONE;
>>>+
>>>+	if (dev->type != ARPHRD_CAN)
>>>+		return NOTIFY_DONE;
>>>+
>>>+	if (ro->ifindex != dev->ifindex)
>>>+		return NOTIFY_DONE;
>>
>>
>>Wouldn't that be a BUG()?
> 
> 
> Would it?  I think there is only one netdev_chain, not one per
> device.  I.e. our raw_notifier() gets all events on any netdevice, not
> only the ones we're interested in, for example also eth0.  And I think
> we should silently ignore these events by returning NOTIFY_DONE.  Am I
> missing something here?


No, I misunderstood the code.
