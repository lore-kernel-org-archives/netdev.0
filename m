From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: sysfs class/net/ problem
Date: Wed, 02 Jun 2010 09:43:22 -0700
Message-ID: <m14ohlxu51.fsf@fess.ebiederm.org>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<20100602154608.GB12361@kroah.com>
	<1275493693.3915.12.camel@jlt3.sipsolutions.net>
	<m1ljaxxvcj.fsf@fess.ebiederm.org>
	<1275495677.3915.16.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58224 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959Ab0FBQn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 12:43:28 -0400
In-Reply-To: <1275495677.3915.16.camel@jlt3.sipsolutions.net> (Johannes Berg's message of "Wed\, 02 Jun 2010 18\:21\:17 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Wed, 2010-06-02 at 09:17 -0700, Eric W. Biederman wrote:
>
>> >> Ah, so the network devices aren't getting removed?
>> >
>> > Well the netdevs are gone, just the links aren't going away. the
>> > mac80211_hwsim directory is gone too.
>> >
>> >> Do you have network namespaces enabled in your kernel or disabled?
>> >
>> > enabled
>> >
>> >> And this is 2.6.35-rc1, right?
>> >
>> > yes.
>> >
>> > Come to think of it, maybe somehow it ends up removing
>> > mac80211_hwsim/hwsim0 before wlan0, and thus the link stays around? I
>> > guess I could make it print messages about that somehow?
>> 
>> The wireless drivers are a little different, and come to think of it
>> network namespace support has been added to the wireless drivers since
>> last I looked closely. 
>
> Yeah, I now need to go add tagged sysfs support to it too.
>
>>  Do you know what creates/deletes these links?
>> Is it the normal register_netdevice -> device_add path?
>
> Yes, they aren't done specially.



>> I definitely changed the symlink code a little making things network namespace
>> aware so it is reasonable to assume that something in my changes affected the
>> wireless drivers.
>
>> I took a quick look and with my patches against 2.6.33 I'm not seeing this.
>
> Hmm. I'm also not seeing it with veth, it would seem that ought to be
> similar?

Since it is the register_netdev path it should be exactly the same.

The big change I made is I in some instances I replaced
sysfs_remove_link with sysfs_delete_link so I could have enough
information to infer which network namespace the link was in.  Since
wlan0 is a netdevice all of that information should already be there.


>> I take a closer look at 2.6.35-rc1 and see if I can figure out what is
>> going on.  It would definitely be wrong if hwsim0 is removed before
>> wlan0.
>
> I don't know if that's happening .. just guessing that it might cause
> such a problem, and maybe some things are deferred somehow? Since netdev
> destruction can be deferred, but the wifi sysfs destruction isn't. But
> then that link there should cause the refcount to not go down until the
> link goes away>?

unregister_netdevice will defer the final destruction but it does not
defer netdev_unregister_kobject -> device_del.

What happens if in exit_mac80211_hwsim you call unregister_netdev before
mac80211_hwsim_free?

At a quick glance it simply looks like you have the ordering reversed in your
module cleanup, and this is not network namespace related at all.

Eric

