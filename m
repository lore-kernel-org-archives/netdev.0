From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [net-2.6 patch 1/2][NETNS] fix device renaming for sysfs
Date: Wed, 04 Jun 2008 04:59:53 -0700
Message-ID: <m1fxrtpg06.fsf@frodo.ebiederm.org>
References: <20080430213113.410541118@localhost.localdomain>
	<20080430213320.825349005@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:60585 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbYFDMAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 08:00:25 -0400
In-Reply-To: <20080430213320.825349005@localhost.localdomain> (Daniel
	Lezcano's message of "Wed, 30 Apr 2008 23:31:14 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano <dlezcano@fr.ibm.com> writes:

> When a netdev is moved across namespaces with the 'dev_change_net_namespace' 
> function, the 'device_rename' function is used to fixup kobject and refresh 
> the sysfs tree. The device_rename function will call kobject_rename and this
> one will check if there is an object with the same name and this is the case
> because we are renaming the object with the same name.
>
> The use of 'device_rename' seems for me wrong because we usually don't
> rename it but just move it across namespaces. As we just want to do a 
> mini "netdev_[un]register", IMO the functions 'netdev_[un]register_kobject' 
> should be used instead, like an usual network device [un]registering.

device_rename is correct.  Because doing device_del; device_add removes
any driver specific sysfs attributes.

Causing your patch to introduce subtle driver breakage only when we
move a network device between namespaces.  Ouch!

To support this operation we need something like device_rename that
can preserve driver specific attributes, and generally handle
movement between namespaces.  Since device_rename already does 99% of
what we need it to do I found it easier to extend device_rename to
handle this case then to introduce yet another function into the
kobject layer.

> This patch replace device_rename by netdev_unregister_kobject, followed by
> netdev_register_kobject.

And sysfs comes a' tumblin' down.

My apologies for not replying sooner I just spotted this.

Eric
