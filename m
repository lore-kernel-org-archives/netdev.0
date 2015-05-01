From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] etherdev: Avoid unnecessary byte swap in check for
 Ethertype
Date: Thu, 30 Apr 2015 17:13:00 -0700
Message-ID: <1430439180.3711.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
	 <20150430215348.1798.15509.stgit@ahduyck-vm-fedora22>
	 <1430435029.3711.106.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5542B9A0.70605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:35363 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbbEAAND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 20:13:03 -0400
Received: by igbyr2 with SMTP id yr2so28655571igb.0
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 17:13:02 -0700 (PDT)
In-Reply-To: <5542B9A0.70605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-30 at 16:24 -0700, Alexander Duyck wrote:

> Actually a byte operation itself is not faster.  Note in the next line 
> we are returning the value.  So what you typically end up with by doing 
> it that way would be 2 reads, one for the u8 and one for the u16 return 
> value.  That is actually what I am trying to address in the second patch 
> in the set since we were doing a 8b test on the first byte of the 
> address followed by a 64b read.
> 
> The advantage with the way I wrote this is that the compiler itself 
> should be able to sort out how it wants to test the value while 
> accessing it in a 16b size.  So at worst case it is a mask and compare, 
> followed by a return of the value.  From what I have seen the compiler 
> seems to be smart enough on x86 anyway to just convert this into a one 
> byte compare on AL and then return the result in AX.  I would suspect 
> that for bit-endian systems it would likely just perform the compare.
> 

My compiler (4.8.2 (Ubuntu 4.8.2-19ubuntu1)) does the following :

 62d:	0f b7 42 0c          	movzwl 0xc(%rdx),%eax
 631:	0f b6 d0             	movzbl %al,%edx
 634:	83 fa 05             	cmp    $0x5,%edx
 637:	7e 02                	jle    63b <eth_type_trans+0x8b>
 639:	c9                   	leaveq 
 63a:	c3                   	retq   

Presumably this would be possible

          	movzwl 0xc(%rdx),%eax
            	cmp    $0x5,%al
               	jle    63b <eth_type_trans+0x8b>
               	leaveq 
               	retq   
