From: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH v3 3/3] lib/string_helpers.c: Change semantics of
 string_escape_mem
Date: Mon, 02 Mar 2015 14:37:26 +0200
Message-ID: <1425299846.14897.124.camel@linux.intel.com>
References: <1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1423525491-12613-4-git-send-email-linux@rasmusvillemoes.dk>
	 <1423571552.31903.468.camel@linux.intel.com>
	 <87386dj4x0.fsf@rasmusvillemoes.dk>
	 <1423578150.31903.480.camel@linux.intel.com>
	 <87oaoo59n2.fsf@rasmusvillemoes.dk>
	 <1424695820.14897.10.camel@linux.intel.com>
	 <87k2z86xvs.fsf@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87k2z86xvs.fsf-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-02-23 at 23:55 +0100, Rasmus Villemoes wrote:
> On Mon, Feb 23 2015, Andy Shevchenko <andriy.shevchenko-VuQAYsv1563A2t4k+OOtxA@public.gmane.org=
om> wrote:

> >> If you insist on a separate function for doing the overflow testin=
g,
> >> I'll just rip it out from my code and let you add such a test late=
r.
> >
> > What about to make it a separate function *and* call from inside of
> > test_string_escape? Would it work for you?
>=20
> See my earlier point about "quite a lot of state to pass". But if thi=
s
>=20
> static __init void
> test_string_escape_overflow(const char *in, int p, char *out_real, in=
t out_size,
> 			    unsigned int flags, const char *esc, int q_test,
> 			    const char *name)
> {
> 	int q_real;
>=20
> 	memset(out_real, 'Z', out_size);
> 	q_real =3D string_escape_mem(in, p, out_real, 0, flags, esc);
> 	if (q_real !=3D q_test)
> 		pr_warn("Test '%s' failed: flags =3D %u, osz =3D 0, expected %d, go=
t %d\n",
> 			name, flags, q_test, q_real);
> 	if (memchr_inv(out_real, 'Z', out_size))
> 		pr_warn("Test '%s' failed: osz =3D 0 but string_escape_mem wrote to=
 the buffer\n",
> 			name);
> }
>=20
> is what you want, sure, have it your way.

Something like above, though might be few variables can be defined
inside it, such as out_real, out_size.

> I need to fix fs/proc/array.c in 3/3 as well, to make the kernel
> compile+boot and make the series bisectable. Before I send v4 please =
let
> me know what you think about this (the minimal fix I could come up wi=
th):
>=20
> diff --git a/fs/proc/array.c b/fs/proc/array.c
> index 1295a00ca316..20f2d50e2dba 100644
> --- a/fs/proc/array.c
> +++ b/fs/proc/array.c
> @@ -99,10 +99,9 @@ static inline void task_name(struct seq_file *m, s=
truct task_struct *p)
>         buf =3D m->buf + m->count;
> =20
>         /* Ignore error for now */
> -       string_escape_str(tcomm, &buf, m->size - m->count,
> -                         ESCAPE_SPACE | ESCAPE_SPECIAL, "\n\\");
> +       m->count +=3D string_escape_str(tcomm, buf, m->size - m->coun=
t,
> +                                     ESCAPE_SPACE | ESCAPE_SPECIAL, =
"\n\\");

Just a nitpick: what if we keep buf arithmetics in place, i.e.
buf +=3D string_escape_str();
m->count =3D =E2=80=A6

Also shouldn't we check if seq_overflow is set before even trying to
escape? Otherwise it will return something which is bigger that 0 and
advance m->count too far.

> =20
> -       m->count =3D buf - m->buf;
>         seq_putc(m, '\n');
>  }
> =20
> [Longer-term I think it would be a lot better not to poke around in
> the internals of struct seq_file. One way is to do the escaping into =
a
> stack buffer (2*sizeof(p->comm) should be enough) and then use someth=
ing
> like seq_write(m, buffer, min(sizeof(buffer),
> return-value-from-string_escape_str)).
>=20
> Another option is to do everything with a single seq_printf call,
> something like
>=20
> seq_printf(m, "Name:\t%*pEcs\n, (int)strlen(tcomm), tcomm)
>=20
> That will escape more than just \ and \n, but that would IMO be an
> improvement. But of course this is out of scope for this series.]

It should be %pT and reconsider policy how we print task name in
different cases (vsprintf.c::comm_name()).

--=20
Andy Shevchenko <andriy.shevchenko-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Intel Finland Oy

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
