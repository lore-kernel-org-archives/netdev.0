From: "Kevin W. Rudd" <ruddk@us.ibm.com>
Subject: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 10:23:15 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312101020480.21684-100000@w-kevinr.svc.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Here is a recent posting to linux-kernel related to PMTU issues when
routers use DSCP marking.

> Subject Yet another UDP pmtud iss, it's different, really
> Date Sun, 16 Nov 2003 22:25:08 -0800
> From "Johnson, Chester F" <chester.f.johnson@intel.com>
> 
> This is not the same as the pmtud issues discussed ad-nauseum from 1999
> through 2001. It really is different. Trust me, please read on.
> 
> Well, it is similar, but with a twist. We are in the middle of deploying
> DiffServ compliant QoS throughout our networks and stumbled across an
> issue that occurs when we configure our routers to mark the DiffServ
> Code Points (DSCP) for UDP traffic (AFS, NFS, other full frame size UDP
> traffic).
> 
> The problem is that when the marked traffic reaches an IPsec/Ethernet
> segment, and the DF bit set to true, an ICMP message is returned to the
> transmitting host to say basically "fix your MTU". Since we have changed
> the ToS field with DSCP information, the ICMP message no longer matches
> anything in the route cache hash. If the ToS field is not "0", it must
> match src, dst, and ToS in the cache. Well, we changed one of them and
> there can be no such match.
> 
> The net result is that the transmitting host sends another 1500 byte
> packet and the process repeats itself. Ultimately the data transfer
> fails. When we stop DSCP marking, MTU negotiation works just fine, but
> we have no QoS.
> 
> This kind of match might be great if we use a Linux platform as a
> router. It may indeed be useful for higher performance DiffServ routing.
> This kind of match requirement for an end-host is problematic. In our
> estimation it looks like a bug.
> 
> Can anyone out there help sort this out?
> 
> Chester Johnson
> Network Transport Engineering
> Intel Corporation
> 

At least in the case of a "Destination unreachable/Fragmentation
needed" ICMP message, there is an assumption that the TOS value
returned will not have changed.  The ip_rt_frag_needed() routine
will fail to find a cached route with a matching TOS (since it has
been changed by the DSCP marking) and so the MTU will not be properly
updated.  Given that the DS field definition supersedes the previous
TOS definitions, this does indeed present a problem for route modifying
ICMP messages in a network environment that is using DSCP marking.

This particular user would like the ability to turn off the caching of
the TOS value within the routing tables.  On the surface, it looks like
simply manipulating the IPTOS_RT_MASK would accomplish what they are
looking for with minimal code changes.  This can currently be done with
something equivalent in include/net/route.h:

#ifndef CONFIG_IP_ROUTE_TOS
#define IPTOS_RT_MASK   0
#endif

and then rebuilding the kernel with the CONFIG_IP_ROUTE_TOS unset.  If
the approach of zeroing out the TOS routing mask seems reasonable, a
more dynamic approach would be desired (a sysctl variable that can be
modified without having to build a custom kernel).

Long term, does it really make sense to continue trying to make routing
decisions based on TOS when this field is obsolete?

Thoughts?  Comments?

Thanks,
       -Kevin

--
 Kevin W. Rudd
 Linux Change Team
 IBM Global Services
 1-800-426-7378,  T/L 775-4161
