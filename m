From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Fri, 26 Jun 2009 04:19:31 +0200
Message-ID: <4A443033.8060401@gmail.com>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> <20090625122416.GA23613@redhat.com> <alpine.DEB.1.10.0906251827510.9517@makko.or.mcafeemobile.com> <4A442B65.8040701@gmail.com> <alpine.DEB.1.10.0906251858520.9517@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oleg Nesterov <oleg@redhat.com>, Jiri Olsa <jolsa@redhat.com>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	Tejun Heo <htejun@gmail.com>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34291 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433AbZFZCUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 22:20:00 -0400
In-Reply-To: <alpine.DEB.1.10.0906251858520.9517@makko.or.mcafeemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Davide Libenzi a =E9crit :
> On Fri, 26 Jun 2009, Eric Dumazet wrote:
>=20
>> Davide Libenzi a =E9crit :
>>> On Thu, 25 Jun 2009, Oleg Nesterov wrote:
>>>
>>>> Can't really comment this patch, except this all looks reasonable =
to me.
>>>> Add more CCs.
>>> While this can work, IMO it'd be cleaner to have the smp_mb() moved=
 from=20
>>> fs/select.c to the ->poll() function.
>>> Having a barrier that matches another one in another susbsystem, be=
cause=20
>>> of the special locking logic of such subsystem, is not too shiny IM=
HO.
>>>
>> Yes but barrier is necessary only if add_wait_queue() was actually c=
alled, and __pollwait()
>> does this call.
>>
>> Adding a plain smp_mb() in tcp_poll() for example would slowdown sel=
ect()/poll() with NULL
>> timeout.
>=20
> Do you think of it as good design adding an MB on a subsystem, becaus=
e of=20
> the special locking logic of another one?
> The (eventual) slowdown, IMO can be argued sideways, by saying that=20
> non-socket users will pay the price for their polls.
>=20

I wont argue with you David, just try to correct bugs.

fs/ext4/ioctl.c line 182

	set_current_state(TASK_INTERRUPTIBLE);
	add_wait_queue(&EXT4_SB(sb)->ro_wait_queue, &wait);
	if (timer_pending(&EXT4_SB(sb)->turn_ro_timer)) {
		schedule();

Another example of missing barrier after add_wait_queue()

Because add_wait_queue() misses a barrier, we have to add one after eac=
h call.

Maybe it would be safer to add barrier in add_wait_queue() itself, not =
in _pollwait().

