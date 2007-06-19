From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [RFC][PATCH -mm take5 4/7] using symlink for the net_device
Date: Tue, 19 Jun 2007 20:10:00 +0530
Message-ID: <a781481a0706190740w14ae94f1r1ea8449524c5fb99@mail.gmail.com>
References: <466FC455.5060001@bx.jp.nec.com> <466FC6ED.9060208@bx.jp.nec.com>
	 <a781481a0706130949j7b35e33ds9cda5d8a551c9d7d@mail.gmail.com>
	 <a781481a0706131203g405a4407y1212bb397f14e8eb@mail.gmail.com>
	 <4677AA23.1080708@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Matt Mackall" <mpm@selenic.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Keiichi KII" <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:12730 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbXFSOkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 10:40:01 -0400
Received: by nz-out-0506.google.com with SMTP id n1so1766237nzf
        for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 07:40:00 -0700 (PDT)
In-Reply-To: <4677AA23.1080708@bx.jp.nec.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 6/19/07, Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:
> Hello Satyam,
>
> > and this is why we have to use the dual-list mechanism to react to the net
> > device rename. This isn't so obvious, a comment at the point where you
> > declare modify_target_list would be nice? (BTW temporary_list would be
> > a better name for that, IMO)
>
> All right, my patches are short of comments. So, I will add comments
> to the ambiguous codes.
>
> > Ok, so reading through the code makes it obvious that this mutex is used
> > to protect against the following race:
> >
> > Thread #1                               Thread #2
> > =========                               =========
> >
> > [ NETDEV_CHANGENAME notifier ]          [ ioctl(NETCON_REMOVE_TARGET) ]
> >
> > netconsole_event()
> > move from target_list to temp list
> > work on temp list
> >                                        kobject_unregister()
> >                                        -> release_target()
> >                                           -> remove_target()
> > move back to target_list
> >
> > Which would mean a deleted/removed target added back => *boom*
> >
> > But, the race still hasn't been closed properly!
> >
> > You're taking the mutex only around "work on temp list" which is
> > insufficient, you need to ensure atomicity inside netconsole_event()
> > _completely_ like this (renaming netdev_change_sem to
> > netdev_changename_mtx):
>
> After the target moves from target_list to temporary_list,
> the kobject_unregister() of possible raced target isn't called
> in ioctl(NETCON_REMOVE_TARGET) because the target_list doesn't contain
> the target .

Hum, then why have we introduced that lock (netdev_change_sem)
in the first place, as in what exactly is it protecting?

In any case, however, the point to extend the critical section here
to encapsulate all the three parts still stands. We wouldn't want
ioctl(NETCON_REMOVE_TARGET) on the specified target to
return without removing the target that the user specified just
because that target's ethernet interface happens to be currently
undergoing a name change. The correct behaviour would be to
sleep on a mutex till the renaming has completed (which will
then relinquish the mutex) and then (after acquiring the mutex)
proceed to remove it, IMHO.

> >> +static char *make_netdev_class_name(char *netdev_name)
> >> +{
> >> +       char *name;
> >> +
> >> +       name = kasprintf(GFP_KERNEL, "net:%s", netdev_name);
> >
> > Why the "net:" prefix in the filename?
>
> Because I drew upon dev_change_name() method in net/core/dev.c.
> The device_rename() in the above function makes use of same prefix
> related to netdev.

I think you're referring to make_class_name() here? That seems to
be somewhat bulkier than simply being a wrapper over kasprintf()
like the make_netdev_class_name() here. I'd definitely recommend
not obfuscating this simple functionality here.

Thanks,
Satyam
