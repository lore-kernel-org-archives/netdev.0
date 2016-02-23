From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Variable download speed
Date: Tue, 23 Feb 2016 08:53:26 -0800
Message-ID: <56CC8E86.7000102@hpe.com>
References: <alpine.LNX.2.20.1602231223530.29937@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: sdrb@onet.eu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:53801 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440AbcBWQxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 11:53:34 -0500
Received: from g4t3428.houston.hp.com (g4t3428.houston.hp.com [15.201.208.56])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id EBE4D62620
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 16:53:28 +0000 (UTC)
In-Reply-To: <alpine.LNX.2.20.1602231223530.29937@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2016 03:24 AM, sdrb@onet.eu wrote:
> Hi,
>
> I've got a problem with network on one of my embedded boards.
> I'm testing download speed of 256MB file from my PC to embedded board
> through 1Gbit ethernet link using ftp.
>
> The problem is that sometimes I achieve 25MB/s and sometimes it is only
> 14MB/s. There are also situations where the transfer speed starts at
> 14MB/s and after a few seconds achieves 25MB/s.
> I've caught the second case with tcpdump and I noticed that when the speed
> is 14MB/s - the tcp window size is 534368 bytes and when the speed
> achieved 25MB/s the tcp window size is 933888.
>
> My question is: what causes such dynamic change in the window size (while
> transferring data)?  Is it some kernel parameter wrong set or something
> like this?
> Do I have any influence on such dynamic change in tcp window size?


If an application using TCP does not make an explicit setsockopt() call 
to set the SO_SNDBUF and/or SO_RCVBUF size, then the socket buffer and 
TCP window size will "autotune" based on what the stack believes to be 
the correct thing to do.  It will be bounded by the values in the 
tcp_rmem and tcp_wmem sysctl settings:


net.ipv4.tcp_rmem = 4096	87380	6291456
net.ipv4.tcp_wmem = 4096	16384	4194304

Those are min, initial, max, units of octets (bytes).

If on the other hand an application makes an explicit setsockopt() call, 
  that will be the size of the socket buffer, though it will be 
"clipped" by the values of:

net.core.rmem_max = 4194304
net.core.wmem_max = 4194304

Those sysctls will default to different values based on how much memory 
is in the system.  And I think in the case of those last two, I have 
tweaked them myself away from their default values.

You might also look at the CPU utilization of all the CPUs of your 
embedded board, as well as the link-level statistics for your interface, 
and the netstat statistics.  You would be looking for saturation, and 
"excessive" drop rates.  I would also suggest testing network 
performance with something other than FTP.  While one can try to craft 
things so there is no storage I/O of note, it would still be better to 
use a network-specific tool such as netperf or iperf.  Minimize the 
number of variables.

happy benchmarking,

rick jones
