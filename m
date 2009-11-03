From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14427] New: ipv6 forward cause strange route
Date: Mon, 2 Nov 2009 22:32:37 -0800
Message-ID: <20091102223237.c0102f19.akpm@linux-foundation.org>
References: <bug-14427-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, green@msu.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40902 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396AbZKCGdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 01:33:16 -0500
In-Reply-To: <bug-14427-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 17 Oct 2009 10:42:01 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14427
> 
>            Summary: ipv6 forward cause strange route
>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: green@msu.ru
>         Regression: No
> 
> 
> When enabling forwarding for IPv6 on interface, in the routing table local
> appears new route. It like route to local ip but with all host bits set to 0.
> Example:
> --------------------------------------------------
>   # cat /proc/sys/net/ipv6/conf/eth0/forwarding
>   0
>   # ip -6 addr add 2001:db8:1:1::5/64 dev eth0
>   # ip -6 route show table local
>   ...
>   local 2001:db8:1:1::5 via :: dev lo  proto none  metric 0  mtu 16436 advmss
> 16376 hoplimit 4294967295
>   ...
>   # echo 1 > /proc/sys/net/ipv6/conf/eth0/forwarding 
>   # ip -6 route show table local
>   ...
>   local 2001:db8:1:1:: via :: dev lo  proto none  metric 0  mtu 16436 advmss
> 16376 hoplimit 4294967295
>   local 2001:db8:1:1::5 via :: dev lo  proto none  metric 0  mtu 16436 advmss
> 16376 hoplimit 4294967295
>   ...
> --------------------------------------------------
> After enabling forwarding, route "2001:db8:1:1:: via :: dev lo" is added. No
> matter, forwarding is enabled before or after adding of address, this route is
> "on" with forwarding and "off" without it.
> Such behavior causes problems with /127 network masks. For example:
> --------------------------------------------------
>   # echo 1 > /proc/sys/net/ipv6/conf/eth0/forwarding 
>   # ip -6 addr add 2001:db8:1:1::5/127 dev eth0
>   # ip -6 route add default via 2001:db8:1:1::4
>   RTNETLINK answers: Invalid argument
> --------------------------------------------------
> But if we disable forwarding (and strange route) when adding needed route, we
> will succeed.
> --------------------------------------------------
>   # echo 0 > /proc/sys/net/ipv6/conf/eth0/forwarding 
>   # ip -6 route add default via 2001:db8:1:1::4
>   # echo 1 > /proc/sys/net/ipv6/conf/eth0/forwarding 
> --------------------------------------------------
> Default route remains in the table after enabling forwarding and it is doing in
> work. But in this case we still can not access 2001:db8:1:1::4, because it is
> routed to loopback:
> --------------------------------------------------
>   # ping6 -c 1 2001:db8:1:1::4
>   PING 2001:db8:1:1::4(2001:db8:1:1::4) 56 data bytes
>   64 bytes from 2001:db8:1:1::5: icmp_seq=1 ttl=64 time=0.114 ms
> --------------------------------------------------
> We get reply from self interface.
> 
> This was tested on x86 and x86_64 with 2.6.30 kernel and some previous versions
> on ArchLinux (2.6.30 x86 and x86_64), Ubuntu (2.6.28-15-generic x86_64) and
> gentoo (2.6.30-gentoo-r5 x86_64).
> 

