From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Tue, 27 Apr 2010 18:33:04 +0200
Message-ID: <1272385984.2295.318.camel@edumazet-laptop>
References: <20100422160144.GC2524@linux.vnet.ibm.com>
	 <h2xa44ae5cd1004230550uf734c89eo2b1d1945d446068c@mail.gmail.com>
	 <20100423194255.GE2589@linux.vnet.ibm.com>
	 <m2xa44ae5cd1004231559hcf90671asf146a43b4748c2c3@mail.gmail.com>
	 <20100425023455.GM2440@linux.vnet.ibm.com>
	 <w2sa44ae5cd1004250849q73704370vc6af935c70db9b73@mail.gmail.com>
	 <p2ga44ae5cd1004251320j55d23ba7ua0fa14497f623d76@mail.gmail.com>
	 <20100426160925.GD2529@linux.vnet.ibm.com>
	 <m1hbmydpup.fsf@fess.ebiederm.org>
	 <20100427042744.GD2510@linux.vnet.ibm.com>
	 <20100427162201.GA5826@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Miles Lane <miles.lane@gmail.com>,
	Vivek Goyal <vgoyal@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	netdev@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100427162201.GA5826@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 27 avril 2010 =C3=A0 09:22 -0700, Paul E. McKenney a =C3=A9cri=
t :
> On Mon, Apr 26, 2010 at 09:27:44PM -0700, Paul E. McKenney wrote:
> > On Mon, Apr 26, 2010 at 11:35:10AM -0700, Eric W. Biederman wrote:
> > > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> writes:
> > >=20
> > > > Eric Dumazet traced these down to a commit from Eric Biederman.
> > > >
> > > > If I don't hear from Eric Biederman in a few days, I will attem=
pt a
> > > > patch, but it would be more likely to be correct coming from so=
meone
> > > > with a better understanding of the code.  ;-)
> > >=20
> > > I already replied.
> > >=20
> > > http://lkml.org/lkml/2010/4/21/420
> >=20
> > You did indeed!!!  This experience is giving me an even better appr=
eciation
> > of the maintainers' ability to keep all their patches straight!
> >=20
> > I will put together something based on your suggestion.
>=20
> How about the following?
>=20
> 							Thanx, Paul
>=20
> ---------------------------------------------------------------------=
---
>=20
> commit 85fa42bd568ab99c375f018761ae6345249942cd
> Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Date:   Mon Apr 26 21:40:05 2010 -0700
>=20
>     net: suppress RCU lockdep false positive in twsk_net()
>    =20
>     Calls to twsk_net() are in some cases protected by reference coun=
ting
>     as an alternative to RCU protection.  Cases covered by reference =
counts
>     include __inet_twsk_kill(), inet_twsk_free(), inet_twdr_do_twkill=
_work(),
>     inet_twdr_twcal_tick(), and tcp_timewait_state_process().  RCU is=
 used
>     by inet_twsk_purge().  Locking is used by established_get_first()
>     and established_get_next().  Finally, __inet_twsk_hashdance() is =
an
>     initialization case.
>    =20
>     It appears to be non-trivial to locate the appropriate locks and
>     reference counts from within twsk_net(), so used rcu_dereference_=
raw().
>    =20
>     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>=20
> diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_time=
wait_sock.h
> index 79f67ea..a066fdd 100644
> --- a/include/net/inet_timewait_sock.h
> +++ b/include/net/inet_timewait_sock.h
> @@ -224,7 +224,9 @@ static inline
>  struct net *twsk_net(const struct inet_timewait_sock *twsk)
>  {
>  #ifdef CONFIG_NET_NS
> -	return rcu_dereference(twsk->tw_net);
> +	return rcu_dereference_raw(twsk->tw_net); /* protected by locking, =
*/
> +						  /* reference counting, */
> +						  /* initialization, or RCU. */
>  #else
>  	return &init_net;
>  #endif
> --

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
