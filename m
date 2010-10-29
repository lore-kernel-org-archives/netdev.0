From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Thu, 28 Oct 2010 23:40:50 -0700
Message-ID: <AANLkTinAzvfrRHwW-w-Ppdu7LWd7nGTa4EWP=e6pKV2F@mail.gmail.com>
References: <20101028.112231.232747062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, drosenberg@vsecurity.com,
	jon.maloy@ericsson.com, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49347 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754923Ab0J2GmQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 02:42:16 -0400
Received: from mail-iw0-f174.google.com (mail-iw0-f174.google.com [209.85.214.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o9T6fDai011475
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 23:41:25 -0700
Received: by iwn10 with SMTP id 10so3299310iwn.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 23:41:11 -0700 (PDT)
In-Reply-To: <20101028.112231.232747062.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh, btw, noticed another small detail..

I don't know if this matters, but the regular read/write routines
don't actually use INT_MAX as the limit, but instead a "maximally
page-aligned value that fits in an int":

   #define MAX_RW_COUNT (INT_MAX & PAGE_CACHE_MASK)

because the code does _not_ want to turn a nice set of huge
page-aligned big writes into a write of an odd number (2GB-1).

This may not make much of a difference to networking - you guys are
already used to working with odd sizes like 1500 bytes of data payload
per packet etc. Most regular filesystems are much more sensitive to
things like block (and particularly page-cache sized) boundaries
because of the vagaries of disk and cache granularities. But MAX_INT
is a _really_ odd size, and things like csum_and_copy still tends to
want to get things at least word-aligned, no? And if nothing else, the
memory copies tend to be better with cacheline boundaries.

It would be sad if a 4GB aligned write turns into
 - one 2GB-1 aligned write
 - one pessimally unaligned 2G-1 write where every read from user
space is unaligned
 - finally a single 2-byte write.

I suspect it would be better off using the same kind of (MAX_INT &
PAGE_CACHE_MASK) logic - that 4GB write would still get split into
three partial writes (and _lots_ of packets ;), but at least they'd
all be word-aligned.

Does it matter? I dunno. Once you do 2GB+ writes, these kinds of small
details may be totally hidden in all the noise.

                    Linus

On Thu, Oct 28, 2010 at 11:22 AM, David Miller <davem@davemloft.net> wr=
ote:
>
> This helps protect us from overflow issues down in the
> individual protocol sendmsg/recvmsg handlers. =A0Once
> we hit INT_MAX we truncate out the rest of the iovec
> by setting the iov_len members to zero.
>
> This works because:
>
> 1) For SOCK_STREAM and SOCK_SEQPACKET sockets, partial
> =A0 writes are allowed and the application will just continue
> =A0 with another write to send the rest of the data.
>
> 2) For datagram oriented sockets, where there must be a
> =A0 one-to-one correspondance between write() calls and
> =A0 packets on the wire, INT_MAX is going to be far larger
> =A0 than the packet size limit the protocol is going to
> =A0 check for and signal with -EMSGSIZE.
>
> Based upon a patch by Linus Torvalds.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>
> Ok, this is the patch I am testing right now. =A0It ought to
> plug the TIPC holes wrt. handling iovecs given by the
> user.
>
> I'll look at the recently discovered RDS crap next :-/
>
> =A0include/linux/socket.h | =A0 =A02 +-
> =A0net/compat.c =A0 =A0 =A0 =A0 =A0 | =A0 12 +++++++-----
> =A0net/core/iovec.c =A0 =A0 =A0 | =A0 19 +++++++++----------
> =A03 files changed, 17 insertions(+), 16 deletions(-)
>
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 5146b50..86b652f 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -322,7 +322,7 @@ extern int csum_partial_copy_fromiovecend(unsigne=
d char *kdata,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0int offset,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0unsigned int len, __wsum *csump);
>
> -extern long verify_iovec(struct msghdr *m, struct iovec *iov, struct=
 sockaddr *address, int mode);
> +extern int verify_iovec(struct msghdr *m, struct iovec *iov, struct =
sockaddr *address, int mode);
> =A0extern int memcpy_toiovec(struct iovec *v, unsigned char *kdata, i=
nt len);
> =A0extern int memcpy_toiovecend(const struct iovec *v, unsigned char =
*kdata,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int offset, i=
nt len);
> diff --git a/net/compat.c b/net/compat.c
> index 63d260e..71bfd8e 100644
> --- a/net/compat.c
> +++ b/net/compat.c
> @@ -34,17 +34,19 @@ static inline int iov_from_user_compat_to_kern(st=
ruct iovec *kiov,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0struct compat_iovec __user *uiov32,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0int niov)
> =A0{
> - =A0 =A0 =A0 int tot_len =3D 0;
> + =A0 =A0 =A0 size_t tot_len =3D 0;
>
> =A0 =A0 =A0 =A0while (niov > 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compat_uptr_t buf;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compat_size_t len;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (get_user(len, &uiov32->iov_len) ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0get_user(buf, &uiov32->iov_base)=
) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tot_len =3D -EFAULT;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_user(buf, &uiov32->iov_base=
))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (len > INT_MAX - tot_len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D INT_MAX - tot_l=
en;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tot_len +=3D len;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kiov->iov_base =3D compat_ptr(buf);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kiov->iov_len =3D (__kernel_size_t) le=
n;
> diff --git a/net/core/iovec.c b/net/core/iovec.c
> index 72aceb1..e7f5b29 100644
> --- a/net/core/iovec.c
> +++ b/net/core/iovec.c
> @@ -35,10 +35,10 @@
> =A0* =A0 =A0 in any case.
> =A0*/
>
> -long verify_iovec(struct msghdr *m, struct iovec *iov, struct sockad=
dr *address, int mode)
> +int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockadd=
r *address, int mode)
> =A0{
> =A0 =A0 =A0 =A0int size, ct;
> - =A0 =A0 =A0 long err;
> + =A0 =A0 =A0 size_t err;
>
> =A0 =A0 =A0 =A0if (m->msg_namelen) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (mode =3D=3D VERIFY_READ) {
> @@ -62,14 +62,13 @@ long verify_iovec(struct msghdr *m, struct iovec =
*iov, struct sockaddr *address,
> =A0 =A0 =A0 =A0err =3D 0;
>
> =A0 =A0 =A0 =A0for (ct =3D 0; ct < m->msg_iovlen; ct++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err +=3D iov[ct].iov_len;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Goal is not to verify user data, b=
ut to prevent returning
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* negative value, which is interpret=
ed as errno.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Overflow is still possible, but it=
 is harmless.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err < 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EMSGSIZE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t len =3D iov[ct].iov_len;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (len > INT_MAX - err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D INT_MAX - err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iov[ct].iov_len =3D len=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err +=3D len;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return err;
> --
> 1.7.3.2
>
>
