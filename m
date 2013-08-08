From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: Tree for Aug 7
Date: Wed, 07 Aug 2013 17:06:55 -0700
Message-ID: <1375920415.4004.67.camel@edumazet-glaptop>
References: <20130807.104713.1615549684239408926.davem@davemloft.net>
	 <20130807183758.GB16263@orbit.nwl.cc>
	 <20130807.162748.779496444843938176.davem@davemloft.net>
	 <20130807.163621.84433966934449459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: phil@nwl.cc, johannes@sipsolutions.net, sedat.dilek@gmail.com,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	hannes@stressinduktion.org, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130807.163621.84433966934449459.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-07 at 16:36 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 07 Aug 2013 16:27:48 -0700 (PDT)
> 
> > Look, I'm going to fix this myself, because I'm pretty tired of
> > waiting for the obvious fix.
> 
> Someone please test this:
> 
> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
> index c623861..afc02a6 100644
> --- a/include/linux/etherdevice.h
> +++ b/include/linux/etherdevice.h
> @@ -29,6 +29,7 @@
>  
>  #ifdef __KERNEL__
>  extern __be16		eth_type_trans(struct sk_buff *skb, struct net_device *dev);
> +extern __be16		__eth_type_trans(struct sk_buff *skb, struct net_device *dev);
>  extern const struct header_ops eth_header_ops;
>  
>  extern int eth_header(struct sk_buff *skb, struct net_device *dev,
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index be1f64d..35dc1be 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -146,6 +146,45 @@ int eth_rebuild_header(struct sk_buff *skb)
>  EXPORT_SYMBOL(eth_rebuild_header);
>  
>  /**
> + * __eth_type_trans - only determine the packet's protocol ID.
> + * @skb: packet
> + * @dev: device
> + */
> +__be16 __eth_type_trans(struct sk_buff *skb, struct net_device *dev)
> +{

We probably want an inline here

Or else, we are adding an extra function call in rx fast path.

(At least my compiler did this)


0000000000000470 <eth_type_trans>:
 470:	e8 00 00 00 00       	callq  475 <eth_type_trans+0x5>
			471: R_X86_64_PC32	__fentry__-0x4
 475:	48 8b 8f d0 00 00 00 	mov    0xd0(%rdi),%rcx
 47c:	48 8b 87 c8 00 00 00 	mov    0xc8(%rdi),%rax
 483:	44 8b 47 60          	mov    0x60(%rdi),%r8d
 487:	55                   	push   %rbp
 488:	48 89 77 20          	mov    %rsi,0x20(%rdi)
 48c:	48 89 ca             	mov    %rcx,%rdx
 48f:	48 89 e5             	mov    %rsp,%rbp
 492:	48 29 c2             	sub    %rax,%rdx
 495:	41 83 f8 0d          	cmp    $0xd,%r8d
 499:	66 89 97 b8 00 00 00 	mov    %dx,0xb8(%rdi)
 4a0:	76 19                	jbe    4bb <eth_type_trans+0x4b>
 4a2:	41 83 e8 0e          	sub    $0xe,%r8d
 4a6:	44 3b 47 64          	cmp    0x64(%rdi),%r8d
 4aa:	44 89 47 60          	mov    %r8d,0x60(%rdi)
 4ae:	72 36                	jb     4e6 <eth_type_trans+0x76>
 4b0:	48 83 c1 0e          	add    $0xe,%rcx
 4b4:	48 89 8f d0 00 00 00 	mov    %rcx,0xd0(%rdi)
 4bb:	81 e2 ff ff 00 00    	and    $0xffff,%edx
 4c1:	48 01 d0             	add    %rdx,%rax
 4c4:	f6 00 01             	testb  $0x1,(%rax)
 4c7:	75 2e                	jne    4f7 <eth_type_trans+0x87>
 4c9:	48 8b 96 88 02 00 00 	mov    0x288(%rsi),%rdx
 4d0:	48 8b 00             	mov    (%rax),%rax
 4d3:	48 33 02             	xor    (%rdx),%rax
 4d6:	48 c1 e0 10          	shl    $0x10,%rax
 4da:	48 85 c0             	test   %rax,%rax
 4dd:	75 09                	jne    4e8 <eth_type_trans+0x78>
 4df:	e8 00 00 00 00       	callq  4e4 <eth_type_trans+0x74>
			4e0: R_X86_64_PC32	__eth_type_trans-0x4
 4e4:	5d                   	pop    %rbp
 4e5:	c3                   	retq   
 4e6:	0f 0b                	ud2    
 4e8:	0f b6 47 75          	movzbl 0x75(%rdi),%eax
 4ec:	83 e0 f8             	and    $0xfffffff8,%eax
 4ef:	83 c8 03             	or     $0x3,%eax
 4f2:	88 47 75             	mov    %al,0x75(%rdi)
 4f5:	eb e8                	jmp    4df <eth_type_trans+0x6f>
 4f7:	48 8b 00             	mov    (%rax),%rax
 4fa:	48 33 86 b8 02 00 00 	xor    0x2b8(%rsi),%rax
 501:	48 c1 e0 10          	shl    $0x10,%rax
 505:	48 85 c0             	test   %rax,%rax
 508:	0f b6 47 75          	movzbl 0x75(%rdi),%eax
 50c:	75 0b                	jne    519 <eth_type_trans+0xa9>
 50e:	83 e0 f8             	and    $0xfffffff8,%eax
 511:	83 c8 01             	or     $0x1,%eax
 514:	88 47 75             	mov    %al,0x75(%rdi)
 517:	eb c6                	jmp    4df <eth_type_trans+0x6f>
 519:	83 e0 f8             	and    $0xfffffff8,%eax
 51c:	83 c8 02             	or     $0x2,%eax
 51f:	88 47 75             	mov    %al,0x75(%rdi)
 522:	eb bb                	jmp    4df <eth_type_trans+0x6f>
