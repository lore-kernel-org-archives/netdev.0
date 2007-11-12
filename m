From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 1/1][NETNS][IPV6] protect addrconf from loopback registration
Date: Mon, 12 Nov 2007 09:59:52 -0700
Message-ID: <m1abpj4cxj.fsf@ebiederm.dsl.xmission.com>
References: <20071112151953.052335971@mai.toulouse-stg.fr.ibm.com>
	<20071112152403.273795630@mai.toulouse-stg.fr.ibm.com>
	<473879C3.5020301@sw.ru> <47387B31.20805@fr.ibm.com>
	<473883FF.5010505@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, xemul@openvz.org, ebiederm@xmission.com,
	containers@lists.osdl.org, yoshfuji@linux-ipv6.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:33843 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755331AbXKLRBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 12:01:16 -0500
In-Reply-To: <473883FF.5010505@sw.ru> (Denis V. Lunev's message of "Mon, 12
	Nov 2007 19:49:03 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Denis V. Lunev" <den@sw.ru> writes:

>>> why should we care on down? we are destroying the device. It should
>>> gone. All references to it should also gone. So, we should perform the
>>> cleaning and remove all IPv6 addresses, so notifier should also work.
>> 
>> We need to take care of netdev down, someone can put the loopback down
>> if he wants.
>> 
>>> The code relies on the "persistent" loopback and this is a _bad_ thing.
>>> This is longstanding bug in the code, that the dst_entry should have a
>>> valid reference to a device. This is the only purpose for a loopback
>>> persistence. Though, at the namespace death no such entries must be and
>>> this will be checked during unregister process. This patch definitely
>>> breaks this assumption :(
>>>
>>> Namespaces are good to catch leakage using standard codepaths, so they
>>> should be preserved as much as possible. So, _all_ normal down code
>>> should be called for a loopback device in other than init_net context.
>> 
>> I agree with you, this is a bug in ipv6 and the loopback; when playing
>> with ipv6 we found that the loopback is still referenced 9 times when
>> the system is shutdown.
>
> Pff...  I can't guess right now where the error can be :( We have
> correct behavior of loopback even for IPv6 within OpenVZ. On down the
> count is 0 and device is destroyed correctly without these kludges. So,
> something is definitely wrong.
>
>> The purpose of this patch is to protect the __actual__ code from the new
>> loopback behavior. We are looking at a more generic approach with the
>> namespace for ipv6, as you mentioned, namespaces are good for network
>> leakage detection as we create several instances of the network stack.
>
> The only kludge required is already in place. addrconf_ifdown has a
> protection for init_net.
>         if (dev == init_net.loopback_dev && how == 1)
>                 how = 0;
> Other places should be untouched.
>
> Unregister for a loopback in !init_net is a _valid_ operation and should
> be clean, i.e. without kludges in the path. This is the only way to
> check the ref-counting.

Oh.  Speaking of.  One way to catch this kind of thing during debugging
is to instrument dev_put and dev_hold to add a print statement.  Something
like:

/**
 *	dev_put - release reference to device
 *	@dev: network device
 *
 * Release reference to device to allow it to be freed.
 */
static inline void __dev_put(struct net_device *dev, char *file, char *func, int line)
{
        if (dev->flags & IFF_LOOPBACK)
        	printk("%s: %s.%s.%d\n", __func__, file, file, line);
	atomic_dec(&dev->refcnt);
}

#define dev_put(DEV) __dev_put(DEV, __FILE__, __func__, __LINE__)

/**
 *	dev_hold - get reference to device
 *	@dev: network device
 *
 * Hold reference to device to keep it from being freed.
 */
static inline void __dev_hold(struct net_device *dev, char *file, char *func, int line)
{
        if (dev->flags & IFF_LOOPBACK)
        	printk("%s: %s.%s.%d\n", __func__, file, file, line);
	atomic_inc(&dev->refcnt);
}

#define dev_hold(DEV) __dev_hold(DEV, __FILE__, __func__, __LINE__)

