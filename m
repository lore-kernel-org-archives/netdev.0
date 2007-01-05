From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] INET: fix incorrect "inet_sock->is_icsk" assignment
Date: Fri, 5 Jan 2007 00:32:31 -0200
Message-ID: <39e6f6c70701041832u6e1d8c86w4728ac605f7449e3@mail.gmail.com>
References: <20070104200430.149943972@hp.com> <20070104200437.008980288@hp.com>
	 <20070104.165735.102614518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.229]:10382 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030276AbXAECcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 21:32:32 -0500
Received: by wr-out-0506.google.com with SMTP id 68so1007697wri
        for <netdev@vger.kernel.org>; Thu, 04 Jan 2007 18:32:31 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20070104.165735.102614518.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/4/07, David Miller <davem@davemloft.net> wrote:
> From: "Paul Moore" <paul.moore@hp.com>
> Date: Thu, 04 Jan 2007 15:04:31 -0500
>
> > From: Paul Moore <paul.moore@hp.com>
> >
> > The inet_create() and inet6_create() functions incorrectly set the
> > inet_sock->is_icsk field.  Both functions assume that the is_icsk field is
> > large enough to hold at least a INET_PROTOSW_ICSK value when it is actually
> > only a single bit.  This patch corrects the assignment by doing a boolean
> > comparison whose result will safely fit into a single bit field.
> >
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
>
> Applied, thanks a lot Paul.

Well spotted, gcc let me down on this one:

[acme@newtoy ~]$ cat a.c
#include <stdio.h>

struct foo { int a_bit:1; };

int main(void) {
        int trickme = 0x04;
        struct foo oof;

        oof.a_bit = trickme & 4;
        printf("%u\n", oof.a_bit);
}
[acme@newtoy ~]$ make a
cc     a.c   -o a
[acme@newtoy ~]$ ./a
0
[acme@newtoy ~]$

But...

[acme@newtoy ~]$ cat a.c
#include <stdio.h>

struct foo { int a_bit:1; };

int main(void) {
        struct foo oof;

        oof.a_bit = 0x04;
        printf("%u\n", oof.a_bit);
}
[acme@newtoy ~]$ make a
cc     a.c   -o a
a.c: In function 'main':
a.c:8: warning: overflow in implicit constant conversion
[acme@newtoy ~]$

I expected a warning since the and operation clearly could yield a
value that would overflow, just like in the constant case...

Anyway, thanks a lot Paul!

- Arnaldo
