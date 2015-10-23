From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 23 Oct 2015 06:02:20 -0700
Message-ID: <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk>
	 <20151021.182955.1434243485706993231.davem@davemloft.net>
	 <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk>
	 <20151022060304.GQ22011@ZenIV.linux.org.uk>
	 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
	 <20151022172146.GS22011@ZenIV.linux.org.uk>
	 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
	 <20151022190701.GV22011@ZenIV.linux.org.uk>
	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
	 <20151022215741.GW22011@ZenIV.linux.org.uk>
	  <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35102 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbbJWNCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:02:23 -0400
Received: by pasz6 with SMTP id z6so118190426pas.2
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 06:02:22 -0700 (PDT)
In-Reply-To: <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-23 at 11:52 +0200, Casper.Dik@oracle.com wrote:
> 
> >Ho-hum...  It could even be made lockless in fast path; the problems I see
> >are
> >	* descriptor-to-file lookup becomes unsafe in a lot of locking
> >conditions.  Sure, most of that happens on the entry to some syscall, with
> >very light locking environment, but... auditing every sodding ioctl that
> >might be doing such lookups is an interesting exercise, and then there are
> >->mount() instances doing the same thing.  And procfs accesses.  Probably
> >nothing impossible to deal with, but nothing pleasant either.
> 
> In the Solaris kernel code, the ioctl code is generally not handled a file 
> descriptor but instead a file pointer (i.e., the lookup is done early in 
> the system call).
> 
> In those specific cases where a system call needs to convert a file 
> descriptor to a file pointer, there is only one routines which can be used.
> 
> >	* memory footprint.  In case of Linux on amd64 or sparc64,
> >main()
> >{
> >	int i;
> >	for (i = 0; i < 1<<24; dup2(0, i++))	// 16M descriptors
> >		;
> >}
> >will chew 132Mb of kernel data (16Mpointer + 32Mbit, assuming sufficient ulimit -n,
> >of course).  How much will Solaris eat on the same?
> 
> Yeah, that is a large amount of memory.  Of course, the table is only 
> sized when it is extended and there is a reason why there is a limit on 
> file descriptors.  But we're using more data per file descriptor entry.
> 
> 
> >	* related to the above - how much cacheline sharing will that involve?
> >These per-descriptor use counts are bitch to pack, and giving each a cacheline
> >of its own...  <shudder>
> 
> As I said, we do actually use a lock and yes that means that you really  
> want to have a single cache line for each and every entry.  It does make 
> it easy to have non-racy file description updates.  You certainly do not 
> want false sharing when there is a lot of contention.
> 
> Other data is used to make sure that it only takes O(log(n)) to find the 
> lowest available file descriptor entry.  (Where n, I think, is the returned
> descriptor)

Yet another POSIX deficiency.

When a server deals with 10,000,000+ socks, we absolutely do not care of
this requirement.

O(log(n)) is still crazy if it involves O(log(n)) cache misses.

> 
> Not contended locks aren't expensive.  And all is done on a single cache 
> line.
> 
> One question about the Linux implementation: what happens when a socket in 
> select is closed?  I'm assuming that the kernel waits until "shutdown" is 
> given or when a connection comes in?
> 
> Is it a problem that you can "hide" your listening socket with a thread in 
> accept()?  I would think so (It would be visible in netstat but you can't 
> easily find out why has it)

Again, netstat -p on a server with 10,000,000 sockets never completes.

Never try this unless you are desperate and want to avoid a reboot
maybe.

If you absolutely want to nuke a listener because of untrusted
applications, we better implement a proper syscall.

Android has such a facility.

Alternative would be to extend netlink (ss command from iproute2
package) to carry one pid per socket.

ss -atnp state listening

-> would not have to readlink (/proc/*/fd/*)
