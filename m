From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Tue, 27 Apr 2010 16:31:11 -0700
Message-ID: <20100427233111.GF2424@linux.vnet.ibm.com>
References: <20100423194255.GE2589@linux.vnet.ibm.com>
 <m2xa44ae5cd1004231559hcf90671asf146a43b4748c2c3@mail.gmail.com>
 <20100425023455.GM2440@linux.vnet.ibm.com>
 <w2sa44ae5cd1004250849q73704370vc6af935c70db9b73@mail.gmail.com>
 <p2ga44ae5cd1004251320j55d23ba7ua0fa14497f623d76@mail.gmail.com>
 <20100426160925.GD2529@linux.vnet.ibm.com>
 <m1hbmydpup.fsf@fess.ebiederm.org>
 <20100427042744.GD2510@linux.vnet.ibm.com>
 <20100427162201.GA5826@linux.vnet.ibm.com>
 <g2ya44ae5cd1004271058p9f73fba1v3f611693e81869c3@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Vivek Goyal <vgoyal@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <g2ya44ae5cd1004271058p9f73fba1v3f611693e81869c3@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 27, 2010 at 01:58:30PM -0400, Miles Lane wrote:
> On Tue, Apr 27, 2010 at 12:22 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Mon, Apr 26, 2010 at 09:27:44PM -0700, Paul E. McKenney wrote:
> >> On Mon, Apr 26, 2010 at 11:35:10AM -0700, Eric W. Biederman wrote:
> >> > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> writes:
> >> >
> >> > > Eric Dumazet traced these down to a commit from Eric Biederman=
=2E
> >> > >
> >> > > If I don't hear from Eric Biederman in a few days, I will atte=
mpt a
> >> > > patch, but it would be more likely to be correct coming from s=
omeone
> >> > > with a better understanding of the code. =A0;-)
> >> >
> >> > I already replied.
> >> >
> >> > http://lkml.org/lkml/2010/4/21/420
> >>
> >> You did indeed!!! =A0This experience is giving me an even better a=
ppreciation
> >> of the maintainers' ability to keep all their patches straight!
> >>
> >> I will put together something based on your suggestion.
> >
> > How about the following?
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Thanx, Paul
> >
> > -------------------------------------------------------------------=
-----
> >
> > commit 85fa42bd568ab99c375f018761ae6345249942cd
> > Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Date: =A0 Mon Apr 26 21:40:05 2010 -0700
> >
> > =A0 =A0net: suppress RCU lockdep false positive in twsk_net()
> >
> > =A0 =A0Calls to twsk_net() are in some cases protected by reference=
 counting
> > =A0 =A0as an alternative to RCU protection. =A0Cases covered by ref=
erence counts
> > =A0 =A0include __inet_twsk_kill(), inet_twsk_free(), inet_twdr_do_t=
wkill_work(),
> > =A0 =A0inet_twdr_twcal_tick(), and tcp_timewait_state_process(). =A0=
RCU is used
> > =A0 =A0by inet_twsk_purge(). =A0Locking is used by established_get_=
first()
> > =A0 =A0and established_get_next(). =A0Finally, __inet_twsk_hashdanc=
e() is an
> > =A0 =A0initialization case.
> >
> > =A0 =A0It appears to be non-trivial to locate the appropriate locks=
 and
> > =A0 =A0reference counts from within twsk_net(), so used rcu_derefer=
ence_raw().
> >
> > =A0 =A0Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> >
> > diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_ti=
mewait_sock.h
> > index 79f67ea..a066fdd 100644
> > --- a/include/net/inet_timewait_sock.h
> > +++ b/include/net/inet_timewait_sock.h
> > @@ -224,7 +224,9 @@ static inline
> > =A0struct net *twsk_net(const struct inet_timewait_sock *twsk)
> > =A0{
> > =A0#ifdef CONFIG_NET_NS
> > - =A0 =A0 =A0 return rcu_dereference(twsk->tw_net);
> > + =A0 =A0 =A0 return rcu_dereference_raw(twsk->tw_net); /* protecte=
d by locking, */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* reference counting, */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* initialization, or RCU. */
> > =A0#else
> > =A0 =A0 =A0 =A0return &init_net;
> > =A0#endif
> >
>=20
> Worked for me.  Thanks!

Thank you both!  I have added Eric's Acked-by and Miles's Tested-by.

							Thanx, Paul
