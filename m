From: Casper.Dik@oracle.com
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for sockets in accept(3)
Date: Thu, 22 Oct 2015 20:24:51 +0200
Message-ID: <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
References: <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk> <20151021.182955.1434243485706993231.davem@davemloft.net> <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk> <20151022060304.GQ22011@ZenIV.linux.org.uk> <201510220634.t9M6YJLD017883@room101.nl.oracle.com> <20151022172146.GS22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32175 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757917AbbJVSlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 14:41:01 -0400
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t9MIexDo029605
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 18:41:00 GMT
Received: from room101.nl.oracle.com (room101.nl.oracle.com [10.161.249.34])
	by userv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t9MIS4Q5020340
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 18:40:59 GMT
In-Reply-To: <20151022172146.GS22011@ZenIV.linux.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>On Thu, Oct 22, 2015 at 08:34:19AM +0200, Casper.Dik@oracle.com wrote:
>> 
>> 
>> >And I'm really curious about the things Solaris would do with dup2() there.
>> >Does it take into account the possibility of new accept() coming just as
>> >dup2() is trying to terminate the ongoing ones?  Is there a window when
>> >descriptor-to-file lookups would fail?  Looks like a race/deadlock country...
>> 
>> Solaris does not "terminate" threads, instead it tells them that the
>> file descriptor information used is stale and wkae's up the thread.
>
>Sorry, lousy wording - I meant "terminate syscall in another thread".
>Better yet, make that "what happens if new accept(newfd) comes while dup2()
>waits for affected syscalls in other threads to finish"?  Assuming it
>does wait, that is..

No there is no such window; the accept() call either returns EBADF
(dup2()) wins the race or it returns a new file descriptor (and dup2()
then closes the listening descriptor).

One or the other.

>While we are at it, what's the relative order of record locks removal
>and switching the meaning of newfd?  In our kernel it happens *after*
>the switchover (i.e. if another thread is waiting for a record lock held on
>any alias of newfd and we do dup2(oldfd, newfd), the waiter will not see
>the state with newfd still refering to what it used to; note that waiter
>might be using any descriptor refering to the file newfd used to refer
>to, so it won't be affected by the "wake those who had the meaning of
>their arguments change" side of things).

The external behaviour atomic; you cannot distinguish the order
between the closing of the original file (and waking up other threads
waiting for a record lock) or changing the file referenced by that newfd.

But this not include a global or process specific lock.

Casper
