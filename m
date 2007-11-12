From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 1/1][NETNS][IPV6] protect addrconf from loopback registration
Date: Mon, 12 Nov 2007 18:01:22 +0100
Message-ID: <473886E2.3020703@fr.ibm.com>
References: <20071112151953.052335971@mai.toulouse-stg.fr.ibm.com> <20071112152403.273795630@mai.toulouse-stg.fr.ibm.com> <473879C3.5020301@sw.ru> <m1ejev4dap.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@sw.ru>, davem@davemloft.net,
	netdev@vger.kernel.org, xemul@openvz.org,
	containers@lists.osdl.org, yoshfuji@linux-ipv6.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:65299 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759694AbXKLRFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 12:05:54 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id lACH5rjZ134470
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2007 17:05:53 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lACH5rYl2015430
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2007 18:05:53 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lACH5q2W026555
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2007 18:05:53 +0100
In-Reply-To: <m1ejev4dap.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> "Denis V. Lunev" <den@sw.ru> writes:
> 
>>> Index: linux-2.6-netns/net/ipv6/addrconf.c
>>> ===================================================================
>>> --- linux-2.6-netns.orig/net/ipv6/addrconf.c
>>> +++ linux-2.6-netns/net/ipv6/addrconf.c
>>> @@ -2272,7 +2272,8 @@ static int addrconf_notify(struct notifi
>>>  
>>>  	switch(event) {
>>>  	case NETDEV_REGISTER:
>>> -		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
>>> +		if (!(dev->flags & IFF_LOOPBACK) &&
>>> +		    !idev && dev->mtu >= IPV6_MIN_MTU) {
> 
> It is idev being true here for the loopback device that would
> prevent things not missing the REGISTER event.
> 
> Hmm.  But we do call ipv6_add_dev on loopback and now the loopback
> device is practically guaranteed to be the first device so we can
> probably just remove the special case in addrconf_init.
> 
> Anyway Daniels patch makes increasingly less sense the more I look
> at it.

Let me try to clarify:

  * when the init network namespace is created, the loopback is created 
first, before ipv6, and the notifier call chain for ipv6 is not setup, 
so the protocol does not receive the REGISTER event

  * when the init network namespace is destroyed during shutdown, the 
loopback is not unregistered, so there is no UNREGISTER event

  * when we create a new network namespace, a new instance of the 
loopback is created and a NETDEV_REGISTER is sent to ipv6 because the 
notifier call chain has been setup by the init netns (while ipv6 
protocol is not yet configured for the namespace which is being created)

  * when the network namespace exits, the loopback is unregistered after 
the ipv6 protocol but the NETDEV_UNREGISTER is sent to addrconf_notify 
while the ipv6 protocol has been destroyed.


The objective of the patch is to discard these events because they were 
never taken into account and they are not expected to be receive by ipv6 
protocol.
