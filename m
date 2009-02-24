From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12753] New: /proc/net/xt_recent/: +IP / -IP
 commands broken for IPv4
Date: Tue, 24 Feb 2009 12:58:30 -0800
Message-ID: <20090224125830.e89f28c5.akpm@linux-foundation.org>
References: <bug-12753-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, joe-lk@ttdpatch.net
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60622 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756612AbZBXU6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 15:58:42 -0500
In-Reply-To: <bug-12753-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 22 Feb 2009 15:11:56 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12753
> 
>            Summary: /proc/net/xt_recent/: +IP / -IP commands broken for IPv4
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.28.7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: joe-lk@ttdpatch.net
> 
> 
> Latest working kernel version: up to at least 2.6.24
> Earliest failing kernel version: first noticed with upgrade to 2.6.28

So it's a regression?

> Distribution: Debian lenny, Ubuntu 8.04
> Hardware Environment: x86
> 
> Problem Description: 
> An uninitialized buffer causes IPv4 addresses added manually (via the +IP
> command to the proc interface) to never match any packets. Similarly, the -IP
> command fails to remove IPv4 addresses.
> 
> Details:
> In the function recent_entry_lookup, the xt_recent module does comparisons of
> the entire nf_inet_addr union value, both for IPv4 and IPv6 addresses. For
> addresses initialized from actual packets the remaining 12 bytes not occupied
> by the IPv4 are zeroed so this works correctly. However when setting the
> nf_inet_addr addr variable in the recent_mt_proc_write function, only the IPv4
> bytes are initialized and the remaining 12 bytes contain garbage.
> 
> Hence addresses added in this way never match any packets, unless these
> uninitialized 12 bytes happened to be zero by coincidence. Similarly, addresses
> cannot consistently be removed using the proc interface due to mismatch of the
> garbage bytes (although it will sometimes work to remove an address that was
> added manually).
> 
> Reading the /proc/net/xt_recent/ entries hides this problem because this only
> uses the first 4 bytes when displaying IPv4 addresses.

OK.

> Steps to reproduce:
> $ iptables -I INPUT -m recent --rcheck -j LOG
> $ echo +169.254.156.239 > /proc/net/xt_recent/DEFAULT
> $ cat /proc/net/xt_recent/DEFAULT
> src=169.254.156.239 ttl: 0 last_seen: 119910 oldest_pkt: 1 119910
> 
> [At this point no packets from 169.254.156.239 are being logged.]
> 
> $ iptables -I INPUT -s 169.254.156.239 -m recent --set
> $ cat /proc/net/xt_recent/DEFAULT
> src=169.254.156.239 ttl: 0 last_seen: 119910 oldest_pkt: 1 119910
> src=169.254.156.239 ttl: 255 last_seen: 126184 oldest_pkt: 4 125434, 125684,
> 125934, 126184
> 
> [At this point, adding the address via an iptables rule, packets are being
> logged correctly.]
> 
> $ echo -169.254.156.239 > /proc/net/xt_recent/DEFAULT
> $ cat /proc/net/xt_recent/DEFAULT
> src=169.254.156.239 ttl: 0 last_seen: 119910 oldest_pkt: 1 119910
> src=169.254.156.239 ttl: 255 last_seen: 126992 oldest_pkt: 10 125434, 125684,
> 125934, 126184, 126434, 126684, 126934, 126991, 126991, 126992
> $ echo -169.254.156.239 > /proc/net/xt_recent/DEFAULT
> $ cat /proc/net/xt_recent/DEFAULT
> src=169.254.156.239 ttl: 0 last_seen: 119910 oldest_pkt: 1 119910
> src=169.254.156.239 ttl: 255 last_seen: 126992 oldest_pkt: 10 125434, 125684,
> 125934, 126184, 126434, 126684, 126934, 126991, 126991, 126992
> 
> [Removing the address via /proc interface failed evidently.]
> 
> 
> Possible solutions:
> - initialize the addr variable in recent_mt_proc_write
> - compare only 4 bytes for IPv4 addresses in recent_entry_lookup
> 
> Simplest fix:
> --- linux-2.6.28.7/net/netfilter/xt_recent.c.org        2009-02-22
> 17:34:19.000000000 +0100
> +++ linux-2.6.28.7/net/netfilter/xt_recent.c    2009-02-22 17:34:21.000000000
> +0100
> @@ -544,7 +544,7 @@
>         struct recent_entry *e;
>         char buf[sizeof("+b335:1d35:1e55:dead:c0de:1715:5afe:c0de")];
>         const char *c = buf;
> -       union nf_inet_addr addr;
> +       union nf_inet_addr addr = {};
>         u_int16_t family;
>         bool add, succ;
> 

hm, that function does some pretty ugly things.

I wonder if the same bug exists elsewhere (or might do so in the
future).  A more general fix would be to write a new
in6_to_nf_inet_addr() and in4_to_nf_inet_addr() which correctly
initialise the whole union.


