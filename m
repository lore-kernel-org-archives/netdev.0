From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: Still oopsing in nf_nat_move_storage()
Date: Thu, 31 Jan 2008 13:03:03 -0500
Message-ID: <47A20D57.5040907@redhat.com>
References: <479F5E5A.8050108@redhat.com> <479F5FDC.5040903@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <479F5FDC.5040903@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/29/2008 12:18 PM, Patrick McHardy wrote:
> Chuck Ebbert wrote:
>> nf_nat_move_storage():
>> /usr/src/debug/kernel-2.6.23/linux-2.6.23.i686/net/ipv4/netfilter/nf_nat_core.c:612
>>
>>       87:       f7 47 64 80 01 00 00    testl  $0x180,0x64(%edi)
>>       8e:       74 39                   je     c9
>> <nf_nat_move_storage+0x65>
>>
>> line 612:
>>         if (!(ct->status & IPS_NAT_DONE_MASK))
>>                 return;
>>
>> ct is NULL
> 
> The current kernel (and 2.6.23-stable) have:
> 
>         if (!ct || !(ct->status & IPS_NAT_DONE_MASK))
>                 return;
> 
> so it seems you're using an old version.

Sorry, I re-used the analysis from before that change went in. I now
have an oops report from 2.6.23.14 on x86_64.

It is oopsing there, and only on x86_64 now, because x86_64 refuses to
use a non-canonical address. ct contains what appears to be ASCII data.
i386 might be dereferencing some random address instead of oopsing...


   0:   48 f7 45 78 80 01 00    testq  $0x180,0x78(%rbp)
   7:   00
   8:   74 4c                   je     0x56
   a:   48 c7 c7 e0 18 28 88    mov    $0xffffffff882818e0,%rdi

%rbp has a bogus (non-canonical) address. On i386 there is no such test possible
so it will just dereference the address if it is mapped.

%rbp contains 8 valid ASCII chars: "salcf x\"

