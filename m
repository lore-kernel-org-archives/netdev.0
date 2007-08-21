From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8914] New: filter attached to prio qdisc
 breaks priomap handling of packets it does _not_ match
Date: Tue, 21 Aug 2007 11:29:42 -0700
Message-ID: <20070821112942.9a5c78ca.akpm@linux-foundation.org>
References: <bug-8914-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, lionel@mamane.lu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38969 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761392AbXHUSaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 14:30:04 -0400
In-Reply-To: <bug-8914-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Aug 2007 05:32:57 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8914
> 
>            Summary: filter attached to prio qdisc breaks priomap handling of
>                     packets it does _not_ match
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@osdl.org
>         ReportedBy: lionel@mamane.lu
> 
> 
> Most recent kernel where this bug did not occur: none known to me
> Distribution: Debian (sid / unstable / distro development bleeding edge)
> Hardware Environment: reproduced on i386 and x64-64 machines
> Software Environment: Debian, iproute 20070313-1
> Problem Description:
> 
> When I attach a filter to a prio qdisc, the packets that it does _not_
> match are not correctly handled (enqueued) according to the priomap
> anymore, that is the same way than when there is no filter attached to
> the qdisc. They seem to always fall in the map for best effort traffic.
> 
> Problem first noticed on Debian precompiled kernels (2.6.18-4-amd64, based on
> 2.6.18.7 and 2.6.22-1-686, based on 2.6.22.1), reproduced with self-compiled
> (with .config copied from Debian precompiled one) straight-from-kernel.org
> 2.6.22.4 .
> 
> Steps to reproduce:
> 
> Run attached script (as root), trying to ensure no other traffic happens over
> the interface: it installs qdiscs on interface ${TIF} (defaults to eth0), pings
> host ${PHOST} (defaults to master.debian.org - numerical IP hardcoded) with
> various IP TOS bits set, installs a filter that matches TCP (_not_ ICMP) and
> does the pings again. You have to ensure that pings to ${PHOST} leaver over
> ${TIF}. You may have to "modprobe em_cmp" before running the script.
> 
> Notice how the first pings (before filters get installed) get in the
> right queue according to their TOS bits, but after the filter gets
> installed, they all end up in the "best effort" queue.
> 
> 
> The output I get (non-relevant bits snipped out) is:
> 
>  Running test on interface eth0
>  by pinging host 70.103.162.29
> 
>  Pinging with normal service 1 times
>  Pinging with minimise delay 2 times
>  Pinging with minimise cost 4 times
>  qdisc pfifo 22: parent 20:2 limit 1000p
>   Sent 196 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 23: parent 20:3 limit 1000p
>   Sent 98 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 24: parent 20:4 limit 1000p
>   Sent 392 bytes 4 pkt (dropped 0, overlimits 0 requeues 0)
> 
>  Adding a filter that does _not_ match ICMP
> 
>  Pinging with normal service 8 times
>  qdisc pfifo 22: parent 20:2 limit 1000p
>   Sent 196 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 23: parent 20:3 limit 1000p
>   Sent 924 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 24: parent 20:4 limit 1000p
>   Sent 392 bytes 4 pkt (dropped 0, overlimits 0 requeues 0)
> 
>  Pinging with minimise delay 16 times
>  qdisc pfifo 22: parent 20:2 limit 1000p
>   Sent 196 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 23: parent 20:3 limit 1000p
>   Sent 2492 bytes 26 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 24: parent 20:4 limit 1000p
>   Sent 392 bytes 4 pkt (dropped 0, overlimits 0 requeues 0)
> 
>  Pinging with minimise cost 32 times
>  qdisc pfifo 22: parent 20:2 limit 1000p
>   Sent 196 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 23: parent 20:3 limit 1000p
>   Sent 5628 bytes 58 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 24: parent 20:4 limit 1000p
>   Sent 392 bytes 4 pkt (dropped 0, overlimits 0 requeues 0)
> 
> 
> The output I would expect is:
> 
>  (... snip ...)
> 
>  Adding a filter that does _not_ match ICMP
> 
>  Pinging with normal service 8 times
>  qdisc pfifo 22: parent 20:2 limit 1000p
>   Sent XXX bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 23: parent 20:3 limit 1000p
>   Sent XXX bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 24: parent 20:4 limit 1000p
>   Sent XXX bytes 4 pkt (dropped 0, overlimits 0 requeues 0)
> 
>  Pinging with minimise delay 16 times
>  qdisc pfifo 22: parent 20:2 limit 1000p
>   Sent XXX bytes 18 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 23: parent 20:3 limit 1000p
>   Sent XXX bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 24: parent 20:4 limit 1000p
>   Sent XXX bytes 4 pkt (dropped 0, overlimits 0 requeues 0)
> 
>  Pinging with minimise cost 32 times
>  qdisc pfifo 22: parent 20:2 limit 1000p
>   Sent XXX bytes 18 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 23: parent 20:3 limit 1000p
>   Sent XXX bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
>  qdisc pfifo 24: parent 20:4 limit 1000p
>   Sent XXX bytes 36 pkt (dropped 0, overlimits 0 requeues 0)
