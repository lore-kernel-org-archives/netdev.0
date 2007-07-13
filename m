From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8747] New: MSG_ERRQUEUE messages do not pass
 to connected raw sockets
Date: Fri, 13 Jul 2007 10:34:29 -0700
Message-ID: <20070713103429.b1447d38.akpm@linux-foundation.org>
References: <bug-8747-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>, dmitry@butskoy.name
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36556 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757248AbXGMReh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 13:34:37 -0400
In-Reply-To: <bug-8747-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Jul 2007 09:56:20 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8747
> 
>            Summary: MSG_ERRQUEUE messages do not pass to connected raw
>                     sockets
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: dmitry@butskoy.name
> 
> 
> Problem Description:
> 
> It is related to the possibility to obtain MSG_ERRQUEUE messages from the udp
> and raw sockets, both connected and unconnected.
> 
> There is a little typo in net/ipv6/icmp.c code, which prevents such messages to
> be delivered to the errqueue of the correspond raw socket, when the socket is
> CONNECTED. The typo is due to swap of local/remote addresses.
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
> net/ipv6/icmp.c:icmpv6_notify() , daddr/saddr are obtained from the echoed
> fragment of the "bad" packet, i.e. "daddr" is the original destination address
> of that packet, "saddr" is our local address. Hence, for icmpv6_notify() must
> use "saddr, daddr" in its arguments, not "daddr, saddr" ...
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
> 

This bugzilla report includes a patch, which is below.

Dmitry, please don't send patches via bugzilla: we very much prefer that
they be emailed directly as per Documentation/SubmittingPatches, thanks.

--- net/ipv6/icmp.c	2007-02-04 21:44:54.000000000 +0300
+++ net/ipv6/icmp.c.OK	2007-07-13 20:57:37.000000000 +0400
@@ -600,7 +600,7 @@
 
 	read_lock(&raw_v6_lock);
 	if ((sk = sk_head(&raw_v6_htable[hash])) != NULL) {
-		while((sk = __raw_v6_lookup(sk, nexthdr, daddr, saddr,
+		while((sk = __raw_v6_lookup(sk, nexthdr, saddr, daddr,
 					    IP6CB(skb)->iif))) {
 			rawv6_err(sk, skb, NULL, type, code, inner_offset, info);
 			sk = sk_next(sk);

