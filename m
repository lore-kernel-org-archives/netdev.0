From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] VSOCK: fix uapi/linux/vm_sockets.h incomplete types
Date: Wed, 20 Sep 2017 16:22:22 +0100
Message-ID: <20170920152222.GI9409@stefanha-x1.localdomain>
References: <20170912163435.4049-1-stefanha@redhat.com>
 <20170915.141432.1514866054657107786.davem@davemloft.net>
 <20170918152100.GF4141@stefanha-x1.localdomain>
 <20170919.103840.379059301652331060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33516 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751775AbdITPWX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 11:22:23 -0400
Content-Disposition: inline
In-Reply-To: <20170919.103840.379059301652331060.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 10:38:40AM -0700, David Miller wrote:
> From: Stefan Hajnoczi <stefanha@redhat.com>
> Date: Mon, 18 Sep 2017 16:21:00 +0100
> 
> > On Fri, Sep 15, 2017 at 02:14:32PM -0700, David Miller wrote:
> >> > diff --git a/include/uapi/linux/vm_sockets.h b/include/uapi/linux/vm_sockets.h
> >> > index b4ed5d895699..4ae5c625ac56 100644
> >> > --- a/include/uapi/linux/vm_sockets.h
> >> > +++ b/include/uapi/linux/vm_sockets.h
> >> > @@ -18,6 +18,10 @@
> >> >  
> >> >  #include <linux/socket.h>
> >> >  
> >> > +#ifndef __KERNEL__
> >> > +#include <sys/socket.h> /* struct sockaddr */
> >> > +#endif
> >> > +
> >> 
> >> There is no precedence whatsoever to include sys/socket.h in _any_ UAPI
> >> header file provided by the kernel.
> > 
> > <linux/if.h> does it for the same reason:
> > 
> > include/uapi/linux/if.h:#include <sys/socket.h>                 /* for struct sockaddr.         */
> 
> You don't need it for struct sockaddr, you need it for sa_family_t,
> the comment is very misleading.
> 
> Please do as I have instructed and it will fix this problem.

No, you really cannot rely on struct sockaddr from <linux/socket.h> in
uapi headers.  You can check this yourself:

  $ cd /tmp && gcc -o a.o -c /usr/include/linux/vm_sockets.h
  /usr/include/linux/vm_sockets.h:148:32: error: invalid application of ‘sizeof’ to incomplete type ‘struct sockaddr’
  unsigned char svm_zero[sizeof(struct sockaddr) -
                                ^~~~~~

The weird situation is:

1. When compiling the kernel, <linux/socket.h> brings in struct sockaddr
   because the compiler finds include/linux/socket.h first before
   include/uapi/linux/socket.h.

2. When compiling a userspace application, <linux/socket.h> does not
   bring in struct sockaddr because include/uapi/linux/socket.h is
   found.

This is why I added the #include <sys/socket> when !__KERNEL__.  Sorry
that the commit description wasn't clear on this.

Am I misunderstanding something?

Stefan
