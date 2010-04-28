From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.34-rc5-git7 (plus all patches) -- another suspicious
 rcu_dereference_check() usage.
Date: Wed, 28 Apr 2010 13:09:04 -0700
Message-ID: <20100428200904.GS2540@linux.vnet.ibm.com>
References: <h2ya44ae5cd1004261751waa5cb65ei3d139cbcfa2cc5cf@mail.gmail.com>
 <20100428175426.GK2540@linux.vnet.ibm.com>
 <1272483491.2201.9.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Miles Lane <miles.lane@gmail.com>, Vivek Goyal <vgoyal@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	netdev@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1272483491.2201.9.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 28, 2010 at 09:38:11PM +0200, Eric Dumazet wrote:
> Le mercredi 28 avril 2010 =E0 10:54 -0700, Paul E. McKenney a =E9crit=
 :
> > On Mon, Apr 26, 2010 at 08:51:06PM -0400, Miles Lane wrote:
> > > This one occurred during the wakeup from suspend to RAM.
> > >=20
> > > [  984.724697] [ INFO: suspicious rcu_dereference_check() usage. =
]
> > > [  984.724700] --------------------------------------------------=
-
> > > [  984.724703] include/linux/fdtable.h:88 invoked
> > > rcu_dereference_check() without protection!
> > > [  984.724706]
> > > [  984.724707] other info that might help us debug this:
> > > [  984.724708]
> > > [  984.724711]
> > > [  984.724711] rcu_scheduler_active =3D 1, debug_locks =3D 1
> > > [  984.724714] no locks held by dbus-daemon/4680.
> > > [  984.724717]
> > > [  984.724717] stack backtrace:
> > > [  984.724721] Pid: 4680, comm: dbus-daemon Not tainted 2.6.34-rc=
5-git7 #33
> > > [  984.724724] Call Trace:
> > > [  984.724734]  [<ffffffff81074556>] lockdep_rcu_dereference+0x9d=
/0xa6
> > > [  984.724740]  [<ffffffff810fc785>] fcheck_files+0xb1/0xc9
> > > [  984.724745]  [<ffffffff810fc7f5>] fget_light+0x35/0xab
> > > [  984.724751]  [<ffffffff81433e1b>] ? sock_poll_wait+0x13/0x18
> > > [  984.724755]  [<ffffffff81433e39>] ? unix_poll+0x19/0x95
> > > [  984.724762]  [<ffffffff8110aa95>] do_sys_poll+0x1ff/0x3e5
> > > [  984.724766]  [<ffffffff8110a19e>] ? __pollwait+0x0/0xc7
> > > [  984.724771]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > [  984.724776]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > [  984.724780]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > [  984.724784]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > [  984.724788]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > [  984.724793]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > [  984.724797]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > [  984.724802]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > [  984.724806]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > [  984.724812]  [<ffffffff8110ae0f>] sys_poll+0x50/0xbb
> > > [  984.724818]  [<ffffffff81009d82>] system_call_fastpath+0x16/0x=
1b
> >=20
> > Hmmm...  I am not convinced that this is a false positive.  Couldn'=
t
> > there be a multi-threaded process where one thread is invoking poll=
()
> > on a UNIX socket just as another thread is calling close() on it?
> >=20
> > The current fcheck_files() logic requires that the caller either (1=
) be in
> > an RCU read-side critical section, (2) hold ->files_lock, or (3) pa=
ssing
> > in a files_struct with ->count equal to 1 (initialization or cleanu=
p).
> >=20
> > So I don't feel comfortable just slapping an RCU read-side critical
> > section around this one, at least not unless someone who understand=
s
> > the locking says that doing so is OK.
> >=20
> > 	=09
>=20
> Its a single threaded program.
>=20
> So fget_light() calls fcheck_files(files, fd); without rcu lock,
> but some /proc/pid/fd/... user temporarly raised files->count just
> before we perform the condition check.

So I should add a single-threaded check.  My first thought was to use
current_is_single_threaded(), but the bit about scanning the full list
of processes does give me pause.  However, thread_group_empty() looks
like a much lighter-weight alternative.

I believe that it is possible for a pair of single-threaded processes
to share a file descriptor, but that should not be a problem, as both
of them would need to close it for it to go away.

But what happens if someone does a clone() with CLONE_FILES, as some
of the AIO stuff seems to do?  Won't that allow one of the resulting
processes to close the file for both of them, even though both are
otherwise single-threaded?  And the ->count seems to be the only
distinction between these two cases.

And AIO does CLONE_VM as well as CLONE_FILES, but that seems to mean th=
at
the check must scan the processes with current_is_single_threaded().
Besides which, a user could invoke clone() with only CLONE_FILES
specified, right?

Or am I just confused here?

							Thanx, Paul
