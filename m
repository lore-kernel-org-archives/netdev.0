From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Fri, 28 Nov 2003 10:54:33 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1070013272.2144.4.camel@teapot.felipe-alfaro.com>
References: <1069974209.5349.7.camel@teapot.felipe-alfaro.com>
	 <20031128.092326.39861126.yoshfuji@linux-ipv6.org>
	 <20031128.092642.47232575.yoshfuji@linux-ipv6.org>
	 <20031128.094022.106776635.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: rmk+lkml@arm.linux.org.uk, davem@redhat.com,
        Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?= =?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031128.094022.106776635.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-11-28 at 01:40, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E wrote:
> In article <20031128.092642.47232575.yoshfuji@linux-ipv6.org> (at Fri, =
28 Nov 2003 09:26:42 +0900 (JST)), YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E <yoshfuji@linux-ipv6.org> says:
>=20
> > >  3)   if (len)
> > >          strncpy(dst, src, len - 1);
> > >       dst[len] =3D 0;
>=20
> grr, another mistake...:
>=20
>           if (len) {
>              strncpy(dst, src, len - 1);
>              dst[len - 1];
>           }
>=20
> ----------------
> 1) use strlcpy0(dst, src, len)
>=20
> size_t strlcpy0(char *dst, const char *src, size_t maxlen)
> {
>   size_t len =3D strlcpy(dst, src, maxlen);
>   if (likely(maxlen !=3D 0) && len < maxlen - 1)
>     memset(dst + len + 1, 0, maxlen - len - 1);
> }
>=20
> 2a) use strncpy0(dst, src, len)
>=20
> char *strncpy0(char *dst, const char *src, size_t maxlen)
> {
>   memset(dst, 0, maxlen);
>   if (likely(maxlen !=3D 0))
>     strncpy(dst, src, maxlen - 1);
> }
>=20
> 2b) fix strncpy() to zero-out rest of destination buffer=20
>     and use strncpy0(dst, src, len)
>=20
> char *strncpy0(char *dst, const char *src, size_t maxlen)
> {
>   if (likely(maxlen !=3D 0)) {
>     strncpy(dst, src, maxlen - 1);
>     dst[maxlen - 1] =3D 0;
>   }
> }
>=20
>=20
> I prefer 1 > 2b >> 2a.

What about coding a new function str0cpy()?

/**
 * str0cpy - Copy a length-limited, %NUL-terminated string
 * @dest: Where to copy the string to
 * @src: Where to copy the string from
 * @count: The maximum number of bytes to copy
 */
char * str0cpy(char * dest,const char *src,size_t count)
{
        if (count) {
                char *tmp =3D dest;

                count--;
                while (count) {
                        if ((*tmp =3D *src) !=3D 0) src++;
                        tmp++;
                        count--;
                }
                *tmp =3D 0;
        }
        return dest;
}

It behaves like strncpy() but correctly null-terminates the string in
every case.
