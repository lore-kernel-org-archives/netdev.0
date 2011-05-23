From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [v3 00/39] faster tree-based sysctl implementation
Date: Mon, 23 May 2011 16:26:47 +0300
Message-ID: <BANLkTinH7h2+Vj6o=c03FoPt3nAZ3VU0oQ@mail.gmail.com>
References: <BANLkTim7xn8tM4wTyd_m_nwUQg_CUTapeA@mail.gmail.com>
 <m14o4mavod.fsf@fess.ebiederm.org> <BANLkTinqX_=TLU3TuKJFFTJBBxm1scZ3Ew@mail.gmail.com>
 <m1mxid7of6.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1mxid7of6.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2011 at 12:32 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Mostly it is simplicity. =C2=A0There is also the fact that the spin l=
ock is
> used in the implementation of something that is essentially a
> reader/writer lock already.


The amount of time in which the spin lock is held in the current
implementation can be quite large: in __register_sysctl_paths:

https://github.com/mirrors/linux-2.6/blob/v2.6.39/kernel/sysctl.c#L1887

	spin_lock(&sysctl_lock);
	for (set =3D header->set; set; set =3D set->parent)
		list_for_each_entry(p, &set->list, ctl_entry)
			try_attach(p, header);
	spin_unlock(&sysctl_lock);


=46or N=3D10^5 headers and try_attach=3DO(N) it's not a very good locki=
ng mechanism.

That's why I opted for a rwlock for each dir's subdirs/tables.


> In that context I'm not certain I am comfortable with separating proc
> inode usage from other proc usage. But I haven't read through that
> section of your code well enough yet to tell if you are making sense.


Proc inode usage (->count) was already separate from other proc usage (=
->use).
It was not separate from other header references (shared in ->count).

I separated the two because when I call unregister on a header I need
to decide whether to really unregister it (->unregistering=3Dtrue and n=
o
one can see this header and anything under it any more) or just
decrement a reference.

In the current implementation a header is only created by a
__register_sysctl_paths call and it's clear that at unregister we have
to set ->unregistering.
In my implementation headers are created dynamically to create new
directory elements. I need to know when to unregister such a header
regardless of any possible procfs inode references.

https://github.com/luciang/linux-2.6-new-sysctl/blob/v4-new-sysctl-alg/=
kernel/sysctl.c#L2390



I pushed a new version:
git://github.com/luciang/linux-2.6-new-sysctl.git v4-new-sysctl-alg

I undid int->u8 for ctl_procfs_refs.

I left the ->permissions hook get it's namespace form current->
because rewriting history for that change trips on too many patches
and a new parameter can be very easily added later when needed. Hope
this is ok with you.


I'd like to send patches for review to archs/drivers/etc. that
register only tables of files, not whole sysctl trees.
The patches don't depend on anything from this series.

Examples:
* http://thread.gmane.org/gmane.linux.kernel/1137032/focus=3D1137089
* http://thread.gmane.org/gmane.linux.kernel/1137032/focus=3D1137087


I'd like an OK-GO from you.

--=20
=C2=A0.
=2E.: Lucian
