From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH] rcu: fix a race in hlist_nulls_for_each_entry_rcu macro
Date: Tue, 21 May 2013 18:47:36 +0400
Message-ID: <519B8908.9080007@yandex-team.ru>
References: <519B38EC.90401@yandex-team.ru>  <20130521120906.GD3578@linux.vnet.ibm.com> <1369143885.3301.221.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, Dipankar Sarma <dipankar@in.ibm.com>,
	zhmurov@yandex-team.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369143885.3301.221.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.05.2013 17:44, Eric Dumazet wrote:
> On Tue, 2013-05-21 at 05:09 -0700, Paul E. McKenney wrote:
>
>>>
>>> -#define hlist_nulls_first_rcu(head) \
>>> -	(*((struct hlist_nulls_node __rcu __force **)&(head)->first))
>>> +#define hlist_nulls_first_rcu(head)			\
>>> +	(*((struct hlist_nulls_node __rcu __force **)	\
>>> +	   &((volatile typeof(*head) *)head)->first))
>>
>> Why not use ACCESS_ONCE() or (better) rcu_dereference_raw() here?
>
> More exactly we have :
>
> #define list_entry_rcu(ptr, type, member) \
>          ({typeof (*ptr) __rcu *__ptr = (typeof (*ptr) __rcu __force *)ptr; \
>           container_of((typeof(ptr))rcu_dereference_raw(__ptr), type, member); \
>          })
>
> #define list_for_each_entry_rcu(pos, head, member) \
>          for (pos = list_entry_rcu((head)->next, typeof(*pos), member); \
>                  &pos->member != (head); \
>                  pos = list_entry_rcu(pos->member.next, typeof(*pos), member))
> << and >>
>
> #define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member)                 \
>          for (pos = rcu_dereference_raw(hlist_nulls_first_rcu(head));            \
>                  (!is_a_nulls(pos)) &&                                           \
>                  ({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1; }); \
>                  pos = rcu_dereference_raw(hlist_nulls_next_rcu(pos)))
>
> We need to change hlist_nulls_for_each_entry_rcu() to use same construct,
> so that the rcu_dereference_raw() is performed at the right place.

No.

This code has the same mistake: it is rcu_dereference_raw(head->first), 
so there is nothing that prevents gcc to store the (head->first) value 
in a register.

Let's see on assembler (3.4.46, net/ipv4/udp.c, udp4_lib_lookup2()):

(0): here we get head address from stack
(1): here we get head->first
(2): this is a place, where we jump (by mistake) in original version 
from (3), (4) and (5). But in (4) we make same as in (1), so it's not a 
problem. In patched version we always jump to (1).

1) original version:
0000000000002840 <udp4_lib_lookup2.isra.35>:
     2840:	41 57                	push   %r15
     2842:	41 89 d7             	mov    %edx,%r15d
     2845:	41 56                	push   %r14
     2847:	41 55                	push   %r13
     2849:	41 54                	push   %r12
     284b:	55                   	push   %rbp
     284c:	48 89 fd             	mov    %rdi,%rbp
     284f:	53                   	push   %rbx
     2850:	48 83 ec 28          	sub    $0x28,%rsp
(0) 2854:	48 8b 44 24 60       	mov    0x60(%rsp),%rax
     2859:	44 8b 64 24 68       	mov    0x68(%rsp),%r12d
(1) 285e:	4c 8b 28             	mov    (%rax),%r13
(2) 2861:	31 ff                	xor    %edi,%edi
     2863:	41 f6 c5 01          	test   $0x1,%r13b
     2867:	4d 89 ea             	mov    %r13,%r10
     286a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
     286f:	74 32                	je     28a3 <udp4_lib_lookup2.isra.35+0x63>
     2871:	e9 20 02 00 00       	jmpq   2a96 
<udp4_lib_lookup2.isra.35+0x256>
     ...
     2940:	49 d1 ea             	shr    %r10
     2943:	4d 39 e2             	cmp    %r12,%r10
(3) 2946:	0f 85 15 ff ff ff    	jne    2861 <udp4_lib_lookup2.isra.35+0x21>
     294c:	48 85 ff             	test   %rdi,%rdi
     294f:	74 27                	je     2978 
<udp4_lib_lookup2.isra.35+0x138>
     2951:	41 89 db             	mov    %ebx,%r11d
     2954:	48 8d 5f 4c          	lea    0x4c(%rdi),%rbx
     2958:	41 ba 02 00 00 00    	mov    $0x2,%r10d
     295e:	66 90                	xchg   %ax,%ax
     2960:	45 8d 6a 01          	lea    0x1(%r10),%r13d
     2964:	44 89 d0             	mov    %r10d,%eax
     2967:	f0 44 0f b1 2b       	lock cmpxchg %r13d,(%rbx)
     296c:	41 39 c2             	cmp    %eax,%r10d
     296f:	74 36                	je     29a7 
<udp4_lib_lookup2.isra.35+0x167>
     2971:	85 c0                	test   %eax,%eax
     2973:	41 89 c2             	mov    %eax,%r10d
     2976:	75 e8                	jne    2960 
<udp4_lib_lookup2.isra.35+0x120>
     2978:	31 ff                	xor    %edi,%edi
     297a:	48 83 c4 28          	add    $0x28,%rsp
     297e:	48 89 f8             	mov    %rdi,%rax
     2981:	5b                   	pop    %rbx
     2982:	5d                   	pop    %rbp
     2983:	41 5c                	pop    %r12
     2985:	41 5d                	pop    %r13
     2987:	41 5e                	pop    %r14
     2989:	41 5f                	pop    %r15
     298b:	c3                   	retq
     298c:	0f 1f 40 00          	nopl   0x0(%rax)
     2990:	4d 8b b2 58 02 00 00 	mov    0x258(%r10),%r14
     2997:	41 f6 46 6e 10       	testb  $0x10,0x6e(%r14)
     299c:	0f 85 de fe ff ff    	jne    2880 <udp4_lib_lookup2.isra.35+0x40>
     29a2:	e9 17 ff ff ff       	jmpq   28be <udp4_lib_lookup2.isra.35+0x7e>
     29a7:	48 3b 6f 30          	cmp    0x30(%rdi),%rbp
     29ab:	74 43                	je     29f0 
<udp4_lib_lookup2.isra.35+0x1b0>
     29ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     29b2:	41 39 c3             	cmp    %eax,%r11d
     29b5:	7e c3                	jle    297a 
<udp4_lib_lookup2.isra.35+0x13a>
     29b7:	89 4c 24 10          	mov    %ecx,0x10(%rsp)
     29bb:	89 74 24 18          	mov    %esi,0x18(%rsp)
     29bf:	44 89 44 24 08       	mov    %r8d,0x8(%rsp)
     29c4:	44 89 0c 24          	mov    %r9d,(%rsp)
     29c8:	e8 c3 dc ff ff       	callq  690 <sock_put>
     29cd:	48 8b 44 24 60       	mov    0x60(%rsp),%rax
     29d2:	8b 4c 24 10          	mov    0x10(%rsp),%ecx
     29d6:	8b 74 24 18          	mov    0x18(%rsp),%esi
     29da:	44 8b 44 24 08       	mov    0x8(%rsp),%r8d
     29df:	44 8b 0c 24          	mov    (%rsp),%r9d
     29e3:	4c 8b 28             	mov    (%rax),%r13
(4) 29e6:	e9 76 fe ff ff       	jmpq   2861 <udp4_lib_lookup2.isra.35+0x21>
     29eb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
     29f0:	44 0f b7 57 0c       	movzwl 0xc(%rdi),%r10d
     29f5:	66 41 83 fa 0a       	cmp    $0xa,%r10w
     29fa:	74 7f                	je     2a7b 
<udp4_lib_lookup2.isra.35+0x23b>
     29fc:	3b 4f 04             	cmp    0x4(%rdi),%ecx
     29ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     2a04:	75 ac                	jne    29b2 
<udp4_lib_lookup2.isra.35+0x172>
     2a06:	0f b7 9f 7a 02 00 00 	movzwl 0x27a(%rdi),%ebx
     2a0d:	41 39 d8             	cmp    %ebx,%r8d
     2a10:	75 a0                	jne    29b2 
<udp4_lib_lookup2.isra.35+0x172>
     2a12:	8b 1f                	mov    (%rdi),%ebx
     2a14:	66 41 83 fa 02       	cmp    $0x2,%r10w
     2a19:	41 0f 94 c2          	sete   %r10b
     2a1d:	45 0f b6 d2          	movzbl %r10b,%r10d
     2a21:	85 db                	test   %ebx,%ebx
     2a23:	44 89 d0             	mov    %r10d,%eax
     2a26:	74 0d                	je     2a35 
<udp4_lib_lookup2.isra.35+0x1f5>
     2a28:	39 de                	cmp    %ebx,%esi
     2a2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     2a2f:	75 81                	jne    29b2 
<udp4_lib_lookup2.isra.35+0x172>
     2a31:	41 8d 42 02          	lea    0x2(%r10),%eax
     2a35:	44 0f b7 97 78 02 00 	movzwl 0x278(%rdi),%r10d
     2a3c:	00
     2a3d:	66 45 85 d2          	test   %r10w,%r10w
     2a41:	74 0d                	je     2a50 
<udp4_lib_lookup2.isra.35+0x210>
     2a43:	66 45 39 d7          	cmp    %r10w,%r15w
     2a47:	0f 85 60 ff ff ff    	jne    29ad 
<udp4_lib_lookup2.isra.35+0x16d>
     2a4d:	83 c0 02             	add    $0x2,%eax
     2a50:	44 8b 57 10          	mov    0x10(%rdi),%r10d
     2a54:	45 85 d2             	test   %r10d,%r10d
     2a57:	0f 84 55 ff ff ff    	je     29b2 
<udp4_lib_lookup2.isra.35+0x172>
     2a5d:	8d 58 02             	lea    0x2(%rax),%ebx
     2a60:	45 39 d1             	cmp    %r10d,%r9d
     2a63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     2a68:	0f 44 c3             	cmove  %ebx,%eax
     2a6b:	e9 42 ff ff ff       	jmpq   29b2 
<udp4_lib_lookup2.isra.35+0x172>
     2a70:	41 bb ff ff ff ff    	mov    $0xffffffff,%r11d
     2a76:	e9 05 fe ff ff       	jmpq   2880 <udp4_lib_lookup2.isra.35+0x40>
     2a7b:	48 8b 9f 70 02 00 00 	mov    0x270(%rdi),%rbx
     2a82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     2a87:	f6 43 6e 10          	testb  $0x10,0x6e(%rbx)
     2a8b:	0f 85 21 ff ff ff    	jne    29b2 
<udp4_lib_lookup2.isra.35+0x172>
     2a91:	e9 66 ff ff ff       	jmpq   29fc 
<udp4_lib_lookup2.isra.35+0x1bc>
     2a96:	4c 89 e8             	mov    %r13,%rax
     2a99:	48 d1 e8             	shr    %rax
     2a9c:	4c 39 e0             	cmp    %r12,%rax
(5) 2a9f:	0f 85 bc fd ff ff    	jne    2861 <udp4_lib_lookup2.isra.35+0x21>
     2aa5:	e9 ce fe ff ff       	jmpq   2978 
<udp4_lib_lookup2.isra.35+0x138>
     2aaa:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

2) patched version:
0000000000002840 <udp4_lib_lookup2>:
     2840:	41 57                	push   %r15
     2842:	41 89 d7             	mov    %edx,%r15d
     2845:	41 56                	push   %r14
     2847:	41 55                	push   %r13
     2849:	41 54                	push   %r12
     284b:	55                   	push   %rbp
     284c:	48 89 fd             	mov    %rdi,%rbp
     284f:	53                   	push   %rbx
     2850:	48 83 ec 28          	sub    $0x28,%rsp
     2854:	44 8b 6c 24 68       	mov    0x68(%rsp),%r13d
(0) 2859:	4c 8b 64 24 60       	mov    0x60(%rsp),%r12
(1) 285e:	4d 8b 14 24          	mov    (%r12),%r10
(2) 2862:	31 ff                	xor    %edi,%edi
     2864:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
     2869:	41 f6 c2 01          	test   $0x1,%r10b
     286d:	74 2c                	je     289b <udp4_lib_lookup2+0x5b>
     286f:	e9 0a 02 00 00       	jmpq   2a7e <udp4_lib_lookup2+0x23e>
     ...
     2930:	49 d1 ea             	shr    %r10
     2933:	4d 39 d5             	cmp    %r10,%r13
(3) 2936:	0f 85 22 ff ff ff    	jne    285e <udp4_lib_lookup2+0x1e>
     293c:	48 85 ff             	test   %rdi,%rdi
     293f:	74 27                	je     2968 <udp4_lib_lookup2+0x128>
     2941:	41 89 db             	mov    %ebx,%r11d
     2944:	48 8d 5f 4c          	lea    0x4c(%rdi),%rbx
     2948:	41 ba 02 00 00 00    	mov    $0x2,%r10d
     294e:	66 90                	xchg   %ax,%ax
     2950:	45 8d 72 01          	lea    0x1(%r10),%r14d
     2954:	44 89 d0             	mov    %r10d,%eax
     2957:	f0 44 0f b1 33       	lock cmpxchg %r14d,(%rbx)
     295c:	41 39 c2             	cmp    %eax,%r10d
     295f:	74 36                	je     2997 <udp4_lib_lookup2+0x157>
     2961:	85 c0                	test   %eax,%eax
     2963:	41 89 c2             	mov    %eax,%r10d
     2966:	75 e8                	jne    2950 <udp4_lib_lookup2+0x110>
     2968:	31 ff                	xor    %edi,%edi
     296a:	48 83 c4 28          	add    $0x28,%rsp
     296e:	48 89 f8             	mov    %rdi,%rax
     2971:	5b                   	pop    %rbx
     2972:	5d                   	pop    %rbp
     2973:	41 5c                	pop    %r12
     2975:	41 5d                	pop    %r13
     2977:	41 5e                	pop    %r14
     2979:	41 5f                	pop    %r15
     297b:	c3                   	retq
     297c:	0f 1f 40 00          	nopl   0x0(%rax)
     2980:	4d 8b b2 58 02 00 00 	mov    0x258(%r10),%r14
     2987:	41 f6 46 6e 10       	testb  $0x10,0x6e(%r14)
     298c:	0f 85 e6 fe ff ff    	jne    2878 <udp4_lib_lookup2+0x38>
     2992:	e9 1f ff ff ff       	jmpq   28b6 <udp4_lib_lookup2+0x76>
     2997:	48 3b 6f 30          	cmp    0x30(%rdi),%rbp
     299b:	74 3b                	je     29d8 <udp4_lib_lookup2+0x198>
     299d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     29a2:	41 39 c3             	cmp    %eax,%r11d
     29a5:	7e c3                	jle    296a <udp4_lib_lookup2+0x12a>
     29a7:	89 4c 24 10          	mov    %ecx,0x10(%rsp)
     29ab:	89 74 24 18          	mov    %esi,0x18(%rsp)
     29af:	44 89 44 24 08       	mov    %r8d,0x8(%rsp)
     29b4:	44 89 0c 24          	mov    %r9d,(%rsp)
     29b8:	e8 d3 dc ff ff       	callq  690 <sock_put>
     29bd:	8b 4c 24 10          	mov    0x10(%rsp),%ecx
     29c1:	8b 74 24 18          	mov    0x18(%rsp),%esi
     29c5:	44 8b 44 24 08       	mov    0x8(%rsp),%r8d
     29ca:	44 8b 0c 24          	mov    (%rsp),%r9d
(4) 29ce:	e9 8b fe ff ff       	jmpq   285e <udp4_lib_lookup2+0x1e>

     29d3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
     29d8:	44 0f b7 57 0c       	movzwl 0xc(%rdi),%r10d
     29dd:	66 41 83 fa 0a       	cmp    $0xa,%r10w
     29e2:	74 7f                	je     2a63 <udp4_lib_lookup2+0x223>
     29e4:	3b 4f 04             	cmp    0x4(%rdi),%ecx
     29e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     29ec:	75 b4                	jne    29a2 <udp4_lib_lookup2+0x162>
     29ee:	0f b7 9f 7a 02 00 00 	movzwl 0x27a(%rdi),%ebx
     29f5:	41 39 d8             	cmp    %ebx,%r8d
     29f8:	75 a8                	jne    29a2 <udp4_lib_lookup2+0x162>
     29fa:	8b 1f                	mov    (%rdi),%ebx
     29fc:	66 41 83 fa 02       	cmp    $0x2,%r10w
     2a01:	41 0f 94 c2          	sete   %r10b
     2a05:	45 0f b6 d2          	movzbl %r10b,%r10d
     2a09:	85 db                	test   %ebx,%ebx
     2a0b:	44 89 d0             	mov    %r10d,%eax
     2a0e:	74 0d                	je     2a1d <udp4_lib_lookup2+0x1dd>
     2a10:	39 de                	cmp    %ebx,%esi
     2a12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     2a17:	75 89                	jne    29a2 <udp4_lib_lookup2+0x162>
     2a19:	41 8d 42 02          	lea    0x2(%r10),%eax
     2a1d:	44 0f b7 97 78 02 00 	movzwl 0x278(%rdi),%r10d
     2a24:	00
     2a25:	66 45 85 d2          	test   %r10w,%r10w
     2a29:	74 0d                	je     2a38 <udp4_lib_lookup2+0x1f8>
     2a2b:	66 45 39 d7          	cmp    %r10w,%r15w
     2a2f:	0f 85 68 ff ff ff    	jne    299d <udp4_lib_lookup2+0x15d>
     2a35:	83 c0 02             	add    $0x2,%eax
     2a38:	44 8b 57 10          	mov    0x10(%rdi),%r10d
     2a3c:	45 85 d2             	test   %r10d,%r10d
     2a3f:	0f 84 5d ff ff ff    	je     29a2 <udp4_lib_lookup2+0x162>
     2a45:	8d 58 02             	lea    0x2(%rax),%ebx
     2a48:	45 39 d1             	cmp    %r10d,%r9d
     2a4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     2a50:	0f 44 c3             	cmove  %ebx,%eax
     2a53:	e9 4a ff ff ff       	jmpq   29a2 <udp4_lib_lookup2+0x162>
     2a58:	41 bb ff ff ff ff    	mov    $0xffffffff,%r11d
     2a5e:	e9 15 fe ff ff       	jmpq   2878 <udp4_lib_lookup2+0x38>
     2a63:	48 8b 9f 70 02 00 00 	mov    0x270(%rdi),%rbx
     2a6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     2a6f:	f6 43 6e 10          	testb  $0x10,0x6e(%rbx)
     2a73:	0f 85 29 ff ff ff    	jne    29a2 <udp4_lib_lookup2+0x162>
     2a79:	e9 66 ff ff ff       	jmpq   29e4 <udp4_lib_lookup2+0x1a4>
     2a7e:	49 d1 ea             	shr    %r10
     2a81:	4d 39 d5             	cmp    %r10,%r13
(5) 2a84:	0f 85 d4 fd ff ff    	jne    285e <udp4_lib_lookup2+0x1e>
     2a8a:	e9 d9 fe ff ff       	jmpq   2968 <udp4_lib_lookup2+0x128>
     2a8f:	90                   	nop

>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
