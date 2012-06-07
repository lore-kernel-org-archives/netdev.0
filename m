From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] fix kernel crash in the macvlan driver
Date: Thu, 07 Jun 2012 15:24:58 -0700
Message-ID: <87fwa6pxol.fsf@xmission.com>
References: <alpine.OSX.2.00.1206071137360.86561@animac.local>
	<87bokux5po.fsf@xmission.com>
	<alpine.OSX.2.00.1206071320040.86561@animac.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42353 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933294Ab2FGWZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 18:25:18 -0400
In-Reply-To: <alpine.OSX.2.00.1206071320040.86561@animac.local> (Ani Sinha's
	message of "Thu, 7 Jun 2012 13:37:53 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ani Sinha <ani@aristanetworks.com> writes:

> Hi Eric :
>
> On Thu, 7 Jun 2012, Eric W. Biederman wrote:
>
>> I don't completely follow the logic of your change.  Crashing in
>> macvlan_addr_busy does seem to indicate you are using a corrupted data
>> structure.
>
> The logic of my change is as follows :
>
> As far as I can see, macvlan_newlink() pairs with macvlan_dellink(). If
> you are incrementing the reference count in newlink(), the corresponding
> decrement should be, in my opinion in dellink(). If you are derementing
> the count in uninit(), you are asuming that for every dellink() call,
> there is a corresponding uninit() call. I am not sure if this assumption
> is correct. Perhaps you can shed some more lights on this.

Yes.  Look at net/core/dev.c
dellink calls unregister_netdevice_queue.
The active part of unregister_netdevice_queue rollback_registered_many
calls dev->ndo_stop() and then ndo_uninit.

We might still be using rcu hash lookups until ndo_close is called and
so we really don't want to move the decrement before then.

>> My compiled version of macvlan_addr_busy is much smaller than yours so I
>> can't guess based on your disassembly what is wrong.  But by reading the
>> code it must either be port->dev->dev_addr or the rcu
>> macvlan_hash_lookup.
>
> Yes, the corruption is in port->dev->dev_addr. The dev_addr seems to get a
> bogus address value.

Interesting if it is port->dev->dev_addr than count is really out of the
picture.

My blind guess would be that port->dev is getting freed and recycled
before dev_addr gets accessed.  But macvlan_device_event seems to
prevent that.

>> I might just be dense today but I can't possibly see how moving that
>> decrement would solve the crash you have reported below.
>
> In my tests, I have confirmed that with my change, the crash I reported is
> no longer reproducable with our scripts. I have also verified that when I
> pull out your d5cd92448fded change, I can also no longer reproduce the
> issue. So I believe that the crash is related to the above change.
> However, I am not very familier with the code in the macvlan
> driver, so I can not say for sure that the fix I made genuinely solves the
> problem.

It sounds to me like you have a memory stomp and that recompiling the
code winds up changing what gets stomped.

Eric
