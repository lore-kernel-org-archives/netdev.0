From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: unix: non blocking recvmsg() should not return
 -EINTR
Date: Thu, 27 Mar 2014 09:36:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6EA4FF@AcuExch.aculab.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>
	<87zjkd802t.fsf@sable.mobileactivedefense.com>
	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	<87y4zw7ngi.fsf@sable.mobileactivedefense.com>
 <87ha6k7jt7.fsf@sable.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: 'Rainer Weikusat' <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60221 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752043AbaC0JhT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 05:37:19 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07957-07 for <netdev@vger.kernel.org>;
 Thu, 27 Mar 2014 09:37:13 +0000 (GMT)
In-Reply-To: <87ha6k7jt7.fsf@sable.mobileactivedefense.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rainer Weikusat 
> Rainer Weikusat <rw@sable> writes:
> 
> [...]
> 
> > The underlying problem would seem to be that a O_NONBLOCK call might
> > actually block forever in case a blocking receiver sits on the lock and
> > no data is ever received.
> 
> ... except that this probably cannot happen because O_NONBLOCK is a file
> status flag and not a file descriptor flag.
> 
> NB: I've neither tested nor checked this.

While dup() gives a second fd referring to the same kernel 'file'
doing open("/dev/fd/4", ...) traditionally gives you an additional
'file' referring to the same vnode.
For real files the file offset is in the 'file' structure, and
I think the O_NONBLOCK flag is in the same place.
Which means that is possible (but maybe not that usual or sensible)
for a process to try a non-blocking read on a socket while another
process is blocked in the read code.

The same would be true for writes, and for writes to a datagram
socket it might even make sense.

In any case I expect EAGAIN to mean 'there is no data to read'
not 'something happened and I didn't bother to look for data'.

As the code stands (or with the suggested change) if a datagram
socket has an indefinite supply of data, and several processes
are doing nonblocking reads, and some are also receiving signals
then some of the reads will fail with EINTR/EAGAIN/EWOULDBLOCK.
That doesn't seem right.

	David
