From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: Fw: [Bug 55861] New: PMTU discovery no longer works in Linux
 3.6+ with routers that do not send next hop MTU information
Date: Thu, 28 Mar 2013 09:59:04 +0800
Message-ID: <5153A3E8.9000004@cn.fujitsu.com>
References: <20130327083127.0740d793@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:22654 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752930Ab3C1CLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 22:11:42 -0400
In-Reply-To: <20130327083127.0740d793@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems to be in icmp_unreach():

		case ICMP_FRAG_NEEDED:
			if (ipv4_config.no_pmtu_disc) {
				LIMIT_NETDEBUG(KERN_INFO pr_fmt("%pI4: fragmentation needed and DF set\n"),
					       &iph->daddr);
			} else {
				info = ntohs(icmph->un.frag.mtu);
				if (!info)
					goto out;

When MTU is zero, we skip the process in icmp_socket_deliver() which propagate
this error to transport protocols.

After some investigation it seems in transport protocols' err_handler which
finally called dst->update_pmtu(ip_rt_update_pmtu for IPv4) can deal with this
situation properly.

So I think we can simply kill the check of icmph->un.frag.mtu here.

On 03/27/2013 11:31 PM, Stephen Hemminger wrote:
> 
> 
> Begin forwarded message:
> 
> Date: Wed, 27 Mar 2013 08:25:40 -0700
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 55861] New: PMTU discovery no longer works in Linux 3.6+ with routers that do not send next hop MTU information
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=55861
> 
>            Summary: PMTU discovery no longer works in Linux 3.6+ with
>                     routers that do not send next hop MTU information
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.6 onwards
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: _@maxb.eu
>         Regression: Yes
> 
> 
> After upgrading recently, I found that path MTU discovery no longer worked
> correctly for accessing some devices on the other side of an IPsec tunnel.
> 
> Bisection revealed the problems started with 3.6 and are still present in
> 3.9-rc4 (latest available at time of reporting).
> 
> Some investigation into code changes leads me to the belief that Linux lost
> support for handling ICMP destination unreachable fragmentation needed packets
> for which the next hop MTU field is zero. This is an expected condition when
> dealing with older routers, as RFC792 originally defined ICMP destination
> unreachable fragmentation needed without a next hop MTU field, and it was later
> added in bytes previously allocated as unused.
> 
> The particular router in my case generating such packets is a machine running
> OpenBSD 4.6.
> 
> A commit that appears to be of particular interest in this bug is
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=46517008e1168dc926cf2c47d529efc07eca85c0
> 
