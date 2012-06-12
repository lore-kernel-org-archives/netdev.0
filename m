From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [PATCH] fix kernel crash in the macvlan driver
Date: Mon, 11 Jun 2012 18:50:40 -0700 (PDT)
Message-ID: <alpine.OSX.2.00.1206111840260.6713@animac.local>
References: <alpine.OSX.2.00.1206071137360.86561@animac.local> <87bokux5po.fsf@xmission.com> <alpine.OSX.2.00.1206071320040.86561@animac.local> <87fwa6pxol.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:53453 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761Ab2FLBum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 21:50:42 -0400
Received: by dady13 with SMTP id y13so6167923dad.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 18:50:42 -0700 (PDT)
In-Reply-To: <87fwa6pxol.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric :

I have found the reason for the crash :

On Thu, 7 Jun 2012, Eric W. Biederman wrote:

> >
> > The logic of my change is as follows :
> >
> > As far as I can see, macvlan_newlink() pairs with macvlan_dellink(). If
> > you are incrementing the reference count in newlink(), the corresponding
> > decrement should be, in my opinion in dellink(). If you are derementing
> > the count in uninit(), you are asuming that for every dellink() call,
> > there is a corresponding uninit() call. I am not sure if this assumption
> > is correct. Perhaps you can shed some more lights on this.
>
> Yes.  Look at net/core/dev.c
> dellink calls unregister_netdevice_queue.
> The active part of unregister_netdevice_queue rollback_registered_many
> calls dev->ndo_stop() and then ndo_uninit.

You are correct with respect the current upstream code. However, please
take a look at the commit : 0696c3a8acd3b7c3186dd231d65d97e05a75189f

Before this change was committed, a failure in dev_get_valid_name() would
cause netdev_ops->ndo_uninit() to get called as a part of the clneaup
code. This in turn will mess up (decrement) the port->count values causing
an unbalanced reference cound decrement. This was the reason why the port
was getting freed and a use after free resulted in the crash. I have
verified this was indeed the case using printks. After applying the fix in
0696c3a8acd3b7c3186dd231d65d97e05a75189f  along with your original
ref-count on dev->port fix, I can no longer reproduce the crash.

When moved the counter decrement from uninit() to dellink(), this fixed
the issue since although we had an extra unbalanced uninit() call, it
wasn't modifying the counter values. However ...

>
> We might still be using rcu hash lookups until ndo_close is called and
> so we really don't want to move the decrement before then.

I agree with you on this one. Hence, we should keep the reference counter
modification code where it currently is.


So there was a window when you had applied your patch (port reference
counting) and Peter's fix did not go in. In that period, the upstream
kernel was broken as well. Fortunately, it's all fixed now :)

Cheers,
Ani
