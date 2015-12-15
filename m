From: David Miller <davem@davemloft.net>
Subject: Re: Information leak in llcp_sock_bind/llcp_raw_sock_bind
Date: Tue, 15 Dec 2015 15:48:51 -0500 (EST)
Message-ID: <20151215.154851.2132284113916223057.davem@davemloft.net>
References: <CACT4Y+bjSFyXZi1PKTUsT9PhAYvCGiGjRkOBRbUON0Pw7rJxGg@mail.gmail.com>
	<20151215.153626.1500179484827859040.davem@davemloft.net>
	<CACT4Y+ZnZ2EcZwc6T5LZ1YR2zC8+6aFT_JFYb_LeegnB6tmESw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: syzkaller@googlegroups.com, lauro.venancio@openbossa.org,
	aloisio.almeida@openbossa.org, sameo@linux.intel.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com, kcc@google.com,
	glider@google.com, sasha.levin@oracle.com
To: dvyukov@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180AbbLOUsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 15:48:53 -0500
In-Reply-To: <CACT4Y+ZnZ2EcZwc6T5LZ1YR2zC8+6aFT_JFYb_LeegnB6tmESw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 15 Dec 2015 21:45:16 +0100

> On Tue, Dec 15, 2015 at 9:36 PM, David Miller <davem@davemloft.net> wrote:
>> From: Dmitry Vyukov <dvyukov@google.com>
>> Date: Tue, 15 Dec 2015 21:00:20 +0100
>>
>>> The problem is that llcp_sock_bind/llcp_raw_sock_bind do not check
>>> sockaddr_len passed in, so they copy stack garbage from stack into the
>>> socket and then return it in getsockname.
>>> This can defeat ASLR, leak crypto keys, etc.
>>
>> That's actually the first thing these functions do.
>>
>> They completely clear out the on-stack llcp_addr, then they copy only
>> as much as the user gave them, being careful not to use more than
>> sizeof(llcp_addr).
>>
>>         memset(&llcp_addr, 0, sizeof(llcp_addr));
>>         len = min_t(unsigned int, sizeof(llcp_addr), alen);
>>         memcpy(&llcp_addr, addr, len);
>>
>> I don't see what the problem is, you'll need to be more specific.
> 
> You are right. Sorry.
> 
> There still seems to be a minor leak here:
> 
>   if (!addr || addr->sa_family != AF_NFC)
>       return -EINVAL;
> 
> addr->sa_family can be uninit.

That shouldn't matter at all, that can't cause socket state corruption.

I want to ask you if you are actually seeing kernel stack in that hexdump
you are posting?  If so, how do you actually account for it?  Nothing you
have shown so far make that clear.
