From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Tue, 31 Jul 2012 13:03:34 +0400
Message-ID: <50179F66.1000604@parallels.com>
References: <50160EEF.6050406@parallels.com> <87pq7dh6b2.fsf@xmission.com> <87fw89h5zk.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1169 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133Ab2GaJDq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 05:03:46 -0400
In-Reply-To: <87fw89h5zk.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/2012 02:56 PM, Eric W. Biederman wrote:
> ebiederm@xmission.com (Eric W. Biederman) writes:
> 
>> Pavel Emelyanov <xemul@parallels.com> writes:
>>
>>> Currently the RTM_NEWLINK results in -EOPNOTSUPP if the ifinfomsg->ifi_index
>>> is not zero. I propose to allow requesting ifindices on link creation. This
>>> is required by the checkpoint-restore to correctly restore a net namespace
>>> (i.e. -- a container). The question what to do with pre-created devices such
>>> as lo or sit fbdev is open, but for manually created devices this can be 
>>> solved by this patch.
>>
>> Have you walked through and found the locations where we still rely on
>> ifindex being globally unique?
>>
>> Last time I was working in this area there were serveral places where
>> things were indexed by just the interface index.
> 
> If it is really safe to make ifindex per network namespace at this
> point you can make dev_new_ifindex have a per network namespace base
> counter, and that will fix your problems with the loopback device.

Not it's not so unfortunately :(

First, let's imagine that on host A the loopback device got registered as
first device, but on host B for some reason some other device got registered
first. In that case after migration from A to B the lo on B will have index
equals 2. And there's no any strict requirement that lo's per net operations
are registered first. Please, correct me if I'm wrong.

Next. In fact, lo is not the only problem. Look at the e.g. sit versus ipgre
fallback devices. Both gets created on netns creation and obtain whatever
ifindices are generated for them. Even if we make ifidex per netns chances
that sit gets registered _strictly_ before ipgre equal zero, since they are
both modules.

> Unless you have done the work to root out the last of dependencies on
> ifindex being globally unique I think you will run into some operational
> problems.

I totally agree with that. Before doing this patch I revisited the ancient
attempt to make ifindices per netns and checked the issues Dave and you
discussed then -- I have looked through how the ifindices are used in the
networking code and found no places where the system-wide uniqueness is still
required. That's why I proposed this patch for inclusion. If you know the 
places I've missed, please let me know, I will work on it.

> Eric
> 
> .
> 

Thanks,
Pavel
