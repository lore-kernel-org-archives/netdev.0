From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [BUG] in inet6_create
Date: Tue, 06 Nov 2007 19:06:23 +0300
Message-ID: <473090FF.7000707@openvz.org>
References: <472A3218.20708@tiscali.nl> <472A41AF.2030704@tiscali.nl> <472AEAB0.5090709@openvz.org> <472B638C.1030001@tiscali.nl> <47302255.7060708@openvz.org> <47308BEC.1040302@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: Roel Kluin <12o3l@tiscali.nl>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <47308BEC.1040302@tiscali.nl>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roel Kluin wrote:
> Pavel Emelyanov wrote:
>> Roel Kluin wrote:
>>> Pavel Emelyanov wrote:
>>>> Roel Kluin wrote:
>>>>> Roel Kluin wrote:
>>>>>> I got this bug recently, I am not sure whether this is related to any previously 
>>>>>> reported ones. It was a recently pulled git kernel. Also I have been hacking my
>>>>>> kernel a bit lately, but I think that I haven't got any changes in the currently
>>>>>> running kernel.
>>>>>>
>>>>>> FYI: my network card was not running (module not loaded, and I just started 
>>>>>> thunderbird)
>>>>>>
>>>>>> More information needed?
>>>> Yes, please.
>>>>
>>>> Can you send us the disasm (objdump -dr) of your ipv6 module. 
>>>> More precisely - I need the disassembled inet6_create() function to
>>>> figure out where exactly this thing happened.
>>> I was very lucky to still be able to produce this: When the bug hit me, I had just
>>> recompiled a new kernel, however, since I had previously git-pulled, (but not yet
>>> compiled) the old module was not overwritten.
>>>
>>> to answer the question in your other mail - whether I hacked this kernel - I am not
>>> 100% certain, I am certain, however that I did not touch IPv6 code, and my changes
>>> to net code were very trivial oneliner changes that I have previously posted, and
>>> were generally accepted as fixes.
>>> --
>>> 000002f0 <inet6_create>:
>> Hm... The oops says that the buggy place is <inet6_create>+0x5f, that is
>> (according to this dump) 0x2f0 + 0x5f = 0x34f, but:
>>
>> 1. there's no instruction at this address (there are 0x34e and 0x355)
>> 2. the codeline (... 1c <8b> 00 0f 18 ...) is not present here
>>
>> There's something wrong with this oops...
> 
> hmmm, I see my mistake:
> I _was_ already running the 2.6.24-rc1 kernel. It even says so in the BUG report

Brrr... I'm completely confused. What was the kernel that oops-ed?
2.6.24-rc, net-2.6.24-rc1 or net-2.6.24-rc1-with-your-patches?

> Since the module is already overwritten, does it still help to make the objdump?
> 
> Ok, I'll check for the address... yes it exists 

Yup. My first guess was correct - the inetsw6 list is broken - there's
some NULL pointer in it. Looking at the code I see that this list
is accessed for modifications under the spinlock and that it is properly
initialized in the ->init callback before any code gets the access to this
list. No ideas why this can happen... :(

> Sorry for my mistake, the objdump for this module is below. note however that the
> module has been overwritten previously after kernel compilation.
> 
>> Is this reproducible? If yes, can you try the non-patched net-2.6 kernel.
> 
> I'll try to reproduce it. I'll confirm it when it happens again.

Yes, please.

> --
> 000002f0 <inet6_create>:
>      2f0:	55                   	push   %ebp
>      2f1:	bd 9f ff ff ff       	mov    $0xffffff9f,%ebp
>      2f6:	57                   	push   %edi
>      2f7:	89 cf                	mov    %ecx,%edi
>      2f9:	56                   	push   %esi
>      2fa:	53                   	push   %ebx
>      2fb:	83 ec 20             	sub    $0x20,%esp
>      2fe:	3d 00 00 00 00       	cmp    $0x0,%eax
> 			2ff: R_386_32	init_net
>      303:	89 54 24 10          	mov    %edx,0x10(%esp)
>      307:	74 0a                	je     313 <inet6_create+0x23>
>      309:	83 c4 20             	add    $0x20,%esp
>      30c:	89 e8                	mov    %ebp,%eax
>      30e:	5b                   	pop    %ebx
>      30f:	5e                   	pop    %esi
>      310:	5f                   	pop    %edi
>      311:	5d                   	pop    %ebp
>      312:	c3                   	ret    
>      313:	8b 72 20             	mov    0x20(%edx),%esi
>      316:	8d 46 fe             	lea    -0x2(%esi),%eax
>      319:	66 83 f8 01          	cmp    $0x1,%ax
>      31d:	76 0e                	jbe    32d <inet6_create+0x3d>
>      31f:	8b 0d 00 00 00 00    	mov    0x0,%ecx
> 			321: R_386_32	inet_ehash_secret
>      325:	85 c9                	test   %ecx,%ecx
>      327:	0f 84 12 02 00 00    	je     53f <inet6_create+0x24f>
>      32d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
>      334:	00 
>      335:	0f bf c6             	movswl %si,%eax
>      338:	c1 e0 03             	shl    $0x3,%eax
>      33b:	8b 98 00 00 00 00    	mov    0x0(%eax),%ebx
> 			33d: R_386_32	.bss
>      341:	8d 90 00 00 00 00    	lea    0x0(%eax),%edx
> 			343: R_386_32	.bss
>      347:	89 5c 24 1c          	mov    %ebx,0x1c(%esp)
>      34b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
>      34f:	8b 00                	mov    (%eax),%eax
>      351:	8d 44 20 00          	lea    0x0(%eax),%eax
>      355:	39 d3                	cmp    %edx,%ebx
>      357:	bd a2 ff ff ff       	mov    $0xffffffa2,%ebp
>      35c:	75 36                	jne    394 <inet6_create+0xa4>
>      35e:	e9 f3 01 00 00       	jmp    556 <inet6_create+0x266>
>      363:	85 ff                	test   %edi,%edi
>      365:	0f 84 25 02 00 00    	je     590 <inet6_create+0x2a0>
>      36b:	66 85 c0             	test   %ax,%ax
>      36e:	66 90                	xchg   %ax,%ax
>      370:	74 31                	je     3a3 <inet6_create+0xb3>
>      372:	8b 1b                	mov    (%ebx),%ebx
>      374:	89 5c 24 1c          	mov    %ebx,0x1c(%esp)
>      378:	8b 44 24 1c          	mov    0x1c(%esp),%eax
>      37c:	8b 00                	mov    (%eax),%eax
>      37e:	8d 44 20 00          	lea    0x0(%eax),%eax
>      382:	0f bf c6             	movswl %si,%eax
>      385:	8d 04 c5 00 00 00 00 	lea    0x0(,%eax,8),%eax
> 			388: R_386_32	.bss
>      38c:	39 d8                	cmp    %ebx,%eax
>      38e:	0f 84 bd 01 00 00    	je     551 <inet6_create+0x261>
>      394:	0f b7 43 0a          	movzwl 0xa(%ebx),%eax
>      398:	0f b7 c8             	movzwl %ax,%ecx
>      39b:	39 cf                	cmp    %ecx,%edi
>      39d:	75 c4                	jne    363 <inet6_create+0x73>
>      39f:	85 ff                	test   %edi,%edi
>      3a1:	74 cf                	je     372 <inet6_create+0x82>
>      3a3:	8b 43 14             	mov    0x14(%ebx),%eax
>      3a6:	85 c0                	test   %eax,%eax
>      3a8:	7e 12                	jle    3bc <inet6_create+0xcc>
>      3aa:	e8 fc ff ff ff       	call   3ab <inet6_create+0xbb>
> 			3ab: R_386_PC32	capable
>      3af:	85 c0                	test   %eax,%eax
>      3b1:	bd ff ff ff ff       	mov    $0xffffffff,%ebp
>      3b6:	0f 84 4d ff ff ff    	je     309 <inet6_create+0x19>
>      3bc:	8b 43 10             	mov    0x10(%ebx),%eax
>      3bf:	8b 54 24 10          	mov    0x10(%esp),%edx
>      3c3:	89 42 08             	mov    %eax,0x8(%edx)
>      3c6:	0f b6 43 18          	movzbl 0x18(%ebx),%eax
>      3ca:	8b 73 0c             	mov    0xc(%ebx),%esi
>      3cd:	88 44 24 17          	mov    %al,0x17(%esp)
>      3d1:	0f b6 53 19          	movzbl 0x19(%ebx),%edx
>      3d5:	88 54 24 16          	mov    %dl,0x16(%esp)
>      3d9:	8b 56 70             	mov    0x70(%esi),%edx
>      3dc:	85 d2                	test   %edx,%edx
>      3de:	0f 84 17 02 00 00    	je     5fb <inet6_create+0x30b>
>      3e4:	b9 d0 00 00 00       	mov    $0xd0,%ecx
>      3e9:	ba 0a 00 00 00       	mov    $0xa,%edx
>      3ee:	b8 00 00 00 00       	mov    $0x0,%eax
> 			3ef: R_386_32	init_net
>      3f3:	89 34 24             	mov    %esi,(%esp)
>      3f6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
>      3fd:	00 
>      3fe:	bd 97 ff ff ff       	mov    $0xffffff97,%ebp
>      403:	e8 fc ff ff ff       	call   404 <inet6_create+0x114>
> 			404: R_386_PC32	sk_alloc
>      408:	85 c0                	test   %eax,%eax
>      40a:	89 c6                	mov    %eax,%esi
>      40c:	0f 84 f7 fe ff ff    	je     309 <inet6_create+0x19>
>      412:	89 c2                	mov    %eax,%edx
>      414:	8b 44 24 10          	mov    0x10(%esp),%eax
>      418:	e8 fc ff ff ff       	call   419 <inet6_create+0x129>
> 			419: R_386_PC32	sock_init_data
>      41d:	80 64 24 17 03       	andb   $0x3,0x17(%esp)
>      422:	0f b6 54 24 17       	movzbl 0x17(%esp),%edx
>      427:	0f b6 46 28          	movzbl 0x28(%esi),%eax
>      42b:	c1 e2 02             	shl    $0x2,%edx
>      42e:	83 e0 f3             	and    $0xfffffff3,%eax
>      431:	09 d0                	or     %edx,%eax
>      433:	88 46 28             	mov    %al,0x28(%esi)
>      436:	0f b6 44 24 16       	movzbl 0x16(%esp),%eax
>      43b:	a8 01                	test   $0x1,%al
>      43d:	74 04                	je     443 <inet6_create+0x153>
>      43f:	c6 46 03 01          	movb   $0x1,0x3(%esi)
>      443:	0f b6 96 5b 01 00 00 	movzbl 0x15b(%esi),%edx
>      44a:	c1 e8 02             	shr    $0x2,%eax
>      44d:	83 e0 01             	and    $0x1,%eax
>      450:	01 c0                	add    %eax,%eax
>      452:	83 e2 fd             	and    $0xfffffffd,%edx
>      455:	09 c2                	or     %eax,%edx
>      457:	88 96 5b 01 00 00    	mov    %dl,0x15b(%esi)
>      45d:	8b 44 24 10          	mov    0x10(%esp),%eax
>      461:	66 83 78 20 03       	cmpw   $0x3,0x20(%eax)
>      466:	0f 84 43 01 00 00    	je     5af <inet6_create+0x2bf>
>      46c:	89 fa                	mov    %edi,%edx
>      46e:	c7 86 34 01 00 00 00 	movl   $0x0,0x134(%esi)
>      475:	00 00 00 
> 			474: R_386_32	inet_sock_destruct
>      478:	66 c7 06 0a 00       	movw   $0xa,(%esi)
>      47d:	88 56 29             	mov    %dl,0x29(%esi)
>      480:	8b 43 0c             	mov    0xc(%ebx),%eax
>      483:	8b 40 40             	mov    0x40(%eax),%eax
>      486:	89 86 30 01 00 00    	mov    %eax,0x130(%esi)
>      48c:	8b 46 20             	mov    0x20(%esi),%eax
>      48f:	8b 48 74             	mov    0x74(%eax),%ecx
>      492:	83 e9 70             	sub    $0x70,%ecx
>      495:	8d 0c 0e             	lea    (%esi,%ecx,1),%ecx
>      498:	89 8e 38 01 00 00    	mov    %ecx,0x138(%esi)
>      49e:	0f b6 41 46          	movzbl 0x46(%ecx),%eax
>      4a2:	66 c7 41 3c ff ff    	movw   $0xffff,0x3c(%ecx)
>      4a8:	66 c7 41 3e ff ff    	movw   $0xffff,0x3e(%ecx)
>      4ae:	83 e0 e7             	and    $0xffffffe7,%eax
>      4b1:	83 c8 09             	or     $0x9,%eax
>      4b4:	88 41 46             	mov    %al,0x46(%ecx)
>      4b7:	0f b6 15 00 00 00 00 	movzbl 0x0,%edx
> 			4ba: R_386_32	sysctl_ipv6_bindv6only
>      4be:	83 e0 df             	and    $0xffffffdf,%eax
>      4c1:	83 e2 01             	and    $0x1,%edx
>      4c4:	c1 e2 05             	shl    $0x5,%edx
>      4c7:	09 d0                	or     %edx,%eax
>      4c9:	88 41 46             	mov    %al,0x46(%ecx)
>      4cc:	80 8e 5b 01 00 00 10 	orb    $0x10,0x15b(%esi)
>      4d3:	66 c7 86 4c 01 00 00 	movw   $0xffff,0x14c(%esi)
>      4da:	ff ff 
>      4dc:	c6 86 59 01 00 00 01 	movb   $0x1,0x159(%esi)
>      4e3:	c7 86 5c 01 00 00 00 	movl   $0x0,0x15c(%esi)
>      4ea:	00 00 00 
>      4ed:	c7 86 64 01 00 00 00 	movl   $0x0,0x164(%esi)
>      4f4:	00 00 00 
>      4f7:	a1 04 00 00 00       	mov    0x4,%eax
> 			4f8: R_386_32	ipv4_config
>      4fc:	85 c0                	test   %eax,%eax
>      4fe:	0f b7 86 46 01 00 00 	movzwl 0x146(%esi),%eax
>      505:	0f 94 86 5a 01 00 00 	sete   0x15a(%esi)
>      50c:	66 85 c0             	test   %ax,%ax
>      50f:	0f 85 82 00 00 00    	jne    597 <inet6_create+0x2a7>
>      515:	8b 46 20             	mov    0x20(%esi),%eax
>      518:	31 ed                	xor    %ebp,%ebp
>      51a:	8b 50 14             	mov    0x14(%eax),%edx
>      51d:	85 d2                	test   %edx,%edx
>      51f:	0f 84 e4 fd ff ff    	je     309 <inet6_create+0x19>
>      525:	89 f0                	mov    %esi,%eax
>      527:	ff d2                	call   *%edx
>      529:	85 c0                	test   %eax,%eax
>      52b:	89 c5                	mov    %eax,%ebp
>      52d:	0f 84 d6 fd ff ff    	je     309 <inet6_create+0x19>
>      533:	89 f0                	mov    %esi,%eax
>      535:	e8 fc ff ff ff       	call   536 <inet6_create+0x246>
> 			536: R_386_PC32	sk_common_release
>      53a:	e9 ca fd ff ff       	jmp    309 <inet6_create+0x19>
>      53f:	90                   	nop    
>      540:	e8 fc ff ff ff       	call   541 <inet6_create+0x251>
> 			541: R_386_PC32	build_ehash_secret
>      545:	8b 44 24 10          	mov    0x10(%esp),%eax
>      549:	8b 70 20             	mov    0x20(%eax),%esi
>      54c:	e9 dc fd ff ff       	jmp    32d <inet6_create+0x3d>
>      551:	bd a3 ff ff ff       	mov    $0xffffffa3,%ebp
>      556:	83 7c 24 18 02       	cmpl   $0x2,0x18(%esp)
>      55b:	0f 84 a8 fd ff ff    	je     309 <inet6_create+0x19>
>      561:	ff 44 24 18          	incl   0x18(%esp)
>      565:	83 7c 24 18 01       	cmpl   $0x1,0x18(%esp)
>      56a:	74 64                	je     5d0 <inet6_create+0x2e0>
>      56c:	89 7c 24 08          	mov    %edi,0x8(%esp)
>      570:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
>      577:	00 
>      578:	c7 04 24 1b 00 00 00 	movl   $0x1b,(%esp)
> 			57b: R_386_32	.rodata.str1.1
>      57f:	e8 fc ff ff ff       	call   580 <inet6_create+0x290>
> 			580: R_386_PC32	request_module
>      584:	8b 44 24 10          	mov    0x10(%esp),%eax
>      588:	8b 70 20             	mov    0x20(%eax),%esi
>      58b:	e9 a5 fd ff ff       	jmp    335 <inet6_create+0x45>
>      590:	89 cf                	mov    %ecx,%edi
>      592:	e9 0c fe ff ff       	jmp    3a3 <inet6_create+0xb3>
>      597:	8b 56 20             	mov    0x20(%esi),%edx
>      59a:	66 c1 c0 08          	rol    $0x8,%ax
>      59e:	66 89 86 54 01 00 00 	mov    %ax,0x154(%esi)
>      5a5:	89 f0                	mov    %esi,%eax
>      5a7:	ff 52 44             	call   *0x44(%edx)
>      5aa:	e9 66 ff ff ff       	jmp    515 <inet6_create+0x225>
>      5af:	81 ff ff 00 00 00    	cmp    $0xff,%edi
>      5b5:	66 89 be 46 01 00 00 	mov    %di,0x146(%esi)
>      5bc:	0f 85 aa fe ff ff    	jne    46c <inet6_create+0x17c>
>      5c2:	83 ca 08             	or     $0x8,%edx
>      5c5:	88 96 5b 01 00 00    	mov    %dl,0x15b(%esi)
>      5cb:	e9 9c fe ff ff       	jmp    46c <inet6_create+0x17c>
>      5d0:	0f bf c6             	movswl %si,%eax
>      5d3:	89 7c 24 08          	mov    %edi,0x8(%esp)
>      5d7:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
>      5de:	00 
>      5df:	89 44 24 0c          	mov    %eax,0xc(%esp)
>      5e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
> 			5e6: R_386_32	.rodata.str1.1
>      5ea:	e8 fc ff ff ff       	call   5eb <inet6_create+0x2fb>
> 			5eb: R_386_PC32	request_module
>      5ef:	8b 54 24 10          	mov    0x10(%esp),%edx
>      5f3:	8b 72 20             	mov    0x20(%edx),%esi
>      5f6:	e9 3a fd ff ff       	jmp    335 <inet6_create+0x45>
>      5fb:	c7 44 24 0c a2 00 00 	movl   $0xa2,0xc(%esp)
>      602:	00 
>      603:	c7 44 24 08 a0 00 00 	movl   $0xa0,0x8(%esp)
>      60a:	00 
> 			607: R_386_32	.rodata.str1.4
>      60b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
>      612:	00 
> 			60f: R_386_32	.rodata.str1.1
>      613:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
> 			616: R_386_32	.rodata.str1.4
>      61a:	e8 fc ff ff ff       	call   61b <inet6_create+0x32b>
> 			61b: R_386_PC32	printk
>      61f:	e9 c0 fd ff ff       	jmp    3e4 <inet6_create+0xf4>
>      624:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
>      62a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi
> 
> 00000630 <inet6_destroy_sock>:
> 

