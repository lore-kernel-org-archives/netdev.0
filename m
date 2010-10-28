From: Andy Grover <andy.grover@oracle.com>
Subject: Re: [Security] TIPC security issues
Date: Thu, 28 Oct 2010 11:45:04 -0700
Message-ID: <4CC9C4B0.50404@oracle.com>
References: <20101027.105047.183059900.davem@davemloft.net> <1288203979.1836.2.camel@dan> <AANLkTikKZdq9u0+Nkd4wtEcAZMT3YCPaXMv6FZaafetc@mail.gmail.com> <20101027.122757.98903207.davem@davemloft.net> <AANLkTikdh-kqroCDA5EsjSMTLjViqe_U=hxM1L6U4Ppb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jon.maloy@ericsson.com,
	netdev@vger.kernel.org, drosenberg@vsecurity.com,
	security@kernel.org, allan.stephens@windriver.com,
	RDS Devel <rds-devel@oss.oracle.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:17054 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761196Ab0J1Sss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 14:48:48 -0400
In-Reply-To: <AANLkTikdh-kqroCDA5EsjSMTLjViqe_U=hxM1L6U4Ppb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2010 08:32 AM, Linus Torvalds wrote:
> Heh. We apparently have _another_ iovec overflow in networking. This time rds.
>
> Reported by Thomas Pollet<thomas.pollet@gmail.com>: look at
> net/rds/rdma.c around line 490. It doesn't use the regular iovec code,
> instead it cooks its own, and has a few problems with overflow.
>
> It gathers the number of pages into an "unsigned int", and for each
> entry in its own rds_iovec it will check that the size is<  UINT_MAX,
> and then generate the number of pages for that entry. With the whole
> "unaligned address adds one" logic, it means that each entry can get
> (UINT_MAX>>  PAGE_SHIFT)+1 pages.

FWIW both the signed issue and not checking the iovec changed were 
correct in 2.6.36, and only added in ff87e97.

> And how many entries can we have? Apparently that is capped to
> UINT_MAX too. So add all those up, and they can easily overflow the
> unsigned int page counter.
>
> So this time fixing verify_iovec() doesn't help, because rds just
> cooks its own, and this is using a totally different interface: it
> seems to hook into sendmsg, but it looks like it uses the ancillary
> data objects and passes in its own magical iovec rather than use any
> "normal" iovec thing. I don't know the code, I may be totally off.

Yes that's right, it's to map a memory region that will be the target of 
an RDMA operation. I don't know why struct rds_iovec was used instead of 
struct iovec, but I think we're stuck, since it's part of our socket API.

I'll send DaveM patches to fix those two immediately-identified problems 
today, and we'll take a good long look at the rest of the code for 
further issues.

Regards -- Andy
