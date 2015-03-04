From: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH v4 3/3] lib/string_helpers.c: Change semantics of
 string_escape_mem
Date: Wed, 04 Mar 2015 13:49:35 +0200
Message-ID: <1425469775.14897.174.camel@linux.intel.com>
References: <1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1425424836-17947-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1425424836-17947-4-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425424836-17947-4-git-send-email-linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-03-04 at 00:20 +0100, Rasmus Villemoes wrote:
> The current semantics of string_escape_mem are inadequate for one of
> its current users, vsnprintf(). If that is to honour its contract, it
> must know how much space would be needed for the entire escaped
> buffer, and string_escape_mem provides no way of obtaining that (shor=
t
> of allocating a large enough buffer (~4 times input string) to let it
> play with, and that's definitely a big no-no inside vsnprintf).
>=20
> So change the semantics for string_escape_mem to be more
> snprintf-like: Return the size of the output that would be generated
> if the destination buffer was big enough, but of course still only
> write to the part of dst it is allowed to, and (contrary to snprintf)
> don't do '\0'-termination. It is then up to the caller to detect
> whether output was truncated and to append a '\0' if desired. Also, w=
e
> must output partial escape sequences, otherwise a call such as
> snprintf(buf, 3, "%1pE", "\123") would cause printf to write a \0 to
> buf[2] but leaving buf[0] and buf[1] with whatever they previously
> contained.
>=20
> This also fixes a bug in the escaped_string() helper function, which
> used to unconditionally pass a length of "end-buf" to
> string_escape_mem(); since the latter doesn't check osz for being
> insanely large, it would happily write to dst. For example,
> kasprintf(GFP_KERNEL, "something and then %pE", ...); is an easy way
> to trigger an oops.
>=20
> In test-string_helpers.c, the -ENOMEM test is replaced with testing
> for getting the expected return value even if the buffer is too
> small. We also ensure that nothing is written (by relying on a NULL
> pointer deref) if the output size is 0 by passing NULL - this has to
> work for kasprintf("%pE") to work.
>=20
> In net/sunrpc/cache.c, I think qword_add still has the same
> semantics. Someone should definitely double-check this.
>=20
> In fs/proc/array.c, I made the minimum possible change, but
> longer-term it should stop poking around in seq_file internals.
>=20
> Signed-off-by: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>

Thanks!

One nitpick below, but anyway
Acked-by: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
for everything except net/sunrpc/cache.c

> ---
>  fs/proc/array.c                |  4 ++--
>  include/linux/string_helpers.h |  8 +++----
>  lib/string_helpers.c           | 49 ++++++--------------------------=
----------
>  lib/test-string_helpers.c      | 40 +++++++++++++++++---------------=
--
>  lib/vsprintf.c                 |  8 +++++--
>  net/sunrpc/cache.c             |  8 ++++---
>  6 files changed, 44 insertions(+), 73 deletions(-)
>=20
> diff --git a/fs/proc/array.c b/fs/proc/array.c
> index 1295a00ca316..b5405889a780 100644
> --- a/fs/proc/array.c
> +++ b/fs/proc/array.c
> @@ -99,8 +99,8 @@ static inline void task_name(struct seq_file *m, st=
ruct task_struct *p)
>  	buf =3D m->buf + m->count;
> =20
>  	/* Ignore error for now */
> -	string_escape_str(tcomm, &buf, m->size - m->count,
> -			  ESCAPE_SPACE | ESCAPE_SPECIAL, "\n\\");
> +	buf +=3D string_escape_str(tcomm, buf, m->size - m->count,
> +				 ESCAPE_SPACE | ESCAPE_SPECIAL, "\n\\");
> =20
>  	m->count =3D buf - m->buf;
>  	seq_putc(m, '\n');
> diff --git a/include/linux/string_helpers.h b/include/linux/string_he=
lpers.h
> index 657571817260..0991913f4953 100644
> --- a/include/linux/string_helpers.h
> +++ b/include/linux/string_helpers.h
> @@ -47,22 +47,22 @@ static inline int string_unescape_any_inplace(cha=
r *buf)
>  #define ESCAPE_ANY_NP		(ESCAPE_ANY | ESCAPE_NP)
>  #define ESCAPE_HEX		0x20
> =20
> -int string_escape_mem(const char *src, size_t isz, char **dst, size_=
t osz,
> +int string_escape_mem(const char *src, size_t isz, char *dst, size_t=
 osz,
>  		unsigned int flags, const char *esc);
> =20
>  static inline int string_escape_mem_any_np(const char *src, size_t i=
sz,
> -		char **dst, size_t osz, const char *esc)
> +		char *dst, size_t osz, const char *esc)
>  {
>  	return string_escape_mem(src, isz, dst, osz, ESCAPE_ANY_NP, esc);
>  }
> =20
> -static inline int string_escape_str(const char *src, char **dst, siz=
e_t sz,
> +static inline int string_escape_str(const char *src, char *dst, size=
_t sz,
>  		unsigned int flags, const char *esc)
>  {
>  	return string_escape_mem(src, strlen(src), dst, sz, flags, esc);
>  }
> =20
> -static inline int string_escape_str_any_np(const char *src, char **d=
st,
> +static inline int string_escape_str_any_np(const char *src, char *ds=
t,
>  		size_t sz, const char *esc)
>  {
>  	return string_escape_str(src, dst, sz, ESCAPE_ANY_NP, esc);
> diff --git a/lib/string_helpers.c b/lib/string_helpers.c
> index 9c48ddad0f0d..1826c7407258 100644
> --- a/lib/string_helpers.c
> +++ b/lib/string_helpers.c
> @@ -274,11 +274,6 @@ static bool escape_space(unsigned char c, char *=
*dst, char *end)
>  		return false;
>  	}
> =20
> -	if (out + 2 > end) {
> -		*dst =3D out + 2;
> -		return true;
> -	}
> -
>  	if (out < end)
>  		*out =3D '\\';
>  	++out;
> @@ -309,11 +304,6 @@ static bool escape_special(unsigned char c, char=
 **dst, char *end)
>  		return false;
>  	}
> =20
> -	if (out + 2 > end) {
> -		*dst =3D out + 2;
> -		return true;
> -	}
> -
>  	if (out < end)
>  		*out =3D '\\';
>  	++out;
> @@ -332,11 +322,6 @@ static bool escape_null(unsigned char c, char **=
dst, char *end)
>  	if (c)
>  		return false;
> =20
> -	if (out + 2 > end) {
> -		*dst =3D out + 2;
> -		return true;
> -	}
> -
>  	if (out < end)
>  		*out =3D '\\';
>  	++out;
> @@ -352,11 +337,6 @@ static bool escape_octal(unsigned char c, char *=
*dst, char *end)
>  {
>  	char *out =3D *dst;
> =20
> -	if (out + 4 > end) {
> -		*dst =3D out + 4;
> -		return true;
> -	}
> -
>  	if (out < end)
>  		*out =3D '\\';
>  	++out;
> @@ -378,11 +358,6 @@ static bool escape_hex(unsigned char c, char **d=
st, char *end)
>  {
>  	char *out =3D *dst;
> =20
> -	if (out + 4 > end) {
> -		*dst =3D out + 4;
> -		return true;
> -	}
> -
>  	if (out < end)
>  		*out =3D '\\';
>  	++out;
> @@ -449,20 +424,17 @@ static bool escape_hex(unsigned char c, char **=
dst, char *end)
>   * it if needs.
>   *
>   * Return:
> - * The amount of the characters processed to the destination buffer,=
 or
> - * %-ENOMEM if the size of buffer is not enough to put an escaped ch=
aracter is
> - * returned.
> - *
> - * Even in the case of error @dst pointer will be updated to point t=
o the byte
> - * after the last processed character.
> + * The total size of the escaped output that would be generated for
> + * the given input and flags. To check whether the output was
> + * truncated, compare the return value to osz. There is room left in
> + * dst for a '\0' terminator if and only if ret < osz.
>   */
> -int string_escape_mem(const char *src, size_t isz, char **dst, size_=
t osz,
> +int string_escape_mem(const char *src, size_t isz, char *dst, size_t=
 osz,
>  		      unsigned int flags, const char *esc)
>  {
> -	char *p =3D *dst;
> +	char *p =3D dst;
>  	char *end =3D p + osz;
>  	bool is_dict =3D esc && *esc;
> -	int ret;
> =20
>  	while (isz--) {
>  		unsigned char c =3D *src++;
> @@ -502,13 +474,6 @@ int string_escape_mem(const char *src, size_t is=
z, char **dst, size_t osz,
>  		escape_passthrough(c, &p, end);
>  	}
> =20
> -	if (p > end) {
> -		*dst =3D end;
> -		return -ENOMEM;
> -	}
> -
> -	ret =3D p - *dst;
> -	*dst =3D p;
> -	return ret;
> +	return p - dst;
>  }
>  EXPORT_SYMBOL(string_escape_mem);
> diff --git a/lib/test-string_helpers.c b/lib/test-string_helpers.c
> index ab0d30e1e18f..8e376efd88a4 100644
> --- a/lib/test-string_helpers.c
> +++ b/lib/test-string_helpers.c
> @@ -260,16 +260,28 @@ static __init const char *test_string_find_matc=
h(const struct test_string_2 *s2,
>  	return NULL;
>  }
> =20
> +static __init void
> +test_string_escape_overflow(const char *in, int p, unsigned int flag=
s, const char *esc,
> +			    int q_test, const char *name)

Just a nitpick. Can we reformat this to have return type and name on on=
e
line?

> +{
> +	int q_real;
> +
> +	q_real =3D string_escape_mem(in, p, NULL, 0, flags, esc);
> +	if (q_real !=3D q_test)
> +		pr_warn("Test '%s' failed: flags =3D %u, osz =3D 0, expected %d, g=
ot %d\n",
> +			name, flags, q_test, q_real);
> +}
> +
>  static __init void test_string_escape(const char *name,
>  				      const struct test_string_2 *s2,
>  				      unsigned int flags, const char *esc)
>  {
> -	int q_real =3D 512;
> -	char *out_test =3D kmalloc(q_real, GFP_KERNEL);
> -	char *out_real =3D kmalloc(q_real, GFP_KERNEL);
> +	size_t out_size =3D 512;
> +	char *out_test =3D kmalloc(out_size, GFP_KERNEL);
> +	char *out_real =3D kmalloc(out_size, GFP_KERNEL);
>  	char *in =3D kmalloc(256, GFP_KERNEL);
> -	char *buf =3D out_real;
>  	int p =3D 0, q_test =3D 0;
> +	int q_real;
> =20
>  	if (!out_test || !out_real || !in)
>  		goto out;
> @@ -301,29 +313,19 @@ static __init void test_string_escape(const cha=
r *name,
>  		q_test +=3D len;
>  	}
> =20
> -	q_real =3D string_escape_mem(in, p, &buf, q_real, flags, esc);
> +	q_real =3D string_escape_mem(in, p, out_real, out_size, flags, esc)=
;
> =20
>  	test_string_check_buf(name, flags, in, p, out_real, q_real, out_tes=
t,
>  			      q_test);
> +
> +	test_string_escape_overflow(in, p, flags, esc, q_test, name);
> +
>  out:
>  	kfree(in);
>  	kfree(out_real);
>  	kfree(out_test);
>  }
> =20
> -static __init void test_string_escape_nomem(void)
> -{
> -	char *in =3D "\eb \\C\007\"\x90\r]";
> -	char out[64], *buf =3D out;
> -	int rc =3D -ENOMEM, ret;
> -
> -	ret =3D string_escape_str_any_np(in, &buf, strlen(in), NULL);
> -	if (ret =3D=3D rc)
> -		return;
> -
> -	pr_err("Test 'escape nomem' failed: got %d instead of %d\n", ret, r=
c);
> -}
> -
>  static int __init test_string_helpers_init(void)
>  {
>  	unsigned int i;
> @@ -342,8 +344,6 @@ static int __init test_string_helpers_init(void)
>  	for (i =3D 0; i < (ESCAPE_ANY_NP | ESCAPE_HEX) + 1; i++)
>  		test_string_escape("escape 1", escape1, i, TEST_STRING_2_DICT_1);
> =20
> -	test_string_escape_nomem();
> -
>  	return -EINVAL;
>  }
>  module_init(test_string_helpers_init);
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index a1b6487c6710..9651686f3b42 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -1241,8 +1241,12 @@ char *escaped_string(char *buf, char *end, u8 =
*addr, struct printf_spec spec,
> =20
>  	len =3D spec.field_width < 0 ? 1 : spec.field_width;
> =20
> -	/* Ignore the error. We print as many characters as we can */
> -	string_escape_mem(addr, len, &buf, end - buf, flags, NULL);
> +	/*
> +	 * string_escape_mem() writes as many characters as it can to
> +	 * the given buffer, and returns the total size of the output
> +	 * had the buffer been big enough.
> +	 */
> +	buf +=3D string_escape_mem(addr, len, buf, buf < end ? end - buf : =
0, flags, NULL);
> =20
>  	return buf;
>  }
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 33fb105d4352..22c4418057f4 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1068,12 +1068,14 @@ void qword_add(char **bpp, int *lp, char *str=
)
>  {
>  	char *bp =3D *bpp;
>  	int len =3D *lp;
> -	int ret;
> +	int ret, written;
> =20
>  	if (len < 0) return;
> =20
> -	ret =3D string_escape_str(str, &bp, len, ESCAPE_OCTAL, "\\ \n\t");
> -	if (ret < 0 || ret =3D=3D len)
> +	ret =3D string_escape_str(str, bp, len, ESCAPE_OCTAL, "\\ \n\t");
> +	written =3D min(ret, len);
> +	bp +=3D written;

Do we need extra variable?

> +	if (ret >=3D len)

Something already done in the min.

>  		len =3D -1;
>  	else {
>  		len -=3D ret;

Would we simplify this?
=20
ret =3D string_escape_str(str, bp, len, ESCAPE_OCTAL, "\\ \n\t");
if (ret >=3D len) {
 bp +=3D len;
 len =3D -1;
} else {
 bp +=3D ret;
=E2=80=A6


--=20
Andy Shevchenko <andriy.shevchenko-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Intel Finland Oy

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
