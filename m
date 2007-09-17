From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add ICMPMsgStats MIB (RFC 4293) [rev 2]
Date: Sun, 16 Sep 2007 17:04:47 -0700 (PDT)
Message-ID: <20070916.170447.107942117.davem@davemloft.net>
References: <OF04820EEE.89F4D267-ON88257356.0074B537-88257356.00759E10@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48011
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751171AbXIQAEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 20:04:48 -0400
In-Reply-To: <OF04820EEE.89F4D267-ON88257356.0074B537-88257356.00759E10@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Fri, 14 Sep 2007 15:25:32 -0600

> Background: RFC 4293 deprecates existing individual, named ICMP
> type counters to be replaced with the ICMPMsgStatsTable. This table
> includes entries for both IPv4 and IPv6, and requires counting of all
> ICMP types, whether or not the machine implements the type.
> 
> These patches "remove" (but not really) the existing counters, and
> replace them with the ICMPMsgStats tables for v4 and v6.
> It includes the named counters in the /proc places they were, but gets the
> values for them from the new tables. It also counts packets generated
> from raw socket output (e.g., OutEchoes, MLD queries, RA's from
> radvd, etc).
> 
> Changes:
> 1) create icmpmsg_statistics mib
> 2) create icmpv6msg_statistics mib
> 3) modify existing counters to use these
> 4) modify /proc/net/snmp to add "IcmpMsg" with all ICMP types
>         listed by number for easy SNMP parsing
> 5) modify /proc/net/snmp printing for "Icmp" to get the named data
>         from new counters.
> [new to 2nd revision]
> 6) support per-interface ICMP stats
> 7) use common macro for per-device stat macros
> 
> IPv6 patch attached.
> 
>                                         +-DLS
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

No objections, so patch applied to net-2.6.24

The following is not directed at this patch specifically, but rather
in general.

All of these crappy "idev == NULL" checks for nearly EVERY SINGLE ipv6
counter bump has gotten _WAY_ out of control.  By definition this
whole situation is broken if we need to test the thing basically
everywhere.

And it's the worst kind of disease because it's hidden inside all
kinds of macros so when you're reading the code you don't see this
nearly constant overhead spread all over the ipv6 stack in the most
critical paths we have.

How many remote OOPS'er DoS bugs have we had in ipv6 because of how
this stuff works?  I can remember at least 3, and that's 3 too many.

We need to fix this, and I don't care how, such that idev is never
NULL and at least points to some dummy ipv6 idev object.  And it
must be done in such a way that the cure is not worse than the
disease :-)
