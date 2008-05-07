From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 10/11] avoid kobject name conflict with different namespaces
Date: Wed, 07 May 2008 13:54:27 -0700
Message-ID: <m1hcd9esxo.fsf@frodo.ebiederm.org>
References: <20080506173030.653828076@theryb.frec.bull.fr>
	<20080506173335.922289888@theryb.frec.bull.fr>
	<m13aoueyq8.fsf@frodo.ebiederm.org> <20080507190838.GA4467@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54117 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762148AbYEGVAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 17:00:00 -0400
In-Reply-To: <20080507190838.GA4467@suse.de> (Greg KH's message of "Wed, 7 May
	2008 12:08:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <gregkh@suse.de> writes:

> On Wed, May 07, 2008 at 11:49:19AM -0700, Eric W. Biederman wrote:
>> Unless there is another path I think placing an additional pointer in
>> kobj_type so we can find it through ktype is the simplest solution.
>> Although using the kset is also sane.
>
> Ick, ick, ick :)

Well yes we are dealing with a pile of seemingly unnecessary layers,
that are attempting to add uniformity where no uniformity existed.
That is an easy recipe for ick.

>> The easiest and most trivially correct thing to do would be to simply
>> remove the unnecessary check from kobject_rename.  We perform the
>> check at the upper levels in the network anyway.  And kobject_rename
>> is only used by the network stack.
>
> Wireless uses it also for some things, and it requires that it fail if a
> duplicate is found.

Looks like it, that use is brand new, and at first glance I thought
it was another instance of the device_rename case that kobject uses.
Apparently not.

It looks like getting the wireless devices into the network namespace
is going to be interesting.  Since this phy name is user controllable
and shows up in rtnetlink messages it definitely appears to belong in
the network namespace. 

Virtual/logical devices are such a pain.

....

Given that kobject_rename is growing users we definitely need to
fix it so a noop rename does not return -EINVAL.

i.e. if (temp_kobj && (temp_kobj != kobj)) return -EINVAL.
instead of just if (temp_kobj) return -EINVAL;

> I thought that s390 also used it, but I don't see
> that usage in the tree anymore, perhaps they switched to something else.

That is the device_move -> kobject_move case.  Very similar (and nice
if we can figure out how to combine them).

> good luck,

Thanks.  It looks like we are just about there.

Hopefully we can get this merged soon so there won't be many more sets
of shifting requirements to chase.

Eric
