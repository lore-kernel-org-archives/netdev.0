From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 27 Oct 2015 14:13:31 +0000
Message-ID: <562F868B.4040001@oracle.com>
References: <562F577E.6000901@oracle.com>	<20151027.064228.237119117273824839.davem@davemloft.net>	<562F7E16.2070906@oracle.com> <20151027.065924.796277086557445997.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31740 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbbJ0ONg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 10:13:36 -0400
In-Reply-To: <20151027.065924.796277086557445997.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/10/2015 13:59, David Miller wrote:

> From: Alan Burlison <Alan.Burlison@oracle.com>
> Date: Tue, 27 Oct 2015 13:37:26 +0000
>
>> If you took that argument to it's logical extreme they you'd never
>> make any changes that made changes to existing behaviour, and that's
>> patently not the case.
>
> You know exactly what I mean, and what you're saying here is just a
> scarecrow distracting the discussion from the real issue.

I think you probably mean "a straw man".

The problematic case is MT applications that don't manage sharing of FDs 
in a sensible way and need to have a way of terminating any accept() in 
other threads. On Linux that's currently done with a shutdown()+close(), 
on other platforms you can use open()+dup2(). However the Linux 
shutdown() mechanism relies on bending the POSIX semantics and the 
dup2() mechanism doesn't work on Linux as it also doesn't kick other 
threads off accept().

At the moment, on Linux you have to explicitly call shutdown() on a 
socket on which another thread may be sat in accept(). If closing the 
socket in one thread terminated any accept()s in other threads, in the 
same way that an explicit shutdown() does, then the explicit shutdown() 
wouldn't be needed for more sensibly written apps that weren't prone to 
FD recycling races. As far as I can tell, that would work cross-platform.

Ideally there'd be a single way of doing this that worked 
cross-platform, at the moment there isn't. And yes, even if such a 
mechanism was available now it would be some time before it could be 
assumed to be available everywhere. I don't know enough about the Linux 
implementation to know if there is a practical way around this, and of 
course even if such a change were made, potential breakage of existing 
code would be a concern. If there's a better, cross-platform way of 
doing this then I'm all ears.

-- 
Alan Burlison
--
