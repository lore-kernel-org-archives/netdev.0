From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] Fix verify_iovec() to not allow overflow of iov_len
	values
Date: Wed, 30 Aug 2006 10:57:16 -0700
Message-ID: <1156960637.3354.26.camel@w-sridhar2.beaverton.ibm.com>
References: <1156874129.3147.2.camel@w-sridhar2.beaverton.ibm.com>
	 <20060829.214453.112264010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: chrisw@sous-sol.org, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:63115 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751271AbWH3R6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 13:58:07 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7UHw4pR009647
	for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 13:58:04 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7UHvJwM150182
	for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 13:57:19 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7UHvIut024779
	for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 13:57:18 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060829.214453.112264010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-29 at 21:44 -0700, David Miller wrote:
> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Tue, 29 Aug 2006 10:55:29 -0700
> 
> > verify_iovec() has the following piece of code that allows overflow
> > of iov_len values in an iovec.
> > 
> >         for (ct = 0; ct < m->msg_iovlen; ct++) {
> >                 err += iov[ct].iov_len;
> >                 /*
> >                  * Goal is not to verify user data, but to prevent returning
> >                  * negative value, which is interpreted as errno.
> >                  * Overflow is still possible, but it is harmless.
> >                  */
> >                 if (err < 0)
> >                         return -EMSGSIZE;
> >         }
> > 
> > The comment specifically says that overflow is harmless, but I don't see any
> > valid reason to allow overflow.
> > 
> > Also, iov_len is of type size_t which is a 64-bit value on 64-bit systems,
> > but we store and return the overall iovec length in an int.
> 
> Just some notes so that it is understood the context in which
> such changes are being proposed.
> 
> First of all, several memcpy() and copy_{to,from}_user()
> implementations BUG trap on lengths which have bit 31 or higher set.
> It always indicates a bug of some sort in the call chain, so behaving
> as if we support larger than positive signed 32-bit lengths here is
> probably asking for trouble.
> 
> Also, the protocol downcalls all return "int", not "long" so it's even
> impossible to report successful sending of larger than positive signed
> 32-bit lengths.  Even kernel_sendmsg() and friends return "int".
> 
> We can pretend that larger than positive signed 32-bit lengths in an
> iovec will work, but they surely won't.
> 
> And since the sendmsg() man page was quoted:
> 
>        If the message is too long to pass atomically  through  the  underlying
>        protocol, the error EMSGSIZE is returned, and the message is not trans$,1rp
>        mitted.
> 
> which matches perfectly with the fact that the protocol downcalls
> return "int"  not "size_t" nor  "ssize_t".

OK. So the maximum message size that can be supported via sendmsg/recvmsg
is limited to INT_MAX. Then i think we should limit each iov_len value
and the sum of all iov_len values to INT_MAX.
It looks like copy_{to,from}_user() support upto LONG_MAX but most of the
networking routines return only an int.

Currently if we pass an iovec with 2 iov_len values 0x7fffffff and 
0x80000002, verify_iovec returns a total length as 1 and we proceed
without any error with a truncated user message.

The following patch avoids overflow of iov_len values beyond INT_MAX.

diff --git a/net/compat.c b/net/compat.c
index d5d69fa..e8f5345 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -44,7 +44,11 @@ static inline int iov_from_user_compat_t
 			tot_len = -EFAULT;
 			break;
 		}
+		if (unlikely(len > INT_MAX))
+			return -EMSGSIZE;
 		tot_len += len;
+		if (unlikely(tot_len < 0))
+			return -EMSGSIZE;
 		kiov->iov_base = compat_ptr(buf);
 		kiov->iov_len = (__kernel_size_t) len;
 		uiov32++;
diff --git a/net/core/iovec.c b/net/core/iovec.c
index 65e4b56..ee5a265 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -61,11 +61,12 @@ int verify_iovec(struct msghdr *m, struc
 	err = 0;
 
 	for (ct = 0; ct < m->msg_iovlen; ct++) {
+		if (unlikely(iov[ct].iov_len > INT_MAX))
+			return -EMSGSIZE;
 		err += iov[ct].iov_len;
 		/*
 		 * Goal is not to verify user data, but to prevent returning
 		 * negative value, which is interpreted as errno.
-		 * Overflow is still possible, but it is harmless.
 		 */
 		if (err < 0)
 			return -EMSGSIZE;


