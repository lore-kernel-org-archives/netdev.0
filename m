From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] net: optimize csum_replace2()
Date: Mon, 24 Mar 2014 08:14:47 -0700
Message-ID: <1395674087.12610.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140321.140730.1007660405690890605.davem@davemloft.net>
	 <1395629496.9117.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6E778C@AcuExch.aculab.com>
	 <1395667527.12610.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6E7939@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"hkchu@google.com" <hkchu@google.com>,
	"mwdalton@google.com" <mwdalton@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:52114 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639AbaCXPOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 11:14:55 -0400
Received: by mail-pd0-f172.google.com with SMTP id p10so5455193pdj.17
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 08:14:55 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6E7939@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 14:38 +0000, David Laight wrote:
> But C only has 32bit maths, so all the 16bit values keep
> need masking.
> 
> > But again if you prefer m ^ 0xffff, thats up to you ;)
> 
> On ppc I get much better code for (retyped):
> static inline u32 csum_add(u32 c, u32 a)
> {
> 	c += a'
> 	return (c + (c >> 16)) & 0xffff;
> }
> void csum_repl(u16 *c16, u16 o16, u16 n)
> {
> 	u32 c = *c16, o = o16;
> 	*c16 = csum_add(csum_add(c ^ 0xffff, o ^ 0xffff), n);
> }
> 13 instructions and no branches against 21 instructions
> and 2 branches.
> The same is probably true of arm.
> For amd64 (where the compiler can do a 16bit compare)
> my version is one instruction longer.
> I've not tried to guess at the actual cycle counts!
> 
> 	David

Code I provided uses no conditional branch on x86.

It sounds you could provide helper to arm, if you really care of this
path. I find surprising you did not comment on my prior mails on this
subject and you suddenly seem to care now the patch is merged.

We for example have the following helper in x86 :

static inline unsigned add32_with_carry(unsigned a, unsigned b)
{
        asm("addl %2,%0\n\t"
            "adcl $0,%0"
            : "=r" (a)
            : "0" (a), "r" (b));
        return a;
}

But these days, gcc seems to do a pretty good job without these helpers.

Yes we could save 4 instructions, but I doubt it is worth the pain of
adding arch helpers. I certainly wont do it.

0000000000000030 <inet_gro_complete>:
      30:	55                   	push   %rbp
      31:	48 63 c6             	movslq %esi,%rax
      34:	48 03 87 d0 00 00 00 	add    0xd0(%rdi),%rax
      3b:	48 89 e5             	mov    %rsp,%rbp
      3e:	8b 57 68             	mov    0x68(%rdi),%edx
      41:	44 0f b7 40 02       	movzwl 0x2(%rax),%r8d
      46:	0f b7 48 0a          	movzwl 0xa(%rax),%ecx
      4a:	66 29 f2             	sub    %si,%dx
      4d:	66 c1 c2 08          	rol    $0x8,%dx
      51:	44 0f b6 48 09       	movzbl 0x9(%rax),%r9d
      56:	66 89 50 02          	mov    %dx,0x2(%rax)
      5a:	41 f7 d0             	not    %r8d
      5d:	f7 d1                	not    %ecx
      5f:	66 44 01 c1          	add    %r8w,%cx
      63:	41 0f 92 c0          	setb   %r8b
      67:	45 0f b6 c0          	movzbl %r8b,%r8d
      6b:	44 01 c1             	add    %r8d,%ecx
      6e:	66 01 d1             	add    %dx,%cx
      71:	41 0f 92 c0          	setb   %r8b
      75:	45 0f b6 c0          	movzbl %r8b,%r8d
      79:	44 01 c1             	add    %r8d,%ecx
      7c:	f7 d1                	not    %ecx
      7e:	66 89 48 0a          	mov    %cx,0xa(%rax)
      82:	49 63 c1             	movslq %r9d,%rax
      85:	48 8b 04 c5 00 00 00 	mov    0x0(,%rax,8),%rax
