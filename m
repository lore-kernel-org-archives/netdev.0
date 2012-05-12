From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] codel: use Newton method instead of sqrt()
 and divides
Date: Sat, 12 May 2012 23:48:44 +0200
Message-ID: <1336859324.31653.1385.camel@edumazet-glaptop>
References: <1336829533.31653.1108.camel@edumazet-glaptop>
	 <20120512.155259.1178343836887150194.davem@davemloft.net>
	 <1336855256.31653.1329.camel@edumazet-glaptop>
	 <20120512.164513.1156706853054390966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dave.taht@bufferbloat.net, netdev@vger.kernel.org,
	nichols@pollere.com, van@pollere.net, codel@lists.bufferbloat.net,
	ycheng@google.com, mattmathis@google.com, therbert@google.com,
	shemminger@vyatta.com, nanditad@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:61613 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723Ab2ELVst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 17:48:49 -0400
Received: by weyu7 with SMTP id u7so1052303wey.19
        for <netdev@vger.kernel.org>; Sat, 12 May 2012 14:48:48 -0700 (PDT)
In-Reply-To: <20120512.164513.1156706853054390966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-05-12 at 16:45 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 12 May 2012 22:40:56 +0200
> 
> > 24 bit of precision for the reciprocal value is more than enough (Van
> > suggested 16 bits in fact), so we have actually room for 7 bits if
> > needed.
> 
> Using a u16 would also work for me.

I tried it but it gives noticeable errors for count > 16000, and no
speed gain.


count=16525 scale=0 sqrt(scaled_count)=2056 reciprocal(sq)=1fe0200
Newton=235
  interval/sqrt(16525) = 
	777909 (float compute)
	778210 (integer approx)
	777926 (int_sqrt_div)
	862121 (Newton approx)

And if a flow is really agressive, count can grow above 10^6

> 
> > By the way, gcc on x86 generates nice "and 0xfffffffe,%eax" instruction
> > for (vars->rec_inv_sqrt << 1).
> 
> Yeah but what do stores of ->rec_inv_sqrt look like?

The load is "shr %edi" as in :
and the store an "or %ecx,%esi"

 5f2:	8b 72 08             	mov    0x8(%rdx),%esi
 5f5:	44 8b 02             	mov    (%rdx),%r8d
 5f8:	89 f7                	mov    %esi,%edi
 5fa:	41 83 c0 01          	add    $0x1,%r8d    vars->count + 1
 5fe:	83 e6 01             	and    $0x1,%esi    vars->dropping in esi

 601:	d1 ef                	shr    %edi
 603:	44 89 02             	mov    %r8d,(%rdx)  vars->count++;
 606:	45 89 c0             	mov    %r8d,%r8d
 609:	89 ff                	mov    %edi,%edi
 60b:	48 89 f9             	mov    %rdi,%rcx
 60e:	48 0f af cf          	imul   %rdi,%rcx

 612:	48 c1 e9 1f          	shr    $0x1f,%rcx
 616:	49 0f af c8          	imul   %r8,%rcx
 61a:	49 b8 00 00 00 80 01 	mov    $0x180000000,%r8
 621:	00 00 00 
 624:	49 29 c8             	sub    %rcx,%r8
 627:	4c 89 c1             	mov    %r8,%rcx
 62a:	48 0f af cf          	imul   %rdi,%rcx
 62e:	48 c1 e9 20          	shr    $0x20,%rcx
 632:	01 c9                	add    %ecx,%ecx
 634:	09 ce                	or     %ecx,%esi        combine the two fields
 636:	89 72 08             	mov    %esi,0x8(%rdx)   final store

 
Using 24bits generates roughly same code. (constants are different)
