From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [bisected] [oops] gre/gro oops in skb_gro_receive+0x118/0x453
Date: Fri, 16 May 2014 20:38:35 +0300
Message-ID: <20140516203835.5941ea3f@vostro>
References: <20140516104014.607d2d0f@vostro>
	<1400245157.7973.150.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140516173443.0b40157e@vostro>
	<1400257768.7973.204.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140516194037.4486cd63@vostro>
	<1400259027.7973.211.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140516200112.114cf1bb@vostro>
	<1400260430.7973.222.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:55147 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758098AbaEPRiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 13:38:18 -0400
Received: by mail-lb0-f182.google.com with SMTP id z11so1977989lbi.27
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 10:38:16 -0700 (PDT)
In-Reply-To: <1400260430.7973.222.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 May 2014 10:13:50 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Fri, 2014-05-16 at 20:01 +0300, Timo Teras wrote:
> Documentation/oops-tracing.txtscripts/decodecode
> > I believe it crashes, but cannot say with 100% certainty. I can
> > test later on if needed. Based on earlier experiment, the only way
> > to avoid the crash was to turn off gro on gre1.
> > 
> > In any case I don't think it should make any effect, since the GRE
> > packets arrive IPseced. eth0 is receiving ESP packets - and I
> > believe there's no ESP GRO support. Only after decryption they go
> > to gre1, so gre1 gro is basically the place where received packets
> > are coalesced.
> 
> Oh this is definitely useful.
> 
> I thought we might have a problem now with have GRE enabled GRO in
> native GRO layer. I was wondering if the double attempt to GRO
> packets a second time was a problem.
> 
> So it looks like ESP provides packets that are not very gentle for
> skb_gro_receive()...
> 
> Could you provide scripts/decodecode output ?

[ 286.930813] Code: 54 29 56 50 c7 46 54 00 00 00 00 29
d1 89 8e b4 00 00 00 e9 09 03 00 00 8b 45 f0 f6 80 87
00 00 00 01 8b 45 e8 0f 84 cf 00 00 00 <8a> 00 88 45 d8
0f b6 d0 8b 45 f0 8b 80 ac 00 00 00 89 45 d4 05

All code
========
   0:	54                   	push   %esp
   1:	29 56 50             	sub    %edx,0x50(%esi)
   4:	c7 46 54 00 00 00 00 	movl   $0x0,0x54(%esi)
   b:	29 d1                	sub    %edx,%ecx
   d:	89 8e b4 00 00 00    	mov    %ecx,0xb4(%esi)
  13:	e9 09 03 00 00       	jmp    0x321
  18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1b:	f6 80 87 00 00 00 01 	testb  $0x1,0x87(%eax)
  22:	8b 45 e8             	mov    -0x18(%ebp),%eax
  25:	0f 84 cf 00 00 00    	je     0xfa
  2b:*	8a 00                	mov    (%eax),%al		<-- trapping instruction
  2d:	88 45 d8             	mov    %al,-0x28(%ebp)
  30:	0f b6 d0             	movzbl %al,%edx
  33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  36:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  3c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  3f:	05                   	.byte 0x5

Code starting with the faulting instruction
===========================================
   0:	8a 00                	mov    (%eax),%al
   2:	88 45 d8             	mov    %al,-0x28(%ebp)
   5:	0f b6 d0             	movzbl %al,%edx
   8:	8b 45 f0             	mov    -0x10(%ebp),%eax
   b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  11:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  14:	05                   	.byte 0x5

Unfortunately, I do not have fully matching identical .s, or debug
built kernel. I can do that on Monday if this does not help.

Additionally, the .s file from separate, but similar build, that seems
to have matching assembly is as follows:

	movl	168(%esi), %edx	# MEM[(const struct sk_buff *)skb_19(D)].end, D.55920
	subl	172(%esi), %edx	# MEM[(const struct sk_buff *)skb_19(D)].head, D.55920
	movb	$1, 43(%esi)	#, MEM[(struct napi_gro_cb *)skb_19(D) + 24B].free
	leal	-384(%ecx), %eax	#, delta_truesize
	subl	%edx, %eax	# D.55920, delta_truesize
	movl	84(%esi), %edx	# skb_19(D)->data_len, D.55922
	subl	%edx, 80(%esi)	# D.55922, skb_19(D)->len
	movl	$0, 84(%esi)	#, skb_19(D)->data_len
	subl	%edx, %ecx	# D.55922, tmp300
	movl	%ecx, 180(%esi)	# tmp300, skb_19(D)->truesize
	jmp	.L572	#
.L568:
	movl	-16(%ebp), %eax	# %sfp, skb
	testb	$1, 135(%eax)	#, *skb_19(D)
	movl	-24(%ebp), %eax	# %sfp, D.55921
	je	.L573	#,
## Crash on the next opcode
	movb	(%eax), %al	# MEM[(struct skb_shared_info *)_29].nr_frags, D.55923
	movb	%al, -40(%ebp)	# D.55923, %sfp
	movzbl	%al, %edx	# D.55923, nr_frags
	movl	-16(%ebp), %eax	# %sfp, skb
	movl	172(%eax), %eax	# skb_19(D)->head, skb_19(D)->head
	movl	%eax, -44(%ebp)	# skb_19(D)->head, %sfp
	addl	$1073741824, %eax	#, page
	shrl	$12, %eax	#, page
	sall	$5, %eax	#, page
	addl	mem_map, %eax	# mem_map, page
	movl	(%eax), %ecx	# MEM[(const long unsigned int *)page_213], D.55925
	movl	%eax, %edi	# page, D.55929
	andb	$128, %ch	#, D.55925
	je	.L574	#,
	movl	28(%eax), %esi	# page_213->D.14510.first_page, head
	movl	(%eax), %ecx	# MEM[(const long unsigned int *)page_213], D.55925
	andb	$128, %ch	#, D.55925
	je	.L587	#,
	movl	%esi, %edi	# head, D.55929
	jmp	.L574	#
