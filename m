From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: Re: [PATCH] uapi: fix linux/if.h userspace compilation errors
Date: Tue, 21 Feb 2017 23:19:14 +0300
Message-ID: <20170221201914.GA28360@altlinux.org>
References: <20170220115841.GA6846@altlinux.org> <20170221.121022.676021611021776681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=x-unknown;
        protocol="application/pgp-signature"; boundary="h31gzZEtNLTqOjlF"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170221.121022.676021611021776681.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 21, 2017 at 12:10:22PM -0500, David Miller wrote:
> From: "Dmitry V. Levin" <ldv@altlinux.org>
> Date: Mon, 20 Feb 2017 14:58:41 +0300
>=20
> > Include <sys/socket.h> (guarded by ifndef __KERNEL__) to fix
> > the following linux/if.h userspace compilation errors:
>=20
> Wouldn't it be so much better to do this in include/uapi/linux/socket.h?

Yes, it would be nicer if we could afford it.  However, changing
uapi/linux/socket.h to include <sys/socket.h> is less conservative than
changing every uapi header that fails to compile because of its use
of struct sockaddr.  It's risky because <sys/socket.h> pulls in other
types that might conflict with definitions provided by uapi headers.

I've checked all uapi headers that have no compilation errors whether
inclusion of <sys/socket.h> before them causes any issues, and found
that linux/time.h and linux/uio.h (and their users) stop compiling
because of type conflicts:

$ gcc -S -o/dev/null -xc /dev/null -include /usr/include/sys/socket.h -incl=
ude /usr/include/linux/time.h
In file included from <command-line>:32:0:
/usr/include/linux/time.h:9:8: error: redefinition of 'struct timespec'
 struct timespec {
        ^~~~~~~~
In file included from /usr/include/sys/select.h:45:0,
                 from /usr/include/sys/types.h:219,
                 from /usr/include/sys/uio.h:23,
                 from /usr/include/sys/socket.h:26,
                 from <command-line>:32:
/usr/include/time.h:120:8: note: originally defined here
 struct timespec
        ^~~~~~~~
In file included from <command-line>:32:0:
/usr/include/linux/time.h:15:8: error: redefinition of 'struct timeval'
 struct timeval {
        ^~~~~~~
In file included from /usr/include/sys/select.h:47:0,
                 from /usr/include/sys/types.h:219,
                 from /usr/include/sys/uio.h:23,
                 from /usr/include/sys/socket.h:26,
                 from <command-line>:32:
/usr/include/bits/time.h:30:8: note: originally defined here
 struct timeval
        ^~~~~~~
$ gcc -S -o/dev/null -xc /dev/null -include /usr/include/sys/socket.h -incl=
ude /usr/include/linux/uio.h
In file included from <command-line>:32:0:
/usr/include/linux/uio.h:16:8: error: redefinition of 'struct iovec'
 struct iovec
        ^~~~~
In file included from /usr/include/sys/uio.h:28:0,
                 from /usr/include/sys/socket.h:26,
                 from <command-line>:32:
/usr/include/bits/uio.h:43:8: note: originally defined here
 struct iovec
        ^~~~~

We can try to workaround these ancient <time.h> against <linux/time.h>
and <sys/uio.h> against <linux/uio.h> conflicts on uapi side by
introducing __UAPI_DEF_TIMESPEC, __UAPI_DEF_TIMEVAL, and __UAPI_DEF_IOVEC
guards, but these workarounds will work only one way (when libc headers
are included before uapi ones) until glibc catches up, and the latter
may take a lot of time.

> I mean, look at the comment right by the change you are making:
>=20
> > @@ -24,6 +24,10 @@
> >  #include <linux/socket.h>		/* for "struct sockaddr" et al	*/
>=20
> Anyone including linux/socket.h is trying to obtain that type.

I think this comment is true for #ifdef __KERNEL__ code only.


--=20
ldv

--h31gzZEtNLTqOjlF
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYrKDCAAoJEAVFT+BVnCUIFJYQAKPX0TJmcqYGjslugJf4+jmC
FWJ06U4bnkhcEVVJV4XNlLr0U+j/0iYnpuSNu9XCOD3Gs0sAUToyxeBgv+0/xITG
WxGiHmJQo80YTrUJmkTRnNw54LhCTUrzvKdsYaU+tPKfd8Z4gFobbPDBc2WEaRD8
kXdeSieykEceRwcv9x+4aE/LDcDALvfqiQK73VtXo/tijCmtyt9IMwShoFrgESto
Bt/Gs58rv34LfpBDYQeYXoNHdUAelBj5YSKrzi+qH3nfC2JAjhsfZJRSe2n91MHy
272YaDm9dzObESjhAFJl7scgCqVewimLAPPIzGDkXLW8AnMfEtPZiMXn1BhMfj3w
MJhZZS5/T/BPX+5VoB4diXz1DQX0sdginS0dNTA67vLFCR+ywLu5B7+D1tOBNEmQ
uGtTZLJrjl3080pBviZJdbnpzEUAA5F+jdgSYhsBg5uGEIP0E/7MIER/OIDGyT2u
WeqXL013OhTr5REz1gMjPluG75A1D3UExXnXGxQ/H0JOoXI0++6zbeSyOof9B8Mx
lpLMsfWEGf/HRc3ZdERpy43+U/QECK7TecXJMq15CVnRf+8DS4TPV26dlM6uHHXj
HzVHehzeobI7OJrx/zihGXIs7uO5AwevXABg+0D9TekLpbgT+67fvdTZlQ9zKAFm
2wgT3rr30ZtDjP7MC69z
=YvcB
-----END PGP SIGNATURE-----

--h31gzZEtNLTqOjlF--
