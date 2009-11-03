From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] sysctl: reduce ram usage by 40 %
Date: Tue, 03 Nov 2009 02:23:08 -0800
Message-ID: <m1bpjjewkz.fsf@fess.ebiederm.org>
References: <20091101163130.GA7911@kvack.org>
	<20091103035058.GA19515@kroah.com> <4AEFCA49.4020305@gmail.com>
	<4AEFD544.6040602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59489 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbZKCKXM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 05:23:12 -0500
In-Reply-To: <4AEFD544.6040602@gmail.com> (Eric Dumazet's message of "Tue\, 03 Nov 2009 08\:01\:24 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Eric Dumazet a =C3=A9crit :
>
>> Its curious because in my tests the biggest problems come from
>> kernel/sysctl.c (__register_sysctl_paths) consuming 80% of cpu
>> in following attempt to create 20.000 devices

I bet that is Al's cute glue all the sysctl data structures together
patch.  It improves readdir and lookup at a small cost at registration
time.

>> (disable hotplug before trying this, and ipv6 too !)
>> modprobe dummy numdummies=3D20000


>> I believe we should address __register_sysctl_paths() scalability
>> problems too.

Agreed.

>> I dont know what is the 'sentinel' we allocate after each struct ctl=
_table
>> But I suspect we could reduce size requirement of the 'sentinel' to =
include
>> only needed fields for the sentinel (and move them at start of ctl_t=
able)

The sentinel is just a NULL terminator.

> Here is the patch to reduce ram usage of sysctl :
>
> [PATCH] sysctl: reduce ram usage by 40 %
>
> We currently reserve space for a so called sentinel, a full struct ct=
l_table
> for each ctl_table. We can cheat a bit since only needed fields of a =
sentinel
> are ctl_name and procname. Add a new structure (struct ctl_table_sent=
inel)
> that includes a full ctl_table and only required part of a sentinel.

Before we address sysctl I would like to get out my patchset that
makes sys_sysctl a wrapper around the ascii version of
/proc/sys/net. Once that goes in it becomes much easier to do things
and perform radical surgery on sysctl.  Little things like .ctl_name an=
d
=2Estrategy go away.

Have you happened to look at the other cost of /proc proper?  Hmm.
Except for /proc/net/dev_snmp6 it doesn't look like we keep per
interface directories in proc so without ivp6 you won't see the proc
generic code at all.

The practical consequence is if /proc/net/dev_snmp6 is not painful duri=
ng
registration right now we can probably convert all of /proc/sys/net to =
proc
generic after my other changes are in.

Eric
