From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net] vxlan: revert per-vxlan port
Date: Wed, 22 May 2013 22:14:39 -0400
Message-ID: <OF0BD0286F.81969B78-ON85257B74.00097DBA-85257B74.000C5443@us.ibm.com>
References: <20130520103017.054ae605@nehalam.linuxnetplumber.net> <OFECE722DE.3DBEE821-ON85257B71.00610478-85257B71.006456B5@us.ibm.com> <20130520113000.0057ce90@nehalam.linuxnetplumber.net> <20130522.150830.1305371698781503084.davem@davemloft.net> <OFB688A387.A3698315-ON85257B73.007C1B7B-85257B73.00800294@us.ibm.com> <20130522173954.7f75f62d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:55412 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756474Ab3EWCOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 22:14:46 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 22 May 2013 20:14:45 -0600
In-Reply-To: <20130522173954.7f75f62d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> wrote on 05/22/2013 
08:39:54 PM:

> The per-vxlan device stuff is the issue. I don't think it works
> as is in 3.10 because there is no real way to use it to receive.
> And don't want to let it out broken. By reverting that part, we avoid
> raising false expectations.
> 

Of course you can use it to receive; the remote hosts can be
listening on a different port and this is the only mechanism
to send to those if there are not fdb entries on the local machine.

So, for example, host A:
binds to 1234
has no fdb entries, but sets the default remote port to 4789

host B
binds to 4789
has no fdb entries and sets the default remote port to 1234

...or you have an agent listening on a multicast address with port 5429
and the agent's job is to dynamically populate the fdb tables of any
hosts that don't have matching entries. All the VXLAN instances bind
to, say 4789, and the agent binds to port 5429. The agent receives a
packet, and adds an entry to the fdb table on the sending host where
the destination is the actual VXLAN receiver with port 4789. But the
default port on all of them for this kind of set-up is correctly the
different 5429, not 4789.

These configurations have nothing to do with multiple listen ports,
and reverting the patch prohibits an admin from doing it at all.
In the first set up, you can link two segments on different ports
without knowing any destination MAC addresses. In the second, you
can separate traffic not matching any destination MAC from traffic
with a known destination, and use that to fill forwarding tables.

I know these configurations don't match your sense of how VXLAN
should be used, but these are not "broken", do receives perfectly fine,
and have no dependency at all on multiple listen ports. I don't know
what  "false expectations" you think are there-- I think anyone
changing the default destination port to a different value from
the binding port simply expects that transmits using the default
will go to one port and received packets will go to another. Deciding
in advance that that is never appropriate is short-sighted; that
decision belongs with the admin setting it up. Reverting the patch
removes that choice.


                                                        +-DLS
