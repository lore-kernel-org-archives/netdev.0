From: "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: Re: [PATCH 08/17] net: convert sk_filter.refcnt from
 atomic_t to refcount_t
Date: Fri, 17 Mar 2017 08:02:02 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B41C5A560@IRSMSX102.ger.corp.intel.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
	<1489678147-21404-9-git-send-email-elena.reshetova@intel.com>
	<58CAB7A1.8060500@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "keescook@chromium.org" <keescook@chromium.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	Hans Liljestrand <ishkamiel@gmail.com>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>, David Windsor <dwindsor@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <58CAB7A1.8060500@iogearbox.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


> On 03/16/2017 04:28 PM, Elena Reshetova wrote:
> > refcount_t type and corresponding API should be
> > used instead of atomic_t when the variable is used as
> > a reference counter. This allows to avoid accidental
> > refcounter overflows that might lead to use-after-free
> > situations.
> >
> > Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> > Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > Signed-off-by: David Windsor <dwindsor@gmail.com>
> > ---
> >   include/linux/filter.h | 3 ++-
> >   net/core/filter.c      | 7 ++++---
> >   2 files changed, 6 insertions(+), 4 deletions(-)
> >
> > diff --git a/include/linux/filter.h b/include/linux/filter.h
> > index 8053c38..20247e7 100644
> > --- a/include/linux/filter.h
> > +++ b/include/linux/filter.h
> > @@ -7,6 +7,7 @@
> >   #include <stdarg.h>
> >
> >   #include <linux/atomic.h>
> > +#include <linux/refcount.h>
> >   #include <linux/compat.h>
> >   #include <linux/skbuff.h>
> >   #include <linux/linkage.h>
> > @@ -431,7 +432,7 @@ struct bpf_prog {
> >   };
> >
> >   struct sk_filter {
> > -	atomic_t	refcnt;
> > +	refcount_t	refcnt;
> >   	struct rcu_head	rcu;
> >   	struct bpf_prog	*prog;
> >   };
> > diff --git a/net/core/filter.c b/net/core/filter.c
> > index ebaeaf2..62267e2 100644
> > --- a/net/core/filter.c
> > +++ b/net/core/filter.c
> > @@ -928,7 +928,7 @@ static void sk_filter_release_rcu(struct rcu_head *=
rcu)
> >    */
> >   static void sk_filter_release(struct sk_filter *fp)
> >   {
> > -	if (atomic_dec_and_test(&fp->refcnt))
> > +	if (refcount_dec_and_test(&fp->refcnt))
> >   		call_rcu(&fp->rcu, sk_filter_release_rcu);
> >   }
> >
> > @@ -950,7 +950,7 @@ bool sk_filter_charge(struct sock *sk, struct sk_fi=
lter *fp)
> >   	/* same check as in sock_kmalloc() */
> >   	if (filter_size <=3D sysctl_optmem_max &&
> >   	    atomic_read(&sk->sk_omem_alloc) + filter_size <
> sysctl_optmem_max) {
> > -		atomic_inc(&fp->refcnt);
> > +		refcount_inc(&fp->refcnt);
> >   		atomic_add(filter_size, &sk->sk_omem_alloc);
> >   		return true;
> >   	}
> > @@ -1179,12 +1179,13 @@ static int __sk_attach_prog(struct bpf_prog *pr=
og,
> struct sock *sk)
> >   		return -ENOMEM;
> >
> >   	fp->prog =3D prog;
> > -	atomic_set(&fp->refcnt, 0);
> > +	refcount_set(&fp->refcnt, 1);
> >
> >   	if (!sk_filter_charge(sk, fp)) {
> >   		kfree(fp);
> >   		return -ENOMEM;
> >   	}
> > +	refcount_set(&fp->refcnt, 1);
>=20
> Regarding the two subsequent refcount_set(, 1) that look a bit strange
> due to the sk_filter_charge() having refcount_inc() I presume ... can't
> the refcount API handle such corner case?=20

Yes, it was exactly because of recount_inc() from zero in sk_filter_charge(=
).=20
refcount_inc() would refuse to do an inc from zero for security reasons. At=
 some=20
point in past we discussed refcount_inc_not_one() but it was decided to be =
too special case
to support (we really have very little of such cases).


Or alternatively the let the
> sk_filter_charge() handle it, for example:
>=20
> bool __sk_filter_charge(struct sock *sk, struct sk_filter *fp)
> {
> 	u32 filter_size =3D bpf_prog_size(fp->prog->len);
>=20
> 	/* same check as in sock_kmalloc() */
> 	if (filter_size <=3D sysctl_optmem_max &&
> 	    atomic_read(&sk->sk_omem_alloc) + filter_size <
> sysctl_optmem_max) {
> 		atomic_add(filter_size, &sk->sk_omem_alloc);
> 		return true;
> 	}
> 	return false;
> }
>=20
> And this goes to filter.h:
>=20
> bool __sk_filter_charge(struct sock *sk, struct sk_filter *fp);
>=20
> bool sk_filter_charge(struct sock *sk, struct sk_filter *fp)
> {
> 	bool ret =3D __sk_filter_charge(sk, fp);
> 	if (ret)
> 		refcount_inc(&fp->refcnt);
> 	return ret;
> }
>=20
> ... and let __sk_attach_prog() call __sk_filter_charge() and only fo
> the second refcount_set()?
>=20
> >   	old_fp =3D rcu_dereference_protected(sk->sk_filter,
> >
> lockdep_sock_is_held(sk));
> >

Oh, yes, this would make it look less awkward. Thank you for the suggestion=
 Daniel!=20
I guess we try to be less invasive for code changes overall, maybe even too=
 careful...=20

I will update the patch and send a new version.=20

Best Regards,
Elena.
