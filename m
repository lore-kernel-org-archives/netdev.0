From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Fri, 29 Oct 2010 10:00:20 -0400
Message-ID: <1288360820.2092.34.camel@dan>
References: <20101028.112231.232747062.davem@davemloft.net>
	 <AANLkTinAzvfrRHwW-w-Ppdu7LWd7nGTa4EWP=e6pKV2F@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, allan.stephens@windriver.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:51260 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932586Ab0J2OAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 10:00:25 -0400
In-Reply-To: <AANLkTinAzvfrRHwW-w-Ppdu7LWd7nGTa4EWP=e6pKV2F@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While you guys are at it, you might consider preventing sendto(), etc.
calls from requesting >= 2GB data in one go.  Several families have no
restrictions on total size (or even worse, assign the size to a signed
int type and then do a signed comparison as a check).  This can result
in all kinds of ugliness when allocating sk_buffs based on that size,
some of which result in kernel panics (due to bad sk_buff tail position)
or heap corruption.

If you'd rather I dig up specific examples, I can do that as well, but I
think making changes to core code to protect individual modules from
their own inevitable stupid decisions is the best choice.

-Dan

On Thu, 2010-10-28 at 23:40 -0700, Linus Torvalds wrote:
> Oh, btw, noticed another small detail..
> 
> I don't know if this matters, but the regular read/write routines
> don't actually use INT_MAX as the limit, but instead a "maximally
> page-aligned value that fits in an int":
> 
>    #define MAX_RW_COUNT (INT_MAX & PAGE_CACHE_MASK)
> 
> because the code does _not_ want to turn a nice set of huge
> page-aligned big writes into a write of an odd number (2GB-1).
> 
> This may not make much of a difference to networking - you guys are
> already used to working with odd sizes like 1500 bytes of data payload
> per packet etc. Most regular filesystems are much more sensitive to
> things like block (and particularly page-cache sized) boundaries
> because of the vagaries of disk and cache granularities. But MAX_INT
> is a _really_ odd size, and things like csum_and_copy still tends to
> want to get things at least word-aligned, no? And if nothing else, the
> memory copies tend to be better with cacheline boundaries.
> 
> It would be sad if a 4GB aligned write turns into
>  - one 2GB-1 aligned write
>  - one pessimally unaligned 2G-1 write where every read from user
> space is unaligned
>  - finally a single 2-byte write.
> 
> I suspect it would be better off using the same kind of (MAX_INT &
> PAGE_CACHE_MASK) logic - that 4GB write would still get split into
> three partial writes (and _lots_ of packets ;), but at least they'd
> all be word-aligned.
> 
> Does it matter? I dunno. Once you do 2GB+ writes, these kinds of small
> details may be totally hidden in all the noise.
> 
>                     Linus
> 
> On Thu, Oct 28, 2010 at 11:22 AM, David Miller <davem@davemloft.net> wrote:
> >
> > This helps protect us from overflow issues down in the
> > individual protocol sendmsg/recvmsg handlers.  Once
> > we hit INT_MAX we truncate out the rest of the iovec
> > by setting the iov_len members to zero.
> >
> > This works because:
> >
> > 1) For SOCK_STREAM and SOCK_SEQPACKET sockets, partial
> >   writes are allowed and the application will just continue
> >   with another write to send the rest of the data.
> >
> > 2) For datagram oriented sockets, where there must be a
> >   one-to-one correspondance between write() calls and
> >   packets on the wire, INT_MAX is going to be far larger
> >   than the packet size limit the protocol is going to
> >   check for and signal with -EMSGSIZE.
> >
> > Based upon a patch by Linus Torvalds.
> >
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > ---
> >
> > Ok, this is the patch I am testing right now.  It ought to
> > plug the TIPC holes wrt. handling iovecs given by the
> > user.
> >
> > I'll look at the recently discovered RDS crap next :-/
> >
> >  include/linux/socket.h |    2 +-
> >  net/compat.c           |   12 +++++++-----
> >  net/core/iovec.c       |   19 +++++++++----------
> >  3 files changed, 17 insertions(+), 16 deletions(-)
> >
> > diff --git a/include/linux/socket.h b/include/linux/socket.h
> > index 5146b50..86b652f 100644
> > --- a/include/linux/socket.h
> > +++ b/include/linux/socket.h
> > @@ -322,7 +322,7 @@ extern int csum_partial_copy_fromiovecend(unsigned char *kdata,
> >                                          int offset,
> >                                          unsigned int len, __wsum *csump);
> >
> > -extern long verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address, int mode);
> > +extern int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address, int mode);
> >  extern int memcpy_toiovec(struct iovec *v, unsigned char *kdata, int len);
> >  extern int memcpy_toiovecend(const struct iovec *v, unsigned char *kdata,
> >                             int offset, int len);
> > diff --git a/net/compat.c b/net/compat.c
> > index 63d260e..71bfd8e 100644
> > --- a/net/compat.c
> > +++ b/net/compat.c
> > @@ -34,17 +34,19 @@ static inline int iov_from_user_compat_to_kern(struct iovec *kiov,
> >                                          struct compat_iovec __user *uiov32,
> >                                          int niov)
> >  {
> > -       int tot_len = 0;
> > +       size_t tot_len = 0;
> >
> >        while (niov > 0) {
> >                compat_uptr_t buf;
> >                compat_size_t len;
> >
> >                if (get_user(len, &uiov32->iov_len) ||
> > -                  get_user(buf, &uiov32->iov_base)) {
> > -                       tot_len = -EFAULT;
> > -                       break;
> > -               }
> > +                   get_user(buf, &uiov32->iov_base))
> > +                       return -EFAULT;
> > +
> > +               if (len > INT_MAX - tot_len)
> > +                       len = INT_MAX - tot_len;
> > +
> >                tot_len += len;
> >                kiov->iov_base = compat_ptr(buf);
> >                kiov->iov_len = (__kernel_size_t) len;
> > diff --git a/net/core/iovec.c b/net/core/iovec.c
> > index 72aceb1..e7f5b29 100644
> > --- a/net/core/iovec.c
> > +++ b/net/core/iovec.c
> > @@ -35,10 +35,10 @@
> >  *     in any case.
> >  */
> >
> > -long verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address, int mode)
> > +int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address, int mode)
> >  {
> >        int size, ct;
> > -       long err;
> > +       size_t err;
> >
> >        if (m->msg_namelen) {
> >                if (mode == VERIFY_READ) {
> > @@ -62,14 +62,13 @@ long verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address,
> >        err = 0;
> >
> >        for (ct = 0; ct < m->msg_iovlen; ct++) {
> > -               err += iov[ct].iov_len;
> > -               /*
> > -                * Goal is not to verify user data, but to prevent returning
> > -                * negative value, which is interpreted as errno.
> > -                * Overflow is still possible, but it is harmless.
> > -                */
> > -               if (err < 0)
> > -                       return -EMSGSIZE;
> > +               size_t len = iov[ct].iov_len;
> > +
> > +               if (len > INT_MAX - err) {
> > +                       len = INT_MAX - err;
> > +                       iov[ct].iov_len = len;
> > +               }
> > +               err += len;
> >        }
> >
> >        return err;
> > --
> > 1.7.3.2
> >
> >


