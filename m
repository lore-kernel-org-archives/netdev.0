From: Chris Mason <clm@fb.com>
Subject: Re: crash in __kfree_skb on v3.18-rc5 with CONFIG_DEBUG_PAGEALLOC
Date: Fri, 21 Nov 2014 11:57:39 -0500
Message-ID: <1416589059.24312.7@mail.thefacebook.com>
References: <20141121160937.GA32608@ret.masoncoding.com>
	<1416587469.8629.106.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39123 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932347AbaKUQ5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 11:57:50 -0500
In-Reply-To: <1416587469.8629.106.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2014 at 11:31 AM, Eric Dumazet <eric.dumazet@gmail.com> 
wrote:
> On Fri, 2014-11-21 at 11:16 -0500, Chris Mason wrote:
>>  Hi everyone,
>> 
>>  I've hit this a few times today while hammering on my btrfs queue 
>> for
>>  the next merge window.  It's plain v3.18-rc5 plus a few btrfs 
>> patches,
>>  so it isn't impossible a btrfs double free is causing trouble.
>> 
>>  But, that should also show up in places outside the networking 
>> stack and I've
>>  gotten this exact stack trace twice now:
>> 
>>  [ 2255.152925] BUG: unable to handle kernel paging request at 
>> ffff880fa1f91f96
>>  [ 2255.185251]  [<ffffffff81595f68>] __kfree_skb+0x58/0xc0Hi Chris
> 
> Can you double check, or send whole __kfree_skb() disassembly ?
> 
> I do not understand how skb->fclone could possibly trap _at_ this 
> point.

So I double checked and got worried about the orb instruction until I 
realized fclone is in a bitfield:

Dump of assembler code for function __kfree_skb:
   0xffffffff81595f10 <+0>:	push   %rbp
   0xffffffff81595f11 <+1>:	mov    %rsp,%rbp
   0xffffffff81595f14 <+4>:	push   %rbx
   0xffffffff81595f15 <+5>:	sub    $0x8,%rsp
   0xffffffff81595f19 <+9>:	callq  0xffffffff81672c40 <mcount>
   0xffffffff81595f1e <+14>:	mov    %rdi,%rbx
   0xffffffff81595f21 <+17>:	callq  0xffffffff81595ee0 <skb_release_all>
   0xffffffff81595f26 <+22>:	movzbl 0x7e(%rbx),%eax
   0xffffffff81595f2a <+26>:	shr    $0x2,%al
   0xffffffff81595f2d <+29>:	and    $0x3,%eax
   0xffffffff81595f30 <+32>:	cmp    $0x1,%eax
   0xffffffff81595f33 <+35>:	je     0xffffffff81595f78 <__kfree_skb+104>
   0xffffffff81595f35 <+37>:	cmp    $0x2,%eax
   0xffffffff81595f38 <+40>:	je     0xffffffff81595f58 <__kfree_skb+72>
   0xffffffff81595f3a <+42>:	test   %eax,%eax
   0xffffffff81595f3c <+44>:	jne    0xffffffff81595f4d <__kfree_skb+61>
   0xffffffff81595f3e <+46>:	mov    %rbx,%rsi
   0xffffffff81595f41 <+49>:	mov    0x760858(%rip),%rdi        # 
0xffffffff81cf67a0 <skbuff_head_cache>
   0xffffffff81595f48 <+56>:	callq  0xffffffff81190580 <kmem_cache_free>
   0xffffffff81595f4d <+61>:	add    $0x8,%rsp
   0xffffffff81595f51 <+65>:	pop    %rbx
   0xffffffff81595f52 <+66>:	leaveq
   0xffffffff81595f53 <+67>:	retq
   0xffffffff81595f54 <+68>:	nopl   0x0(%rax)
   0xffffffff81595f58 <+72>:	lea    -0xd8(%rbx),%rsi
   0xffffffff81595f5f <+79>:	lock decl 0x1b0(%rsi)
   0xffffffff81595f66 <+86>:	je     0xffffffff81595fb0 <__kfree_skb+160>
   0xffffffff81595f68 <+88>:	orb    $0xc,0x7e(%rbx)

^^^^^^^^^^^^^^^^^^^^^
Should be skb->fclone = SKB_FCLONE_FREE;

   0xffffffff81595f6c <+92>:	add    $0x8,%rsp
   0xffffffff81595f70 <+96>:	pop    %rbx
   0xffffffff81595f71 <+97>:	leaveq
   0xffffffff81595f72 <+98>:	retq
   0xffffffff81595f73 <+99>:	nopl   0x0(%rax,%rax,1)
   0xffffffff81595f78 <+104>:	lock decl 0x1b0(%rbx)
   0xffffffff81595f7f <+111>:	je     0xffffffff81595f90 
<__kfree_skb+128>
   0xffffffff81595f81 <+113>:	add    $0x8,%rsp
   0xffffffff81595f85 <+117>:	pop    %rbx
   0xffffffff81595f86 <+118>:	leaveq
   0xffffffff81595f87 <+119>:	retq
   0xffffffff81595f88 <+120>:	nopl   0x0(%rax,%rax,1)
   0xffffffff81595f90 <+128>:	mov    %rbx,%rsi
   0xffffffff81595f93 <+131>:	mov    0x7607fe(%rip),%rdi        # 
0xffffffff81cf6798 <skbuff_fclone_cache>
   0xffffffff81595f9a <+138>:	callq  0xffffffff81190580 
<kmem_cache_free>
   0xffffffff81595f9f <+143>:	add    $0x8,%rsp
   0xffffffff81595fa3 <+147>:	pop    %rbx
   0xffffffff81595fa4 <+148>:	leaveq
   0xffffffff81595fa5 <+149>:	retq
   0xffffffff81595fa6 <+150>:	nopw   %cs:0x0(%rax,%rax,1)
   0xffffffff81595fb0 <+160>:	mov    0x7607e1(%rip),%rdi        # 
0xffffffff81cf6798 <skbuff_fclone_cache>
   0xffffffff81595fb7 <+167>:	callq  0xffffffff81190580 
<kmem_cache_free>
   0xffffffff81595fbc <+172>:	add    $0x8,%rsp
   0xffffffff81595fc0 <+176>:	pop    %rbx
   0xffffffff81595fc1 <+177>:	leaveq
   0xffffffff81595fc2 <+178>:	retq

-chris
