From: Casper.Dik@oracle.com
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for sockets in accept(3)
Date: Thu, 22 Oct 2015 08:34:19 +0200
Message-ID: <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
References: <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk> <20151021.182955.1434243485706993231.davem@davemloft.net> <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk> <20151022060304.GQ22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:16478 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbbJVGuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 02:50:21 -0400
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t9M6oK6F019263
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 06:50:21 GMT
Received: from room101.nl.oracle.com (room101.nl.oracle.com [10.161.249.34])
	by aserv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t9M6bUjU000684
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 06:50:20 GMT
In-Reply-To: <20151022060304.GQ22011@ZenIV.linux.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>And I'm really curious about the things Solaris would do with dup2() there.
>Does it take into account the possibility of new accept() coming just as
>dup2() is trying to terminate the ongoing ones?  Is there a window when
>descriptor-to-file lookups would fail?  Looks like a race/deadlock country...

Solaris does not "terminate" threads, instead it tells them that the
file descriptor information used is stale and wkae's up the thread.

The accept call gets woken up and it checks for incoming connections; it 
will then either find a new connection and returns that particular 
connection or it will find nothing and returns EINTR; in the post-syscall 
glue this is checked (the kernel thread has been told to take the 
expensive post-syscall routine) and if the system call was interrupted, 
EBADF is returned instead.

It is also possible for the connection to come in late and then the socket 
will be changed and the already accepted (in TCP terms, not in the
socket API terms) embryonic will be closed too as is normal when a 
listening socket is closed with a list of not ready accept()ed connections.

Casper
