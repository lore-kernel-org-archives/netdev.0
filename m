From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [PATCH] fix kernel crash in the macvlan driver
Date: Thu, 7 Jun 2012 13:37:53 -0700 (PDT)
Message-ID: <alpine.OSX.2.00.1206071320040.86561@animac.local>
References: <alpine.OSX.2.00.1206071137360.86561@animac.local> <87bokux5po.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:47046 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754296Ab2FGUhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 16:37:55 -0400
Received: by dady13 with SMTP id y13so1372357dad.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 13:37:55 -0700 (PDT)
In-Reply-To: <87bokux5po.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric :

On Thu, 7 Jun 2012, Eric W. Biederman wrote:

> I don't completely follow the logic of your change.  Crashing in
> macvlan_addr_busy does seem to indicate you are using a corrupted data
> structure.

The logic of my change is as follows :

As far as I can see, macvlan_newlink() pairs with macvlan_dellink(). If
you are incrementing the reference count in newlink(), the corresponding
decrement should be, in my opinion in dellink(). If you are derementing
the count in uninit(), you are asuming that for every dellink() call,
there is a corresponding uninit() call. I am not sure if this assumption
is correct. Perhaps you can shed some more lights on this.

Now since, macvlan_common_newlink() symbol has been exported but dellink() is not, it
is possible to call the common_newlink() from some GPL driver code and
increment the reference count which will not have a corresponding
decrement. I am not sure what can be done about this issue either.

>
> My compiled version of macvlan_addr_busy is much smaller than yours so I
> can't guess based on your disassembly what is wrong.  But by reading the
> code it must either be port->dev->dev_addr or the rcu
> macvlan_hash_lookup.

Yes, the corruption is in port->dev->dev_addr. The dev_addr seems to get a
bogus address value.


> I might just be dense today but I can't possibly see how moving that
> decrement would solve the crash you have reported below.

In my tests, I have confirmed that with my change, the crash I reported is
no longer reproducable with our scripts. I have also verified that when I
pull out your d5cd92448fded change, I can also no longer reproduce the
issue. So I believe that the crash is related to the above change.
However, I am not very familier with the code in the macvlan
driver, so I can not say for sure that the fix I made genuinely solves the
problem.

Cheers,
Ani
