From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [v3 00/39] faster tree-based sysctl implementation
Date: Mon, 23 May 2011 02:32:13 -0700
Message-ID: <m1mxid7of6.fsf@fess.ebiederm.org>
References: <BANLkTim7xn8tM4wTyd_m_nwUQg_CUTapeA@mail.gmail.com>
	<m14o4mavod.fsf@fess.ebiederm.org>
	<BANLkTinqX_=TLU3TuKJFFTJBBxm1scZ3Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTinqX_=TLU3TuKJFFTJBBxm1scZ3Ew@mail.gmail.com> (Lucian
	Adrian Grijincu's message of "Mon, 23 May 2011 09:37:35 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lucian Adrian Grijincu <lucian.grijincu@gmail.com> writes:

> On Mon, May 23, 2011 at 7:27 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> This patchset looks like it is deserving of some close scrutiny, and
>> not just the high level design overview I have given the previous
>> patches. =C2=A0This is going to be a busy week for me so I probably =
won't
>> get through all of the patches for a while.
>
>
> I have one more question. The current implementation uses a single
> sysctl_lock to synchronize all changes to the data structures.
>
> In my algorithm I change a few places to use a per-header read-write
> lock. Even though the code is organized to handle a per-header rwlock=
,
> the implementation uses a single global rwlock. In v2 I got rid of th=
e
> rwlock and replaced the subdirs/files regular lists with rcu-protecte=
d
> lists and that's why I did not bother giving each header a rwlock.
>
>
> I have no idea how to use rcu with rbtree. Should I now give each
> header it's own lock to reduce contention?

I would only walk down that path if we can find some profile data
showing that the lock is where we are hot.

> I'm asking this because I don't know why the only is a global sysctl
> spin lock, when multiple locks could have been used, each to protect
> it's own domain of values.

Mostly it is simplicity.  There is also the fact that the spin lock is
used in the implementation of something that is essentially a
reader/writer lock already.

With the help of the reference counts we block when we are unregisterin=
g
until there are no more users.

In that context I'm not certain I am comfortable with separating proc
inode usage from other proc usage. But I haven't read through that
section of your code well enough yet to tell if you are making sense.

One of the things that would be very nice to do is add lockdep
annotations like I have to sysfs_activate and sysfs_deactivate, so we
can catch the all too common case of someone unregistering a sysctl
table when there are problems.

Personally I'm not happy with the state of the locking abstractions in
sysctl today.  It is all much too obscure, and there are too few
warnings.  However for your set of changes I think the thing to focus
on is getting sysctl to better data structures so that it can scale.

Once the data structures are simple enough any remaining issues should
be fixable with small straight forward patches.

Eric
