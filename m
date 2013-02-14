From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Fw: [Bug 53821] New: ip rules (policy routing) no longer applied
 consistency
Date: Thu, 14 Feb 2013 22:53:05 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1302142234480.1820@ja.ssi.bg>
References: <20130214082616.44ad070c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:40424 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758971Ab3BNUr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 15:47:59 -0500
In-Reply-To: <20130214082616.44ad070c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 14 Feb 2013, Stephen Hemminger wrote:

> Begin forwarded message:
> 
> Date: Thu, 14 Feb 2013 01:26:32 -0800
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 53821] New: ip rules (policy routing) no longer applied consistency
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=53821
> 
>            Summary: ip rules (policy routing) no longer applied
>                     consistency
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: korn-kernel.org@elan.rulez.org
>         Regression: Yes
> 
> 
> Hi,
> 
> on upgrading to 3.7.x, I noticed that some of my ip rules were no longer
> applied.
> 
> For example, I had:
> 
> # ip ru sh
> 0:      from all lookup local 
> 32762:  from 192.168.0.15 lookup foo
> 32763:  from 1.2.3.4 lookup foo
> 32764:  from 10.74.91.0/24 lookup foo
> 32765:  from 192.168.0.19 lookup vpntunnel 
> 32766:  from all lookup main 
> 32767:  from all lookup default 
> 
> # ip ro sh table vpntunnel
> default via 192.168.0.144 dev br0 
> 192.168.0.0/24 dev br0  scope link 
> 
> The 'lookup foo' rules were applied, but 'lookup vpntunnel' was not.
> 
> I then tried to use an fwmark based rule to achieve the same result:
> 
> # ip ru sh
> 0:      from all lookup local 
> 32761:  from all fwmark 0x2 lookup vpntunnel 
> 32762:  from 192.168.0.15 lookup foo
> 32763:  from 1.2.3.4 lookup foo
> 32764:  from 10.74.91.0/24 lookup foo
> 32765:  from 192.168.0.19 lookup vpntunnel 
> 32766:  from all lookup main 
> 32767:  from all lookup default 
> 
> Of course I made sure the appropriate packets were marked with 0x2. This worked
> a lot better and most packets go out via 192.168.0.144 now, but strangely, not
> all. I have a netfilter rule that catches the ones going the wrong way, and I
> get quite a few log messages along the lines of:
> 
> kernel: FW: DROP: IN= OUT=eth1 SRC=192.168.0.19 DST=2.3.4.5 LEN=131 TOS=0x00
> PREC=0x00 TTL=64 ID=0 DF PROTO=UDP SPT=17504 DPT=42834 LEN=111 UID=1007
> GID=1007 MARK=0x2 
> 
> As you can see, the packet is logged as having the correct fwmark, but is still
> sent out through eth1 instead of br0. (And the IP based rule should have
> applied to, but didn't.)
> 
> This particular result was obtained with 3.7.6-vs2.3.5.5 (linux-vserver patch),
> but I've seen similar behaviour with 3.7.anything.

	Not sure if it is related but in patch-3.7.7-vs2.3.5.6.diff
there is function ip_v4_find_src() that calls __ip_route_output_key
multiple times without resetting some input keys (oif, tos) with
flowi4_update_output(). ip_route_connect() is example for
such usage. This is needed in case we want to provide
original TOS and OIF for next lookups.

> Source IP based rules worked fine with kernels up to 3.6. Confusingly, _some_
> of them still work, but not all.
> 
> Maybe something was broken by the removal of the route cache?

	At first look I don't see other problems with
the route usage in this patch.

Regards

--
Julian Anastasov <ja@ssi.bg>
