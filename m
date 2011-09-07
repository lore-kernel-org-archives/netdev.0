From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 42372] New: routing table cache entries lose
 mtu/advmss attributes
Date: Wed, 7 Sep 2011 14:32:59 -0700
Message-ID: <20110907143259.cd19969c.akpm@linux-foundation.org>
References: <bug-42372-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, david+bugs@madore.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51288 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757188Ab1IGVdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2011 17:33:51 -0400
In-Reply-To: <bug-42372-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 4 Sep 2011 18:45:16 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=42372
> 
>            Summary: routing table cache entries lose mtu/advmss attributes
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.0.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: david+bugs@madore.org
>         Regression: Yes
> 
> 
> To reproduce: create a static IPv6 route with a specific mtu/advmss attribute,
> then open a TCP connection to a host (never contacted before) within this
> route: this creates a cache entry with additional information (such as rtt);
> when these data expire, the route mtu/advmss are also forgotten, even though
> they are specified in the (static) routing table.
> 
> E.g. (using www.kame.net = 2001:200:dff:fff1:216:3eff:feb1:44d7 as example):
> 
> david@terre:~$ sudo ip route get 2001:200:dff:fff1:216:3eff:feb1:44d7
> 2001:200:dff:fff1:216:3eff:feb1:44d7 from :: via fe80::20e:a6ff:fef1:db7f dev
> eth0  src 2001:7a8:78ae:37:21f:c6ff:fec1:c877  metric 0 
>     cache 
> david@terre:~$ sudo ip route add 2001:200:dff:fff1::/64 from :: via
> fe80::20e:a6ff:fef1:db7f dev eth0  src 2001:7a8:78ae:37:21f:c6ff:fec1:c877 mtu
> 1460 advmss 1400
> david@terre:~$ sudo ip route get 2001:200:dff:fff1:216:3eff:feb1:44d7
> 2001:200:dff:fff1:216:3eff:feb1:44d7 from :: via fe80::20e:a6ff:fef1:db7f dev
> eth0  src 2001:7a8:78ae:37:21f:c6ff:fec1:c877  metric 0 
>     cache  mtu 1460 advmss 1400
> david@terre:~$ wget -O /dev/null
> 'http://[2001:200:dff:fff1:216:3eff:feb1:44d7]/'
> (...)
> david@terre:~$ sudo ip route get 2001:200:dff:fff1:216:3eff:feb1:44d7
> 2001:200:dff:fff1:216:3eff:feb1:44d7 from :: via fe80::20e:a6ff:fef1:db7f dev
> eth0  src 2001:7a8:78ae:37:21f:c6ff:fec1:c877  metric 0 
>     cache  mtu 1460 rtt 324ms rttvar 324ms cwnd 10 advmss 1400 hoplimit 255
> david@terre:~$ sleep 30
> david@terre:~$ sudo ip route get 2001:200:dff:fff1:216:3eff:feb1:44d7
> 2001:200:dff:fff1:216:3eff:feb1:44d7 from :: via fe80::20e:a6ff:fef1:db7f dev
> eth0  src 2001:7a8:78ae:37:21f:c6ff:fec1:c877  metric 0 
>     cache  hoplimit 64
> 
> In the last output, the mtu and advmss for the route have been forgotten, even
> though the route is still supposed to be active.  This is not just the output
> of "ip" which is bad: actually opening a TCP connection at this point will use
> a wrong MSS.
> 
> A similar bug might be present in IPv4 routes, but I found it trickier to
> reproduce, so I'm not entirely sure whether this is really an IPv6-related
> problem.
> 
