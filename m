From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ipv4: inlining ip_send_check()
Date: Tue, 18 Aug 2015 07:46:25 -0700
Message-ID: <1439909185.6443.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150818121439.3E5621A241A@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150818121439.3E5621A241A@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-08-18 at 14:14 +0200, Christophe Leroy wrote:
> ip_send_check() is a function that does nothing but calling
> ip_fast_csum() after having zeroed iph->check
> 
> We get (on PPC) a quite long function for just that, as it requires
> setting the stack frame, saving volatile regs, restoring them after
> the call, etc ...
> 
> c02d3e3c <ip_send_check>:
> c02d3e3c:       7c 08 02 a6     mflr    r0
> c02d3e40:       94 21 ff f0     stwu    r1,-16(r1)
> c02d3e44:       39 20 00 00     li      r9,0
> c02d3e48:       93 e1 00 0c     stw     r31,12(r1)
> c02d3e4c:       90 01 00 14     stw     r0,20(r1)
> c02d3e50:       b1 23 00 0a     sth     r9,10(r3)
> c02d3e54:       88 83 00 00     lbz     r4,0(r3)
> c02d3e58:       7c 7f 1b 78     mr      r31,r3
> c02d3e5c:       54 84 07 3e     clrlwi  r4,r4,28
> c02d3e60:       4b d3 ab 7d     bl      c000e9dc <ip_fast_csum>
> c02d3e64:       b0 7f 00 0a     sth     r3,10(r31)
> c02d3e68:       80 01 00 14     lwz     r0,20(r1)
> c02d3e6c:       83 e1 00 0c     lwz     r31,12(r1)
> c02d3e70:       7c 08 03 a6     mtlr    r0
> c02d3e74:       38 21 00 10     addi    r1,r1,16
> c02d3e78:       4e 80 00 20     blr

That's because you should inline ip_fast_csum() instead.

We do not want to inline ip_send_check() on eg x86, as it is clearly too
long.

ffffffff816d72e0 <ip_send_check>:
ffffffff816d72e0:       e8 9b e3 0c 00          callq  ffffffff817a5680 <__fentry__>
ffffffff816d72e5:       0f b6 17                movzbl (%rdi),%edx
ffffffff816d72e8:       55                      push   %rbp
ffffffff816d72e9:       31 c0                   xor    %eax,%eax
ffffffff816d72eb:       66 89 47 0a             mov    %ax,0xa(%rdi)
ffffffff816d72ef:       48 89 f8                mov    %rdi,%rax
ffffffff816d72f2:       48 89 e5                mov    %rsp,%rbp
ffffffff816d72f5:       83 e2 0f                and    $0xf,%edx
ffffffff816d72f8:       8b 08                   mov    (%rax),%ecx
ffffffff816d72fa:       83 ea 04                sub    $0x4,%edx
ffffffff816d72fd:       76 24                   jbe    ffffffff816d7323 <ip_send_check+0x43>
ffffffff816d72ff:       03 48 04                add    0x4(%rax),%ecx
ffffffff816d7302:       13 48 08                adc    0x8(%rax),%ecx
ffffffff816d7305:       13 48 0c                adc    0xc(%rax),%ecx
ffffffff816d7308:       13 48 10                adc    0x10(%rax),%ecx
ffffffff816d730b:       48 8d 40 04             lea    0x4(%rax),%rax
ffffffff816d730f:       ff ca                   dec    %edx
ffffffff816d7311:       75 f5                   jne    ffffffff816d7308 <ip_send_check+0x28>
ffffffff816d7313:       83 d1 00                adc    $0x0,%ecx
ffffffff816d7316:       89 ca                   mov    %ecx,%edx
ffffffff816d7318:       c1 e9 10                shr    $0x10,%ecx
ffffffff816d731b:       66 01 d1                add    %dx,%cx
ffffffff816d731e:       83 d1 00                adc    $0x0,%ecx
ffffffff816d7321:       f7 d1                   not    %ecx
ffffffff816d7323:       66 89 4f 0a             mov    %cx,0xa(%rdi)
ffffffff816d7327:       5d                      pop    %rbp
ffffffff816d7328:       c3                      retq
