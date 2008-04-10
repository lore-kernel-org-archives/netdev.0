From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10437] New: MSG_ERRQUEUE messages do not pass
 to connected raw sockets
Date: Thu, 10 Apr 2008 10:34:44 -0700
Message-ID: <20080410103444.d7309e1f.akpm@linux-foundation.org>
References: <bug-10437-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: dmitry@butskoy.name
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33694 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756672AbYDJRfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 13:35:17 -0400
In-Reply-To: <bug-10437-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 10 Apr 2008 05:53:39 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10437
> 
>            Summary: MSG_ERRQUEUE messages do not pass to connected raw
>                     sockets
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: dmitry@butskoy.name
> 
> 
> There was a similar bug #8747 , but the fix is not somplete.
> 
> Problem Description:
> 
> It is related to the possibility to obtain MSG_ERRQUEUE messages from the udp
> and raw sockets, both connected and unconnected.
> 
> There is a bug in net/ipv6/icmp.c code, which prevents such messages to
> be delivered to the errqueue of the correspond raw socket, when the socket is
> CONNECTED. The bug is related to wrong obtaining of the saddr/daddr pair, used
> to find the raw socket.
> 
> Consider __raw_v6_lookup() function from net/ipv6/raw.c. When a raw socket is
> looked up usual way, it is something like:
> 
> sk = __raw_v6_lookup(sk, nexthdr, daddr, saddr, IP6CB(skb)->iif);
> 
> where "daddr" is a destination address of the incoming packet (IOW our local
> address), "saddr" is a source address of the incoming packet (the remote end).
> 
> But when the raw socket is looked up for some icmp error report, in
> net/ipv6/icmp.c:icmpv6_notify() , daddr/saddr must be obtained from the echoed
> fragment of the "bad" packet, not from the ipv6 header of the icmp packet
> itself.
> 
> Consider:
> 
> ipv6_header -- icmp_header -- echoed_ipv6_header -- at_least_8_bytes ...
> 
> Now saddr/daddr, used for __raw_v6_lookup, are from the first "ipv6_header",
> but must be from the "echoed_ipv6_header" .
> 
> 
> In the previous bug #8747, I assumed that the issue is just a typo, by
> switching saddr/daddr in agrument list. Unfortunately, it appears that the pair
> is even obtained from the wrong place...
> 
> 
> Steps to reproduce:
> 
> Create some raw socket, connect it to an address, and cause some error
> situation: f.e. set ttl=1 where the remote address is more than 1 hop to reach.
> Set IPV6_RECVERR .
> Then send something and wait for the error (f.e. poll() with POLLERR|POLLIN).
> You should receive "time exceeded" icmp message (because of "ttl=1"), but the
> socket do not receive it.
> 
> If you do not connect your raw socket, you will receive MSG_ERRQUEUE 
> successfully. (The reason is that for unconnected socket there are no actual
> checks for local/remote addresses).
> 

(There's more info, and a patch at the above link).

Dmitry, I'd suggest that you send the patch via email to
netdev@vger.kernel.org and to YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>.
