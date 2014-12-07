From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 1/6] net-PPP: Replacement of a printk() call by
 pr_warn() in mppe_rekey()
Date: Sun, 07 Dec 2014 04:30:13 -0800
Message-ID: <1417955413.31745.25.camel@perches.com>
References: <1417731809.2721.17.camel@perches.com>
	 <alpine.DEB.2.02.1412050820290.2059@localhost6.localdomain6>
	 <1417765287.2721.39.camel@perches.com>
	 <alpine.DEB.2.02.1412071140290.2044@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1412071140290.2044@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-12-07 at 11:44 +0100, Julia Lawall wrote:
> > A negative to that approach is inlined functions would
> > take the function name of the parent not keep the
> > inlined function name.
> 
> I tried the following:
> 
> #include <stdio.h>
> 
> inline int foo() {
>   printf("%s %x\n",__func__,0x12345);
> }
> 
> int main () {
>   foo();
> }
> 
> The assembly code generated for main is:
> 
> 0000000000400470 <main>:
>   400470:       b9 45 23 01 00          mov    $0x12345,%ecx
>   400475:       ba 4b 06 40 00          mov    $0x40064b,%edx
>   40047a:       be 44 06 40 00          mov    $0x400644,%esi
>   40047f:       bf 01 00 00 00          mov    $0x1,%edi
>   400484:       31 c0                   xor    %eax,%eax
>   400486:       e9 d5 ff ff ff          jmpq   400460 <__printf_chk@plt>
> 
> That is, the call to foo seems tom be inlined.
> 
> But the output is:
> 
> foo 12345
> 
> So it seems that __func__ is determined before inlining.

True, and that's what I intended to describe.

If you did that with a kernel module and replaced
"%s, __func__" with "%pf, __builtin_return_address(0)"
when built with kallsyms you should get:

"modname 12345" when most would expect "foo 12345"

when built without kallsyms, that output should be
"<address> 12345"

but the object code should be smaller.
