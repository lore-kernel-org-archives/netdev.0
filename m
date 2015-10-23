From: Casper.Dik@oracle.com
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for sockets in accept(3)
Date: Fri, 23 Oct 2015 11:52:34 +0200
Message-ID: <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk> <20151021.182955.1434243485706993231.davem@davemloft.net> <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk> <20151022060304.GQ22011@ZenIV.linux.org.uk> <201510220634.t9M6YJLD017883@room101.nl.oracle.com> <20151022172146.GS22011@ZenIV.linux.org.uk> <201510221824.t9MIOp6n003978@room101.nl.oracle.com> <20151022190701.GV22011@ZenIV.linux.org.uk> <201510221951.t9MJp5LC005892@room101.nl.oracle.com> <20151022215741.GW22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29654 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbbJWKIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 06:08:43 -0400
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t9NA8gSB008218
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 10:08:42 GMT
Received: from room101.nl.oracle.com (room101.nl.oracle.com [10.161.249.34])
	by userv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t9N9tl3t032221
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 10:08:41 GMT
In-Reply-To: <20151022215741.GW22011@ZenIV.linux.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>Ho-hum...  It could even be made lockless in fast path; the problems I see
>are
>	* descriptor-to-file lookup becomes unsafe in a lot of locking
>conditions.  Sure, most of that happens on the entry to some syscall, with
>very light locking environment, but... auditing every sodding ioctl that
>might be doing such lookups is an interesting exercise, and then there are
>->mount() instances doing the same thing.  And procfs accesses.  Probably
>nothing impossible to deal with, but nothing pleasant either.

In the Solaris kernel code, the ioctl code is generally not handled a file 
descriptor but instead a file pointer (i.e., the lookup is done early in 
the system call).

In those specific cases where a system call needs to convert a file 
descriptor to a file pointer, there is only one routines which can be used.

>	* memory footprint.  In case of Linux on amd64 or sparc64,
>main()
>{
>	int i;
>	for (i = 0; i < 1<<24; dup2(0, i++))	// 16M descriptors
>		;
>}
>will chew 132Mb of kernel data (16Mpointer + 32Mbit, assuming sufficient ulimit -n,
>of course).  How much will Solaris eat on the same?

Yeah, that is a large amount of memory.  Of course, the table is only 
sized when it is extended and there is a reason why there is a limit on 
file descriptors.  But we're using more data per file descriptor entry.


>	* related to the above - how much cacheline sharing will that involve?
>These per-descriptor use counts are bitch to pack, and giving each a cacheline
>of its own...  <shudder>

As I said, we do actually use a lock and yes that means that you really  
want to have a single cache line for each and every entry.  It does make 
it easy to have non-racy file description updates.  You certainly do not 
want false sharing when there is a lot of contention.

Other data is used to make sure that it only takes O(log(n)) to find the 
lowest available file descriptor entry.  (Where n, I think, is the returned
descriptor)

Not contended locks aren't expensive.  And all is done on a single cache 
line.

One question about the Linux implementation: what happens when a socket in 
select is closed?  I'm assuming that the kernel waits until "shutdown" is 
given or when a connection comes in?

Is it a problem that you can "hide" your listening socket with a thread in 
accept()?  I would think so (It would be visible in netstat but you can't 
easily find out why has it)

Casper
