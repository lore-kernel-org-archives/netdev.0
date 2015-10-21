From: Casper.Dik@oracle.com
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for sockets in accept(3)
Date: Wed, 21 Oct 2015 18:04:53 +0200
Message-ID: <201510211604.t9LG4r9A005345@room101.nl.oracle.com>
References: <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com> <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com> <20151021.083008.1870598627666404990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan.Burlison@oracle.com, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23514 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbbJUQU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 12:20:58 -0400
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t9LGKvBi032183
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 16:20:58 GMT
Received: from room101.nl.oracle.com (room101.nl.oracle.com [10.161.249.34])
	by aserv0022.oracle.com (8.13.8/8.13.8) with ESMTP id t9LG859N006783
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 16:20:57 GMT
In-Reply-To: <20151021.083008.1870598627666404990.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: David Miller <davem@davemloft.net>
Date: Wed, 21 Oct 2015 08:30:08 -0700 (PDT) (17:30 CEST)

>From: Alan Burlison <Alan.Burlison@oracle.com>
>Date: Wed, 21 Oct 2015 15:38:51 +0100
>
>> While this algorithm is pretty expensive, it is not often invoked.
>
>I bet it can be easily intentionally invoked, by a malicious entity no
>less.

It is only expensive within the process itself.  Whether it is run inside 
the kernel isn't much different in the context of Solaris.  If you have an 
attacker which can run any code, it doesn't really matter what that code 
is.  It is not really, expensive (like grabbing expensive locks or
for any length of time).  It's basically O(n) depending on the numbers of 
threads in the process.

If you have an application which can be triggered in doing that, it is 
still a bug in the application.  

Is such socket still listed with netstat on Linux?  I believe it uses
uses /proc and it will not be able to find that socket through the list of 
opened files.

If we look at our typical problem we have a accept loop:

		for (;;) {
			newfd = accept(fd. ...);  /* X */

			/* stuff */
		}

While we have a second thread doing a "close(fd);" and possibly opening 
another file which just happens to return this particular fd.

In Solaris the following one of the following things will happen,
whatever the first thread is doing once close() is called:

	- accept() dies with EBADF (close() before or during the call to
	  accept())
	- accept() returns some other error (new fd you can't accept on)
	- accept() returns a new fd (if it was closed and reopened and a 
	  the new fd allows accept())

On Linux exactly the same thing happens *except* when we find ourselves in accept(),
then we wait until a connection made or "shutdown()" is called.

I don't think any of the outcomes in the first thread is acceptable; 
clearly no sufficient synchronization between the threads.


At that point Linux cannot find out who owns the socket:

#  netstat -p -a | grep /tmp/unix
unix  2      [ ACC ]     STREAM     LISTENING     14743  -                   /tmp/unix_sock

In Solaris you'd get:

netstat -u -f unix| grep unix_
stream-ord casper     5334 shutdown       /tmp/unix_sock

Simple synchronization is can be done.

Casper
