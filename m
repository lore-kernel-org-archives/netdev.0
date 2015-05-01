From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/3] etherdev: Avoid unnecessary byte swap in check for
 Ethertype
Date: Thu, 30 Apr 2015 17:41:04 -0700
Message-ID: <5542CBA0.2030907@gmail.com>
References: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>	 <20150430215348.1798.15509.stgit@ahduyck-vm-fedora22>	 <1430435029.3711.106.camel@edumazet-glaptop2.roam.corp.google.com>	 <5542B9A0.70605@gmail.com> <1430439180.3711.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34150 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbbEAAlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 20:41:06 -0400
Received: by pacyx8 with SMTP id yx8so75762093pac.1
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 17:41:05 -0700 (PDT)
In-Reply-To: <1430439180.3711.110.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2015 05:13 PM, Eric Dumazet wrote:
> On Thu, 2015-04-30 at 16:24 -0700, Alexander Duyck wrote:
>
>> Actually a byte operation itself is not faster.  Note in the next line
>> we are returning the value.  So what you typically end up with by doing
>> it that way would be 2 reads, one for the u8 and one for the u16 return
>> value.  That is actually what I am trying to address in the second patch
>> in the set since we were doing a 8b test on the first byte of the
>> address followed by a 64b read.
>>
>> The advantage with the way I wrote this is that the compiler itself
>> should be able to sort out how it wants to test the value while
>> accessing it in a 16b size.  So at worst case it is a mask and compare,
>> followed by a return of the value.  From what I have seen the compiler
>> seems to be smart enough on x86 anyway to just convert this into a one
>> byte compare on AL and then return the result in AX.  I would suspect
>> that for bit-endian systems it would likely just perform the compare.
>>
>
> My compiler (4.8.2 (Ubuntu 4.8.2-19ubuntu1)) does the following :
>
>   62d:	0f b7 42 0c          	movzwl 0xc(%rdx),%eax
>   631:	0f b6 d0             	movzbl %al,%edx
>   634:	83 fa 05             	cmp    $0x5,%edx
>   637:	7e 02                	jle    63b <eth_type_trans+0x8b>
>   639:	c9                   	leaveq
>   63a:	c3                   	retq
>
> Presumably this would be possible
>
>            	movzwl 0xc(%rdx),%eax
>              	cmp    $0x5,%al
>                 	jle    63b <eth_type_trans+0x8b>
>                 	leaveq
>                 	retq
>
>

My compiler (5.0.1 (Red Hat 5.0.1-0.1)) does like what you have in the 
"would be possible" example.  What I end up with is something like this:
  648:   0f b7 42 0c             movzwl 0xc(%rdx),%eax
  64c:   3c 05                   cmp    $0x5,%al
  64e:   76 40                   jbe    690 <eth_type_trans+0xc0>

The assembler before my patch was:
  652:   0f b7 40 0c             movzwl 0xc(%rax),%eax
  656:   89 c2                   mov    %eax,%edx
  658:   66 c1 c2 08             rol    $0x8,%dx
  65c:   0f b7 d2                movzwl %dx,%edx
  65f:   81 fa ff 05 00 00       cmp    $0x5ff,%edx
  665:   7e 41                   jle    6a8 <eth_type_trans+0xd8>

The savings isn't meant to be anything huge for the patch, maybe a cycle 
or two.  I suspect the before on your system is probably something 
similar to what I had so we are still probably dropping at least 2 
instructions.

- Alex
