From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [iproute PATCH 21/51] lib/libnetlink: Don't pass NULL parameter
 to memcpy()
Date: Fri, 18 Aug 2017 15:13:39 -0400 (EDT)
Message-ID: <1953007845.2202528.1503083619344.JavaMail.zimbra@redhat.com>
References: <20170812120510.28750-1-phil@nwl.cc> <20170812120510.28750-22-phil@nwl.cc> <20170815081555.104dab6e@xeon-e3> <20170815164255.GA10864@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33392 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751037AbdHRTNl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 15:13:41 -0400
In-Reply-To: <20170815164255.GA10864@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Phil Sutter" <phil@nwl.cc>
> To: "Stephen Hemminger" <stephen@networkplumber.org>
> Cc: netdev@vger.kernel.org
> Sent: Tuesday, August 15, 2017 12:42:55 PM
> Subject: Re: [iproute PATCH 21/51] lib/libnetlink: Don't pass NULL parameter to memcpy()
> 
> On Tue, Aug 15, 2017 at 08:15:55AM -0700, Stephen Hemminger wrote:
> > On Sat, 12 Aug 2017 14:04:40 +0200
> > Phil Sutter <phil@nwl.cc> wrote:
> > 
> > > Both addattr_l() and rta_addattr_l() may be called with NULL data
> > > pointer and 0 alen parameters. Avoid calling memcpy() in that case.
> > > 
> > > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > 
> > What are you fixing. memcpy(dest, NULL, 0) should be harmless NOP
> 
> Yes, if that turns into a NOP this patch is not needed.
> 
> Thanks, Phil
> 

It is a NOP in this case, but it is also "undefined behavior" and can lead
to the compiler assuming that dest != NULL, which would be problematic
if dest were dereferenced later in the code (it isn't in this case, but
might be in general).

A small example with current gcc:

foo.c:
    #include <stdio.h>

    extern void foo(char *, size_t);

    int main(int argc, char **argv)
    {
            char x[128];

            foo(x, sizeof x);
            foo(NULL, 0);

            return 0;
    }

bar.c:
    #include <stdio.h>
    #include <string.h>

    void foo(char *ptr, size_t len)
    {
            memset(ptr, 0, len);

            if (ptr)
                    printf("ptr is non-null: %p\n", ptr);
    }

Compile the code:

    $ gcc -o foobar -O2 foo.c bar.c

Execute it (note second line of output, which might be surprising):

    $ ./foobar
    ptr is non-null: 0x7ffdc47daef0
    ptr is non-null: (nil)


Regards,

    Lance Richardson
