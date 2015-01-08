From: 'Ignacy Gawedzki' <ignacy.gawedzki@green-communications.fr>
Subject: Re: [PATCH net 1/2] gen_stats.c: Duplicate xstats buffer for later
 use
Date: Thu, 8 Jan 2015 13:02:03 +0100
Message-ID: <20150108120203.GA7223@zenon.in.qult.net>
References: <20150108103518.GA7214@zenon.in.qult.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CAC353D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:54168 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753257AbbAHMDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 07:03:03 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAC353D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2015 at 11:05:24AM +0000, thus spake David Laight:
> This rather implies that you are calling kmalloc() with a spin lock h=
elp.
> If this is valid at all then you should probably specify GPF_ATOMIC.

Yes, you're right, my mistake.

> OTOH it is better to call kmalloc() before acquiring the lock.

This would certainly be the best solution, but still, it looks pretty h=
ard to
implement this way since the whole sequence of functions is called from
tc_fill_qdisc() and tc_fill_tclass() in net/sched/sch_api.c: first a ca=
ll to
gnet_stats_start_copy_compat() acquires the lock, then a call to per-qd=
isc
dump_stats() is performed that itself calls gnet_stats_copy_app() with =
the
pointer to the automatic structure that needs to be duplicated and fina=
lly
gnet_stats_finish_copy() is called that eventually releases the lock.  =
In the
originaly code, only gnet_stats_copy() can cause a failure and so the r=
elease
of the lock is performed there in such a case.

I don't see any easy way of knowing how much to allocate *before* the c=
all to
gnet_stats_start_copy_compat().

> The locking itself looks odd - since the corresponding spin_lock_bh()
> isn't in the same function.

I agree that this doesn't look too good.

=46or the moment I'll post a corrected patch that uses GPF_ATOMIC.  The=
n anyone
can come up with a better fix anytime.

Ignacy

--=20
Ignacy Gaw=EAdzki
R&D Engineer
Green Communications
