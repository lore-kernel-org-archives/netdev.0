From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : change layout of ehash table
Date: Fri, 9 Feb 2007 10:36:58 +0100
Message-ID: <200702091036.58474.dada1@cosmosbay.com>
References: <p73zm7n1ygk.fsf@bingen.suse.de> <200702091006.24242.dada1@cosmosbay.com> <20070209.011542.21927454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, linux@horizon.com, akepner@sgi.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:48933 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946271AbXBIJhE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 04:37:04 -0500
In-Reply-To: <20070209.011542.21927454.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 09 February 2007 10:15, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 9 Feb 2007 10:06:24 +0100
>
> > Yes, but a decent C compiler for such targets should not use a
> > multiply instruction to perform a (idx * 12) operation... :)
>
> Good point.
>
> Actually, I could never get GCC to avoid a divide on sparc64 for
> certain kinds of pointer arithmetic when the elements were not
> a power of two.  It probably has something to do with signedness.
>
> I think I narrowed is down to the fact that you can't legally replace
> a signed divide with shift/add/subtract.  But I could be remembering
> things wrong.

Thats strange, because pointer arithmetic is unsigned...
I dont know when gcc started to use reciprocal division, maybe your gcc was 
very old ?

$ cat div.c
struct s1 {        int pad[3];        };

unsigned long diffptr(struct s1 *a, struct s1 *b)
{
return a - b;
}

If compiled on i386 , gcc-4.1.1 :

$ gcc -O2 -fomit-frame-pointer -S div.c

diffptr:
        movl    4(%esp), %eax
        subl    8(%esp), %eax
        sarl    $2, %eax
        imull   $-1431655765, %eax, %eax
        ret

If compiled on x86_64 , gcc-4.1.1:

diffptr:
        subq    %rsi, %rdi
        movabsq $-6148914691236517205, %rax
        sarq    $2, %rdi
        imulq   %rax, %rdi
        movq    %rdi, %rax
        ret
