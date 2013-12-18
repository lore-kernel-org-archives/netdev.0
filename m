From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 18 Dec 2013 16:19:43 +0800
Message-ID: <52B15A9F.6030301@huawei.com>
References: <529E9579.7090201@cn.fujitsu.com> <529EA9CF.2090008@huawei.com> <20131203.232122.852236751455974887.davem@davemloft.net> <529EC95A.5080908@huawei.com> <1386138457.30495.86.camel@edumazet-glaptop2.roam.corp.google.com> <529EF30A.4050609@huawei.com> <1386170645.30495.108.camel@edumazet-glaptop2.roam.corp.google.com> <529FC980.8020101@cn.fujitsu.com> <529FF066.1070307@huawei.com> <52B142AF.8070708@huawei.com> <20131218075131.GD27460@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <yoshfuji@linux-ipv6.org>,
	<joe@perches.com>, <vfalico@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:51937 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab3LRIe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 03:34:56 -0500
In-Reply-To: <20131218075131.GD27460@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/18 15:51, Hannes Frederic Sowa wrote:
> Hi Ding!
> 
> May I step in for short?
> 
> On Wed, Dec 18, 2013 at 02:37:35PM +0800, Ding Tianhong wrote:
>> On 2013/12/5 11:17, Ding Tianhong wrote:
>>> On 2013/12/5 8:32, Gao feng wrote:
>>>> On 12/04/2013 11:24 PM, Eric Dumazet wrote:
>>>>> On Wed, 2013-12-04 at 17:16 +0800, Ding Tianhong wrote:
>>>>>>>> 						base->running_timer = neigh->timer;
>>>>>>>> 						neigh_timer_handler() => at this time, refcnt is 2;
>>>>>>>>
>>>>>>>> user->	neigh_changeaddr()
>>>>>>>> 	neigh_flush_dev();
>>>>>>>> 	neigh_del_imer, refcnt dec to 1;
>>>>>>>
>>>>>>> Nope : del_timer() would return 0 here, so we do not decrement refcnt.
>>>>>>>
>>>>>>
>>>>>> The first call for del_timer() will return 1, because the timer->entry.next is not NULL,
>>>>>> then in the neigh_destroy, the del_timer() again will return 0 because timer->entry.next is NULL. 
>>>>>
>>>>> Again no. You are very mistaken.
>>>>>
>>>>> del_timer() return code is not a hint. Its a precise meaning.
>>>>>
>>>>> It cannot return 1 if the timer function is running or is about to run.
>>>>>
>>>>> If you believe there is  bug in del_timer(), fix it ;)
>>>>>
>>>>>
>>>>
>>>> Yes, you are right, __run_timers did this job.
>>>> So We still don't know what's the root reason.
>>>>
>>> Yes, I miss it, the running timer is detached from the list, thanks for all above.
>>>
>>> Regards
>>> Ding
>>>
>>
>>
>> Hi Eric:
>>
>> I was so doubt about the situation, can you give me some advise?
>>
>> 	CPU0					  CPU1					  CPU2
>>       --------		      			--------                		---------
>> neigh_timer_handler				
>> write_lock(n->lock);		
>> 	...
>> write_unlock(n->lock);
>> n->ref_cnt = 2 or 3(if mode_time)				
>> 	...					neigh_flush_dev
>> 						write_lock(n->lock);
>> 						n->ref_cnt = 2;
>> 						n->nud_state = NUD_NONE;
>> 						write_unlock(n->lock);
>> 						neigh_release()
>> 						n->ref_cnt = 1;
>> 						...					neigh_periodic_work
>> 											write_lock(n->lock);
>> 											write_unlock(n->lock);
>> 											neigh_release();
>> 											kfree(n)
>> n->ops->solicit()									...
>> ...
>>
>> if that possible? or I was totally wrong? pls give me some advise if I miss something, thanks a lot.
> 
> When you first posted the patch I had my doubts that there is such
> race. E.g. n->dead was 0 in the neigh you posted. After all the neigh
> timer has its own reference and does check ->dead before proceeding. I maybe
> wrong because the memory could already be overwritten.
> 
> (Maybe we should move the ->dead check inside the write_lock to use it as a
> barrier.)
> 
> Maybe there was another dereference which caused the bug. Could you check if
> you have the code section from the panic? It should look something like
> 
> Code: FF FF FF .. <FF> ..
> 
> Sometimes using addr2line on vmlinux with the RIP could give another hint.
> 
> Greetings,
> 
>   Hannes
> 

Hi Hannes:

Thanks for your attention. I hope it useful to you.

235 [64306.090258] Supported: Yes, External
236 [64306.090262] Pid: 58359, comm: socknal_cd04 Tainted: P          N  2.6.32.59-0.7-default #1 T3500 G3
237 [64306.090266] RIP: 0010:[<ffffffff812f8e36>]  [<ffffffff812f8e36>] neigh_timer_handler+0x116/0x3b0
238 [64306.090272] RSP: 0018:ffff880c273499d8  EFLAGS: 00010206
239 [64306.090275] RAX: 0000000000000000 RBX: ffff8801cddf1500 RCX: ffff8801cddf14f2
240 [64306.090278] RDX: 0000000000000000 RSI: ffff8805e40d3a28 RDI: ffff8801cddf1500
241 [64306.090281] RBP: ffff8805e40d3a28 R08: ffff8801cddf1530 R09: ffff880c27349b17
242 [64306.090284] R10: 000000000000000e R11: ffffffff812f8e22 R12: ffff880185c0e840
243 [64306.090287] R13: 0000000000000000 R14: ffff8805e40d3a60 R15: 0000000003484560

ffffffff812f8e36 (t) neigh_timer_handler+278  ../linux/net/core/neighbour.c: 876
crash> dis -l neigh_timer_handler
/usr/src/linux/net/core/neighbour.c: 798
0xffffffff812f8d20 <neigh_timer_handler>:       sub    $0x28,%rsp
0xffffffff812f8d24 <neigh_timer_handler+4>:     mov    %r14,0x20(%rsp)
/usr/src/linux/net/core/neighbour.c: 804
0xffffffff812f8d29 <neigh_timer_handler+9>:     lea    0x40(%rdi),%r14
/usr/src/linux/net/core/neighbour.c: 798
0xffffffff812f8d2d <neigh_timer_handler+13>:    mov    %rbx,(%rsp)
0xffffffff812f8d31 <neigh_timer_handler+17>:    mov    %rdi,%rbx
0xffffffff812f8d34 <neigh_timer_handler+20>:    mov    %rbp,0x8(%rsp)
0xffffffff812f8d39 <neigh_timer_handler+25>:    mov    %r12,0x10(%rsp)
/usr/src/linux/net/core/neighbour.c: 804
0xffffffff812f8d3e <neigh_timer_handler+30>:    mov    %r14,%rdi
/usr/src/linux/net/core/neighbour.c: 798
0xffffffff812f8d41 <neigh_timer_handler+33>:    mov    %r13,0x18(%rsp)
/usr/src/linux/net/core/neighbour.c: 878
0xffffffff812f8d46 <neigh_timer_handler+38>:    xor    %r13d,%r13d
/usr/src/linux/net/core/neighbour.c: 804
0xffffffff812f8d49 <neigh_timer_handler+41>:    callq  0xffffffff81394bb0 <_write_lock>
/usr/src/linux/net/core/neighbour.c: 806
0xffffffff812f8d4e <neigh_timer_handler+46>:    movzbl 0x39(%rbx),%edx
/usr/src/linux/net/core/neighbour.c: 807
0xffffffff812f8d52 <neigh_timer_handler+50>:    mov    0x634ba7(%rip),%rdi        # 0xffffffff8192d900
0xffffffff812f8d59 <neigh_timer_handler+57>:    lea    0x70(%rbx),%r12
/usr/src/linux/net/core/neighbour.c: 808
0xffffffff812f8d5d <neigh_timer_handler+61>:    lea    0xfa(%rdi),%rbp
/usr/src/linux/net/core/neighbour.c: 806
0xffffffff812f8d64 <neigh_timer_handler+68>:    movzbl %dl,%eax
/usr/src/linux/net/core/neighbour.c: 810
0xffffffff812f8d67 <neigh_timer_handler+71>:    test   $0x1b,%al
0xffffffff812f8d69 <neigh_timer_handler+73>:    je     0xffffffff812f8e50 <neigh_timer_handler+304>
/usr/src/linux/net/core/neighbour.c: 817
0xffffffff812f8d6f <neigh_timer_handler+79>:    test   $0x2,%al
0xffffffff812f8d71 <neigh_timer_handler+81>:    je     0xffffffff812f8e98 <neigh_timer_handler+376>
/usr/src/linux/net/core/neighbour.c: 818
0xffffffff812f8d77 <neigh_timer_handler+87>:    mov    0x10(%rbx),%r8
0xffffffff812f8d7b <neigh_timer_handler+91>:    movslq 0x5c(%r8),%rsi
0xffffffff812f8d7f <neigh_timer_handler+95>:    add    0x28(%rbx),%rsi
0xffffffff812f8d83 <neigh_timer_handler+99>:    cmp    %rdi,%rsi
0xffffffff812f8d86 <neigh_timer_handler+102>:   js     0xffffffff812f8f58 <neigh_timer_handler+568>
0xffffffff812f8d8c <neigh_timer_handler+108>:   mov    %rsi,%rbp
/usr/src/linux/net/core/neighbour.c: 857
0xffffffff812f8d8f <neigh_timer_handler+111>:   movzbl %dl,%eax
0xffffffff812f8d92 <neigh_timer_handler+114>:   test   $0x11,%al
0xffffffff812f8d94 <neigh_timer_handler+116>:   je     0xffffffff812f8db0 <neigh_timer_handler+144>
/usr/src/linux/net/core/neighbour.c: 768
0xffffffff812f8d96 <neigh_timer_handler+118>:   test   $0x10,%al
/usr/src/linux/include/asm/atomic_64.h: 23
0xffffffff812f8d98 <neigh_timer_handler+120>:   mov    0x3c(%rbx),%esi
/usr/src/linux/net/core/neighbour.c: 767
0xffffffff812f8d9b <neigh_timer_handler+123>:   mov    0x10(%rbx),%rcx
/usr/src/linux/net/core/neighbour.c: 768
0xffffffff812f8d9f <neigh_timer_handler+127>:   je     0xffffffff812f8fe8 <neigh_timer_handler+712>
0xffffffff812f8da5 <neigh_timer_handler+133>:   mov    0x68(%rcx),%edx
/usr/src/linux/net/core/neighbour.c: 857
0xffffffff812f8da8 <neigh_timer_handler+136>:   cmp    %edx,%esi
0xffffffff812f8daa <neigh_timer_handler+138>:   jge    0xffffffff812f9000 <neigh_timer_handler+736>
/usr/src/linux/net/core/neighbour.c: 864
0xffffffff812f8db0 <neigh_timer_handler+144>:   test   $0x1b,%al
0xffffffff812f8db2 <neigh_timer_handler+146>:   lea    0x70(%rbx),%r12
0xffffffff812f8db6 <neigh_timer_handler+150>:   je     0xffffffff812f8df1 <neigh_timer_handler+209>
/usr/src/linux/net/core/neighbour.c: 865
0xffffffff812f8db8 <neigh_timer_handler+152>:   mov    0x634b41(%rip),%rax        # 0xffffffff8192d900
0xffffffff812f8dbf <neigh_timer_handler+159>:   mov    %rbp,%rdx
0xffffffff812f8dc2 <neigh_timer_handler+162>:   sub    %rax,%rdx
0xffffffff812f8dc5 <neigh_timer_handler+165>:   mov    %rdx,%rax
0xffffffff812f8dc8 <neigh_timer_handler+168>:   sub    $0x7d,%rax
0xffffffff812f8dcc <neigh_timer_handler+172>:   js     0xffffffff812f9020 <neigh_timer_handler+768>
/usr/src/linux/net/core/neighbour.c: 867
0xffffffff812f8dd2 <neigh_timer_handler+178>:   lea    0x98(%rbx),%rdi
0xffffffff812f8dd9 <neigh_timer_handler+185>:   mov    %rbp,%rsi
0xffffffff812f8ddc <neigh_timer_handler+188>:   callq  0xffffffff81057db0 <mod_timer>
0xffffffff812f8de1 <neigh_timer_handler+193>:   test   %eax,%eax
0xffffffff812f8de3 <neigh_timer_handler+195>:   je     0xffffffff812f8fd0 <neigh_timer_handler+688>
0xffffffff812f8de9 <neigh_timer_handler+201>:   movzbl 0x39(%rbx),%eax
0xffffffff812f8ded <neigh_timer_handler+205>:   lea    0x70(%rbx),%r12
/usr/src/linux/net/core/neighbour.c: 870
0xffffffff812f8df1 <neigh_timer_handler+209>:   test   $0x11,%al
0xffffffff812f8df3 <neigh_timer_handler+211>:   je     0xffffffff812f8e50 <neigh_timer_handler+304>
/usr/src/linux/include/linux/skbuff.h: 787
0xffffffff812f8df5 <neigh_timer_handler+213>:   mov    0x80(%rbx),%rbp
0xffffffff812f8dfc <neigh_timer_handler+220>:   lea    0x80(%rbx),%rax
/usr/src/linux/include/linux/skbuff.h: 788
0xffffffff812f8e03 <neigh_timer_handler+227>:   cmp    %rbp,%rax
0xffffffff812f8e06 <neigh_timer_handler+230>:   je     0xffffffff812f9060 <neigh_timer_handler+832>
/usr/src/linux/net/core/neighbour.c: 873
0xffffffff812f8e0c <neigh_timer_handler+236>:   test   %rbp,%rbp
0xffffffff812f8e0f <neigh_timer_handler+239>:   je     0xffffffff812f8e21 <neigh_timer_handler+257>
/usr/src/linux/net/core/neighbour.c: 874
0xffffffff812f8e11 <neigh_timer_handler+241>:   mov    %rbp,%rdi
0xffffffff812f8e14 <neigh_timer_handler+244>:   mov    $0x20,%esi
0xffffffff812f8e19 <neigh_timer_handler+249>:   callq  0xffffffff812e83c0 <skb_copy>
0xffffffff812f8e1e <neigh_timer_handler+254>:   mov    %rax,%rbp
/usr/src/linux/include/asm/spinlock.h: 294
0xffffffff812f8e21 <neigh_timer_handler+257>:   lock addl $0x1000000,0x40(%rbx)
/usr/src/linux/net/core/neighbour.c: 876
0xffffffff812f8e29 <neigh_timer_handler+265>:   mov    0xe8(%rbx),%rax
0xffffffff812f8e30 <neigh_timer_handler+272>:   mov    %rbp,%rsi
0xffffffff812f8e33 <neigh_timer_handler+275>:   mov    %rbx,%rdi
0xffffffff812f8e36 <neigh_timer_handler+278>:   callq  *0x8(%rax)						<-----crash
/usr/src/linux/net/core/neighbour.c: 877
0xffffffff812f8e39 <neigh_timer_handler+281>:   lea    0x3c(%rbx),%rax
/usr/src/linux/include/asm/atomic_64.h: 93
0xffffffff812f8e3d <neigh_timer_handler+285>:   lock incl 0x3c(%rbx)
/usr/src/linux/net/core/neighbour.c: 878
0xffffffff812f8e41 <neigh_timer_handler+289>:   mov    %rbp,%rdi
0xffffffff812f8e44 <neigh_timer_handler+292>:   callq  0xffffffff812e57c0 <kfree_skb>
0xffffffff812f8e49 <neigh_timer_handler+297>:   jmp    0xffffffff812f8e58 <neigh_timer_handler+312>
0xffffffff812f8e4b <neigh_timer_handler+299>:   nopl   0x0(%rax,%rax,1)
/usr/src/linux/include/asm/spinlock.h: 294
0xffffffff812f8e50 <neigh_timer_handler+304>:   lock addl $0x1000000,0x40(%rbx)
/usr/src/linux/net/core/neighbour.c: 884
0xffffffff812f8e58 <neigh_timer_handler+312>:   test   %r13d,%r13d
0xffffffff812f8e5b <neigh_timer_handler+315>:   je     0xffffffff812f8e65 <neigh_timer_handler+325>
/usr/src/linux/net/core/neighbour.c: 885
0xffffffff812f8e5d <neigh_timer_handler+317>:   mov    %rbx,%rdi
0xffffffff812f8e60 <neigh_timer_handler+320>:   callq  0xffffffff812f8950 <neigh_update_notify>
/usr/src/linux/include/asm/atomic_64.h: 123
0xffffffff812f8e65 <neigh_timer_handler+325>:   lock decl (%r12)
0xffffffff812f8e6a <neigh_timer_handler+330>:   sete   %al
/usr/src/linux/include/net/neighbour.h: 288
0xffffffff812f8e6d <neigh_timer_handler+333>:   test   %al,%al
0xffffffff812f8e6f <neigh_timer_handler+335>:   jne    0xffffffff812f8f18 <neigh_timer_handler+504>
/usr/src/linux/net/core/neighbour.c: 888
0xffffffff812f8e75 <neigh_timer_handler+341>:   mov    (%rsp),%rbx
0xffffffff812f8e79 <neigh_timer_handler+345>:   mov    0x8(%rsp),%rbp
0xffffffff812f8e7e <neigh_timer_handler+350>:   mov    0x10(%rsp),%r12
0xffffffff812f8e83 <neigh_timer_handler+355>:   mov    0x18(%rsp),%r13
0xffffffff812f8e88 <neigh_timer_handler+360>:   mov    0x20(%rsp),%r14
0xffffffff812f8e8d <neigh_timer_handler+365>:   add    $0x28,%rsp
0xffffffff812f8e91 <neigh_timer_handler+369>:   retq   
0xffffffff812f8e92 <neigh_timer_handler+370>:   nopw   0x0(%rax,%rax,1)
/usr/src/linux/net/core/neighbour.c: 836
0xffffffff812f8e98 <neigh_timer_handler+376>:   test   $0x8,%al
0xffffffff812f8e9a <neigh_timer_handler+378>:   je     0xffffffff812f8f40 <neigh_timer_handler+544>
/usr/src/linux/net/core/neighbour.c: 837
0xffffffff812f8ea0 <neigh_timer_handler+384>:   mov    0x10(%rbx),%r8
0xffffffff812f8ea4 <neigh_timer_handler+388>:   movslq 0x60(%r8),%rax
0xffffffff812f8ea8 <neigh_timer_handler+392>:   add    0x28(%rbx),%rax
0xffffffff812f8eac <neigh_timer_handler+396>:   cmp    %rdi,%rax
0xffffffff812f8eaf <neigh_timer_handler+399>:   js     0xffffffff812f9030 <neigh_timer_handler+784>
/usr/src/linux/net/core/neighbour.c: 840
0xffffffff812f8eb5 <neigh_timer_handler+405>:   movb   $0x2,0x39(%rbx)
/usr/src/linux/net/core/neighbour.c: 689
0xffffffff812f8eb9 <neigh_timer_handler+409>:   mov    0xe8(%rbx),%rcx
/usr/src/linux/net/core/neighbour.c: 841
0xffffffff812f8ec0 <neigh_timer_handler+416>:   mov    0x634a39(%rip),%rax        # 0xffffffff8192d900
/usr/src/linux/net/core/neighbour.c: 691
0xffffffff812f8ec7 <neigh_timer_handler+423>:   mov    0x68(%rbx),%rdx
/usr/src/linux/net/core/neighbour.c: 841
0xffffffff812f8ecb <neigh_timer_handler+427>:   mov    %rax,0x30(%rbx)
/usr/src/linux/net/core/neighbour.c: 689
0xffffffff812f8ecf <neigh_timer_handler+431>:   mov    0x20(%rcx),%rax
/usr/src/linux/net/core/neighbour.c: 691
0xffffffff812f8ed3 <neigh_timer_handler+435>:   test   %rdx,%rdx
/usr/src/linux/net/core/neighbour.c: 689
0xffffffff812f8ed6 <neigh_timer_handler+438>:   mov    %rax,0x78(%rbx)
/usr/src/linux/net/core/neighbour.c: 691
0xffffffff812f8eda <neigh_timer_handler+442>:   jne    0xffffffff812f8ee7 <neigh_timer_handler+455>
0xffffffff812f8edc <neigh_timer_handler+444>:   jmp    0xffffffff812f8efe <neigh_timer_handler+478>
0xffffffff812f8ede <neigh_timer_handler+446>:   xchg   %ax,%ax
0xffffffff812f8ee0 <neigh_timer_handler+448>:   mov    0xe8(%rbx),%rcx
/usr/src/linux/net/core/neighbour.c: 692
0xffffffff812f8ee7 <neigh_timer_handler+455>:   mov    0x28(%rcx),%rax
0xffffffff812f8eeb <neigh_timer_handler+459>:   mov    %rax,0x88(%rdx)
/usr/src/linux/net/core/neighbour.c: 691
0xffffffff812f8ef2 <neigh_timer_handler+466>:   mov    (%rdx),%rdx
0xffffffff812f8ef5 <neigh_timer_handler+469>:   test   %rdx,%rdx
0xffffffff812f8ef8 <neigh_timer_handler+472>:   jne    0xffffffff812f8ee0 <neigh_timer_handler+448>
0xffffffff812f8efa <neigh_timer_handler+474>:   mov    0x10(%rbx),%r8
/usr/src/linux/net/core/neighbour.c: 844
0xffffffff812f8efe <neigh_timer_handler+478>:   movslq 0x5c(%r8),%rbp
0xffffffff812f8f02 <neigh_timer_handler+482>:   add    0x28(%rbx),%rbp
0xffffffff812f8f06 <neigh_timer_handler+486>:   movzbl 0x39(%rbx),%edx
0xffffffff812f8f0a <neigh_timer_handler+490>:   mov    $0x1,%r13d
0xffffffff812f8f10 <neigh_timer_handler+496>:   jmpq   0xffffffff812f8d8f <neigh_timer_handler+111>
0xffffffff812f8f15 <neigh_timer_handler+501>:   nopl   (%rax)
/usr/src/linux/include/net/neighbour.h: 289
0xffffffff812f8f18 <neigh_timer_handler+504>:   mov    %rbx,%rdi
/usr/src/linux/net/core/neighbour.c: 888
0xffffffff812f8f1b <neigh_timer_handler+507>:   mov    0x8(%rsp),%rbp
0xffffffff812f8f20 <neigh_timer_handler+512>:   mov    (%rsp),%rbx
0xffffffff812f8f24 <neigh_timer_handler+516>:   mov    0x10(%rsp),%r12
0xffffffff812f8f29 <neigh_timer_handler+521>:   mov    0x18(%rsp),%r13
0xffffffff812f8f2e <neigh_timer_handler+526>:   mov    0x20(%rsp),%r14
0xffffffff812f8f33 <neigh_timer_handler+531>:   add    $0x28,%rsp
/usr/src/linux/include/net/neighbour.h: 289
0xffffffff812f8f37 <neigh_timer_handler+535>:   jmpq   0xffffffff812f8ba0 <neigh_destroy>
0xffffffff812f8f3c <neigh_timer_handler+540>:   nopl   0x0(%rax)
/usr/src/linux/net/core/neighbour.c: 854
0xffffffff812f8f40 <neigh_timer_handler+544>:   mov    0x10(%rbx),%rax
0xffffffff812f8f44 <neigh_timer_handler+548>:   movslq 0x54(%rax),%rax
0xffffffff812f8f48 <neigh_timer_handler+552>:   lea    (%rax,%rdi,1),%rbp
0xffffffff812f8f4c <neigh_timer_handler+556>:   jmpq   0xffffffff812f8d8f <neigh_timer_handler+111>
0xffffffff812f8f51 <neigh_timer_handler+561>:   nopl   0x0(%rax)
/usr/src/linux/net/core/neighbour.c: 822
0xffffffff812f8f58 <neigh_timer_handler+568>:   movslq 0x60(%r8),%rax
0xffffffff812f8f5c <neigh_timer_handler+572>:   add    0x20(%rbx),%rax
0xffffffff812f8f60 <neigh_timer_handler+576>:   cmp    %rdi,%rax
0xffffffff812f8f63 <neigh_timer_handler+579>:   js     0xffffffff812f9070 <neigh_timer_handler+848>
/usr/src/linux/net/core/neighbour.c: 825
0xffffffff812f8f69 <neigh_timer_handler+585>:   movb   $0x8,0x39(%rbx)
/usr/src/linux/net/core/neighbour.c: 672
0xffffffff812f8f6d <neigh_timer_handler+589>:   mov    0xe8(%rbx),%rcx
/usr/src/linux/net/core/neighbour.c: 826
0xffffffff812f8f74 <neigh_timer_handler+596>:   mov    0x634985(%rip),%rax        # 0xffffffff8192d900
/usr/src/linux/net/core/neighbour.c: 674
0xffffffff812f8f7b <neigh_timer_handler+603>:   mov    0x68(%rbx),%rdx
/usr/src/linux/net/core/neighbour.c: 826
0xffffffff812f8f7f <neigh_timer_handler+607>:   mov    %rax,0x30(%rbx)
/usr/src/linux/net/core/neighbour.c: 672
0xffffffff812f8f83 <neigh_timer_handler+611>:   mov    0x18(%rcx),%rax
/usr/src/linux/net/core/neighbour.c: 674
0xffffffff812f8f87 <neigh_timer_handler+615>:   test   %rdx,%rdx
/usr/src/linux/net/core/neighbour.c: 672
0xffffffff812f8f8a <neigh_timer_handler+618>:   mov    %rax,0x78(%rbx)
/usr/src/linux/net/core/neighbour.c: 674
0xffffffff812f8f8e <neigh_timer_handler+622>:   jne    0xffffffff812f8faf <neigh_timer_handler+655>
/usr/src/linux/net/core/neighbour.c: 828
0xffffffff812f8f90 <neigh_timer_handler+624>:   movslq 0x60(%r8),%rax
0xffffffff812f8f94 <neigh_timer_handler+628>:   movzbl 0x39(%rbx),%edx
0xffffffff812f8f98 <neigh_timer_handler+632>:   xor    %r13d,%r13d
0xffffffff812f8f9b <neigh_timer_handler+635>:   lea    (%rax,%rdi,1),%rbp
0xffffffff812f8f9f <neigh_timer_handler+639>:   jmpq   0xffffffff812f8d8f <neigh_timer_handler+111>
0xffffffff812f8fa4 <neigh_timer_handler+644>:   nopl   0x0(%rax)
0xffffffff812f8fa8 <neigh_timer_handler+648>:   mov    0xe8(%rbx),%rcx
/usr/src/linux/net/core/neighbour.c: 675
0xffffffff812f8faf <neigh_timer_handler+655>:   mov    0x18(%rcx),%rax
0xffffffff812f8fb3 <neigh_timer_handler+659>:   mov    %rax,0x88(%rdx)
/usr/src/linux/net/core/neighbour.c: 674
0xffffffff812f8fba <neigh_timer_handler+666>:   mov    (%rdx),%rdx
0xffffffff812f8fbd <neigh_timer_handler+669>:   test   %rdx,%rdx
0xffffffff812f8fc0 <neigh_timer_handler+672>:   jne    0xffffffff812f8fa8 <neigh_timer_handler+648>
0xffffffff812f8fc2 <neigh_timer_handler+674>:   mov    0x10(%rbx),%r8
0xffffffff812f8fc6 <neigh_timer_handler+678>:   jmp    0xffffffff812f8f90 <neigh_timer_handler+624>
0xffffffff812f8fc8 <neigh_timer_handler+680>:   nopl   0x0(%rax,%rax,1)
/usr/src/linux/net/core/neighbour.c: 868
0xffffffff812f8fd0 <neigh_timer_handler+688>:   lea    0x70(%rbx),%r12
/usr/src/linux/include/asm/atomic_64.h: 93
0xffffffff812f8fd4 <neigh_timer_handler+692>:   lock incl 0x70(%rbx)
0xffffffff812f8fd8 <neigh_timer_handler+696>:   movzbl 0x39(%rbx),%eax
0xffffffff812f8fdc <neigh_timer_handler+700>:   jmpq   0xffffffff812f8df1 <neigh_timer_handler+209>
0xffffffff812f8fe1 <neigh_timer_handler+705>:   nopl   0x0(%rax)
/usr/src/linux/net/core/neighbour.c: 768
0xffffffff812f8fe8 <neigh_timer_handler+712>:   mov    0x6c(%rcx),%edx
0xffffffff812f8feb <neigh_timer_handler+715>:   add    0x68(%rcx),%edx
0xffffffff812f8fee <neigh_timer_handler+718>:   add    0x70(%rcx),%edx
0xffffffff812f8ff1 <neigh_timer_handler+721>:   jmpq   0xffffffff812f8da8 <neigh_timer_handler+136>
0xffffffff812f8ff6 <neigh_timer_handler+726>:   nopw   %cs:0x0(%rax,%rax,1)
/usr/src/linux/net/core/neighbour.c: 859
0xffffffff812f9000 <neigh_timer_handler+736>:   movb   $0x20,0x39(%rbx)
/usr/src/linux/net/core/neighbour.c: 861
0xffffffff812f9004 <neigh_timer_handler+740>:   mov    %rbx,%rdi
0xffffffff812f9007 <neigh_timer_handler+743>:   mov    $0x1,%r13d
0xffffffff812f900d <neigh_timer_handler+749>:   callq  0xffffffff812f8880 <neigh_invalidate>
0xffffffff812f9012 <neigh_timer_handler+754>:   movzbl 0x39(%rbx),%eax
0xffffffff812f9016 <neigh_timer_handler+758>:   jmpq   0xffffffff812f8db0 <neigh_timer_handler+144>
0xffffffff812f901b <neigh_timer_handler+763>:   nopl   0x0(%rax,%rax,1)
/usr/src/linux/net/core/neighbour.c: 866
0xffffffff812f9020 <neigh_timer_handler+768>:   mov    0x6348d9(%rip),%rax        # 0xffffffff8192d900
0xffffffff812f9027 <neigh_timer_handler+775>:   lea    0x7d(%rax),%rbp
0xffffffff812f902b <neigh_timer_handler+779>:   jmpq   0xffffffff812f8dd2 <neigh_timer_handler+178>
/usr/src/linux/net/core/neighbour.c: 847
0xffffffff812f9030 <neigh_timer_handler+784>:   movb   $0x10,0x39(%rbx)
/usr/src/linux/net/core/neighbour.c: 848
0xffffffff812f9034 <neigh_timer_handler+788>:   mov    0x6348c5(%rip),%rax        # 0xffffffff8192d900
/usr/src/linux/net/core/neighbour.c: 850
0xffffffff812f903b <neigh_timer_handler+795>:   mov    $0x10,%edx
/usr/src/linux/include/asm/atomic_64.h: 35
0xffffffff812f9040 <neigh_timer_handler+800>:   movl   $0x0,0x3c(%rbx)
/usr/src/linux/net/core/neighbour.c: 848
0xffffffff812f9047 <neigh_timer_handler+807>:   mov    %rax,0x30(%rbx)
/usr/src/linux/net/core/neighbour.c: 850
0xffffffff812f904b <neigh_timer_handler+811>:   movslq 0x54(%r8),%rax
0xffffffff812f904f <neigh_timer_handler+815>:   lea    (%rax,%rdi,1),%rbp
0xffffffff812f9053 <neigh_timer_handler+819>:   jmpq   0xffffffff812f8d8f <neigh_timer_handler+111>
0xffffffff812f9058 <neigh_timer_handler+824>:   nopl   0x0(%rax,%rax,1)
/usr/src/linux/include/linux/skbuff.h: 788
0xffffffff812f9060 <neigh_timer_handler+832>:   xor    %ebp,%ebp
0xffffffff812f9062 <neigh_timer_handler+834>:   jmpq   0xffffffff812f8e21 <neigh_timer_handler+257>
0xffffffff812f9067 <neigh_timer_handler+839>:   nopw   0x0(%rax,%rax,1)
/usr/src/linux/net/core/neighbour.c: 831
0xffffffff812f9070 <neigh_timer_handler+848>:   movb   $0x4,0x39(%rbx)
/usr/src/linux/net/core/neighbour.c: 672
0xffffffff812f9074 <neigh_timer_handler+852>:   mov    0xe8(%rbx),%rcx
/usr/src/linux/net/core/neighbour.c: 674
0xffffffff812f907b <neigh_timer_handler+859>:   mov    $0x4,%edx
/usr/src/linux/net/core/neighbour.c: 832
0xffffffff812f9080 <neigh_timer_handler+864>:   mov    0x634879(%rip),%rax        # 0xffffffff8192d900
/usr/src/linux/net/core/neighbour.c: 674
0xffffffff812f9087 <neigh_timer_handler+871>:   mov    0x68(%rbx),%rsi
0xffffffff812f908b <neigh_timer_handler+875>:   mov    $0x1,%r13d
/usr/src/linux/net/core/neighbour.c: 832
0xffffffff812f9091 <neigh_timer_handler+881>:   mov    %rax,0x30(%rbx)
/usr/src/linux/net/core/neighbour.c: 672
0xffffffff812f9095 <neigh_timer_handler+885>:   mov    0x18(%rcx),%rax
/usr/src/linux/net/core/neighbour.c: 674
0xffffffff812f9099 <neigh_timer_handler+889>:   test   %rsi,%rsi
/usr/src/linux/net/core/neighbour.c: 672
0xffffffff812f909c <neigh_timer_handler+892>:   mov    %rax,0x78(%rbx)
/usr/src/linux/net/core/neighbour.c: 674
0xffffffff812f90a0 <neigh_timer_handler+896>:   jne    0xffffffff812f90b7 <neigh_timer_handler+919>
0xffffffff812f90a2 <neigh_timer_handler+898>:   jmpq   0xffffffff812f8d8f <neigh_timer_handler+111>
0xffffffff812f90a7 <neigh_timer_handler+903>:   nopw   0x0(%rax,%rax,1)
0xffffffff812f90b0 <neigh_timer_handler+912>:   mov    0xe8(%rbx),%rcx
/usr/src/linux/net/core/neighbour.c: 675
0xffffffff812f90b7 <neigh_timer_handler+919>:   mov    0x18(%rcx),%rax
0xffffffff812f90bb <neigh_timer_handler+923>:   mov    %rax,0x88(%rsi)
/usr/src/linux/net/core/neighbour.c: 674
0xffffffff812f90c2 <neigh_timer_handler+930>:   mov    (%rsi),%rsi
0xffffffff812f90c5 <neigh_timer_handler+933>:   test   %rsi,%rsi
0xffffffff812f90c8 <neigh_timer_handler+936>:   jne    0xffffffff812f90b0 <neigh_timer_handler+912>
0xffffffff812f90ca <neigh_timer_handler+938>:   jmpq   0xffffffff812f8f06 <neigh_timer_handler+486>
0xffffffff812f90cf <neigh_timer_handler+943>:   nop


crash>  neighbour ffff8801cddf1500
struct neighbour {
  next = 0x4037ad30000045, 
  tbl = 0x2484560013d0640, 
  parms = 0xdc03ff7f03484560, 
  dev = 0x23351d86, 
  used = 170277469553264, 
  confirmed = 649366077121561602, 
  updated = 0, 
  flags = 0 '\000', 
  nud_state = 0 '\000', 
  type = 0 '\000', 
  dead = 0 '\000', 
  probes = {
    counter = 0
  }, 
  lock = {
    raw_lock = {
      lock = 16777216
    }
  }, 
  ha = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0
00", 
  hh = 0x0, 
  refcnt = {
    counter = 0
  }, 
  output = 0, 
  arp_queue = {
    next = 0x10002, 
    prev = 0x0, 
    qlen = 1, 
    lock = {
      raw_lock = {
        slock = 0
      }
    }
  }, 
  timer = {
    entry = {
      next = 0x0, 
      prev = 0x0
    }, 
    expires = 0, 
    function = 0, 
    data = 0, 
    base = 0x0, 
    start_site = 0x0, 
    start_comm = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000", 
    start_pid = 0
  }, 
  ops = 0x0, 
  primary_key = 0xffff8801cddf15f0 ""
}


crash> struct -o neighbour
struct neighbour {
    [0] struct neighbour *next;
    [8] struct neigh_table *tbl;
   [16] struct neigh_parms *parms;
   [24] struct net_device *dev;
   [32] long unsigned int used;
   [40] long unsigned int confirmed;
   [48] long unsigned int updated;
   [56] __u8 flags;
   [57] __u8 nud_state;
   [58] __u8 type;
   [59] __u8 dead;
   [60] atomic_t probes;
   [64] rwlock_t lock;
   [68] unsigned char ha[32];
  [104] struct hh_cache *hh;
  [112] atomic_t refcnt;
  [120] int (*output)(struct sk_buff *);
  [128] struct sk_buff_head arp_queue;
  [152] struct timer_list timer;
  [232] const struct neigh_ops *ops;
  [240] u8 primary_key[0];
}
SIZE: 240


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
