From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: prevent deadlock on slave store with alb mode
Date: Tue, 24 May 2011 14:12:54 -0700
Message-ID: <12577.1306271574@death>
References: <1306265765-8257-1-git-send-email-nhorman@tuxdriver.com> <20110524200047.GI21309@gospo.rdu.redhat.com> <4DDC116F.8020602@gmail.com> <20110524203714.GG28521@hmsreliant.think-freely.org> <4DDC1A4E.6080700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: =?us-ascii?Q?=3D=3FISO-8859-1=3FQ=3FNicolas=5Fde=5FPeslo=3DFCan=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:34005 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631Ab1EXVOO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 17:14:14 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4OL5wtw032497
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 15:05:58 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4OLCxHw038574
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 15:13:02 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4OFCSxu013259
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 09:12:30 -0600
In-reply-to: <4DDC1A4E.6080700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com> wrote:

>Le 24/05/2011 22:37, Neil Horman a =C3=A9crit :
>
>>>>> +		return -EINVAL;
>>>
>>> This will turn a warning into an error.
>>>
>> Yes, because it should have been an error all along.
>>
>>> This warning existed for long, but never caused the bonding setup t=
o
>>> fail. This patch cause some regression for user space. For example,
>>> current ifenslave-2.6 package in Debian doesn't ensure bond is UP
>>> before enslaving, because this was never required.
>>>
>> Thats not a regression, thats the kernel returning an error where it=
 should have
>> done so all along.  Just because a utility got away with it for awhi=
le and it
>> didn't always cause a lockup, doesn't grandfather that application i=
n to a
>> situation where the kernel has to support its broken behavior in per=
pituity.
>>
>> Besides, iirc, the ifsenslave utility still uses the ioctl path, whi=
ch this
>> patch doesn't touch, so ifenslave is currently unaffected (although =
I should
>> look in the ioctl path to see if we have already added such a check,=
 lest you be
>> able to deadlock your system as previously indicated using that tool=
).
>
>Unfortunately, no. Recent versions of ifenslave-2.6 on Debian don't us=
e
>ioctl (ifenslave binary) anymore, but only sysfs.
>
>Documentation/bonding.txt should be updated to reflect this change.
>pr_warning should be changed to pr_ err.
>Bonding version should be bumped.
>
>Anyway, I will fix this package, but I suspect there exist many user
>scripts that don't ensure bond is up before enslaving.

	I looked at sysconfig (as supplied with opensuse) and it uses
sysfs, and does set the master device up first.  The other potential
user that comes to mind is that OFED at one point had a script to set u=
p
bonding for Infiniband devices.  I don't know if this is still the case=
,
nor do I know if it set the bond device up before enslaving.

	Generally speaking, though, in the long run I think it should be
permissible to change any bonding option when the bond is down (even to
values that make no sense in context, e.g., setting the primary to a
device not currently enslaved).  My rationale here is that some options
are very difficult to modify when the bond is up (e.g., changing the
mode), and now some other set is precluded when the bond is down.  The
init scripts already have repeat logic in them; this just makes things
more complicated.

	There should be a state wherein any option can be changed (well,
maybe not max_bonds), and that should be the down state.  A subset can
also be changed while up.  I'd be happy to be able to change all option=
s
while the bond is up, too, but that seems pretty hard to do.

	How much harder is it to fix the locking and permit the action
in question here?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
