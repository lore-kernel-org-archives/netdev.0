From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned to  classes
Date: Thu, 03 Jun 2010 03:00:48 -0700
Message-ID: <m1vda0o2pb.fsf@fess.ebiederm.org>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<20100602154608.GB12361@kroah.com>
	<1275493693.3915.12.camel@jlt3.sipsolutions.net>
	<m1ljaxxvcj.fsf@fess.ebiederm.org>
	<1275495677.3915.16.camel@jlt3.sipsolutions.net>
	<m14ohlxu51.fsf@fess.ebiederm.org>
	<1275498007.3915.20.camel@jlt3.sipsolutions.net>
	<m1ocftwdp7.fsf@fess.ebiederm.org>
	<1275501157.3915.22.camel@jlt3.sipsolutions.net>
	<m1y6exux6x.fsf@fess.ebiederm.org>
	<1275506732.3915.41.camel@jlt3.sipsolutions.net>
	<m16321t4ke.fsf@fess.ebiederm.org>
	<m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	<AANLkTinTSQ6Ncz3FqgFHasJc2ZKfm2vaweJHUam9b-gi@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55811 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab0FCKAz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:00:55 -0400
In-Reply-To: <AANLkTinTSQ6Ncz3FqgFHasJc2ZKfm2vaweJHUam9b-gi@mail.gmail.com> (Kay Sievers's message of "Thu\, 3 Jun 2010 11\:30\:20 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kay Sievers <kay.sievers@vrfy.org> writes:

> On Thu, Jun 3, 2010 at 02:53, Eric W. Biederman <ebiederm@xmission.co=
m> wrote:
>>
>> In the last painful restructuring of sysfs we created started
>> creating class directories under normal devices so we could place
>> devices such as network devices directly under their the hardware
>> that implements them instead of in their class directories like
>> /sys/class/net/. =C2=A0This creation of class directories avoids the
>> need to worry about namespace clonflicts if something is renamed.
>>
>> A special exception was made for devices that were still placed
>> directly in their class directory. =C2=A0Looking at how this interac=
ts
>> with the wireless network devices it appears this special exception
>> is either completely unneeded or at least needs to be restricted to
>> a parent device with the same class as the child device. =C2=A0Certa=
inly
>> in the case of unrelated classes we very much have the possibility
>> of namespace classes and we should be creating the subdirectory.
>
> The class-glue-directories are only created between a bus-parent and
> and a class device. Class devices usually don't have other class
> devices as parents, that's why it wasn't done that way.


> If people use class devices from other classes as parents, they shoul=
d
> definitely convert the class that acts as a parent to a bus, to fit
> into the usual model. All that was really never meant to be used that
> way. The current behavior, to not to create the glue-directory is at
> least the intended one from the driver core's perspective.
>
> What kind of classes do this, where this change would help or would b=
e needed?


> I don't mind trying if that change will work for people, I can't tell
> if there are any other users doing things like this which could break
> with such a change. Stuff like udev will be fine with directories
> inserted, but there are many things out there, that just access their
> parents attributes with ../../foo, which might no longer work when we
> insert directories.

To the best of my knowledge we are talking a very limited number of
real world cases.

The driver in particular that causes problems is mac80211_hwsim. It
winds up placing network devices in a directory that isn't prepared to
take network namespace tagged members, with the result that when the
module is removed we don't delete the symlinks from /sys/class/net/.
I see no reason to believe we are free of possible namespace conflicts
either, which is why I suggested the patch.

=46rom my perspective not creating the directory in some weird corner c=
ase that
appears to practically to never happen looks like an ugly nasty special=
 case.

If the solution winds up being converting mac80211_hwsim to using a
bus instead of a class that seems reasonable to me as well.  More code
in one place to remove the chance of problems elsewhere.

Eric
