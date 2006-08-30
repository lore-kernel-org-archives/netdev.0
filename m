From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix verify_iovec() to not allow overflow of iov_len
 values
Date: Tue, 29 Aug 2006 21:44:53 -0700 (PDT)
Message-ID: <20060829.214453.112264010.davem@davemloft.net>
References: <1156874129.3147.2.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: chrisw@sous-sol.org, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57064
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751429AbWH3Eoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 00:44:54 -0400
To: sri@us.ibm.com
In-Reply-To: <1156874129.3147.2.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Tue, 29 Aug 2006 10:55:29 -0700

> verify_iovec() has the following piece of code that allows overflow
> of iov_len values in an iovec.
> 
>         for (ct = 0; ct < m->msg_iovlen; ct++) {
>                 err += iov[ct].iov_len;
>                 /*
>                  * Goal is not to verify user data, but to prevent returning
>                  * negative value, which is interpreted as errno.
>                  * Overflow is still possible, but it is harmless.
>                  */
>                 if (err < 0)
>                         return -EMSGSIZE;
>         }
> 
> The comment specifically says that overflow is harmless, but I don't see any
> valid reason to allow overflow.
> 
> Also, iov_len is of type size_t which is a 64-bit value on 64-bit systems,
> but we store and return the overall iovec length in an int.

Just some notes so that it is understood the context in which
such changes are being proposed.

First of all, several memcpy() and copy_{to,from}_user()
implementations BUG trap on lengths which have bit 31 or higher set.
It always indicates a bug of some sort in the call chain, so behaving
as if we support larger than positive signed 32-bit lengths here is
probably asking for trouble.

Also, the protocol downcalls all return "int", not "long" so it's even
impossible to report successful sending of larger than positive signed
32-bit lengths.  Even kernel_sendmsg() and friends return "int".

We can pretend that larger than positive signed 32-bit lengths in an
iovec will work, but they surely won't.

And since the sendmsg() man page was quoted:

       If the message is too long to pass atomically  through  the  underlying
       protocol, the error EMSGSIZE is returned, and the message is not trans$,1rp(B
       mitted.

which matches perfectly with the fact that the protocol downcalls
return "int"  not "size_t" nor  "ssize_t".
