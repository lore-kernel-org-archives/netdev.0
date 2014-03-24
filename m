From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [RFC] csum experts, csum_replace2() is too expensive
Date: Mon, 24 Mar 2014 06:17:43 -0700
Message-ID: <1395667063.12610.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a9cknwk4.fsf@tassilo.jf.intel.com>
	 <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140321.145229.1026128975151125729.davem@davemloft.net>
	 <1395629410.9117.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6E77A4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"hkchu@google.com" <hkchu@google.com>,
	"mwdalton@google.com" <mwdalton@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6E77A4@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-03-24 at 10:30 +0000, David Laight wrote:
> From: Eric Dumazet
> > On Fri, 2014-03-21 at 14:52 -0400, David Miller wrote:
> > > From: Eric Dumazet <eric.dumazet@gmail.com>
> > > Date: Fri, 21 Mar 2014 05:50:50 -0700
> > >
> > > > It looks like a barrier() would be more appropriate.
> > >
> > > barrier() == __asm__ __volatile__(:::"memory")
> > 
> > Indeed, but now you mention it, ip_fast_csum() do not uses volatile
> > keyword on x86_64, and has no "m" constraint either.
> 
> Adding 'volatile' isn't sufficient to force gcc to write data
> into the area being checksummed.

You missed the point. Its not about forcing gcc to write data, because
it does.

Point is : gcc doesn't recompute the checksum a second time.

> ip_fast_csum() either needs an explicit "m" constraint for the actual
> buffer (and target) bytes, or the stronger "memory" constraint.
> The 'volatile' is then not needed.

What about you take a look at the actual code ?

"memory" constraint is already there. And no, its not enough, otherwise
I wouldn't have sent this mail.

I actually compiled the code and double checked.

0000000000007010 <foobar>:
    7010:	e8 00 00 00 00       	callq  7015 <foobar+0x5>
			7011: R_X86_64_PC32	__fentry__-0x4
    7015:	55                   	push   %rbp
    7016:	31 c0                	xor    %eax,%eax
    7018:	b9 05 00 00 00       	mov    $0x5,%ecx
    701d:	48 89 e5             	mov    %rsp,%rbp
    7020:	48 83 ec 20          	sub    $0x20,%rsp
    7024:	48 89 5d e8          	mov    %rbx,-0x18(%rbp)
    7028:	4c 89 6d f8          	mov    %r13,-0x8(%rbp)
    702c:	48 89 fb             	mov    %rdi,%rbx
    702f:	4c 89 65 f0          	mov    %r12,-0x10(%rbp)
    7033:	41 89 d5             	mov    %edx,%r13d
    7036:	66 89 47 0a          	mov    %ax,0xa(%rdi)
    703a:	66 89 77 02          	mov    %si,0x2(%rdi)
    703e:	48 89 f8             	mov    %rdi,%rax
    7041:	48 89 fe             	mov    %rdi,%rsi
    7044:	44 8b 20             	mov    (%rax),%r12d
    7047:	83 e9 04             	sub    $0x4,%ecx
    704a:	76 2e                	jbe    707a <foobar+0x6a>
    704c:	44 03 60 04          	add    0x4(%rax),%r12d
    7050:	44 13 60 08          	adc    0x8(%rax),%r12d
    7054:	44 13 60 0c          	adc    0xc(%rax),%r12d
    7058:	44 13 60 10          	adc    0x10(%rax),%r12d
    705c:	48 8d 40 04          	lea    0x4(%rax),%rax
    7060:	ff c9                	dec    %ecx
    7062:	75 f4                	jne    7058 <foobar+0x48>
    7064:	41 83 d4 00          	adc    $0x0,%r12d
    7068:	44 89 e1             	mov    %r12d,%ecx
    706b:	41 c1 ec 10          	shr    $0x10,%r12d
    706f:	66 41 01 cc          	add    %cx,%r12w
    7073:	41 83 d4 00          	adc    $0x0,%r12d
    7077:	41 f7 d4             	not    %r12d
    707a:	31 c0                	xor    %eax,%eax
    707c:	66 44 89 67 0a       	mov    %r12w,0xa(%rdi)
    7081:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
			7084: R_X86_64_32S	.rodata.str1.1+0xabd
    7088:	e8 00 00 00 00       	callq  708d <foobar+0x7d>
			7089: R_X86_64_PC32	printk-0x4
    708d:	66 44 89 6b 02       	mov    %r13w,0x2(%rbx)
    7092:	66 44 89 63 0a       	mov    %r12w,0xa(%rbx)
    7097:	4c 8b 6d f8          	mov    -0x8(%rbp),%r13
    709b:	48 8b 5d e8          	mov    -0x18(%rbp),%rbx
    709f:	4c 8b 65 f0          	mov    -0x10(%rbp),%r12
    70a3:	c9                   	leaveq 
    70a4:	c3                   	retq   
