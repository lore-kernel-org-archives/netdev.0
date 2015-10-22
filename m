From: Casper.Dik@oracle.com
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for sockets in accept(3)
Date: Thu, 22 Oct 2015 21:50:10 +0200
Message-ID: <201510221950.t9MJoAw0005835@room101.nl.oracle.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk> <20151021.182955.1434243485706993231.davem@davemloft.net> <5628636E.1020107@oracle.com> <201510220615.t9M6FL2d017592@room101.nl.oracle.com> <1445513425.22974.100.camel@edumazet-glaptop2.roam.corp.google.com> <5628CF79.2000507@oracle.com> <1445515858.22974.113.camel@edumazet-glaptop2.roam.corp.google.com> <5628E142.7050600@oracle.com> <20151022170548.GR22011@ZenIV.linux.org.uk> <56291F56.2080906@oracle.com> <20151022185610.GU22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45400 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965501AbbJVUGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 16:06:15 -0400
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t9MK6ETi008947
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 20:06:14 GMT
Received: from room101.nl.oracle.com (room101.nl.oracle.com [10.161.249.34])
	by aserv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t9MJrNpX031101
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 20:06:13 GMT
In-Reply-To: <20151022185610.GU22011@ZenIV.linux.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Al Viro <viro@ZenIV.linux.org.uk>

>On Thu, Oct 22, 2015 at 06:39:34PM +0100, Alan Burlison wrote:
>> On 22/10/2015 18:05, Al Viro wrote:
>> 
>> >Oh, for...  Right in this thread an example of complete BS has been quoted
>> >from POSIX close(2).  The part about closing a file when the last descriptor
>> >gets closed.  _Nothing_ is POSIX-compliant in that respect (nor should
>> >it be).
>> 
>> That's not exactly what it says, we've already discussed, for
>> example in the case of pending async IO on a filehandle.
>
>Sigh...  It completely fails to mention descriptor-passing.  Which
>	a) is relevant to what "last close" means and
>	b) had been there for nearly the third of a century.

Why is that different?  These clearly count as file descriptors.

>> I agree that part could do with some polishing.
>
>google("wire brush of enlightenment") is what comes to mind...

Standardese is similar to legalese; it not writing that is directly open 
to interpretation to those who are not inducted in writing may have some 
problem interpreting what exactly is meant by wording of the standard.



>> I think "it shall be closed first" makes it pretty clear that what
>> is expected is the same behaviour as any direct invocation of close,
>> and that has to happen before the reassignment. What makes you
>> believe that's isn't the case?
>
>So unless I'm misparsing something, you want
>thread A: accept(newfd)
>thread B: dup2(oldfd, newfd)
>have accept() bugger off before the switchover happens?

Well, certainly *before* we return from dup2().
(and clearly only once we have determined that dup2() will return
successfully)

>What should happen if thread C does accept(newfd) right as B has decided that
>there's nothing more to wait?  For close(newfd) it would be simple - we are
>going to have lookup by descriptor fail with EBADF anyway, so making it do
>so as soon as we go hunting for those who are currently in accept(newfd)
>would do the trick - no new threads like that shall appear and as long as
>the descriptor is not declared free for taking by descriptor allocation nobody
>is going to be screwed by open() picking that slot of descriptor table too
>early.  Trying to do that for dup2() would lose atomicity.  I honestly don't
>know how Solaris behaves in that case, BTW - the race (if any) would probably
>be hard to hit, so in case of Linux I would have to go and RTFS before saying
>that there isn't one.  I can't do that in with Solaris; all I can do here
>is ask you guys...

Solaris dup2() behaves exactly like close().

>Moreover, see above for record locks removal.  Should that happen prior to
>switchover?  If you have
>
>dup(fd, fd2);
>set a record lock on fd2
>spawn a thread
>in child, try to grab the same lock on fd2
>in parent, do some work and close(fd)

>you are guaranteed that child won't see fd refering to the same file after it
>acquires the lock.

Here's you are talking about a lock held by the "parent" and that the
"child" will only get the lock once close(fd) is done?

Yes.  The final "close" is done *after* the pointer has been removed from 
the file descriptor table.

>Replace close(fd) with dup(fd3, fd); should the same hold true in that case?

Yes.

>FWIW, Linux behaviour in that area is to have record locks removal done
>between the switchover and return to userland in case of dup2() and between
>the removal from descriptor table and return to userland in case of close().
>
>> Personally I believe the spec is clear enough to allow an
>> unambiguous interpretation of the required behavior in this area. If
>> you think there are areas where the Solaris behaviour is in
>> disagreement with the spec then I'd be interested to hear them.
>
>The spec is so vague that I strongly suspect that *both* Solaris and Linux
>behaviours are not in disagreement with it (modulo shutdown(2) extension
>Linux-side and we are really stuck with that one).

I'm not sure if the standard allows a handful of threads in accept() for a 
file descriptor which has already been closed *and* can be re-issued for 
other uses.

Casper
