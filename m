From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
	2.6.38-rc4
Date: Fri, 18 Feb 2011 17:11:46 -0200
Message-ID: <20110218191146.GG13211@ghostprotocols.net>
References: <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com> <20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org> <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com> <20110218122938.GB26779@tiehlicka.suse.cz> <20110218162623.GD4862@tiehlicka.suse.cz> <AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com> <m17hcx43m3.fsf@fess.ebiederm.org> <AANLkTikh4oaR6CBK3NBazer7yjhE0VndsUB5FCDRsbJc@mail.gmail.com> <20110218190128.GF13211@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@openvz.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751458Ab1BRTMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 14:12:05 -0500
Content-Disposition: inline
In-Reply-To: <20110218190128.GF13211@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Feb 18, 2011 at 05:01:28PM -0200, Arnaldo Carvalho de Melo escr=
eveu:
> Em Fri, Feb 18, 2011 at 10:48:18AM -0800, Linus Torvalds escreveu:
> > This seems to be a fairly straightforward bug.
> >=20
> > In net/ipv4/inet_timewait_sock.c we have this:
> >=20
> >   /* These are always called from BH context.  See callers in
> >    * tcp_input.c to verify this.
> >    */
> >=20
> >   /* This is for handling early-kills of TIME_WAIT sockets. */
> >   void inet_twsk_deschedule(struct inet_timewait_sock *tw,
> >                             struct inet_timewait_death_row *twdr)
> >   {
> >           spin_lock(&twdr->death_lock);
> >           ..
> >=20
> > and the intention is clearly that that spin_lock is BH-safe because
> > it's called from BH context.
> >=20
> > Except that clearly isn't true. It's called from a worker thread:
> >=20
> > > stack backtrace:
> > > Pid: 10833, comm: kworker/u:1 Not tainted 2.6.38-rc4-359399.2010A=
roraKernelBeta.fc14.x86_64 #1
> > > Call Trace:
> > > =A0[<ffffffff81460e69>] ? inet_twsk_deschedule+0x29/0xa0
> > > =A0[<ffffffff81460fd6>] ? inet_twsk_purge+0xf6/0x180
> > > =A0[<ffffffff81460f10>] ? inet_twsk_purge+0x30/0x180
> > > =A0[<ffffffff814760fc>] ? tcp_sk_exit_batch+0x1c/0x20
> > > =A0[<ffffffff8141c1d3>] ? ops_exit_list.clone.0+0x53/0x60
> > > =A0[<ffffffff8141c520>] ? cleanup_net+0x100/0x1b0
> > > =A0[<ffffffff81068c47>] ? process_one_work+0x187/0x4b0
> > > =A0[<ffffffff81068be1>] ? process_one_work+0x121/0x4b0
> > > =A0[<ffffffff8141c420>] ? cleanup_net+0x0/0x1b0
> > > =A0[<ffffffff8106a65c>] ? worker_thread+0x15c/0x330
> >=20
> > so it can deadlock with a BH happening at the same time, afaik.
> >=20
> > The code (and comment) is all from 2005, it looks like the BH->work=
er
> > thread has broken the code. But somebody who knows that code better
> > should take a deeper look at it.
> >=20
> > Added acme to the cc, since the code is attributed to him back in 2=
005
> > ;). Although I don't know how active he's been in networking lately
> > (seems to be all perf-related). Whatever, it can't hurt.
>=20
> Original code is ANK's, I just made it possible to use with DCCP, and
> yeah, the smiley is appropriate, something 6 years old and the world
> around it changing continually... well, thanks for the git blame ;-)

But yeah, your analisys seems correct, with the bug being introduced by
one of these world around it changing continually issues, networking
namespaces broke the rules of the game on its cleanup_net() routine,
adding Pavel to the CC list since it doesn't hurt ;-)

- Arnaldo
