From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Mon, 6 Feb 2017 14:44:20 +0100
Message-ID: <20170206134420.7pwau56aiu3k54sy@nataraja>
References: <20170203091231.10142-1-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:58506 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752107AbdBFOEU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 09:04:20 -0500
Content-Disposition: inline
In-Reply-To: <20170203091231.10142-1-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jonas,

On Fri, Feb 03, 2017 at 10:12:31AM +0100, Jonas Bonn wrote:
> The GTP-tunnel driver is explicitly GGSN-side as it searches for PDP
> contexts based on the incoming packets _destination_ address.  If we
> want to write an SGSN, then we want to be idenityfing PDP contexts
> based on _source_ address.

A SGSN should never see the "native" User-IP payload.  It either has a
Gb interface towards the BSS which has a BSSGP/NS/UDP/IP protocol
stacking (for GERAN) or an IuUP or GTP stacking (for UTRAN).

The user-ip tunnel (PDP context) exists between the mobile station and
the GGSN.  Any intermediate nodes (BTS, BSC, NodeB, RNC, SGSN, ...) do
not appear as intermediate IP Layer nodes in that User IP tunnel, but
only serve to transparently pass the user-ip inside that tunnel between
the two tunnel end-points.

As such, I am very surprised by your patch.  Exposing the User IP to the
Linux network stack in the SGSN seems to be a severe layering violation
and contradict everything I know about 3GPP network architecture.  But
maybe I'm missing something here? Please explain.

The only SGSN-level user plane acceleration that I can think of is
quite different:

For an UMTS SGSN that only supports IuPS, and only supports IuPS over
IP (which is a sub-class of a sub-class of all use cases), what would
make sense is some Kernel-level support to map from one GTP
socket/tunnel to another GTP socket/tunnel based on the TEIDs.  So
basically you have a GTP tunnel on the RAN side and another GTP tunnel
on the CN side, without any decapsultaion.

The TEIDs on both sides *could* be identical, or *cold* be separate, as
a matter of implementation policy.  

The IP addresses /port numbers on both sides will in almost all
non-laboratory use cases be separate, as an operator typically doesn't
want a transparent/routed IP network between the RAN and Core Network (CN).

So the GTP tunnels between RNC/hNodeB/heNodeB on the RAN side get mapped
1:1 to GTP tunnels between SGSN and GGSN on the CN side.  However, as no
encapsulation/decapsulation is performed, this is outside of the scope
of the current kernel GTP tunneling module.  Rather, it's more something
similar to static NAT between two pairs of addresses.

Regards,
	Harald

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
