From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Wed, 29 Apr 2009 13:28:58 -0400
Message-ID: <49F88E5A.8070908@myri.com>
References: <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com> <20090427080501.GA21433@gondor.apana.org.au> <20090428061225.GA1591@gondor.apana.org.au> <49F71A00.5090701@myri.com> <20090428152047.GB7549@gondor.apana.org.au> <49F77134.9030907@myri.com> <49F85945.7030900@myri.com> <49F85BF1.1020501@cosmosbay.com> <49F861BF.7060403@myri.com> <49F87188.9000904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1825 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754390AbZD2RaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 13:30:21 -0400
In-Reply-To: <49F87188.9000904@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

 >
 > Sure, probably more cache misses or something...

Yes, that's what I thought.  The code is much more complete,
and spread out than LRO, and seems to open itself to cache
misses.

 > You could try a longer oprofile session (with at least one million 
samples)
 > and :
 >
 > opannotate -a vmlinux >/tmp/FILE
 >
 > And select 3 or 4 suspect functions : inet_gro_receive() 
tcp_gro_receive(),
 > skb_gro_receive(), skb_gro_header()

Here is the opreport -l output from this machine for GRO for a 25 minute
profiling run:


samples  %        image name               app name 
symbol name
3742674  32.2793  vmlinux                  vmlinux 
copy_user_generic_string
890179    7.6775  myri10ge.ko              myri10ge 
myri10ge_poll
547572    4.7226  vmlinux                  vmlinux 
inet_gro_receive
477479    4.1181  vmlinux                  vmlinux 
skb_gro_receive
406562    3.5065  vmlinux                  vmlinux 
free_hot_cold_page
396796    3.4222  vmlinux                  vmlinux 
tcp_gro_receive
332364    2.8665  vmlinux                  vmlinux 
__rmqueue_smallest
319455    2.7552  vmlinux                  vmlinux 
skb_gro_header
269040    2.3204  vmlinux                  vmlinux 
dev_gro_receive
252885    2.1810  vmlinux                  vmlinux 
free_pages_bulk
247832    2.1375  vmlinux                  vmlinux 
get_pageblock_flags_group
211592    1.8249  myri10ge.ko              myri10ge 
myri10ge_alloc_rx_pages
208867    1.8014  vmlinux                  vmlinux 
__list_add
201491    1.7378  vmlinux                  vmlinux 
tcp4_gro_receive
187591    1.6179  vmlinux                  vmlinux 
__napi_gro_receive
170156    1.4675  vmlinux                  vmlinux 
get_page_from_freelist
116321    1.0032  vmlinux                  vmlinux                  list_del
107994    0.9314  vmlinux                  vmlinux                  kfree
106434    0.9180  vmlinux                  vmlinux 
skb_copy_datagram_iovec
100675    0.8683  vmlinux                  vmlinux                  put_page

And is here is the opannotate -a output for a few GRO functions.  BTW, 
did you mean -s
rather than -a?   I'd naively think source might be more helpful.  But 
here is
what you asked for:

ffffffff80479f20 <inet_gro_receive>: /* inet_gro_receive total: 547572 
5.2554 */
  12187  0.1170 :ffffffff80479f20:       push   %r13
   2611  0.0251 :ffffffff80479f22:       mov    %rdi,%r13
                :ffffffff80479f25:       push   %r12
                :ffffffff80479f27:       push   %rbp
   4031  0.0387 :ffffffff80479f28:       push   %rbx
                :ffffffff80479f29:       mov    %rsi,%rbx
                :ffffffff80479f2c:       mov    $0x14,%esi
   6303  0.0605 :ffffffff80479f31:       mov    %rbx,%rdi
                :ffffffff80479f34:       sub    $0x8,%rsp
                :ffffffff80479f38:       callq  ffffffff804357a1 
<skb_gro_header>
                :ffffffff80479f3d:       test   %rax,%rax
   2494  0.0239 :ffffffff80479f40:       mov    %rax,%r8
                :ffffffff80479f43:       je     ffffffff8047a0a4 
<inet_gro_receive+0x184>
                :ffffffff80479f49:       movzbl 0x9(%rax),%eax
   2541  0.0244 :ffffffff80479f4d:       mov 
0xffffffff80d06280(,%rax,8),%r11
     33 3.2e-04 :ffffffff80479f55:       test   %r11,%r11
      5 4.8e-05 :ffffffff80479f58:       je     ffffffff8047a0a4 
<inet_gro_receive+0x184>
  11016  0.1057 :ffffffff80479f5e:       cmpq   $0x0,0x20(%r11)
    292  0.0028 :ffffffff80479f63:       je     ffffffff8047a0a4 
<inet_gro_receive+0x184>
      1 9.6e-06 :ffffffff80479f69:       cmpb   $0x45,(%r8)
   4297  0.0412 :ffffffff80479f6d:       jne    ffffffff8047a0a4 
<inet_gro_receive+0x184>
   6086  0.0584 :ffffffff80479f73:       mov    $0x5,%eax
                :ffffffff80479f78:       mov    %r8,%rcx
  18706  0.1795 :ffffffff80479f7b:       mov    (%rcx),%edx
    341  0.0033 :ffffffff80479f7d:       sub    $0x4,%eax
                :ffffffff80479f80:       jbe    ffffffff80479fa6 
<inet_gro_receive+0x86>
   4609  0.0442 :ffffffff80479f82:       add    0x4(%rcx),%edx
    398  0.0038 :ffffffff80479f85:       adc    0x8(%rcx),%edx
                :ffffffff80479f88:       adc    0xc(%rcx),%edx
   4310  0.0414 :ffffffff80479f8b:       adc    0x10(%rcx),%edx
    790  0.0076 :ffffffff80479f8e:       lea    0x4(%rcx),%rcx
                :ffffffff80479f92:       dec    %eax
   9097  0.0873 :ffffffff80479f94:       jne    ffffffff80479f8b 
<inet_gro_receive+0x6b>
    541  0.0052 :ffffffff80479f96:       adc    $0x0,%edx
                :ffffffff80479f99:       mov    %edx,%eax
   1919  0.0184 :ffffffff80479f9b:       shr    $0x10,%edx
    535  0.0051 :ffffffff80479f9e:       add    %ax,%dx
                :ffffffff80479fa1:       adc    $0x0,%edx
   3633  0.0349 :ffffffff80479fa4:       not    %edx
    683  0.0066 :ffffffff80479fa6:       test   %dx,%dx
      1 9.6e-06 :ffffffff80479fa9:       jne    ffffffff8047a0a4 
<inet_gro_receive+0x184>
   4725  0.0453 :ffffffff80479faf:       movzwl 0x2(%r8),%eax
   9728  0.0934 :ffffffff80479fb4:       mov    0x68(%rbx),%edx
      8 7.7e-05 :ffffffff80479fb7:       mov    $0x1,%ebp
  43000  0.4127 :ffffffff80479fbc:       sub    0x38(%rbx),%edx
  11149  0.1070 :ffffffff80479fbf:       mov    %eax,%ecx
                :ffffffff80479fc1:       shl    $0x8,%eax
  66497  0.6382 :ffffffff80479fc4:       shr    $0x8,%ecx
    735  0.0071 :ffffffff80479fc7:       or     %ecx,%eax
                :ffffffff80479fc9:       movzwl %ax,%eax
   5459  0.0524 :ffffffff80479fcc:       cmp    %edx,%eax
    522  0.0050 :ffffffff80479fce:       jne    ffffffff80479fdc 
<inet_gro_receive+0xbc>
                :ffffffff80479fd0:       xor    %ebp,%ebp
   5373  0.0516 :ffffffff80479fd2:       cmpw   $0x40,0x6(%r8)
    345  0.0033 :ffffffff80479fd8:       setne  %bpl
                :ffffffff80479fdc:       movzwl 0x4(%r8),%eax
   2384  0.0229 :ffffffff80479fe1:       mov    0x0(%r13),%r10
    631  0.0061 :ffffffff80479fe5:       mov    %eax,%edx
                :ffffffff80479fe7:       shl    $0x8,%eax
   3044  0.0292 :ffffffff80479fea:       shr    $0x8,%edx
    303  0.0029 :ffffffff80479fed:       or     %edx,%eax
                :ffffffff80479fef:       movzwl %ax,%r12d
   2747  0.0264 :ffffffff80479ff3:       jmp    ffffffff8047a071 
<inet_gro_receive+0x151>
   2109  0.0202 :ffffffff80479ff5:       lea    0x38(%r10),%r9
     12 1.2e-04 :ffffffff80479ff9:       cmpl   $0x0,0x4(%r9)
     23 2.2e-04 :ffffffff80479ffe:       je     ffffffff8047a06e 
<inet_gro_receive+0x14e>
   2104  0.0202 :ffffffff8047a000:       mov    0xac(%r10),%edi
      2 1.9e-05 :ffffffff8047a007:       add    0xc0(%r10),%rdi
                :ffffffff8047a00e:       mov    0x9(%rdi),%sil
   2391  0.0229 :ffffffff8047a012:       mov    0x1(%rdi),%al
      2 1.9e-05 :ffffffff8047a015:       xor    0x9(%r8),%sil
      7 6.7e-05 :ffffffff8047a019:       xor    0x1(%r8),%al
   2101  0.0202 :ffffffff8047a01d:       mov    0xc(%rdi),%edx
      1 9.6e-06 :ffffffff8047a020:       mov    0x10(%rdi),%ecx
                :ffffffff8047a023:       xor    0xc(%r8),%edx
   2775  0.0266 :ffffffff8047a027:       xor    0x10(%r8),%ecx
                :ffffffff8047a02b:       or     %esi,%eax
                :ffffffff8047a02d:       movzbl %al,%eax
  62734  0.6021 :ffffffff8047a030:       or     %edx,%ecx
                :ffffffff8047a032:       or     %eax,%ecx
                :ffffffff8047a034:       je     ffffffff8047a040 
<inet_gro_receive+0x120>
                :ffffffff8047a036:       movl   $0x0,0x4(%r9)
                :ffffffff8047a03e:       jmp    ffffffff8047a06e 
<inet_gro_receive+0x14e>
   2106  0.0202 :ffffffff8047a040:       movzwl 0x4(%rdi),%edx
                :ffffffff8047a044:       mov    0x8(%rdi),%al
                :ffffffff8047a047:       xor    0x8(%r8),%eax
  64244  0.6166 :ffffffff8047a04b:       mov    %edx,%ecx
                :ffffffff8047a04d:       shl    $0x8,%edx
                :ffffffff8047a050:       shr    $0x8,%ecx
   2072  0.0199 :ffffffff8047a053:       movzbl %al,%eax
                :ffffffff8047a056:       or     0x8(%r9),%eax
                :ffffffff8047a05a:       or     %ecx,%edx
   2629  0.0252 :ffffffff8047a05c:       add    0xc(%r9),%edx
      2 1.9e-05 :ffffffff8047a060:       movzwl %dx,%edx
                :ffffffff8047a063:       xor    %r12d,%edx
  58223  0.5588 :ffffffff8047a066:       or     %edx,%eax
      3 2.9e-05 :ffffffff8047a068:       or     %ebp,%eax
                :ffffffff8047a06a:       mov    %eax,0x8(%r9)
  21878  0.2100 :ffffffff8047a06e:       mov    (%r10),%r10
   2156  0.0207 :ffffffff8047a071:       test   %r10,%r10
                :ffffffff8047a074:       jne    ffffffff80479ff5 
<inet_gro_receive+0xd5>
   3007  0.0289 :ffffffff8047a07a:       mov    0x38(%rbx),%eax
     61 5.9e-04 :ffffffff8047a07d:       or     %ebp,0x40(%rbx)
      3 2.9e-05 :ffffffff8047a080:       mov    %rbx,%rsi
   3091  0.0297 :ffffffff8047a083:       mov    %r13,%rdi
     41 3.9e-04 :ffffffff8047a086:       add    $0x14,%eax
                :ffffffff8047a089:       mov    %eax,0x38(%rbx)
   3704  0.0355 :ffffffff8047a08c:       sub    0xc0(%rbx),%eax
     33 3.2e-04 :ffffffff8047a092:       add    0xc8(%rbx),%eax
                :ffffffff8047a098:       mov    %eax,0xa8(%rbx)
   2468  0.0237 :ffffffff8047a09e:       callq  *0x20(%r11)
  20011  0.1921 :ffffffff8047a0a2:       jmp    ffffffff8047a0ab 
<inet_gro_receive+0x18b>
                :ffffffff8047a0a4:       xor    %eax,%eax
                :ffffffff8047a0a6:       mov    $0x1,%ebp
  24082  0.2311 :ffffffff8047a0ab:       or     %ebp,0x40(%rbx)
    626  0.0060 :ffffffff8047a0ae:       pop    %r10
   1718  0.0165 :ffffffff8047a0b0:       pop    %rbx
    446  0.0043 :ffffffff8047a0b1:       pop    %rbp
   4074  0.0391 :ffffffff8047a0b2:       pop    %r12
   2089  0.0200 :ffffffff8047a0b4:       pop    %r13
    434  0.0042 :ffffffff8047a0b6:       retq




ffffffff80430ea9 <skb_gro_receive>: /* skb_gro_receive total: 477479 
4.5827 */
   2158  0.0207 :ffffffff80430ea9:       push   %r15
   2492  0.0239 :ffffffff80430eab:       mov    %rdi,%r15
                :ffffffff80430eae:       push   %r14
                :ffffffff80430eb0:       push   %r13
   2432  0.0233 :ffffffff80430eb2:       push   %r12
      1 9.6e-06 :ffffffff80430eb4:       push   %rbp
      1 9.6e-06 :ffffffff80430eb5:       mov    %rsi,%rbp
   2430  0.0233 :ffffffff80430eb8:       push   %rbx
                :ffffffff80430eb9:       sub    $0x8,%rsp
                :ffffffff80430ebd:       mov    0x68(%rsi),%ecx
   2420  0.0232 :ffffffff80430ec0:       mov    (%rdi),%r12
      1 9.6e-06 :ffffffff80430ec3:       mov    %ecx,%r14d
      1 9.6e-06 :ffffffff80430ec6:       sub    0x38(%rsi),%r14d
   2317  0.0222 :ffffffff80430eca:       mov    %r14d,%eax
      1 9.6e-06 :ffffffff80430ecd:       add    0x68(%r12),%eax
      1 9.6e-06 :ffffffff80430ed2:       cmp    $0xffff,%eax
   3865  0.0371 :ffffffff80430ed7:       ja     ffffffff80431261 
<skb_gro_receive+0x3b8>
                :ffffffff80430edd:       mov    0xb8(%r12),%eax
                :ffffffff80430ee5:       mov    0xc0(%r12),%rdx
   8082  0.0776 :ffffffff80430eed:       lea    (%rdx,%rax,1),%rsi
                :ffffffff80430ef1:       cmpq   $0x0,0x18(%rsi)
      2 1.9e-05 :ffffffff80430ef6:       jne    ffffffff804311ab 
<skb_gro_receive+0x302>
   9249  0.0888 :ffffffff80430efc:       mov    %ecx,%edi
                :ffffffff80430efe:       sub    0x6c(%rbp),%edi
      6 5.8e-05 :ffffffff80430f01:       cmp    0x38(%rbp),%edi
   3104  0.0298 :ffffffff80430f04:       ja     ffffffff80430fe2 
<skb_gro_receive+0x139>
      2 1.9e-05 :ffffffff80430f0a:       mov    0xb8(%rbp),%ecx
                :ffffffff80430f10:       movzwl 0x4(%rsi),%edx
   8825  0.0847 :ffffffff80430f14:       add    0xc0(%rbp),%rcx
                :ffffffff80430f1b:       movzwl 0x4(%rcx),%eax
     21 2.0e-04 :ffffffff80430f1f:       add    %edx,%eax
  19668  0.1888 :ffffffff80430f21:       cmp    $0x12,%eax
      1 9.6e-06 :ffffffff80430f24:       ja     ffffffff80431261 
<skb_gro_receive+0x3b8>
                :ffffffff80430f2a:       mov    0x38(%rcx),%eax
   1974  0.0189 :ffffffff80430f2d:       add    0x38(%rbp),%eax
                :ffffffff80430f30:       cld
                :ffffffff80430f31:       sub    %edi,%eax
   7666  0.0736 :ffffffff80430f33:       mov    %eax,0x38(%rcx)
      2 1.9e-05 :ffffffff80430f36:       mov    0xb8(%rbp),%edx
                :ffffffff80430f3c:       add    0xc0(%rbp),%rdx
  52468  0.5036 :ffffffff80430f43:       mov    0x3c(%rdx),%eax
      2 1.9e-05 :ffffffff80430f46:       add    0x68(%rbp),%eax
      1 9.6e-06 :ffffffff80430f49:       sub    0x6c(%rbp),%eax
   6592  0.0633 :ffffffff80430f4c:       sub    0x38(%rbp),%eax
                :ffffffff80430f4f:       mov    %eax,0x3c(%rdx)
                :ffffffff80430f52:       mov    0xb8(%r12),%eax
  23018  0.2209 :ffffffff80430f5a:       add    0xc0(%r12),%rax
      1 9.6e-06 :ffffffff80430f62:       mov    0xb8(%rbp),%esi
                :ffffffff80430f68:       add    0xc0(%rbp),%rsi
   8477  0.0814 :ffffffff80430f6f:       movzwl 0x4(%rax),%edi
      6 5.8e-05 :ffffffff80430f73:       movzwl 0x4(%rsi),%ecx
                :ffffffff80430f77:       add    $0x30,%rsi
  21338  0.2048 :ffffffff80430f7b:       shl    $0x4,%rdi
      3 2.9e-05 :ffffffff80430f7f:       lea    0x30(%rdi,%rax,1),%rdi
      1 9.6e-06 :ffffffff80430f84:       shl    $0x4,%rcx
150632  1.4457 :ffffffff80430f88:       rep movsb %ds:(%rsi),%es:(%rdi)
   3988  0.0383 :ffffffff80430f8a:       mov    0xb8(%r12),%eax
   2015  0.0193 :ffffffff80430f92:       mov    0xb8(%rbp),%ecx
     11 1.1e-04 :ffffffff80430f98:       add    0xc0(%r12),%rax
      8 7.7e-05 :ffffffff80430fa0:       mov    0xc0(%rbp),%rdx
   3295  0.0316 :ffffffff80430fa7:       mov    0x4(%rdx,%rcx,1),%edx
                :ffffffff80430fab:       add    %dx,0x4(%rax)
      8 7.7e-05 :ffffffff80430faf:       mov    0xb8(%rbp),%edx
   2507  0.0241 :ffffffff80430fb5:       mov    0xc0(%rbp),%rax
                :ffffffff80430fbc:       movw   $0x0,0x4(%rax,%rdx,1)
   3233  0.0310 :ffffffff80430fc3:       mov    0x6c(%rbp),%eax
      1 9.6e-06 :ffffffff80430fc6:       sub    %eax,0xd0(%rbp)
                :ffffffff80430fcc:       sub    %eax,0x68(%rbp)
  41540  0.3987 :ffffffff80430fcf:       movl   $0x0,0x6c(%rbp)
                :ffffffff80430fd6:       movl   $0x1,0x48(%rbp)
                :ffffffff80430fdd:       jmpq   ffffffff8043123f 
<skb_gro_receive+0x396>
                :ffffffff80430fe2:       mov    0xc8(%r12),%rax
                :ffffffff80430fea:       mov    0x20(%r12),%rdi
                :ffffffff80430fef:       mov    %eax,%r13d
                :ffffffff80430ff2:       sub    %edx,%r13d
                :ffffffff80430ff5:       mov    $0x20,%edx
                :ffffffff80430ffa:       mov    %r13d,%esi
                :ffffffff80430ffd:       add    0x38(%r12),%esi
                :ffffffff80431002:       callq  ffffffff8042ffe0 
<__netdev_alloc_skb>
                :ffffffff80431007:       mov    %rax,%rbx
                :ffffffff8043100a:       mov    $0xfffffff4,%eax
                :ffffffff8043100f:       test   %rbx,%rbx
                :ffffffff80431012:       je     ffffffff80431266 
<skb_gro_receive+0x3bd>
                :ffffffff80431018:       mov    %r12,%rsi
                :ffffffff8043101b:       mov    %rbx,%rdi
                :ffffffff8043101e:       callq  ffffffff8042e2c0 
<__copy_skb_header>
                :ffffffff80431023:       mov    0x70(%r12),%eax
                :ffffffff80431028:       add    %r13d,0xb4(%rbx)
                :ffffffff8043102f:       mov    %ax,0x70(%rbx)
                :ffffffff80431033:       movslq %r13d,%rax
                :ffffffff80431036:       add    %rax,0xc8(%rbx)
                :ffffffff8043103d:       cmpl   $0x0,0x6c(%rbx)
                :ffffffff80431041:       mov    0x38(%r12),%edx
                :ffffffff80431046:       mov    0xb4(%rbx),%eax
                :ffffffff8043104c:       je     ffffffff80431052 
<skb_gro_receive+0x1a9>
                :ffffffff8043104e:       ud2a
                :ffffffff80431050:       jmp    ffffffff80431050 
<skb_gro_receive+0x1a7>
                :ffffffff80431052:       lea    (%rdx,%rax,1),%eax
                :ffffffff80431055:       add    %edx,0x68(%rbx)
                :ffffffff80431058:       mov    0xc8(%r12),%rcx
                :ffffffff80431060:       mov    0xc8(%rbx),%rdx
                :ffffffff80431067:       sub    0xc0(%rbx),%edx
                :ffffffff8043106d:       mov    %eax,0xb4(%rbx)
                :ffffffff80431073:       mov    0xb0(%r12),%eax
                :ffffffff8043107b:       add    0xc0(%r12),%rax
                :ffffffff80431083:       sub    %ecx,%eax
                :ffffffff80431085:       add    %edx,%eax
                :ffffffff80431087:       mov    %eax,0xb0(%rbx)
                :ffffffff8043108d:       mov    0xac(%r12),%eax
                :ffffffff80431095:       add    0xc0(%r12),%rax
                :ffffffff8043109d:       sub    %ecx,%eax
                :ffffffff8043109f:       add    %edx,%eax
                :ffffffff804310a1:       mov    %eax,0xac(%rbx)
                :ffffffff804310a7:       mov    0xa8(%r12),%eax
                :ffffffff804310af:       add    0xc0(%r12),%rax
                :ffffffff804310b7:       sub    %ecx,%eax
                :ffffffff804310b9:       add    %edx,%eax
                :ffffffff804310bb:       mov    %eax,0xa8(%rbx)
                :ffffffff804310c1:       mov    0x68(%r12),%eax
                :ffffffff804310c6:       mov    0x38(%r12),%edx
                :ffffffff804310cb:       sub    %edx,%eax
                :ffffffff804310cd:       cmp    0x6c(%r12),%eax
                :ffffffff804310d2:       mov    %eax,0x68(%r12)
                :ffffffff804310d7:       jae    ffffffff804310dd 
<skb_gro_receive+0x234>
                :ffffffff804310d9:       ud2a
                :ffffffff804310db:       jmp    ffffffff804310db 
<skb_gro_receive+0x232>
                :ffffffff804310dd:       mov    0xb0(%r12),%esi
                :ffffffff804310e5:       mov    %edx,%ecx
                :ffffffff804310e7:       add    0xc8(%r12),%rcx
                :ffffffff804310ef:       add    0xc0(%r12),%rsi
                :ffffffff804310f7:       mov    0xb0(%rbx),%edi
                :ffffffff804310fd:       add    0xc0(%rbx),%rdi
                :ffffffff80431104:       cld
                :ffffffff80431105:       mov    %rcx,0xc8(%r12)
                :ffffffff8043110d:       sub    %rsi,%rcx
                :ffffffff80431110:       rep movsb %ds:(%rsi),%es:(%rdi)
                :ffffffff80431112:       lea    0x38(%rbx),%rdi
                :ffffffff80431116:       lea    0x38(%r12),%rsi
                :ffffffff8043111b:       mov    $0x5,%cl
                :ffffffff8043111d:       rep movsl %ds:(%rsi),%es:(%rdi)
                :ffffffff8043111f:       mov    0xb8(%rbx),%edx
                :ffffffff80431125:       mov    0xc0(%rbx),%rax
                :ffffffff8043112c:       mov    %r12,0x18(%rax,%rdx,1)
                :ffffffff80431131:       mov    0xb8(%r12),%edx
                :ffffffff80431139:       mov    0xc0(%r12),%rax
                :ffffffff80431141:       mov    0xb8(%rbx),%esi
                :ffffffff80431147:       mov    0xc0(%rbx),%rcx
                :ffffffff8043114e:       mov    0x6(%rax,%rdx,1),%ax
                :ffffffff80431153:       mov    %ax,0x6(%rcx,%rsi,1)
                :ffffffff80431158:       testb  $0x10,0x7c(%r12)
                :ffffffff8043115e:       je     ffffffff80431164 
<skb_gro_receive+0x2bb>
                :ffffffff80431160:       ud2a
                :ffffffff80431162:       jmp    ffffffff80431162 
<skb_gro_receive+0x2b9>
                :ffffffff80431164:       mov    0xb8(%r12),%eax
                :ffffffff8043116c:       orb    $0x10,0x7c(%r12)
                :ffffffff80431172:       add    0xc0(%r12),%rax
                :ffffffff8043117a:       lock addl $0x10000,(%rax)
                :ffffffff80431181:       mov    0x68(%r12),%eax
                :ffffffff80431186:       mov    %r12,0x8(%rbx)
                :ffffffff8043118a:       add    %eax,0x6c(%rbx)
                :ffffffff8043118d:       add    %eax,0xd0(%rbx)
                :ffffffff80431193:       add    %eax,0x68(%rbx)
                :ffffffff80431196:       mov    %rbx,(%r15)
                :ffffffff80431199:       mov    (%r12),%rax
                :ffffffff8043119d:       mov    %rax,(%rbx)
                :ffffffff804311a0:       movq   $0x0,(%r12)
                :ffffffff804311a8:       mov    %rbx,%r12
                :ffffffff804311ab:       mov    0x68(%rbp),%ecx
                :ffffffff804311ae:       sub    0x6c(%rbp),%ecx
                :ffffffff804311b1:       cmp    %ecx,0x38(%rbp)
                :ffffffff804311b4:       jbe    ffffffff804311f3 
<skb_gro_receive+0x34a>
                :ffffffff804311b6:       mov    0xb8(%rbp),%edx
                :ffffffff804311bc:       add    0xc0(%rbp),%rdx
                :ffffffff804311c3:       mov    0x38(%rdx),%eax
                :ffffffff804311c6:       add    0x38(%rbp),%eax
                :ffffffff804311c9:       sub    %ecx,%eax
                :ffffffff804311cb:       mov    %eax,0x38(%rdx)
                :ffffffff804311ce:       mov    0xb8(%rbp),%edx
                :ffffffff804311d4:       add    0xc0(%rbp),%rdx
                :ffffffff804311db:       mov    0x3c(%rdx),%eax
                :ffffffff804311de:       add    0x68(%rbp),%eax
                :ffffffff804311e1:       sub    0x6c(%rbp),%eax
                :ffffffff804311e4:       sub    0x38(%rbp),%eax
                :ffffffff804311e7:       mov    %eax,0x3c(%rdx)
                :ffffffff804311ea:       mov    0x68(%rbp),%eax
                :ffffffff804311ed:       sub    0x6c(%rbp),%eax
                :ffffffff804311f0:       mov    %eax,0x38(%rbp)
                :ffffffff804311f3:       mov    0x68(%rbp),%eax
                :ffffffff804311f6:       mov    0x38(%rbp),%edx
                :ffffffff804311f9:       sub    %edx,%eax
                :ffffffff804311fb:       cmp    0x6c(%rbp),%eax
                :ffffffff804311fe:       mov    %eax,0x68(%rbp)
                :ffffffff80431201:       jae    ffffffff80431207 
<skb_gro_receive+0x35e>
                :ffffffff80431203:       ud2a
                :ffffffff80431205:       jmp    ffffffff80431205 
<skb_gro_receive+0x35c>
                :ffffffff80431207:       mov    %edx,%eax
                :ffffffff80431209:       add    %rax,0xc8(%rbp)
                :ffffffff80431210:       mov    0x8(%r12),%rax
                :ffffffff80431215:       mov    %rbp,0x8(%r12)
                :ffffffff8043121a:       mov    %rbp,(%rax)
                :ffffffff8043121d:       testb  $0x10,0x7c(%rbp)
                :ffffffff80431221:       je     ffffffff80431227 
<skb_gro_receive+0x37e>
                :ffffffff80431223:       ud2a
                :ffffffff80431225:       jmp    ffffffff80431225 
<skb_gro_receive+0x37c>
                :ffffffff80431227:       mov    0xb8(%rbp),%eax
                :ffffffff8043122d:       orb    $0x10,0x7c(%rbp)
                :ffffffff80431231:       add    0xc0(%rbp),%rax
                :ffffffff80431238:       lock addl $0x10000,(%rax)
  34919  0.3351 :ffffffff8043123f:       add    %r14d,0x6c(%r12)
   1989  0.0191 :ffffffff80431244:       add    %r14d,0xd0(%r12)
      1 9.6e-06 :ffffffff8043124c:       xor    %eax,%eax
                :ffffffff8043124e:       add    %r14d,0x68(%r12)
  20605  0.1978 :ffffffff80431253:       incl   0x44(%r12)
                :ffffffff80431258:       movl   $0x1,0x3c(%rbp)
                :ffffffff8043125f:       jmp    ffffffff80431266 
<skb_gro_receive+0x3bd>
                :ffffffff80431261:       mov    $0xfffffff9,%eax
  13260  0.1273 :ffffffff80431266:       pop    %r11
   1946  0.0187 :ffffffff80431268:       pop    %rbx
   2010  0.0193 :ffffffff80431269:       pop    %rbp
     64 6.1e-04 :ffffffff8043126a:       pop    %r12
   1948  0.0187 :ffffffff8043126c:       pop    %r13
   2746  0.0264 :ffffffff8043126e:       pop    %r14
     57 5.5e-04 :ffffffff80431270:       pop    %r15
   2067  0.0198 :ffffffff80431272:       retq

ffffffff80460663 <tcp_gro_receive>: /* tcp_gro_receive total: 396796 
3.8083 */
   4433  0.0425 :ffffffff80460663:       push   %r15
   2204  0.0212 :ffffffff80460665:       push   %r14
                :ffffffff80460667:       mov    %rdi,%r14
                :ffffffff8046066a:       push   %r13
   2275  0.0218 :ffffffff8046066c:       push   %r12
                :ffffffff8046066e:       mov    %rsi,%r12
                :ffffffff80460671:       mov    $0x14,%esi
   5933  0.0569 :ffffffff80460676:       mov    %r12,%rdi
                :ffffffff80460679:       push   %rbp
                :ffffffff8046067a:       push   %rbx
   2180  0.0209 :ffffffff8046067b:       sub    $0x8,%rsp
                :ffffffff8046067f:       callq  ffffffff804357a1 
<skb_gro_header>
                :ffffffff80460684:       test   %rax,%rax
   3218  0.0309 :ffffffff80460687:       je     ffffffff804607ed 
<tcp_gro_receive+0x18a>
                :ffffffff8046068d:       mov    0xc(%rax),%al
      1 9.6e-06 :ffffffff80460690:       shr    $0x4,%al
   3528  0.0339 :ffffffff80460693:       movzbl %al,%eax
                :ffffffff80460696:       lea    0x0(,%rax,4),%r13d
      1 9.6e-06 :ffffffff8046069e:       cmp    $0x13,%r13d
   2773  0.0266 :ffffffff804606a2:       jbe    ffffffff804607ed 
<tcp_gro_receive+0x18a>
                :ffffffff804606a8:       mov    %r13d,%esi
                :ffffffff804606ab:       mov    %r12,%rdi
   3327  0.0319 :ffffffff804606ae:       callq  ffffffff804357a1 
<skb_gro_header>
                :ffffffff804606b3:       test   %rax,%rax
   2094  0.0201 :ffffffff804606b6:       mov    %rax,%r8
                :ffffffff804606b9:       je     ffffffff804607ed 
<tcp_gro_receive+0x18a>
                :ffffffff804606bf:       lea    0x38(%r12),%r15
   2245  0.0215 :ffffffff804606c4:       add    %r13d,(%r15)
                :ffffffff804606c7:       mov    0x68(%r12),%ebp
                :ffffffff804606cc:       sub    0x38(%r12),%ebp
   2394  0.0230 :ffffffff804606d1:       mov    0xc(%rax),%ebx
                :ffffffff804606d4:       jmp    ffffffff80460710 
<tcp_gro_receive+0xad>
   2111  0.0203 :ffffffff804606d6:       lea    0x38(%rdi),%r9
      3 2.9e-05 :ffffffff804606da:       cmpl   $0x0,0x4(%r9)
     21 2.0e-04 :ffffffff804606df:       je     ffffffff8046070d 
<tcp_gro_receive+0xaa>
   2592  0.0249 :ffffffff804606e1:       mov    0xa8(%rdi),%eax
                :ffffffff804606e7:       mov    0xc0(%rdi),%r10
                :ffffffff804606ee:       mov    0x2(%r8),%dx
   2440  0.0234 :ffffffff804606f3:       lea    (%r10,%rax,1),%rcx
                :ffffffff804606f7:       mov    (%r8),%eax
      1 9.6e-06 :ffffffff804606fa:       xor    0x2(%rcx),%dx
   6275  0.0602 :ffffffff804606fe:       xor    (%rcx),%eax
      3 2.9e-05 :ffffffff80460700:       or     %ax,%dx
                :ffffffff80460703:       je     ffffffff8046071d 
<tcp_gro_receive+0xba>
                :ffffffff80460705:       movl   $0x0,0x4(%r9)
                :ffffffff8046070d:       mov    %rdi,%r14
   2920  0.0280 :ffffffff80460710:       mov    (%r14),%rdi
     18 1.7e-04 :ffffffff80460713:       test   %rdi,%rdi
      2 1.9e-05 :ffffffff80460716:       jne    ffffffff804606d6 
<tcp_gro_receive+0x73>
     33 3.2e-04 :ffffffff80460718:       jmpq   ffffffff80460807 
<tcp_gro_receive+0x1a4>
   4253  0.0408 :ffffffff8046071d:       mov    0xe(%r8),%ax
   2125  0.0204 :ffffffff80460722:       xor    0xe(%rcx),%ax
      2 1.9e-05 :ffffffff80460726:       mov    %ebx,%edx
                :ffffffff80460728:       and    $0x8000,%edx
   8066  0.0774 :ffffffff8046072e:       or     0x8(%r9),%edx
                :ffffffff80460732:       movzwl %ax,%esi
                :ffffffff80460735:       mov    0x8(%r8),%eax
  64740  0.6214 :ffffffff80460739:       xor    0x8(%rcx),%eax
                :ffffffff8046073c:       or     %eax,%esi
                :ffffffff8046073e:       mov    %ebx,%eax
   2084  0.0200 :ffffffff80460740:       xor    0xc(%rcx),%eax
                :ffffffff80460743:       and    $0x76,%ah
                :ffffffff80460746:       or     %eax,%edx
   2132  0.0205 :ffffffff80460748:       or     %edx,%esi
                :ffffffff8046074a:       mov    $0x14,%edx
                :ffffffff8046074f:       jmp    ffffffff8046075e 
<tcp_gro_receive+0xfb>
                :ffffffff80460751:       movslq %edx,%rax
                :ffffffff80460754:       add    $0x4,%edx
                :ffffffff80460757:       mov    (%r8,%rax,1),%esi
                :ffffffff8046075b:       xor    (%rcx,%rax,1),%esi
   3670  0.0352 :ffffffff8046075e:       test   %esi,%esi
   2162  0.0208 :ffffffff80460760:       jne    ffffffff80460767 
<tcp_gro_receive+0x104>
                :ffffffff80460762:       cmp    %r13d,%edx
      1 9.6e-06 :ffffffff80460765:       jb     ffffffff80460751 
<tcp_gro_receive+0xee>
  50209  0.4819 :ffffffff80460767:       mov    0xb8(%rdi),%eax
   4473  0.0429 :ffffffff8046076d:       mov    0x4(%rcx),%edx
                :ffffffff80460770:       bswap  %edx
   9554  0.0917 :ffffffff80460772:       mov    0x4(%r8),%ecx
                :ffffffff80460776:       bswap  %ecx
                :ffffffff80460778:       movzwl 0x6(%r10,%rax,1),%r13d
   7572  0.0727 :ffffffff8046077e:       mov    0x68(%rdi),%eax
                :ffffffff80460781:       sub    0x38(%rdi),%eax
                :ffffffff80460784:       add    %edx,%eax
   9803  0.0941 :ffffffff80460786:       xor    %eax,%ecx
                :ffffffff80460788:       cmp    %r13d,%ebp
                :ffffffff8046078b:       seta   %al
  50608  0.4857 :ffffffff8046078e:       test   %ebp,%ebp
                :ffffffff80460790:       sete   %dl
                :ffffffff80460793:       or     %edx,%eax
   3161  0.0303 :ffffffff80460795:       movzbl %al,%eax
                :ffffffff80460798:       or     %eax,%esi
                :ffffffff8046079a:       or     %esi,%ecx
   3278  0.0315 :ffffffff8046079c:       jne    ffffffff804607f6 
<tcp_gro_receive+0x193>
                :ffffffff8046079e:       mov    %r12,%rsi
      2 1.9e-05 :ffffffff804607a1:       mov    %r14,%rdi
   2579  0.0248 :ffffffff804607a4:       callq  ffffffff80430ea9 
<skb_gro_receive>
   2059  0.0198 :ffffffff804607a9:       test   %eax,%eax
     49 4.7e-04 :ffffffff804607ab:       jne    ffffffff804607f6 
<tcp_gro_receive+0x193>
                :ffffffff804607ad:       mov    (%r14),%rcx
   1945  0.0187 :ffffffff804607b0:       mov    %ebx,%edx
      3 2.9e-05 :ffffffff804607b2:       and    $0x900,%edx
                :ffffffff804607b8:       mov    0xa8(%rcx),%eax
   2530  0.0243 :ffffffff804607be:       add    0xc0(%rcx),%rax
      3 2.9e-05 :ffffffff804607c5:       or     %edx,0xc(%rax)
     13 1.2e-04 :ffffffff804607c8:       xor    %eax,%eax
   4881  0.0468 :ffffffff804607ca:       cmp    %r13d,%ebp
                :ffffffff804607cd:       setb   %al
                :ffffffff804607d0:       and    $0x2f00,%ebx
   1912  0.0184 :ffffffff804607d6:       or     %ebx,%eax
                :ffffffff804607d8:       test   %rcx,%rcx
                :ffffffff804607db:       je     ffffffff80460816 
<tcp_gro_receive+0x1b3>
   2163  0.0208 :ffffffff804607dd:       cmpl   $0x0,0x4(%r15)
    136  0.0013 :ffffffff804607e2:       je     ffffffff804607e8 
<tcp_gro_receive+0x185>
   2455  0.0236 :ffffffff804607e4:       test   %eax,%eax
     57 5.5e-04 :ffffffff804607e6:       je     ffffffff80460816 
<tcp_gro_receive+0x1b3>
    148  0.0014 :ffffffff804607e8:       mov    %r14,%rdi
    735  0.0071 :ffffffff804607eb:       jmp    ffffffff80460818 
<tcp_gro_receive+0x1b5>
                :ffffffff804607ed:       xor    %edi,%edi
                :ffffffff804607ef:       mov    $0x1,%eax
                :ffffffff804607f4:       jmp    ffffffff80460818 
<tcp_gro_receive+0x1b5>
     68 6.5e-04 :ffffffff804607f6:       xor    %eax,%eax
      1 9.6e-06 :ffffffff804607f8:       test   %ebp,%ebp
     67 6.4e-04 :ffffffff804607fa:       sete   %al
     47 4.5e-04 :ffffffff804607fd:       and    $0x2f00,%ebx
                :ffffffff80460803:       or     %ebx,%eax
     58 5.6e-04 :ffffffff80460805:       jmp    ffffffff804607dd 
<tcp_gro_receive+0x17a>
    122  0.0012 :ffffffff80460807:       xor    %eax,%eax
      9 8.6e-05 :ffffffff80460809:       test   %ebp,%ebp
                :ffffffff8046080b:       sete   %al
     67 6.4e-04 :ffffffff8046080e:       and    $0x2f00,%ebx
      6 5.8e-05 :ffffffff80460814:       or     %ebx,%eax
   1995  0.0191 :ffffffff80460816:       xor    %edi,%edi
     68 6.5e-04 :ffffffff80460818:       or     %eax,0x40(%r12)
    275  0.0026 :ffffffff8046081d:       mov    %rdi,%rax
   2037  0.0196 :ffffffff80460820:       pop    %r11
    191  0.0018 :ffffffff80460822:       pop    %rbx
   4346  0.0417 :ffffffff80460823:       pop    %rbp
   4739  0.0455 :ffffffff80460824:       pop    %r12
    167  0.0016 :ffffffff80460826:       pop    %r13
  23735  0.2278 :ffffffff80460828:       pop    %r14
  56070  0.5381 :ffffffff8046082a:       pop    %r15
    140  0.0013 :ffffffff8046082c:       retq

ffffffff804357a1 <skb_gro_header>: /* skb_gro_header total: 319455 
3.0660 */
  13604  0.1306 :ffffffff804357a1:       push   %rbp
  14938  0.1434 :ffffffff804357a2:       push   %rbx
                :ffffffff804357a3:       mov    %rdi,%rbx
                :ffffffff804357a6:       sub    $0x8,%rsp
  18392  0.1765 :ffffffff804357aa:       mov    0x38(%rdi),%ebp
                :ffffffff804357ad:       mov    0x68(%rdi),%edx
      1 9.6e-06 :ffffffff804357b0:       add    %ebp,%esi
  20559  0.1973 :ffffffff804357b2:       mov    %edx,%edi
                :ffffffff804357b4:       sub    0x6c(%rbx),%edi
                :ffffffff804357b7:       jne    ffffffff804357cc 
<skb_gro_header+0x2b>
  36626  0.3515 :ffffffff804357b9:       mov    0xb8(%rbx),%ecx
      2 1.9e-05 :ffffffff804357bf:       mov    0xc0(%rbx),%rax
      3 2.9e-05 :ffffffff804357c6:       cmp    %esi,0x3c(%rax,%rcx,1)
  18577  0.1783 :ffffffff804357ca:       jae    ffffffff804357ee 
<skb_gro_header+0x4d>
                :ffffffff804357cc:       cmp    %edi,%esi
                :ffffffff804357ce:       jbe    ffffffff804357e3 
<skb_gro_header+0x42>
                :ffffffff804357d0:       cmp    %edx,%esi
                :ffffffff804357d2:       ja     ffffffff80435833 
<skb_gro_header+0x92>
                :ffffffff804357d4:       sub    %edi,%esi
                :ffffffff804357d6:       mov    %rbx,%rdi
                :ffffffff804357d9:       callq  ffffffff8042f6ee 
<__pskb_pull_tail>
                :ffffffff804357de:       test   %rax,%rax
                :ffffffff804357e1:       je     ffffffff80435833 
<skb_gro_header+0x92>
                :ffffffff804357e3:       mov    %ebp,%eax
                :ffffffff804357e5:       add    0xc8(%rbx),%rax
                :ffffffff804357ec:       jmp    ffffffff80435835 
<skb_gro_header+0x94>
      3 2.9e-05 :ffffffff804357ee:       add    0xc0(%rbx),%rcx
  25999  0.2495 :ffffffff804357f5:       mov    $0x1e0000000000,%rax
                :ffffffff804357ff:       mov    $0x6db6db6db6db6db7,%rdx
  44557  0.4276 :ffffffff80435809:       add    0x30(%rcx),%rax
                :ffffffff8043580d:       sar    $0x3,%rax
  12588  0.1208 :ffffffff80435811:       imul   %rdx,%rax
  10104  0.0970 :ffffffff80435815:       mov    $0xffff880000000000,%rdx
                :ffffffff8043581f:       shl    $0xc,%rax
                :ffffffff80435823:       add    %rdx,%rax
  16404  0.1574 :ffffffff80435826:       mov    0x38(%rcx),%edx
                :ffffffff80435829:       add    %rdx,%rax
                :ffffffff8043582c:       mov    %ebp,%edx
  15264  0.1465 :ffffffff8043582e:       add    %rdx,%rax
                :ffffffff80435831:       jmp    ffffffff80435835 
<skb_gro_header+0x94>
                :ffffffff80435833:       xor    %eax,%eax
  45844  0.4400 :ffffffff80435835:       pop    %r10
      2 1.9e-05 :ffffffff80435837:       pop    %rbx
  12844  0.1233 :ffffffff80435838:       pop    %rbp
  13144  0.1262 :ffffffff80435839:       retq

Thanks for your help,

Drew
